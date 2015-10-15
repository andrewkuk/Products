# es = require 'event-stream'
nib = require 'nib'
rev = require 'gulp-rev'
gulp = require 'gulp'
jade = require 'gulp-jade'
# sort = require 'sort-stream'
gutil = require 'gulp-util'
bower = require 'gulp-bower'
shell = require 'gulp-shell'
mocha = require 'gulp-spawn-mocha'
karma = require('karma').server
stylus = require 'gulp-stylus'
coffee = require 'gulp-coffee'
cache = require 'gulp-cached'
inject = require 'gulp-inject'
rimraf = require 'rimraf'
# gulprimraf = require 'gulp-rimraf'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
notify = require 'gulp-notify'
sourcemaps = require 'gulp-sourcemaps'
nodemon = require 'gulp-nodemon'
coffeelint = require 'gulp-coffeelint'
livereload = require 'gulp-livereload'
bowerFiles = require 'main-bower-files'
protractor = require('gulp-protractor').protractor
ngAnnotate = require 'gulp-ng-annotate'
runSequence = require 'run-sequence'
angularFilesort = require 'gulp-angular-filesort'



# Define path's used over the gulpfile
SRC =
  watchForLiveReload: [
    'server/**/*.coffee'
  ]
  nodemonIgnore: [
    'gulpfile.coffee'
    'client/**/*'
    'build/**/*'
    'e2e/**/*'
    'functional/**/*'
    '*.conf.coffee'
    'flightplan.coffee'
    'node_modules/**'
  ]
  applicationAssets: [
    'client/**/assets/**/*'
    '!client/**/*.coffee'
    '!client/**/*.js'
    '!client/**/*.styl'
    '!client/bower_components/**/docs/**/*'
  ]
  coffeeToLint: [
    'server/**/*.coffee'
    'client/**/*.coffee'
    'e2e/**/*.coffee'
    'functional/**/*.coffee'
    '!client/bower_components/**/*'

  ]
  clientTemplatesToCompile: [
    'client/**/*.jade'
    '!client/bower_components/**/*'
  ]
  clientCoffeeToCompile: [
    'client/**/*.coffee'
    '!client/bower_components/**/*'
    '!client/**/*.spec.coffee'
  ]
  clientStylusToCompile: [
    'client/**/*.styl'
    '!client/bower_components/**/*'
  ]
  clientsAssetsSRC: [
    'client/assets/**/*'
  ]
  clientsAssetsDST: 'build/assets'
  clientBowerComponents: 'client/bower_components'
  clientApplicationDst: 'build'
  clientApplicationDstBower: 'build/bower'
  clientApplicationEntryHTML: 'build/index.html'
  clientAppAssetsToInject: [
    'build/assets/**/*.css'
    'build/assets/**/*.js'
    '!build/assets/**/*.spec.js'
  ]
  clientAppBowerFilesToInject: [
    'build/bower/**/*'
  ]
  clientAppJSFilesToInject: [
    'build/**/*.js'
    '!build/bower/**/*'
    '!build/assets/**/*'
  ]
  clientAppCSSFilesToInject: [
    'build/**/*.css'
    '!build/bower/**/*'
    '!build/assets/**/*'
  ]
  clientApplicationCompiledSRC: [
    'build/**/*.css'
    'build/**/*.html'
    'build/**/*.js'
    '!build/bower/**/*'
    '!build/assets/**/*'
  ]
# Copy application assets to build folder
gulp.task 'copyApplicationAssets', ->
  gulp.src SRC.applicationAssets
    .pipe gulp.dest 'build'

gulp.task 'injectKarmaConf', ->
  _bowerFiles = gulp.src bowerFiles(includeDev: yes), read: no
  gulp.src("./karma.conf.js")
  .pipe(inject _bowerFiles,
    starttag: '// {{name}}:{{ext}}'
    endtag: '// endinject-bower'
    name: 'inject-bower'
    relative: no
    transform: (filepath, file, i, length) ->
      "'." + filepath + "',"
  )
  .pipe(inject(gulp.src([
    './client/**/*.coffee'
    '!./client/**/*.spec.coffee'
    '!./client/bower_components/**/*.coffee'
  ],
    read: false
  ),
    starttag: '// inject-app'
    endtag: '// endinject-app'
    transform: (filepath, file, i, length) ->
      "'." + filepath + "'" + ((if i + 1 < length then "," else ""))
  )).pipe gulp.dest './'

