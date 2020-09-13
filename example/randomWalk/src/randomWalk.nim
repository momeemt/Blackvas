import Blackvas, random

Blackvas:
  shapes:
    shape MyCircle:
      circle(100f, 100f, 100f)
  
  style:
    id red:
      color = PrimaryColor.red
  
  data:
    var
      dx = 5.0
      dy = 5.0
  
  methods:
    proc randomWalk(context: var VasContext) =
      context.x += dx
      context.y += dy
      var dPos = rand(5.0) + 5.0
      if context.x <= 0:
        dx = dPos
      elif context.y <= 0:
        dy = dPos
      elif context.x + 200.0 >= width:
        dx = -dPos
      elif context.y + 200.0 >= height:
        dy = -dPos
  
  data:
    const redId = "red"

  view:
    MyCircle:
      id = redId
      @animation = randomWalk