import dom

type
  Canvas* = ref CanvasObj
  CanvasObj {.importc.} = object of dom.Element
    width* : float
    height* : float
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


# methods
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

proc getContext2d*(c: Canvas): CanvasContext2d = {.emit: "`result` = `c`.getContext('2d');".}