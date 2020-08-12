#import HighCanvas

#let canvas2 = initHighCanvas()

type Position2D = tuple
  x: float
  y: float

const width = 500.0
const height = 250.0

proc font(str: string) =
  discard

proc fillStyle(str: string) =
  discard 

proc strokeStyle(str: string) =
  discard 

proc text(str: string) =
  discard

proc position(pos: Position2D) =
  discard

let shapes = {
  "helloCanvas": proc (x: int) =
    "38pt Arial".font
    "coornflowerblue".fillStyle
    "blue".strokeStyle
    "Hello Canvas".text
    (width / 2 - 150, height / 2 + 15).position
}

settings:
  const context = "2d"

events:


# canvas(id = "root"):
#   discard

# events:
#   # イベントの定義
#   discard

view:
  helloCanvas