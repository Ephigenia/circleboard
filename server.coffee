fs = require('fs')
https = require('https')
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

if fs.existsSync './config.coffee'
  CONFIG = require './config.coffee'
else
  CONFIG = require './config.dist.coffee'

# check if apiKey is empty and try to get it from env variables
unless CONFIG.apiKey?
  console.log 'trying to get circle ci status api key from environment variable CIRCLE_CI_API_KEY'
  CONFIG.apiKey = process.env.CIRCLE_CI_API_KEY
unless !!CONFIG.apiKey
  console.error """
  missing circle ci api key, try to set in config.coffee or in CIRCLE_CI_API_KEY enviroment variable
  """
  process.exit(1)

unless webroot
  webroot = __dirname + '/www/'



server.listen(process.env.PORT || 5000)
app.use(express.static(webroot))
app.get '/', (request, response) ->
  response.sendfile(webroot + "index.html")
io.sockets.on 'connection', (socket) ->
  # iterate over configured projects and get builds for each and send
  # the last build to the frontend, repeat the whole thing every interval 
  # seconds
  updateAllProjects = () ->
    console.log 'Updating all Projects'
    for config in CONFIG.projects
      processCircleCiProject socket, config
  setInterval updateAllProjects, CONFIG.interval * 1000
  updateAllProjects()


processCircleCiProject = (socket, config) ->
  success = (response) =>
    lastBuild = parseResponseToBuildArray config.name, response
    socket.emit 'build', lastBuild
  getCircleCiStatusApi config.path, CONFIG.apiKey, success

parseResponseToBuildArray = (name, body) ->
  builds = JSON.parse(body)
  lastBuild = builds[0]
  uuid = name + lastBuild.branch
  return {
    uuid: uuid
    number: lastBuild.build_num
    outcome: lastBuild.outcome
    status: lastBuild.status
    url: lastBuild.build_url
    project: name
    started: lastBuild.start_time
    finished: lastBuild.stop_time
    duration: lastBuild.build_time_millis
    commit:
      subject: lastBuild.subject
      hash: lastBuild.vcs_revision
      author:
        name: lastBuild.committer_name
        email: lastBuild.committer_email
    branch:
      name: lastBuild.branch
  }

getCircleCiStatusApi = (path, apiKey, success) ->
  # build http request for retreiving informations about the circleci project
  options = 
    host: 'circleci.com'
    method: 'GET'
    path: "/api/v1/project/#{path}?circle-token=#{apiKey}"
    headers:
      "Accept": "application/json"
  request = https.request options, (response) ->
    response.setEncoding 'utf8'
    responseBody = ''
    response.on 'data', (chunk) ->
      responseBody += chunk
    response.on 'end', ->
      success(responseBody)
  request.on 'error', (error) ->
    console.error "there has been an errr: #{error.message}"
  request.end()