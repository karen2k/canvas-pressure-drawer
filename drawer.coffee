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

  # tmp vars
  timer = 0
  timerMin = 0
  # tmp vars  

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
    # tmp restriction
    return if ((new Date()).getTime() - timer) < timerMin
    timer = (new Date()).getTime()
    # tmp restriction
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

    pressure = (if penAPI then .5 + Math.round((penAPI.pressure - .1) * 5) else 1)
    
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

    # for i in [1..splines[spline_num].length-1]
      # context.beginPath()
      # context.moveTo splines[spline_num][i-1].x, splines[spline_num][i-1].y
      # midPoint = middlePoint splines[spline_num][i-1], splines[spline_num][i]
      # context.quadraticCurveTo midPoint.x, midPoint.y, splines[spline_num][i].x, splines[spline_num][i].y
    for i in [1..splines[spline_num].length-3]
      context.beginPath()

      xA = splines[spline_num][i - 1].x
      xB = splines[spline_num][i].x
      xC = splines[spline_num][i + 1].x
      xD = splines[spline_num][i + 2].x

      yA = splines[spline_num][i - 1].y
      yB = splines[spline_num][i].y
      yC = splines[spline_num][i + 1].y
      yD = splines[spline_num][i + 2].y

      a3 = (-xA + 3 * (xB - xC) + xD) / 6.0
      a2 = (xA - 2 * xB + xC) / 2.0
      a1 = (xC - xA) / 2.0
      a0 = (xA + 4 * xB + xC) / 6.0
      b3 = (-yA + 3 * (yB - yC) + yD) / 6.0
      b2 = (yA - 2 * yB + yC) / 2.0
      b1 = (yC - yA) / 2.0
      b0 = (yA + 4 * yB + yC) / 6.0


      # for (j = 0; j <= N; j++)
      for j in [0..5]
        # t from 0 to 1
        t = j / 5
        x = (((a3 * t + a2) * t + a1) * t + a0)
        y = (((b3 * t + b2) * t + b1) * t + b0)
        context.lineTo x, y

      context.strokeStyle = strokeStyle
      context.lineWidth = splines[spline_num][i].p
      context.lineCap = 'round'
      context.stroke() 

  toDataURL = ->
    context.toDataURL()


  # construct me
  __construct()