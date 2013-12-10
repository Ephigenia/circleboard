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
    data.authorEmailHash = CryptoJS.MD5 data.committer_email
    data.finished = moment(data.stop_time).fromNow()
    data.subject = 'asdlkj'
    return data

  render: ->
    @onChangeResult @model
    super

class Build extends Backbone.Model

  getUniqueId: ->
    return @get('name') + @get('branch')

class IndexController

  views: {}

  constructor: ->
    socket = io.connect 'http://'
    socket.on 'build', @updateBuild

  updateBuild: (data) =>
    build = new Build data.build
    build.set 'name', data.name
    uniqueId = build.getUniqueId()
    if @views[uniqueId]?
      @views[uniqueId].model.set data
    else
      @views[uniqueId] = new BuildView
        model: build
    @views[uniqueId].render()

window.app = new IndexController()