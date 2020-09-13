import ../../../src/Blackvas, random

Blackvas:
  shapes:
    shape MyCircle:
      circle(100f, 100f, 100f)
    
    shape MyRect:
      rect(300f, 300f, 100f, 100f)
  
  style:
    id red:
      color = PrimaryColor.red
    
    id green:
      color = PrimaryColor.green
    
    id blue:
      color = PrimaryColor.blue
    
    id orange:
      color = PrimaryColor.orange
  
  data:
    var
      dx = 5.0
      dy = 5.0
  
  methods:
    proc changeColor1(context: var VasContext) =
      if context.shapeId == "red":
        context.shapeId = "green"
      else:
        context.shapeId = "red"

    proc changeColor2(context: var VasContext) =
      if context.shapeId == "blue":
        context.shapeId = "orange"
      else:
        context.shapeId = "blue"

    proc randomWalk1(context: var VasContext) =
      context.x += dx
      context.y += dy
      var dPos = rand(10.0) + 5.0
      if context.x <= 0:
        dx = dPos
      elif context.y <= 0:
        dy = dPos
      elif context.x + 200.0 >= width:
        dx = -dPos
      elif context.y + 200.0 >= height:
        dy = -dPos
    
    proc randomWalk2(context: var VasContext) =
      context.x += rand(20.0)
      context.y += rand(20.0)
  
  data:
    const
      redId = "red"
      blueId = "blue"

  view:
    MyCircle:
      id = redId
      @animation = randomWalk1
      @click = changeColor1
    
    MyRect:
      id = "blue"
      @click = changeColor2
      @animation = randomWalk2