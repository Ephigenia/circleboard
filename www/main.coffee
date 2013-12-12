class View extends Backbone.View

  isAttached: false
  containerMethod: 'append'
  autoRender: false

  constructor: ->
    super
    if @autoRender
      @render()

  getTemplateData: ->
    data = {}
    if @model
      data = @model.toJSON()
    return data

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

class HeaderView extends View

  container: '#app'
  tagName: 'header'
  className: 'navbar'
  containerMethod: 'prepend'
  autoRender: true

  template: Handlebars.compile """
  <div class="navbar-left">
    <h1 class="brand">
      CircleBoard 0.0.1
      <small>by <a href="http://www.foobugs.com/?rel=circleboard">foobugs</a>
    </h1>
  </div>
  <div class="navbar-right">
    <small class="status">loading …</small>
    <i class="refresh fa fa-refresh"></i>
  </div>
  """

  events:
    'click i.refresh': 'triggerRefresh'

  lastUpdate: null
  lastUpdateInterval: null

  initialize: ->
    super
    # automatically rerender element to update lastUpdate display
    @lastUpdateInterval = window.setInterval @render, 1000

  triggerRefresh: ->
    document.location.href = document.location.href

  showRefreshing: (text) ->
    @lastUpdate = new Date()
    @$el.find('i').addClass('fa-spin')
    @$el.find('.status').html(text)
    @

  render: =>
    super
    @$el.find('i').removeClass('fa-spin')
    if @lastUpdate
      seconds = ((new Date()).getTime() - @lastUpdate.getTime()) / 1000
      seconds = Math.round(seconds)
      @$el.find('.status').html("last update #{seconds}s ago")
    @

class BuildView extends View

  template: Handlebars.compile $('#build-template').html()
  className: 'build'
  container: '#app > .builds'
  tagName: 'li'

  initialize: ->
    super
    @model.on 'change:outcome', @onChangeResult
    @model.on 'change:status', @onChangeResult

  onChangeResult: (model) =>
    classes = [
      @className
    ]
    if model.get('outcome')
      classes.push "build-" + model.get('outcome')
    if model.get('status') in ['scheduled', 'running', 'not_running']
      classes.push "build-" + model.get('status')
    @$el.attr 'class', classes.join ' '
    if @isAttached
      @animate 'pulse'
    @

  animate: (animationName) ->
    @$el
      .addClass('animated')
      .addClass(animationName)
    window.setTimeout () =>
      @$el
        .removeClass('animated')
        .removeClass(animationName)
    , 750

  getTemplateData: ->
    data = super
    # add author’s email hash for gravatar display
    data.authorEmailHash = CryptoJS.MD5 data.committer_email
    # translate stop_time to relative date
    data.finished = moment(data.stop_time).fromNow()
    return data

  render: ->
    # initially set build status in view
    unless @isAttached
      @onChangeResult @model
    super

  attach: ->
    unless @isAttached
      
      @animate 'flipInX'
    super

class Build extends Backbone.Model

  getUniqueId: ->
    return @get('name') + @get('branch')

class IndexController

  views: {}
  header: null

  constructor: ->
    socket = io.connect 'http://'
    socket.on 'build', @updateBuild
    @header = new HeaderView

  updateBuild: (data) =>
    build = new Build data.build
    build.set 'name', data.name
    uniqueId = build.getUniqueId()
    if @views[uniqueId]?
      @header.showRefreshing "updating #{build.get('name')} …"
      @views[uniqueId].model.set data.build
    else
      @header.showRefreshing "adding #{build.get('name')} …"
      @views[uniqueId] = new BuildView
        model: build
    @views[uniqueId].render()

window.app = new IndexController()