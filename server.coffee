https = require 'https'

API_KEY = "2148d071495b9cda230b7a808ed6a79523374dee"
path = 'foobugs/spritmap-api'
branch = 'master' # branches are optional!

# build http request for retreiving informations about the circleci project
options = 
  host: 'circleci.com'
  method: 'GET'
  path: "/api/v1/project/#{path}/tree/#{branch}?circle-token=#{API_KEY}"
  headers:
    "Accept": "application/json"

success = (body) ->
  console.info "received #{body.length} bytes"
  commits = JSON.parse(body)
  # find the last build
  for commit in commits
    url = commit.build_url
    console.info "#{commit.committer_name} #{commit.branch} #{commit.build_time_millis/1000}s #{commit.outcome} #{commit.status}"

request = https.request options, (response) ->
  response.setEncoding 'utf8'
  responseBody = ''
  response.on 'data', (chunk) ->
    responseBody += chunk
  response.on 'end', ->
    success responseBody
request.on 'error', (error) ->
  console.error "there has been an errr: #{error.message}"
request.end()