Array.prototype.last = 
  ->
    @[@length - 1] # if @length > 0


window.drawer = (canvas_id) ->

  # remember this
  t = this

  # local variables
  canvas = null
  context = null
  logging = true
  prevX = 0
  prevY = 0
  points = []
  strokeStyle = 'black'

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
    canvas = id canvas_id
    context = canvas.getContext '2d'
    addCanvasEventsListeners()


  # events
  addCanvasEventsListeners = ->
    canvas.addEventListener 'mousedown', onCanvasMouseDown

  onCanvasMouseDown = (e) ->
    setPrevXY e.offsetX, e.offsetY
    document.addEventListener 'mouseup', onCanvasMouseUp
    canvas.addEventListener 'mousemove', onCanvasMouseMove

  onCanvasMouseUp = (e) ->
    document.removeEventListener 'mouseup', onCanvasMouseUp
    canvas.removeEventListener 'mousemove', onCanvasMouseMove

  onCanvasMouseMove = (e) ->
    # tmp restriction
    return if ((new Date()).getTime() - timer) < timerMin
    timer = (new Date()).getTime()
    # tmp restriction

    pushPoint e.offsetX, e.offsetY
    setPrevXY e.offsetX, e.offsetY

  # utils
  setPrevXY = (x, y) ->
    [prevX, prevY]= [x, y]

  pushPoint = (x, y) ->
    prevPoint = points.last()
    points.push {x:x, y:y}
    reDrawSpline()

  reDrawSpline = ->
    return unless points.length > 1
    context.clearRect(0, 0, 640, 480)
    # strokeStyle = 'black'
    # for i in [1..points.length-1]
    #   drawLine points[i-1].x, points[i-1].y, points[i].x, points[i].y

    N = 30
    strokeStyle = 'white'

    context.beginPath()
    context.moveTo points[0].x, points[0].y

    for i in [1..points.length-3]
      xA = points[i - 1].x
      xB = points[i].x
      xC = points[i + 1].x
      xD = points[i + 2].x

      yA = points[i - 1].y
      yB = points[i].y
      yC = points[i + 1].y
      yD = points[i + 2].y

      a3 = (-xA + 3 * (xB - xC) + xD) / 6.0
      a2 = (xA - 2 * xB + xC) / 2.0
      a1 = (xC - xA) / 2.0
      a0 = (xA + 4 * xB + xC) / 6.0
      b3 = (-yA + 3 * (yB - yC) + yD) / 6.0
      b2 = (yA - 2 * yB + yC) / 2.0
      b1 = (yC - yA) / 2.0
      b0 = (yA + 4 * yB + yC) / 6.0

    
      # for (j = 0; j <= N; j++)
      for j in [0..N]
        # t from 0 to 1
        t = j / N

        x = (((a3 * t + a2) * t + a1) * t + a0)
        y = (((b3 * t + b2) * t + b1) * t + b0)

        context.lineTo x, y

    context.strokeStyle = strokeStyle
    context.lineWidth = 2
    context.lineCap = 'round'
    context.stroke()

  drawLine = (x0, y0, x1, y1) ->

    controlX = x0 + (x1 - x0) / 2
    controlY = y0 + (y1 - y0) / 2

    context.beginPath()
    context.moveTo x0, y0
    # context.lineTo x1, y1
    context.quadraticCurveTo controlX, controlY, x1, y1
    context.strokeStyle = strokeStyle
    context.lineWidth = 2
    context.lineCap = 'round'
    context.stroke()

  # construct me
  __construct()