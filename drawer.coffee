Array::current = 
  ->
    @[@length - 1] if @length > 0


window.drawer = (canvas) ->

  # remember this
  t = @

  # local variables
  canvas_container = null
  # canvas = null
  canvas_cache = null
  context = null
  context_cache = null
  logging = true
  prevX = 0
  prevY = 0
  splines = []
  strokeStyle = 'white'
  canvasWidth = 0
  canvasHeight = 0
  penAPI = null

  # helpers
  p = (m) ->
    console.log m if logging
  id = (id) ->
    document.getElementById id

  # construct
  __construct = ->
    canvas_container = canvas.parentNode
    setCanvasStyles canvas
    # canvas = canvas_container.getElementsByTagName('canvas')[0]
    canvasWidth = parseInt canvas.getAttribute 'width'
    canvasHeight = parseInt canvas.getAttribute 'height'
    context = canvas.getContext '2d'
    initWacom()
    addCanvasEventsListeners()    

  initWacom = ->
    pluginHTML = """
      <!--[if IE]>

      <object id='wtPlugin' classid='CLSID:092dfa86-5807-5a94-bf3b-5a53ba9e5308' width='1' height='1' style="position:fixed; top: 0px; left: 0px">
      </object>

      <![endif]--><!--[if !IE]> <-->

      <object id="wtPlugin" type="application/x-wacomtabletplugin" width='1' height='1' style="position:fixed; top: 0px; left: 0px">
  	    <!-- <param name="onload" value="pluginLoaded" /> -->
      </object>

      <!--> <![endif]-->
    """
    ###
      Detect Wacom pressure support. Code should look approximately so:
    ###
    wacomPlugin = document.getElementById('wtPlugin')
    if not wacomPlugin
      holder = document.createElement("div")
      holder.innerHTML = pluginHTML
      document.body.appendChild(holder)
      wacomPlugin = document.getElementById('wtPlugin')
  
    penAPI = wacomPlugin.penAPI
  
    if penAPI
      console.debug "Wacom detected"


  # events
  addCanvasEventsListeners = ->
    canvas.addEventListener 'mousedown', onCanvasMouseDown

  onCanvasMouseDown = (e) ->
    createNewSpline e.clientX, e.clientY
    document.addEventListener 'mouseup', onCanvasMouseUp
    canvas.addEventListener 'mousemove', onCanvasMouseMove

  onCanvasMouseUp = (e) ->
    document.removeEventListener 'mouseup', onCanvasMouseUp
    canvas.removeEventListener 'mousemove', onCanvasMouseMove
    finishCurrentSpline e.clientX, e.clientY

  onCanvasMouseMove = (e) ->
    
    pushPoint e.clientX, e.clientY

  # utils
  finishCurrentSpline = (x, y) ->
    context.putImageData context_cache.getImageData(0, 0, canvasWidth, canvasHeight), 0, 0
    pushPoint x, y, false
    canvas_container.removeChild canvas_cache
  
  createNewSpline = (x, y) ->
    cacheCanvasCurrentState()
    splines.push []
    pushPoint x, y

  cacheCanvasCurrentState = ->
    canvas_cache = document.createElement 'canvas'
    canvas_cache.setAttribute 'width', canvasWidth
    canvas_cache.setAttribute 'height', canvasHeight
    setCanvasStyles canvas_cache
    canvas_cache.style.zIndex = '2'
    canvas_container.appendChild canvas_cache
    context_cache = canvas_cache.getContext '2d'
    context_cache.putImageData context.getImageData(0, 0, canvasWidth, canvasHeight), 0, 0

  setCanvasStyles = (canvas) ->
    canvas.style.display = 'block'
    canvas.style.width = '100%'
    canvas.style.position = 'absolute'
    canvas.style.top = '0'
    canvas.style.zIndex = '3'

  pushPoint = (clientX, clientY, clear = true) ->
    
    # Compute all the transforms and offsets
    rect = canvas.getBoundingClientRect()
    canvasLeft = rect.left
    canvasTop = rect.top
    scale = rect.width / canvas.width
    
    # We use clientX instead of pageX because
    # pageX changes when the document is scrolled down from the 0 scroll
    x = (clientX - canvasLeft) / scale
    y = (clientY - canvasTop) / scale

    pressure = (if penAPI then Math.round(penAPI.pressure * 10) else 1)
    
    splines.current().push {x:x, y:y, p:pressure} unless splines.current().length > 0 and splines.current().current().x == x and splines.current().current().y == y
    redrawCanvas clear

  redrawCanvas = (clear = true) ->
    context.clearRect(0, 0, canvasWidth, canvasHeight) if clear
    # redrawSpline i for i in [0..splines.length-1]
    redrawSpline splines.length - 1

  middlePoint = (p1, p2) ->
    return { x: p1.x + (p2.x - p1.x) / 2, y: p1.y + (p2.y - p1.y) / 2 }

  redrawSpline = (spline_num) ->
    return unless splines[spline_num].length > 3

    for i in [1..splines[spline_num].length-1]
      context.beginPath()
      context.moveTo splines[spline_num][i-1].x, splines[spline_num][i-1].y
      midPoint = middlePoint splines[spline_num][i-1], splines[spline_num][i]
      context.quadraticCurveTo splines[spline_num][i-1].x, splines[spline_num][i-1].y, midPoint.x, midPoint.y
      context.strokeStyle = strokeStyle
      context.lineWidth = splines[spline_num][i-1].p
      context.lineCap = 'round'
      context.stroke()    

  toDataURL = ->
    context.toDataURL()


  # construct me
  __construct()