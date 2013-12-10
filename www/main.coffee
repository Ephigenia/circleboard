class View extends Backbone.View

  isAttached: false

  getTemplateData: ->
    return @model.toJSON()

  render: ->
    templateData = @getTemplateData()
    compiledTemplate = @template(templateData)
    @$el.html(compiledTemplate)
    @attach()
    super

  attach: ->
    unless @isAttached
      $(@container)[@containerMethod](@$el)
    @

class BuildView extends View

  template: Handlebars.compile $('#build-template').html()
  className: 'build'
  container: '#app'
  containerMethod: 'append'

  getTemplateData: ->
    data = super
    if data.project.length > 20
      data.project = data.project.substr(0, 20) + '…'
    if data.commit.subject.length > 80
      data.commit.subject = data.commit.subject.length.substr(0, 79) + '…'
    data.commit.author.emailhash = CryptoJS.MD5(data.commit.author.email);
    return data

  attach: ->
    @$el.addClass "build-" + @model.get('result')
    super

class Build extends Backbone.Model


views = {}

# main application
socket = io.connect 'http://'
socket.on 'build', (buildData) ->
  build = new Build buildData
  uniqueId = build.get 'project'
  if views[uniqueId]?
    views[uniqueId].model.set buildData
  else
    views[uniqueId] = new BuildView
      model: build
  views[uniqueId].render()