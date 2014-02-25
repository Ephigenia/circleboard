https = require 'https'

module.exports = class CircleCiApi

  apiKey: null

  constructor: (apiKey = null) ->
    if apiKey
      @apiKey = apiKey
    @

  get: (options, success) ->
    request = https.request options, (response) ->
      response.setEncoding 'utf8'
      responseBody = ''
      response.on 'data', (chunk) ->
        responseBody += chunk
      response.on 'end', ->
        console.log 'OOOOTHER .----------------------------------'
        console.log options.path, responseBody
        success(JSON.parse(responseBody))
    request.on 'error', (error) ->
      console.error "there has been an error: #{error.message}"
    request.end()
	
  getBuilds: (path, apiKey = null, success) ->
    console.info """
    requesting #{path} …
    """
    options = 
      host: 'circleci.com'
      method: 'GET'
      path: "/api/v1/project/#{path}?circle-token=#{apiKey||@apiKey}"
      headers:
        "Accept": "application/json"
    @get options, success