# .pipe inject _bowerFiles, relative: no, name: 'bower', ignorePath: '/client/bower_components/', addPrefix: 'bower'
# Watch for client code changes and reload client if needed
gulp.task 'watchClient', ->
  livereload.listen()
  # # First let's monitor client's coffee
  w1 = gulp.watch SRC.clientCoffeeToCompile, ['clientCoffee']
  # # and client's stylus
  w2 = gulp.watch SRC.clientStylusToCompile, ['stylus']
  # # and client's jade ofc
  w3 = gulp.watch SRC.clientTemplatesToCompile, ['injectIndex']
  w4 = gulp.watch SRC.applicationAssets, ['copyApplicationAssets']
  # # and if compiled files updated - let's livereload
  # w4 = gulp.watch SRC.clientApplicationCompiledSRC
  # w4.on 'change', ->
  #   gutil.log gutil.colors.green 'Requesting livereload'
  #   livereload.changed

# Install bower dependencies
gulp.task 'bower', ->
  bower()

# Clean build folder
gulp.task 'remove-build-folder', (done) ->
  rimraf './build', done

# Bootstrap project
gulp.task 'bootstrap', (done) ->
  runSequence(
    ['build-clean', 'remove-build-folder']
    'bowerCopy'
    'copyAssets'
    'clientCoffeeNoLR'
    'coffeeLint'
    'stylusNoLR'
    'copyApplicationAssets'
    'injectIndexNoLR'
    done
  )

# Copy bower files to build folder
gulp.task 'bowerCopy', ['bower'], ->
  gulp.src bowerFiles(), base: SRC.clientBowerComponents
    .pipe gulp.dest SRC.clientApplicationDstBower

# Compile stylus files and start LiveReload
gulp.task 'stylus', ->
  gulp.src SRC.clientStylusToCompile
    .pipe cache 'stylus'
    .pipe handle stylus use: nib()
      .on 'error', notify.onError (error) -> error.message
    .pipe gulp.dest SRC.clientApplicationDst
    .pipe livereload()

# Compile stylus files and start LiveReload
gulp.task 'stylusNoLR', ->
  gulp.src SRC.clientStylusToCompile
    .pipe cache 'stylus'
    .pipe handle stylus use: nib()
    .pipe gulp.dest SRC.clientApplicationDst
    # .pipe livereload()


# Compile jade files for client application
gulp.task 'clientJade', ->
  gulp.src SRC.clientTemplatesToCompile
    .pipe cache 'clientJade'
    .pipe handle jade
      pretty: yes
      locals:
        developmentEnv: yes
        __v: Date.now()
    .on 'error', notify.onError (error) -> error.message
    # .pipe(notify())
    .pipe gulp.dest SRC.clientApplicationDst


# Inject js/css into client app and reload application
gulp.task 'injectIndex', ['clientJade'], ->
  target = gulp.src SRC.clientApplicationEntryHTML
  _bowerFiles = gulp.src bowerFiles(), read: no
  # _bowerFiles = gulp.src SRC.clientAppBowerFilesToInject, read: no
  assetsFiles = gulp.src SRC.clientAppAssetsToInject, read: no
  sourcesJS = gulp.src SRC.clientAppJSFilesToInject
    .pipe angularFilesort()
  sourcesCSS = gulp.src SRC.clientAppCSSFilesToInject, read: no
  target
    # .pipe inject _bowerFiles, relative: no, name: 'bower'
    .pipe inject _bowerFiles, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: no, name: 'bower', ignorePath: '/client/bower_components/', addPrefix: 'bower'
    .pipe inject assetsFiles, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: yes, name: 'assets'
    .pipe inject sourcesJS, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: yes
    .pipe inject sourcesCSS, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: yes
    .pipe gulp.dest SRC.clientApplicationDst
    .pipe livereload()

# Inject js/css into client app without LR

gulp.task 'injectIndexNoLR', ['clientJade'], ->
  target = gulp.src SRC.clientApplicationEntryHTML
  _bowerFiles = gulp.src bowerFiles(), read: no
  assetsFiles = gulp.src SRC.clientAppAssetsToInject, read: no
  sourcesJS = gulp.src SRC.clientAppJSFilesToInject
    .pipe angularFilesort()
  sourcesCSS = gulp.src SRC.clientAppCSSFilesToInject, read: no
  target
    .pipe inject _bowerFiles, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: no, name: 'bower', ignorePath: '/client/bower_components/', addPrefix: 'bower'
    .pipe inject assetsFiles, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: yes, name: 'assets'
    .pipe inject sourcesJS, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: yes
    .pipe inject sourcesCSS, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: yes
    .pipe gulp.dest SRC.clientApplicationDst
    # .pipe livereload()




