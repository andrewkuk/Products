# Development specific configuration
# ==================================
module.exports =
  # MongoDB connection options
  secrets:
    session: 'm2##$eoki&*6pVBl5U8*dsafasdfsa32f#{4}DA0NUN9RiHvbPclpb1'
  mongo:
    uri: 'mongodb://localhost/prezentor-2-dev'
  seedDB: yes
  port: 3000
  redisQueueDB: 1
  siteURL: 'http://127.0.0.1:3000'
