moment = require 'moment'
tmpDir = "prezentor-2.0-#{moment().format('DD-MM-YYYY-HH:mm:ss')}"
plan = require 'flightplan'
fs = require 'fs'

try
  localConfig = require './local.conf'
catch error
  localConfig = off


REMOTE_DST_DIR = '/data/www/vhosts/p2.0'
plan.target 'production',
  debug: no
  host: '54.195.248.116'
  username: 'prezentor'
  privateKey: localConfig.productionSSHPrivatKey
  port: 2257
# Configuration
plan.target 'staging',
  debug: no
  host: 'p2.prezentor.dk'
  username: 'prezentor'
  privateKey: localConfig.stagingSSHPrivatKey or '/var/lib/jenkins/.ssh/p2.0solshark'

# First let's build code, prepare for production and transfer to remote
plan.local (local) ->
  if plan.runtime.target is 'staging'
    local.log 'Run build'
    local.exec 'gulp build'

    local.log 'Copy files to remote host'

    filesToCopy = local.find './.tmp/*', silent: yes
      .stdout.split '\n'
    local.transfer filesToCopy, "/tmp/#{tmpDir}"
  if plan.runtime.target is 'production'
    _phrase = local.prompt 'Type confirmation phrase:'
    if _phrase is 'I want to update production server'
      # Check if we have fodler with production branch first
      PRODUCTION_BRANCH_FOLDER = './.production'
      PRODUCTION_BRANCH_GIT_FOLDER = "#{PRODUCTION_BRANCH_FOLDER}/.git"
      unless fs.existsSync PRODUCTION_BRANCH_FOLDER
        fs.mkdirSync PRODUCTION_BRANCH_FOLDER
      unless fs.existsSync PRODUCTION_BRANCH_GIT_FOLDER
        local.log 'Checkout production branch'
        local.exec 'git clone -b production git@gitlab.wmt.dk:prezentor2/prezentor-2.git ' + PRODUCTION_BRANCH_FOLDER
      local.log 'Update production branch'
      local.exec "cd #{PRODUCTION_BRANCH_FOLDER} && git checkout production && git pull"
      local.log 'Build project'
      local.exec "cd #{PRODUCTION_BRANCH_FOLDER} && gulp build"
      local.log 'Copy files to remote host'
      filesToCopy = local.find PRODUCTION_BRANCH_FOLDER + '/.tmp/*', silent: yes
        .stdout.split '\n'
      tmpDir = local.exec("cd #{PRODUCTION_BRANCH_FOLDER} && git rev-parse HEAD", silent: yes).stdout
      tmpDir = tmpDir.replace /(\r\n|\n|\r)/gm, ''
      local.transfer filesToCopy, "/tmp/#{tmpDir}"

    else
      console.log "ERROR! Please confirm with correct passphrase!"
      process.exit 1

# Run commands on remote host
plan.remote (remote) ->
  if plan.runtime.target is 'staging'
    remote.log 'Move folder to web root'
    remote.exec "mkdir #{REMOTE_DST_DIR}/#{tmpDir}"
    remote.exec "cp -R /tmp/#{tmpDir}/.tmp/* #{REMOTE_DST_DIR}/#{tmpDir}"
    remote.log "Update permissions"
    remote.exec "find #{REMOTE_DST_DIR}/#{tmpDir}/public -type d | xargs chmod 755"
    remote.exec "find #{REMOTE_DST_DIR}/#{tmpDir}/public -type f | xargs chmod 644"
    remote.rm "-rf /tmp/#{tmpDir}"
    remote.log 'Install dependencies'
    remote.exec "npm --production --prefix ~/#{tmpDir} install ~/#{tmpDir}"
    remote.log 'Reload application'
    remote.exec "ln -snf ~/#{tmpDir} ~/prezentor"
    remote.exec 'pm2 restart all'
  if plan.runtime.target is 'production'
    remote.log 'Move folder to web root'
    remote.exec "mkdir #{REMOTE_DST_DIR}/#{tmpDir}"
    remote.exec "cp -R /tmp/#{tmpDir}/.production/.tmp/* #{REMOTE_DST_DIR}/#{tmpDir}"
    remote.log "Update permissions"
    remote.exec "find #{REMOTE_DST_DIR}/#{tmpDir}/public -type d | xargs chmod 755"
    remote.exec "find #{REMOTE_DST_DIR}/#{tmpDir}/public -type f | xargs chmod 644"
    remote.rm "-rf /tmp/#{tmpDir}"
    remote.log 'Install dependencies'
    remote.exec "npm --production --prefix ~/#{tmpDir} install ~/#{tmpDir}"
    remote.exec "ln -snf ~/#{tmpDir} ~/prezentor"
    remote.log 'Update uploaded, remember to restar app/workers manyally!'
    # remote.log 'Reload application
    # remote.exec 'pm2 reload all'
# Separate task to update remote's database
plan.local 'updatedb', (local) ->
  if plan.runtime.target is 'staging'
    # TODO: allow this task only on staging flight
    local.log "Create local database dump"
    local.rm '-rf ./.dump/*'
    local.exec "mongodump -d prezentor-2-dev -o ./.dump"
    filesToCopy = local.find './.dump/*', silent: yes
      .stdout.split '\n'
    local.transfer filesToCopy, "/tmp/dbdump"
  else
    console.log "updatedb allowed only on staging server"
plan.remote 'updatedb', (remote) ->
  if plan.runtime.target is 'staging'
    remote.log "Remove database on staging server"
    remote.exec 'mongo prezentor-2-production --eval "db.dropDatabase()"'
    remote.log "Load data from dump"
    remote.exec "mongorestore -d prezentor-2-production /tmp/dbdump/.dump/prezentor-2-dev"
    remote.log "Cleaning up"
    remote.rm "-fr /tmp/dbdump"
  else
    console.log "updatedb allowed only on staging server"
