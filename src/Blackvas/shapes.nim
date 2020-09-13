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
    
    import macros, strutils

    proc restructJson(shapeInstanceName, kind, value: string) =
      let restructedShapeJson = virtualCanvas["virtual_canvas"][shapeInstanceName]
      restructedShapeJson[kind] = newJString(value)

    proc restructJson(shapeInstanceName: string, kind: string, value: float) =
      let restructedShapeJson = virtualCanvas["virtual_canvas"][shapeInstanceName]
      restructedShapeJson[kind] = newJFloat(value)
      
    proc getShapeProcNimNode (shape: string): NimNode =
      result = newNimNode(nnkBlockStmt).add(
        ident("shapeProcBlock"),
        newStmtList(
          shape.parseStmt
        )
      )
    
    proc getAddAnimation (procedureName: NimNode, shape: string, shapeInstanceName: string): NimNode =
      echo shapeInstanceName
      result = quote("@@") do:
        discard window.setInterval(
          proc () =
            let shapeTuple = @@procedureName()
            restructJson(@@shapeInstanceName, shapeTuple[0], shapeTuple[1])
            draw(context)
        , 20)

    proc getAddListenerClickEvent (procedureName: NimNode, shape: string, shapeInstanceName: string): NimNode =
      let shapeNimNode = shape.parseStmt
      var devideShapes = newSeq[string]()
      for sentence in shapeNimNode:
        let shapeKind = sentence[0].repr
        case shapeKind:
        of "rect":
          devideShapes.add (%* {
            "kind": shapeKind,
            "x": sentence[1].floatVal.float,
            "y": sentence[2].floatVal.float,
            "width": sentence[3].floatVal.float,
            "height": sentence[4].floatVal.float
          }).pretty
        of "triangle":
          devideShapes.add (%* {
            "kind": shapeKind,
            "x1": sentence[1].floatVal.float,
            "y1": sentence[2].floatVal.float,
            "x2": sentence[3].floatVal.float,
            "y2": sentence[4].floatVal.float,
            "x3": sentence[5].floatVal.float,
            "y3": sentence[6].floatVal.float
          }).pretty
        of "circle":
          devideShapes.add (%* {
            "kind": shapeKind,
            "x": sentence[1].floatVal.float,
            "y": sentence[2].floatVal.float,
            "r": sentence[3].floatVal.float
          }).pretty

      result = quote("@@") do:
        import json
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
                  basePointX = event.clientX - canvasRect.left
                  basePointY = event.clientY - canvasRect.top
                var isClick = false
                var shapes = newSeq[JsonNode]()
                for shapeStr in @@devideShapes:
                  shapes.add shapeStr.parseJson
                for shape in shapes:
                  let
                    rawKind = shape["kind"].pretty
                    kind = rawKind[1..rawKind.len-2]
                  case kind:
                  of "rect":
                    let intoCond1 = shape["x"].getFloat <= basePointX and shape["y"].getFloat <= basePointY
                    let intoCond2 = (shape["x"].getFloat + shape["width"].getFloat) >= basePointX and (shape["y"].getFloat + shape["height"].getFloat) >= basePointY
                    if intoCond1 and intoCond2:
                      isClick = true
                  
                  of "triangle":
                    # ベクトル係数を計算して三角形内にクリック座標が含まれているか
                    let area = 0.5 * (-shape["y2"].getFloat * shape["x3"].getFloat + shape["y1"].getFloat * (-shape["x2"].getFloat + shape["x3"].getFloat) + shape["x1"].getFloat * (shape["y2"].getFloat - shape["y3"].getFloat) + shape["x2"].getFloat * shape["y3"].getFloat)
                    let sScala = 1 / (2 * area) * (shape["y1"].getFloat * shape["x3"].getFloat - shape["x1"].getFloat * shape["y3"].getFloat + (shape["y3"].getFloat - shape["y1"].getFloat) * basePointX + (shape["x1"].getFloat - shape["x3"].getFloat) * basePointY)
                    let tScala = 1 / (2 * area) * (shape["x1"].getFloat * shape["y2"].getFloat - shape["y1"].getFloat * shape["x2"].getFloat + (shape["y1"].getFloat - shape["y2"].getFloat) * basePointX + (shape["x2"].getFloat - shape["x1"].getFloat) * basePointY)
                    let scalaDiff = 1 - sScala - tScala
                    if (0 < sScala and sScala < 1) and (0 < tScala and tScala < 1) and (0 < scalaDiff and scalaDiff < 1):
                      isClick = true
                  
                  of "circle":
                    let pointDistanceSquare = (shape["x"].getFloat - basePointX) ^ 2 + (shape["y"].getFloat - basePointY) ^ 2
                    if pointDistanceSquare <= shape["r"].getFloat ^ 2:
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
          x = sentence[1].floatVal.float
          y = sentence[2].floatVal.float
          width = sentence[3].floatVal.float
          height = sentence[4].floatVal.float
        result.add quote do:
          var rectJson = %* { "func": "rect", "x": `x`, "y": `y`, "width": `width`, "height": `height` }
          localShapeJson.add(rectJson)
      of "triangle":
        let
          x1 = sentence[1].floatVal.float
          y1 = sentence[2].floatVal.float
          x2 = sentence[3].floatVal.float
          y2 = sentence[4].floatVal.float
          x3 = sentence[5].floatVal.float
          y3 = sentence[6].floatVal.float
        result.add quote do:
          var triangleJson = (%* {
            "func": "triangle",
            "x1": `x1`,
            "y1": `y1`,
            "x2": `x2`,
            "y2": `y2`,
            "x3": `x3`,
            "y3": `y3`
          })
          localShapeJson.add(triangleJson)
      of "circle":
        let
          x = sentence[1].floatVal.float
          y = sentence[2].floatVal.float
          r = sentence[3].floatVal.float
        result.add quote do:
          var circleJson = (%* {
            "func": "circle",
            "x": `x`,
            "y": `y`,
            "r": `r`
          })
          localShapeJson.add(circleJson)
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
          of "animation":
            result.add getAddAnimation(procedureNameUntype, `shape`, `shapeInstanceName`)
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