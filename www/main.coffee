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
      @isAttached = true
    @

class BuildView extends View

  template: Handlebars.compile $('#build-template').html()
  className: 'build'
  container: '#app'
  containerMethod: 'append'

  initialize: ->
    super
    @model.on 'change:result', @onChangeResult

  onChangeResult: (model) =>
    classes = [
      @className
    ]
    if model.get 'outcome'
      classes.push "build-" + model.get 'outcome'
    if model.get 'status' in ['scheduled', 'running']
      classes.push "build-" + model.get 'status'
    @$el.attr 'class', classes.join ' '

  getTemplateData: ->
    data = super
    if data.project.length > 20
      data.project = data.project.substr(0, 20) + '…'
    if data.commit.subject.length > 80
      data.commit.subject = data.commit.subject.length.substr(0, 79) + '…'
    data.commit.author.emailhash = CryptoJS.MD5(data.commit.author.email);
    data.finished = moment(data.finished).fromNow()
    return data

  render: ->
    @onChangeResult @model
    super

class Build extends Backbone.Model

  getUniqueId: ->
    return @get 'uuid'

views = {}
updateBuild = (data) ->
  build = new Build data
  uniqueId = build.getUniqueId()
  if views[uniqueId]?
    views[uniqueId].model.set data
  else
    views[uniqueId] = new BuildView
      model: build
  views[uniqueId].render()  

socket = io.connect 'http://'
socket.on 'build', (buildData) ->
  updateBuild buildData