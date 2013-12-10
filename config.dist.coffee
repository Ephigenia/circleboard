# example configuration for circle ci status board
# copy this file to config.coffee and then modify it.

CONFIG =
  # interval bettween polling of circle ci status
  interval: 20
  # insert circle ci status api key here or leave blank and set the environment
  # variable CIRCLE_CI_API_KEY which is then used in the server.coffee
  apiKey: ''
  # list of projects, note that you’ll have to follow the projects with the 
  # account that created the api key to access the build details for that
  # project over the circle ci api
  projects: [
    {
      name: 'Snoopet'
      path: 'bevation/snoopet/tree/master'
    }
    {
      name: 'Snoopet'
      path: 'bevation/snoopet/tree/development'
    }
    {
      name: 'Snoopet Mobile'
      path: 'bevation/snoopet-mobile/tree/master'
    }
    {
      name: 'Snoopet Mobile'
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

module.exports = CONFIG