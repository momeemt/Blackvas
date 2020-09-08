## view.nim
## 
## canvasグラフィックスをDOMに適用するための機能を提供します。
## 
## shapeで仮想DOMに出力する？
## viewでも仮想DOMに出力する
## updateで ことあるごとに redraw する？

import macros

proc getDrawCanvasProc(body: NimNode): NimNode

macro update*(body: untyped): untyped =
  # result = quote do:
  #   # context.clearRect(0, 0, canvas.width, canvas.height)
  result = getDrawCanvasProc(body)
  result.add quote do:
    echo "?"
    drawCanvasProc()

macro view*(body: untyped): untyped =
  # result = getDrawCanvasProc(body)
  result = body
  # result.add quote do:
  #   window.onload = drawCanvasProc

proc getDrawCanvasProc(body: NimNode): NimNode =
  ## DOM要素にグラフィックスを適用します。
  result = quote do:
    proc insertViewBody(canvas: Canvas, context: CanvasContext2d) {.importc.}
    proc drawCanvasProc () =
      let blackvas = document.getElementById("Blackvas")
      var canvas = dom.document.createElement("canvas").Canvas
      canvas.id = Blackvas.canvasId
      canvas.height = Blackvas.height
      canvas.width = Blackvas.width
      blackvas.appendChild(canvas)
      var context = canvas.getContext2d()
      insertViewBody(canvas, context)

  ## 以下のASTツリーは次のようなコードを展開する。
  ## proc insertViewBody (canvas: Canvas, context: CanvasContext2d) {.exportc.} =
  ##   { body } ## bodyは getDrawCanvasProc で受け取る body
  ## shapesマクロで定義された描画情報をもとに描画する関数 insertViewBody を返す
  result.add nnkStmtList.newTree(
    nnkProcDef.newTree(
      newIdentNode("insertViewBody"),
      newEmptyNode(),
      newEmptyNode(),
      nnkFormalParams.newTree(
        newEmptyNode(),
        nnkIdentDefs.newTree(
          newIdentNode("canvas"),
          newIdentNode("Canvas"),
          newEmptyNode()
        ),
        nnkIdentDefs.newTree(
          newIdentNode("context"),
          newIdentNode("CanvasContext2d"),
          newEmptyNode()
        )
      ),
      nnkPragma.newTree(
        newIdentNode("exportc")
      ),
      newEmptyNode(),
      nnkStmtList.newTree(
        copyNimTree(body)
      )
    )
  )
