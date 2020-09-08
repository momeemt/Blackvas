include Blackvas/[settings, view, methods, canvas, data, color, style, shapes]

macro Blackvas*(body: untyped): untyped =
  result = quote do:
    import dom, json, macros
    # canvasの描画情報
    # Forward declaration
    # ここで viewなどが吐き出す関数のforward宣言を先にしておく
    # proc drawCanvasProc ()
    # End
  result = """
import dom, json, macros, strutils, math
var virtualCanvas = %* { "virtual_canvas": [], "events": [] }
proc hogehoge () = echo "hoge"
macro invoke(name, canvas, event: typed): untyped =
  result = nnkStmtList.newTree(
    nnkCall.newTree(
      newIdentNode(name.strVal),
      canvas,
      event
    )
  )
  # result = quote do:
  #   echo repr `canvas`
  #   echo repr `event`
  #   # `name`(`canvas`, `event`)
  #   hogehoge(10)
""".parseStmt
  result.add body
  result.add quote do:
    proc draw (context: CanvasContext2d) =
      let virtualCanvasArray = virtualCanvas["virtual_canvas"]
      for obj in virtualCanvasArray:
        let rawObjFunc = obj["func"].pretty
        let objFunc = rawObjFunc[1..rawObjFunc.len-2]
        case objFunc:
        of "style_reset":
          context.font = "24px Arial"
          context.fillStyle = "#000000"
          context.textAlign = "start"
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
    window.addEventListener("load",
      proc (event: Event) =
        let blackvas = document.getElementById("Blackvas")
        var canvas = dom.document.createElement("canvas").Canvas
        canvas.id = "myCanvas"
        canvas.height = 1000
        canvas.width = 1000
        blackvas.appendChild(canvas)
        var context = canvas.getContext2d()

        let eventsArray = virtualCanvas["events"]
        for obj in eventsArray:
          let
            rawEventType = obj["event"].pretty
            eventType = rawEventType[1..rawEventType.len-2]
            rawProcName = obj["proc"].pretty
            procName = rawProcName[1..rawProcName.len-2]
          echo eventType, " ", procName
          case eventType:
          of "click":
            canvas.addEventListener("click", 
              proc (event: Event) =
                invoke(procName, canvas, event)
            )
        echo "Hello, Blackvas ;)"
        draw(context)
    )
    window.addEventListener("click",
      proc (event: Event) =
        let canvas = document.getElementById("myCanvas").Canvas
        var context = canvas.getContext2d()
        echo "update!"
        var textJson = %* { "func": "text", "value": "updated!", "x": 300.0, "y": 300.0 }
        virtualCanvas["virtual_canvas"].add(textJson)
        draw(context)
    )