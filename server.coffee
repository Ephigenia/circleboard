API_KEY = "2148d071495b9cda230b7a808ed6a79523374dee"

CONFIG =
  interval: 10
  projects: []
    {
      name: 'Snoopet'
      path: 'bevation/snoopet/tree/master'
    }
    {
      name: 'Snoopet Dev'
      path: 'bevation/snoopet/tree/development'
    }
    {
      name: 'Snoopet Mobile'
      path: 'bevation/snoopet-mobile/tree/master'
    }
    {
      name: 'Snoopet Mobile Dev'
      path: 'bevation/snoopet-mobile/tree/development'
    }
    {
      name: 'Spritmap API'
      path: 'foobugs/spritmap-api/tree/master'
    }
    {
      name: 'Spritmap Client'
      path: 'foobugs/spritmap-client/tree/master'
    }
  ]

unless webroot
  webroot = __dirname + '/www/'

https = require('https')
express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

server.listen(process.env.PORT || 5000)
app.use(express.static(webroot))
app.get '/', (request, response) ->
  response.sendfile(webroot + "index.html")
io.sockets.on 'connection', (socket) ->
  # iterate over configured projects and get builds for each and send
  # the last build to the frontend, repeat the whole thing every interval 
  # seconds
  for config in CONFIG.projects
    processCircleCiProject socket, config

processCircleCiProject = (socket, config) ->
  success = (response) =>
    builds = parseResponseToBuildArray config.name, response
    console.log config.name
    socket.emit 'build', builds[0]
  getCircleCiStatusApi config.path, API_KEY, success

parseResponseToBuildArray = (name, body) ->
  commits = JSON.parse(body)

  # find the last build
  builds = []
  for commit in commits
    # transform the circle-ci response to frontend response model
    builds.push
      number: commit.build_num
      result: commit.outcome
      url: commit.build_url
      project: name
      started: commit.start_time
      finished: commit.stop_time
      duration: commit.build_time_millis
      commit:
        subject: commit.subject
        hash: commit.vcs_revision
        author:
          name: commit.committer_name
          email: commit.author_email
      branch:
        name: commit.branch
        status: commit.status

  return builds

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