import dom

type
  Canvas* = ref CanvasObj
  CanvasObj {.importc.} = object of dom.Element
  
  CanvasContext2d* = ref CanvasContext2dObj
  CanvasContext2dObj {.importc.} = object
    font*: cstring
    fillStyle* : cstring
    textAlign* : cstring

proc getContext2d*(c: Canvas): CanvasContext2d = {.emit: "`result` = `c`.getContext('2d');".}

# methods
proc arc*(c: CanvasContext2d, x: float, y: float, radius: float, startAngle: float, endAngle: float, anticlockwise: bool = false) {.importcpp.}
proc arcTo*(c: CanvasContext2d, x1: float, y1: float, x2: float, y2: float, radius: float) {.importcpp.}
proc beginPath*(c: CanvasContext2d) {.importcpp.}
proc clearRect*(c: CanvasContext2d, x: float, y: float, width: float, height: float) {.importcpp.}
proc stroke*(c: CanvasContext2d) {.importcpp.}
proc strokeText*(c: CanvasContext2d, txt: cstring, x, y: float) {.importcpp.}
proc fillText*(c: CanvasContext2d, txt: cstring, x, y: float) {.importcpp.}
proc fill*(c: CanvasContext2d) {.importcpp.}
proc rect*(c: CanvasContext2d, x: float, y: float, width: float, height: float) {.importcpp.}