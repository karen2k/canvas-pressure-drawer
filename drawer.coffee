Array::current = 
  ->
    @[@length - 1] if @length > 0


window.drawer = (canvas_container_id) ->

  # remember this
  t = @

  # local variables
  canvas_container = null
  canvas = null
  canvas_cache = null
  context = null
  context_cache = null
  logging = true
  prevX = 0
  prevY = 0
  splines = []
  strokeStyle = 'black'
  canvasWidth = 0
  canvasHeight = 0

  # helpers
  p = (m) ->
    console.log m if logging
  id = (id) ->
    document.getElementById id

  # construct
  __construct = ->
    canvas_container = id canvas_container_id
    canvas = canvas_container.getElementsByTagName('canvas')[0]
    canvasWidth = parseInt canvas.getAttribute 'width'
    canvasHeight = parseInt canvas.getAttribute 'height'
    context = canvas.getContext '2d'
    addCanvasEventsListeners()


  # events
  addCanvasEventsListeners = ->
    canvas.addEventListener 'mousedown', onCanvasMouseDown

  onCanvasMouseDown = (e) ->
    createNewSpline e.offsetX, e.offsetY
    document.addEventListener 'mouseup', onCanvasMouseUp
    canvas.addEventListener 'mousemove', onCanvasMouseMove

  onCanvasMouseUp = (e) ->
    document.removeEventListener 'mouseup', onCanvasMouseUp
    canvas.removeEventListener 'mousemove', onCanvasMouseMove
    finishCurrentSpline e.offsetX, e.offsetY

  onCanvasMouseMove = (e) ->
    pushPoint e.offsetX, e.offsetY

  # utils
  finishCurrentSpline = (x, y) ->
    context.putImageData context_cache.getImageData(0, 0, canvas.offsetWidth, canvas.offsetHeight), 0, 0
    pushPoint x, y, false
    canvas_container.removeChild canvas_cache
  
  createNewSpline = (x, y) ->
    cacheCanvasCurrentState()
    splines.push []
    pushPoint x, y

  cacheCanvasCurrentState = ->
    canvas_cache = document.createElement 'canvas'
    canvas_container.appendChild canvas_cache
    canvas_cache.setAttribute 'width', canvasWidth
    canvas_cache.setAttribute 'height', canvasHeight
    canvas_cache.style.zIndex = '2'
    context_cache = canvas_cache.getContext '2d'
    context_cache.putImageData context.getImageData(0, 0, canvas.offsetWidth, canvas.offsetHeight), 0, 0

  pushPoint = (x, y, clear = true) ->
    x = x * canvasWidth / canvas.offsetWidth
    y = y * canvasHeight / canvas.offsetHeight
    splines.current().push {x:x, y:y} unless splines.current().length > 0 and splines.current().current().x == x and splines.current().current().y == y
    redrawCanvas clear

  redrawCanvas = (clear = true) ->
    context.clearRect(0, 0, 640, 480) if clear
    # redrawSpline i for i in [0..splines.length-1]
    redrawSpline splines.length - 1

  middlePoint = (p1, p2) ->
    return { x: p1.x + (p2.x - p1.x) / 2, y: p1.y + (p2.y - p1.y) / 2 }

  redrawSpline = (spline_num) ->
    return unless splines[spline_num].length > 3

    strokeStyle = 'white'

    context.beginPath()
    context.moveTo splines[spline_num][0].x, splines[spline_num][0].y

    for i in [1..splines[spline_num].length-1]
      midPoint = middlePoint splines[spline_num][i-1], splines[spline_num][i]
      context.quadraticCurveTo splines[spline_num][i-1].x, splines[spline_num][i-1].y, midPoint.x, midPoint.y

    context.strokeStyle = strokeStyle
    context.lineWidth = 2
    context.lineCap = 'round'
    context.stroke()    


  # construct me
  __construct()