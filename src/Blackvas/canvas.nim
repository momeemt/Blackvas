## canvas.nim
## 
## DOM要素のCanvasを読み込むためのモジュールです。
import dom

type
  Event* = ref EventObj
  EventObj {.importc.} = object of RootObj
    target*: Node
    altKey*, ctrlKey*, shiftKey*: bool
    button*: int
    clientX*, clientY*: float
    keyCode*: int
    layerX*, layerY*: int
    modifiers*: int
    ALT_MASK*, CONTROL_MASK*, SHIFT_MASK*, META_MASK*: int
    offsetX*, offsetY*: int
    pageX*, pageY*: int
    screenX*, screenY*: int
    which*: int
    `type`*: cstring
    x*, y*: int
    ABORT*: int
    BLUR*: int
    CHANGE*: int
    CLICK*: int
    DBLCLICK*: int
    DRAGDROP*: int
    ERROR*: int
    FOCUS*: int
    KEYDOWN*: int
    KEYPRESS*: int
    KEYUP*: int
    LOAD*: int
    MOUSEDOWN*: int
    MOUSEMOVE*: int
    MOUSEOUT*: int
    MOUSEOVER*: int
    MOUSEUP*: int
    MOVE*: int
    RESET*: int
    RESIZE*: int
    SELECT*: int
    SUBMIT*: int
    UNLOAD*: int

  Canvas* = ref CanvasObj
  
  CanvasObj {.importc.} = object of dom.Element
    width* : float
    height* : float

  BoundingRect* {.importc.} = object
    top*, bottom*, left*, right*, x*, y*, width*, height*: float
  
  CanvasContext2d* = ref CanvasContext2dObj

  CanvasContext2dObj {.importc.} = object
    font*: cstring
    fillStyle* : cstring
    textAlign* : cstring
  
  Repetition* = enum
    repeat,
    repeatX = "repeat-x",
    repeatY = "repeat-y",
    noRepeat = "no-repeat"
  
  Align* {.pure.} = enum
    left,
    right,
    center,
    start,
    ends = "end"

# methods
proc addEventListener*(et: Canvas, ev: cstring, cb: proc(ev: Event), useCapture: bool = false) {.importcpp.}
proc addEventListener*(et: Window, ev: cstring, cb: proc(ev: Event), useCapture: bool = false) {.importcpp.}

proc arc*(c: CanvasContext2d, x: float, y: float, radius: float, startAngle: float, endAngle: float, anticlockwise: bool = false) {.importcpp.}
proc arcTo*(c: CanvasContext2d, x1: float, y1: float, x2: float, y2: float, radius: float) {.importcpp.}
proc beginPath*(c: CanvasContext2d) {.importcpp.}
proc bezierCurveTo*(c: CanvasContext2d, cp1x: float, cp1y: float, cp2x: float, cp2y: float, x: float, y: float) {.importcpp.}
proc clearHitRegions*(c: CanvasContext2d) {.importcpp.}
proc clearRect*(c: CanvasContext2d, x: float, y: float, width: float, height: float) {.importcpp.}
proc clip*(c: CanvasContext2d) {.importcpp.}
proc closePath*(c: CanvasContext2d) {.importcpp.}
proc createImageData*(c: CanvasContext2d, width: float, height: float) {.importcpp.}
proc createLinearGradient*(c: CanvasContext2d, x0: float, y0: float, x1: float, y1: float) {.importcpp.}
proc createPattern*(c: CanvasContext2d, image: ImageElement, repretition: Repetition) {.importcpp.}
proc createRadialGradient*(c: CanvasContext2d, x0: float, y0: float, r0: float, x1: float, y1: float, r1: float) {.importcpp.}
proc drawFocusIfNeeded*(c: CanvasContext2d, element: Element) {.importcpp.}
proc drawImage*(c: CanvasContext2d, image: ImageElement, dx: float, dy: float) {.importcpp.}
proc stroke*(c: CanvasContext2d) {.importcpp.}
proc strokeText*(c: CanvasContext2d, txt: cstring, x, y: float) {.importcpp.}
proc fillText*(c: CanvasContext2d, txt: cstring, x, y: float) {.importcpp.}
proc fill*(c: CanvasContext2d) {.importcpp.}
proc rect*(c: CanvasContext2d, x: float, y: float, width: float, height: float) {.importcpp.}
proc fillRect*(c: CanvasContext2d, x: float, y: float, width: float, height: float) {.importcpp.}

proc moveTo*(c: CanvasContext2d, x: float, y: float) {.importcpp.}

proc lineTo*(c: CanvasContext2d, x: float, y: float) {.importcpp.}

proc getContext2d*(c: Canvas): CanvasContext2d = {.emit: "`result` = `c`.getContext('2d');".}
proc getBoundingClientRect*(c: Canvas): BoundingRect {.importcpp.}