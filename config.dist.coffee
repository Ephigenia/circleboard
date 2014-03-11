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
      name: 'FBN/FBN MST'
      path: 'footbonaut/footbonaut/tree/master'
    }
    {
      name: 'FBN/FBN ACT'
      path: 'footbonaut/footbonaut'
    }
    {
      name: 'Eph/FBN ACT'
      path: 'Ephigenia/footbonaut'
    }
    {
      name: 'Franklin ACT'
      path: 'Ephigenia/franklin'
    }
    {
      name: 'CryptoWL ACT'
      path: 'foobugs/cryptocoinwatchlist'
    }
    {
      name: 'GPS-Tracker ACT'
      path: 'foobugs/gps-tracker'
    }
    {
      name: "CircleBoard"
      path: 'foobugs/circleboard/tree/master'
    }
  ]

module.exports = CONFIG