# Compile coffee file for client application and start Livereload
gulp.task 'clientCoffee', ->
  gulp.src SRC.clientCoffeeToCompile
    .pipe cache 'clientCoffee'
    .pipe sourcemaps.init()
    .pipe handle coffee()
      # .on 'error', gutil.log
      .on 'error', notify.onError (error) -> error.message
    .pipe sourcemaps.write()
    .pipe gulp.dest SRC.clientApplicationDst
   .pipe livereload()

# Compile coffee file for client application without Livereload
gulp.task 'clientCoffeeNoLR', ->
  gulp.src SRC.clientCoffeeToCompile
    .pipe cache 'clientCoffee'
    .pipe sourcemaps.init()
    .pipe coffee()
      .on 'error', gutil.log
    .pipe sourcemaps.write()
    .pipe gulp.dest SRC.clientApplicationDst
    # .pipe livereload()

# Lint coffeescript files
gulp.task 'coffeeLint', ->
  gulp.src SRC.coffeeToLint
    .pipe coffeelint
      optFile: './coffeelint.json'

    .pipe coffeelint.reporter()
    .pipe coffeelint.reporter('fail')
      .on 'error', notify.onError (error) -> error.message

# Copy statis assets
gulp.task 'copyAssets', ->
  gulp.src SRC.clientsAssetsSRC, base: 'client/assets'
    .pipe gulp.dest SRC.clientsAssetsDST

# Run unit tests in browser(s) with karma (client)
gulp.task 'test-k', ['coffeeLint','injectKarmaConf'], (done) ->
  karma.start
    configFile: "#{__dirname}/karma.conf.js"
    singleRun: yes
  , done

# Run unit tests in mocha (server)
gulp.task 'test-f', ['coffeeLint'], shell.task ['./functional-tests.sh spec']

# Run unit tests in mocha (server)
gulp.task 'migrate', shell.task ['coffee ./server/migrations/*.migration.coffee']


# Run unit tests in mocha (server)
gulp.task 'test-m', ['coffeeLint'], ->
  gulp.src [
    './server/*.spec.coffee'
    './server/**/**/*.spec.coffee'
  ], read: no
    .pipe mocha
       ui: 'bdd'
       reporter: 'spec'
       env:
         NODE_ENV: 'test'
         DISABLE_KUE_UI: 1
       compilers: 'coffee:coffee-script/register'

# Run e2e tests with proctractor (client)
gulp.task 'test-e', ->
  gulp.src 'e2e/**/*.spec.coffee'
    .pipe protractor
      configFile: "#{__dirname}/protractor.conf.coffee"
    .on 'error', (e) -> throw e



# Run all the tests once except E2E, E2E should be deployed first
gulp.task 'test', ['test-m', 'test-k']

# Clean folder with compiled files
gulp.task 'build-clean', (done) ->
  rimraf './.tmp', done

# Clean bower folder
gulp.task 'bower-clean', (done) ->
  rimraf './client/bower_components', done


# Build/prepare server scripts for deployment
gulp.task 'build-server-scripts', (done) ->
  serverCodeToDeploy = [
    'server/**/*'
    'server/**/*.js'
    '!server/**/*.spec.coffee'
    'package.json'
  ]
  gulp.src serverCodeToDeploy
    .pipe gulp.dest './.tmp'

# Build client html for deployment
gulp.task 'build-html', ->
  # Compile jade files for client application
  _bowerFiles = gulp.src bowerFiles(), read: no
  gulp.src SRC.clientTemplatesToCompile
    .pipe jade
      pretty: no
      locals:
        developmentEnv: no
        __v: Date.now()
    # .pipe inject(
    #   gulp.src './.tmp/public/bower/**/*', read: no
    #   relative: no
    #   ignorePath: '.tmp/public'
    #   name: 'bower'
    # )
    .pipe inject _bowerFiles, starttag: '<!-- {{name}}:{{ext}}-->', endtag: '<!-- endinject-->', relative: no, name: 'bower', ignorePath: '/client/bower_components/', addPrefix: 'bower'
    .pipe inject(
      gulp.src './.tmp/public/assets/**/*', read: no
      starttag: '<!-- {{name}}:{{ext}}-->'
      endtag: '<!-- endinject-->'
      relative: no
      ignorePath: '.tmp/public'
      name: 'assets'
    )
    .pipe inject(
      gulp.src [
        './.tmp/public/*.js'
        './.tmp/public/*.css'
      ], read: no
      starttag: '<!-- {{name}}:{{ext}}-->'
      endtag: '<!-- endinject-->'
      relative: no
      ignorePath: '.tmp/public'
    )

    .pipe gulp.dest './.tmp/public/'

