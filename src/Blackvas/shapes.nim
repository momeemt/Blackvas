import macros, strformat, json

# Forward declaration
proc getNoArgumentShapeMacro (macroName, body: NimNode): NimNode
proc getOnlyBodyShapeMacro (macroName, body: NimNode): NimNode
proc getHeadAndBodyShapeMacro (macroName, body: NimNode): NimNode
proc getShape (body: NimNode): string
# End

macro shapes* (body: untyped): untyped =
  result = newStmtList()
  result.add quote do:
    proc getResetShapeStyle (): NimNode =
      result = quote do:
        var resetStyleJson = %* { "func": "style_reset" }
        virtualCanvas["virtual_canvas"].add(resetStyleJson)
    
    import macros
    proc getShapeProcNimNode (shape: string): NimNode =
      result = newNimNode(nnkBlockStmt).add(
        ident("shapeProcBlock"),
        newStmtList(
          shape.parseStmt
        )
      )
    
    type Rect = object
      x1: int
      y1: int
      x2: int
      y2: int
    
    proc getAddListenerClickEvent (procedureName: NimNode, shape: string): NimNode =
      let shapeNimNode = shape.parseStmt
      var devideShapes: seq[Rect] = @[]
      for sentence in shapeNimNode:
        if sentence[0].repr == "rect":
          devideShapes.add Rect(
            x1: sentence[1].intVal.int,
            y1: sentence[2].intVal.int,
            x2: sentence[1].intVal.int + sentence[3].intVal.int,
            y2: sentence[2].intVal.int + sentence[4].intVal.int
          )
      result = quote("@@") do:
        var clickEventJson = %* { "event": "click", "proc": "testClickProc" }
        virtualCanvas["events"].add(clickEventJson)
        proc testClickProc (canvas: Canvas, event: Event) =
          let
            canvasRect = canvas.getBoundingClientRect()
            basePointX = event.clientX - canvasRect.left.int
            basePointY = event.clientY - canvasRect.top.int
          var isClick = false
          for devideShape in @@devideShapes:
            let intoCond1 = devideShape.x1 <= basePointX and devideShape.y1 <= basePointY
            let intoCond2 = devideShape.x2 >= basePointX and devideShape.y2 >= basePointY
            if intoCond1 and intoCond2:
              isClick = true
          if isClick:
            @@procedureName()

    proc getStyleByAttribute (attributeName, attributeValue: string): NimNode =
      result = quote("@@") do:
        block shapeScope:
          var key = ""
          key = "@" & @@attributeValue
          # if @@attributeName == "id":
          #   key = "#" & @@attributeValue
          # elif @@attributeName == "class":
          #   key = "." & @@attributeValue
          if blackvasStyleMap.hasKey(key):
            for styleKey, styleValue in blackvasStyleMap[key]:
              case styleKey:
              of "color":
                # context.fillStyle = styleValue
                var styleJson = %* { "func": "style_color", "color": styleValue }
                virtualCanvas["virtual_canvas"].add(styleJson)
              of "font":
                # context.font = styleValue
                var styleJson = %* { "func": "style_font", "font": styleValue }
                virtualCanvas["virtual_canvas"].add(styleJson)
              of "textAlign":
                # context.textAlign = styleValue
                var styleJson = %* { "func": "style_text_align", "font": styleValue }
                virtualCanvas["virtual_canvas"].add(styleJson)
  result.add body

macro shape* (head: untyped, body: untyped): untyped =
  result = newStmtList()
  result.add getNoArgumentShapeMacro(head, body)
  result.add getOnlyBodyShapeMacro(head, body)
  result.add getHeadAndBodyShapeMacro(head, body)

proc getNoArgumentShapeMacro (macroName, body: NimNode): NimNode =
  macroName.expectKind(nnkIdent)
  let shape = getShape(body)
  result = quote do:
    import macros
    macro `macroName`* () =
      result = getResetShapeStyle()
      result.add getShapeProcNimNode(`shape`)

