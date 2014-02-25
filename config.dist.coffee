# example configuration for circle ci status board
# copy this file to config.coffee and then modify it.

CONFIG =
  # interval bettween polling of circle ci status
  interval: 15
  # insert circle ci status api key here or leave blank and set the environment
  # variable CIRCLE_CI_API_KEY which is then used in the server.coffee
  apiKey: ''
  # list of projects, note that you’ll have to follow the projects with the 
  # account that created the api key to access the build details for that
  # project over the circle ci api
  projects: [
    {
      name: 'FBN/FBN Master'
      path: 'footbonaut/tree/master'
    }
    {
      name: 'FBN/FBN Activity'
      path: 'footbonaut/footbonaut'
    }
    {
      name: 'Eph/FBN Activity'
      path: 'Ephigenia/footbonaut'
    }
    {
      name: 'Snoopet'
      path: 'bevation/snoopet/tree/master'
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
      name: "CircleBoard"
      path: 'foobugs/circleboard/tree/master'
    }
  ]

module.exports = CONFIG