# Bundle client bower assets. Actually, copy.
# It might be very tricky to solve path issues.
gulp.task 'build-client-bower-assets', ->
  gulp.src [
    'build/bower/**/*'
    # 'build/assets/**/*'
  ]
    # .pipe concat 'vendor.css'
    # .pipe minifyCSS()
    # .pipe uglify mangle: no
    .pipe gulp.dest './.tmp/public/bower'

# Bundle application module/component specific assets
gulp.task 'build-custom-assets', ->
  gulp.src [
    # 'build/**/assets/**/*'
    'client/**/assets/**/*'
    '!client/**/*.coffee'
    '!client/**/*.js'
    '!client/**/*.styl'
  ]
    .pipe gulp.dest './.tmp/public'


# Bundle client generic assets. Actually, copy.
# It might be very tricky to solve path issues.
gulp.task 'build-client-assets', ->
  gulp.src [
    # 'build/bower/**/*'
    'build/assets/**/*'
  ]
    # .pipe concat 'vendor.css'
    # .pipe minifyCSS()
    # .pipe uglify mangle: no
    .pipe gulp.dest './.tmp/public/assets'

# Bundle client styles
gulp.task 'build-client-styles', ->
  gulp.src 'client/**/*.styl'
    .pipe stylus
      use: nib()
      compress: yes
    .pipe concat 'style.css'
    .pipe rev()
    .pipe gulp.dest './.tmp/public'

# Bundle client app (coffee)
gulp.task 'build-client-coffee', ->
  gulp.src [
    'client/**/*.coffee'
    '!client/**/*.spec.coffee'
    '!client/bower_components/**/*'
  ]
    .pipe coffee()
    .pipe concat 'app.js'
    .pipe ngAnnotate()
    .pipe rev()
    # .pipe uglify
    #   remove: yes
    #   add: yes
    .pipe gulp.dest './.tmp/public'


# # Clear dist folder before pushing to remote server
# gulp.task 'build-post-cleanup', ->
#   gulp.src [
#     './.tmp/public/vendor.js'
#     './.tmp/public/app.js'
#   ], read: no
#     .pipe gulprimraf()

# Build project for deployment
gulp.task 'build', (done) ->
  runSequence(
    'build-clean'
    'bower-clean'
    'bowerCopy'
    'copyAssets'
    [
      'build-server-scripts'
      'build-client-bower-assets'
      'build-client-assets'
      'build-client-styles'
      'build-client-coffee'
      'build-custom-assets'
    ]
    # 'build-post-cleanup'
    'build-html'
    done
  )

# Start main development server
gulp.task 'develop', [
    'bootstrap'
    # 'bowerCopy'
    # 'coffeeLint'
    # 'clientCoffee'
    # 'copyAssets'
    # 'stylus'
    # 'copyApplicationAssets'
    # 'injectIndex'
    'watchClient'
  ], ->
    nodemon
      script: 'server/start.js'
      ext: 'coffee, jade, styl'
      ignore: SRC.nodemonIgnore
      env:
        NODE_ENV: 'development'
      # nodeArgs: ['--debug=9999']
    # .on 'change', ['coffeeLint', 'clientCoffee', 'injectIndex']
    .on 'change', ['coffeeLint']
    .on 'restart', ->
      gutil.log gutil.colors.cyan 'Node restarted'
      # livereload()

      # setTimeout (->
      #   gutil.log gutil.colors.green 'Requesting livereload'
      #   livereload.changed()
      # ), 1000
    .on 'error', ->
      gutil.log

# Start development server, quick mode, watching server only
gulp.task 'sdev', [], ->
  nodemon
    script: 'server/start.js'
    ext: 'coffee, jade, styl'
    ignore: SRC.nodemonIgnore
    env:
      NODE_ENV: 'development'
    # nodeArgs: ['--debug=9999']
  # .on 'change', ['coffeeLint', 'clientCoffee', 'injectIndex']
  .on 'change', ['coffeeLint']
  .on 'restart', ->
    gutil.log gutil.colors.cyan 'Node restarted'
    # livereload()

    # setTimeout (->
    #   gutil.log gutil.colors.green 'Requesting livereload'
    #   livereload.changed()
    # ), 1000
  .on 'error', ->
    gutil.log


handle = (stream)->
   stream.on 'error', ->
      # gutil.log.apply this, arguments
      stream.end()
