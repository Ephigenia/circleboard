fs = require 'fs'
http = require 'http'
express = require 'express'
socketIo = require 'socket.io'
app = express()
server = http.createServer app
io = socketIo.listen server

CircleCiApi = require './libraries/circleCiApi.coffee'

if fs.existsSync './config.coffee'
  CONFIG = require './config.coffee'
else
  CONFIG = require './config.dist.coffee'

# Configuration Check
unless !!CONFIG.apiKey
  console.info "trying to get circle ci status api key from environment variable CIRCLE_CI_API_KEY."
  CONFIG.apiKey = process.env.CIRCLE_CI_API_KEY
unless !!CONFIG.apiKey
  console.error """
  missing circle ci api key, try to set in config.coffee or in CIRCLE_CI_API_KEY enviroment variable
  """
  process.exit(1)
unless !!CONFIG.projects or CONFIG.projects.length == 0
  console.error """
  missing projects configuration array.
  """
  process.exit(2)

# express server configuration
server.listen process.env.PORT || 5000
app.use(express.static("./www/"))
app.get '/', (request, response) ->
  response.sendfile "./www/index.html"

processProject = (socket, config) ->
  circleCiApi.getBuilds config.path, null, (builds) ->
    console.info """
    received #{builds.length} builds in #{config.name}
    """
    socket.emit "build", { name: config.name, build: builds[0] }

# socket.io
circleCiApi = new CircleCiApi CONFIG.apiKey
io.sockets.on 'connection', (socket) ->  
  updateAllProjects = () ->
    console.info "Updating #{CONFIG.projects.length} projects …"
    for config in CONFIG.projects
      processProject socket, config
  # create interval to update all projects
  setInterval updateAllProjects, CONFIG.interval * 1000
  # initially trigger update of projects as previously created interval is
  # triggerd later
  updateAllProjects()