proc getOnlyBodyShapeMacro (macroName, body: NimNode): NimNode =
  macroName.expectKind(nnkIdent)
  let shape = getShape(body)
  result = quote do:
    import macros
    macro `macroName`* (body: untyped) =
      result = getResetShapeStyle()
      for sentence in body:
        expectLen(sentence, 2)
        let sentenceKind = sentence[0].kind
        if sentenceKind == nnkPrefix:
          let eventNameUntype = sentence[0][1]
          let eventName = repr eventNameUntype
          let procedureNameUntype = sentence[1]
          case eventName:
          of "click":
            result.add getAddListenerClickEvent(procedureNameUntype, `shape`)
          else:
            discard
        elif sentenceKind == nnkIdent:
          let attributeName = sentence[0].repr
          let attributeValueKind = sentence[1].kind
          let attributeValue = sentence[1].repr
          if attributeValueKind == nnkStrLit:
            if attributeName == "class" or attributeName == "id":
              var trimmedAttributeValue = attributeValue[1..attributeValue.len-2]
              result.add getStyleByAttribute(attributeName, trimmedAttributeValue)
            else:
              error("Undefined attributes", sentence[0])
          elif attributeValueKind == nnkIdent:
            let attributeValueNimNode = sentence[1]
            result.add quote("@@") do:
              let attributeValue = $(@@attributeValueNimNode)
              block shapeScope:
                var key = ""
                key = "@" & attributeValue
                # if @@attributeName == "id":
                #   key = "#" & @@attributeValue
                # elif @@attributeName == "class":
                #   key = "." & @@attributeValue
                if blackvasStyleMap.hasKey(key):
                  for styleKey, styleValue in blackvasStyleMap[key]:
                    case styleKey:
                    of "color":
                      var styleJson = %* { "func": "style_color", "color": styleValue }
                      virtualCanvas["virtual_canvas"].add(styleJson)
                    of "font":
                      var styleJson = %* { "func": "style_font", "font": styleValue }
                      virtualCanvas["virtual_canvas"].add(styleJson)
                    of "textAlign":
                      var styleJson = %* { "func": "style_text_align", "font": styleValue }
                      virtualCanvas["virtual_canvas"].add(styleJson)
          else:
            error("Undefined attributes", sentence[0])
        else:
          error("Unrecognized Events: ", sentence[0])
      result.add getShapeProcNimNode(`shape`)

proc getHeadAndBodyShapeMacro (macroName, body: NimNode): NimNode =
  macroName.expectKind(nnkIdent)
  let shape = getShape(body)
  result = quote do:
    import macros
    macro `macroName`* (head, body: untyped) =
      echo `shape`

proc getShape (body: NimNode): string =
  result = ""
  for sentence in body:
    result &= fmt"{repr(sentence)}" & "\n"

macro text* (head: untyped): untyped =
  let textStr = $head[0]
  let x = intVal(head[1]).float
  let y = intVal(head[2]).float
  result = quote do:
    var textJson = %* { "func": "text", "value": `textStr`, "x": `x`, "y": `y` }
    virtualCanvas["virtual_canvas"].add


template rect* (x, y, width, height: untyped): untyped =
  var rectJson = %* { "func": "rect", "x": `x`, "y": `y`, "width": `width`, "height": `height` }
  virtualCanvas["virtual_canvas"].add(rectJson)

macro triangle* (v1x, v1y, v2x, v2y, v3x, v3y: untyped): untyped =
  result = quote do:
    var triabgleJson = %* {
      "func": "triangle",
      "v1x": `v1x`,
      "v1y": `v1y`,
      "v2x": `v2x`,
      "v2y": `v2y`,
      "v3x": `v3x`,
      "v3y": `v3y`
    }
    virtualCanvas["virtual_canvas"].add(triangleJson)

macro circle* (x, y, r: untyped): untyped =
  result = quote do:
    var circleJson = %* { "func": "circle", "x": `x`, "y": `y`, "r": `r` }
    virtualCanvas["virtual_canvas"].add(circleJson)
