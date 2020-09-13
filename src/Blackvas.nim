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
    proc removeDoubleQuotation(str: string): string =
      result = str[1..str.len-2]
    proc drawShape (context: CanvasContext2d, shapesArr: JsonNode, baseX: float, baseY: float) =
      for obj in shapesArr:
        let rawObjFunc = obj["func"].pretty
        let objFunc = rawObjFunc[1..rawObjFunc.len-2]
        case objFunc:
        of "style_color":
          let color = removeDoubleQuotation(obj["color"].pretty)
          context.fillStyle = color
        of "rect":
          let
            x = obj["x"].pretty.parseFloat + baseX
            y = obj["y"].pretty.parseFloat + baseY
            width = obj["width"].pretty.parseFloat
            height = obj["height"].pretty.parseFloat
          context.beginPath()
          context.rect(x, y, width, height)
          context.fill()
        of "text":
          let
            value = removeDoubleQuotation(obj["value"].pretty)
            x = obj["x"].pretty.parseFloat + baseX
            y = obj["y"].pretty.parseFloat + baseY
          context.strokeText(value, x, y)
          context.fillText(value, x, y)
        of "triangle":
          let
            v1x = obj["x1"].pretty.parseFloat + baseX
            v1y = obj["y1"].pretty.parseFloat + baseY
            v2x = obj["x2"].pretty.parseFloat + baseX
            v2y = obj["y2"].pretty.parseFloat + baseY
            v3x = obj["x3"].pretty.parseFloat + baseX
            v3y = obj["y3"].pretty.parseFloat + baseY
          context.beginPath()
          context.moveTo(v1x, v1y)
          context.lineTo(v2x, v2y)
          context.lineTo(v3x, v3y)
          context.fill()
        of "circle":
          let
            x = obj["x"].pretty.parseFloat + baseX
            y = obj["y"].pretty.parseFloat + baseY
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
        let shapeName = removeDoubleQuotation(item.val["shape"].pretty)
        var
          idName = ""
          className = ""
          baseX = 0.0
          baseY = 0.0
        if item.val.hasKey("id"):
          idName = "#" & removeDoubleQuotation(item.val["id"].pretty)
        if item.val.hasKey("class"):
          className = "." & removeDoubleQuotation(item.val["class"].pretty)
        if item.val.hasKey("x"):
          baseX = item.val["x"].getFloat.float
        if item.val.hasKey("y"):
          baseY = item.val["y"].getFloat.float
        context.font = "24px Arial"
        context.fillStyle = "#000000"
        context.textAlign = "start"
        let shapeArray = shapesObjects[shapeName]
        let styleArrayById = styleObjects[idName]
        for obj in styleArrayById:
          let
            style = removeDoubleQuotation(obj["style"].pretty)
            value = removeDoubleQuotation(obj["value"].pretty)
          case style:
          of "color":
            context.fillStyle = value
        drawShape(context, shapeArray, baseX, baseY)

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