## shape.nim
## 
## オブジェクトをパースして仮想Canvasに書き込みます。

import macros, strformat, json, tables, random, math, strutils

# Forward declaration
proc getNoArgumentShapeMacro (macroName, body: NimNode): NimNode
proc getOnlyBodyShapeMacro (macroName, body: NimNode): NimNode
proc getHeadAndBodyShapeMacro (macroName, body: NimNode): NimNode
proc getShape (body: NimNode): string
# End

macro shapes* (body: untyped): untyped =
  ## shapeオブジェクトをパースして仮想Canvasに書き込みます。
  result = newStmtList()
  # clickEventProcJson
  # 各クリックイベントの処理を格納し、最後にProc NimNodeに変換するための一時変数
  result.add """
import macros, dom
var
  clickEventProcSeq: seq[tuple[name: string, node: NimNode]]
  localShapeJson = %* []
  shapeJson = %* {}
  shapeCount = 0
""".parseStmt
  result.add quote do:
    
    import macros

    proc restructJson(shapeInstanceName, kind, value: string) =
      let restructedShapeJson = virtualCanvas["virtual_canvas"][shapeInstanceName]
      restructedShapeJson[kind] = newJString(value)
      
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

    proc getAddListenerClickEvent (procedureName: NimNode, shape: string, shapeInstanceName: string): NimNode =
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
        window.addEventListener("load",
          proc(event: Event) =
            var canvas: Canvas
            if document.getElementById(canvasId) == nil:
              let blackvas = document.getElementById("Blackvas")
              canvas = dom.document.createElement("canvas").Canvas
              canvas.id = canvasId
              canvas.height = height
              canvas.width = width
              blackvas.appendChild(canvas)
            else:
              canvas = document.getElementById(canvasId).Canvas
            let context = canvas.getContext2d()
            canvas.addEventListener("click", 
              proc (event: Blackvas.Event) =
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
                  let shapeTuple = @@procedureName()
                  restructJson(@@shapeInstanceName, shapeTuple[0], shapeTuple[1])
                  draw(context)
            )
        )
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
      result.add getShapeProcNimNode(`shape`)

var rng {.compileTime.} = initRand(100000000)

proc getOnlyBodyShapeMacro (macroName, body: NimNode): NimNode {.compileTime.} =
  macroName.expectKind(nnkIdent)
  let shape = getShape(body)
  let macroNameStr = macroName.strVal
  result = """
localShapeJson = %* []
""".parseStmt
  let shapeInstanceName = "shape_" & $rng.rand(10000000)
  for sentence in body:
    if sentence[0].kind == nnkIdent:
      let name = repr sentence[0]
      case name:
      of "rect":
        let
          x = sentence[1].intVal.int
          y = sentence[2].intVal.int
          width = sentence[3].intVal.int
          height = sentence[4].intVal.int
        result.add quote do:
          var rectJson = %* { "func": "rect", "x": `x`, "y": `y`, "width": `width`, "height": `height` }
          localShapeJson.add(rectJson)
  result.add quote do:
    virtualCanvas["shapes"].add(`macroNameStr`, localShapeJson)
  result.add quote do:
    import macros
    macro `macroName`* (body: untyped) =
      result = quote do:
        discard # 何故か下の文だけでコンパイルするとエラーになる...
        shapeJson = %* {"shape": `macroNameStr`}
      for sentence in body:
        expectLen(sentence, 2)
        let sentenceKind = sentence[0].kind
        if sentenceKind == nnkPrefix:
          let eventNameUntype = sentence[0][1]
          let eventName = repr eventNameUntype
          let procedureNameUntype = sentence[1]
          case eventName:
          of "click":
            result.add getAddListenerClickEvent(procedureNameUntype, `shape`, `shapeInstanceName`)
          else:
            discard
        elif sentenceKind == nnkIdent:
          let attributeName = sentence[0].repr
          let attributeValueKind = sentence[1].kind
          let attributeValue = sentence[1].repr
          if attributeValueKind == nnkStrLit:
            if attributeName == "class" or attributeName == "id":
              var trimmedAttributeValue = attributeValue[1..attributeValue.len-2]
              result.add quote("@@") do:
                shapeJson[@@attributeName] = newJString @@attributeValue
            else:
              error("Undefined attributes", sentence[0])

          elif attributeValueKind == nnkIdent:
            # 変数が与えられたとき
            let attributeName = sentence[0].repr
            let attributeValueNimNode = sentence[1]
            result.add quote("@@") do:
              shapeJson[@@attributeName] = newJString(@@attributeValueNimNode)
          else:
            error("Undefined attributes", sentence[0])
        else:
          error("Unrecognized Events: ", sentence[0])
      result.add quote do:
        ## 定義したshapeをvirtualCanvasに書き出す
        virtualCanvas["virtual_canvas"].add(`shapeInstanceName`, shapeJson)

proc getHeadAndBodyShapeMacro (macroName, body: NimNode): NimNode =
  macroName.expectKind(nnkIdent)
  let shape = getShape(body)
  result = quote do:
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

template triangle* (v1x, v1y, v2x, v2y, v3x, v3y: untyped): untyped =
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

template circle* (x, y, r: untyped): untyped =
  var circleJson = %* { "func": "circle", "x": `x`, "y": `y`, "r": `r` }
  virtualCanvas["virtual_canvas"].add(circleJson)
