## Blackvas.nim
## 
## 仮想Canvas (virtualCanvas) をHTMLに反映する機能を備えます。

include Blackvas/[settings, view, methods, canvas, data, color, style, shapes]

const
  Debug* = true

macro Blackvas*(body: untyped): untyped =
  ## Blackvasプロジェクトであることを示す文です。
  ## このマクロは、仮想CanvasをHTMLに反映するプロシージャなどを生成します。
  ## また、文中で定義されたプログラムを全て出力します。
  ## 
  ## * 生成される変数
  ## 
  ##  * canvas
  ##    * window.onloadが実行されるタイミングでDOM要素に作成されるcanvas要素が代入されます。
  ## 
  ##  * context
  ##    * canvas要素のcontextが代入されます。
  ## 
  ##  * globalEvent
  ##    * イベントハンドラなどが引数などで渡すeventオブジェクトが代入されます。
  ## 
  ##  * virtualCanvas
  ##    * Blackvasでは、スタイルやオブジェクトなどの情報を全てこのJSONで扱い、最終的にこの値を元にしてHTMLに反映します。
  ## 
  ## * 生成されるプロシージャ
  ## 
  ##  * drawShape (context: CanvasContext2d, shapesArr: JsonNode)
  ##    * shapes情報が含まれるJSONArrayを元に、オブジェクトを画面に反映します。
  ## 
  ##  * draw (context: CanvasContext2d)
  ##    * virtualCanvasを元に、画面にCanvasを描画します。
  ## 
  ##  * window.addEventListener ("load", ...)
  ##    * HTML要素が読み込まれた時、Canvasを作成し、contextなどを変数に代入します。
  result = """
import json, strutils, math, dom, tables
var
  canvas*: Canvas
  context*: CanvasContext2d
  globalEvent*: Blackvas.Event
  virtualCanvas* = %* { "virtual_canvas": {}, "shapes": {}, "styles": {} }
""".parseStmt
  result.add quote do:
    proc drawShape (context: CanvasContext2d, shapesArr: JsonNode) =
      for obj in shapesArr:
        let rawObjFunc = obj["func"].pretty
        let objFunc = rawObjFunc[1..rawObjFunc.len-2]
        case objFunc:
        of "style_color":
          let
            rawColor = obj["color"].pretty
            color = rawColor[1..rawColor.len-2]
          context.fillStyle = color
        of "rect":
          let
            x = obj["x"].pretty.parseFloat
            y = obj["y"].pretty.parseFloat
            width = obj["width"].pretty.parseFloat
            height = obj["height"].pretty.parseFloat
          context.beginPath()
          context.rect(x, y, width, height)
          context.fill()
        of "text":
          let
            rawValue = obj["value"].pretty
            value = rawValue[1..rawValue.len-2]
            x = obj["x"].pretty.parseFloat
            y = obj["y"].pretty.parseFloat
          context.strokeText(value, x, y)
          context.fillText(value, x, y)
        of "triangle":
          let
            v1x = obj["v1x"].pretty.parseFloat
            v1y = obj["v1y"].pretty.parseFloat
            v2x = obj["v2x"].pretty.parseFloat
            v2y = obj["v2y"].pretty.parseFloat
            v3x = obj["v3x"].pretty.parseFloat
            v3y = obj["v3y"].pretty.parseFloat
          context.beginPath()
          context.moveTo(v1x, v1y)
          context.lineTo(v2x, v2y)
          context.lineTo(v3x, v3y)
          context.fill()
        of "circle":
          let
            x = obj["x"].pretty.parseFloat
            y = obj["y"].pretty.parseFloat
            r = obj["r"].pretty.parseFloat
          context.beginPath()
          context.arc(x, y, r, 0, 2 * math.PI)
          context.fill()

    proc draw (context: CanvasContext2d) =
      context.clearRect(0, 0, canvas.width, canvas.height)
      let virtualCanvasObjects = virtualCanvas["virtual_canvas"]
      let shapesObjects = virtualCanvas["shapes"]
      let styleObjects = virtualCanvas["styles"]
      for item in virtualCanvasObjects.pairs:
        if not item.val.hasKey("shape"):
          continue
        let
          rawShapeName = item.val["shape"].pretty
          shapeName = rawShapeName[1..rawShapeName.len-2]
        var
          rawIdName = ""
          rawClassName = ""
          idName = ""
          className = ""
        if item.val.hasKey("id"):
          rawIdName = item.val["id"].pretty
          idName = "#" & rawIdName[1..rawIdName.len-2]
        context.font = "24px Arial"
        context.fillStyle = "#000000"
        context.textAlign = "start"
        let shapeArray = shapesObjects[shapeName]
        let styleArrayById = styleObjects[idName]
        for obj in styleArrayById:
          let
            rawStyle = obj["style"].pretty
            style = rawStyle[1..rawStyle.len-2]
            rawValue = obj["value"].pretty
            value = rawValue[1..rawValue.len-2]
          case style:
          of "color":
            context.fillStyle = value
        drawShape(context, shapeArray)

    window.addEventListener("load",
      proc (event: Event) =
        if document.getElementById(canvasId) == nil:
          let blackvas = document.getElementById("Blackvas")
          canvas = dom.document.createElement("canvas").Canvas
          canvas.id = canvasId
          canvas.height = height
          canvas.width = width
          blackvas.appendChild(canvas)
        else:
          canvas = document.getElementById(canvasId).Canvas
        
        context = canvas.getContext2d()

        when Debug:
          echo pretty virtualCanvas
        draw(context)
        echo "Hello, Blackvas ;)"
    )
  result.add body