API_KEY = "2148d071495b9cda230b7a808ed6a79523374dee"
port = 5000;

https = require('https')
app = require('express')()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

server.listen(port)
app.get '/', (request, response) ->
  response.sendfile(__dirname + '/index.html')
io.sockets.on 'connection', (socket) ->
  success = (response) ->
    builds = parseResponseToBuildArray response
    socket.emit 'builds', builds
  getCircleCiStatusApi('foobugs/spritmap-api/tree/master', API_KEY, success)

parseResponseToBuildArray = (body) ->
  console.info "received #{body.length} bytes"
  commits = JSON.parse(body)

  # find the last build
  builds = []
  for commit in commits
    # transform the circle-ci response to frontend response model
    builds.push
      result: commit.outcome
      url: commit.build_url
      project: 'foobugs/spritmap-api'
      commit:
        subject: commit.subject
        hash: commit.vcs_revision
        author: commit.committer_name
        duration: commit.build_time_millis
      branch:
        name: commit.branch
        status: commit.status

  return builds

getCircleCiStatusApi = (path, apikey, success) ->
  # build http request for retreiving informations about the circleci project
  options = 
    host: 'circleci.com'
    method: 'GET'
    path: "/api/v1/project/#{path}?circle-token=#{API_KEY}"
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