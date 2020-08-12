import macros, strformat

# 単なる区切りmacro
macro shapes*(body: untyped): untyped =
  result = body

proc getUserShapeProc (name, body: NimNode): string =
  # ここでオブジェクトを生成
  # body のオブジェクト定義を展開する
  var nodeStr = ""
  for i in body:
    nodeStr &= fmt"{repr(i)}" & "\n"
  result = nodeStr

proc getUserShapeMacro (name, body: NimNode): NimNode =
  # TODO:
  # macro {repr(name)}(head, body: untyped) を定義する
  # 引数を実装する
  result = fmt"""
import macros
macro {repr(name)}(body: untyped): untyped =
  if body.len == 0:
    echo "empty"
  result = {repr getUserShapeProc(name, body)}.parseStmt
  for i in body:
    if i.len == 2:
      if $(i[0][0]) == "@":
        # イベント発火定義
        let eventType = $(i[0][1])
        let callProc = $(i[1])
        case eventType:
          of "click":
            # クリックイベント
            # 事前に method に定義してある関数を呼ぶ
            # echo "ClickEvent: " & callProc & " !!"
            result.add(
              newCall(
                newDotExpr(
                  newIdentNode("canvas"),
                  newIdentNode("addEventListener")
                ),
                newStrLitNode("click"),
                newNimNode(nnkDo).add(
                  newEmptyNode(),
                  newEmptyNode(),
                  newEmptyNode(),
                  newNimNode(nnkFormalParams).add(
                    newEmptyNode(),
                    newIdentDefs(
                      newIdentNode("e"),
                      newIdentNode("Event"),
                      newEmptyNode()
                    )
                  ),
                  newEmptyNode(),
                  newEmptyNode(),
                  newStmtList(
                    newCall(
                      newIdentNode("foo")
                    )
                  )
                )
              )
            )
          of "mousedown":
            echo "MouseDownEvent: " & callProc & " !!"
            # マウスダウン
          of "mouseup":
            echo "MouseUpEvent: " & callProc & " !!"
            # マウスアップ
          of "focus":
            echo "FocusEvent: " & callProc & " !!"
            # フォーカス
""".parseStmt

# ユーザー定義shapeを呼び出すためのmacroとprocを返すmacro
macro shape*(head: untyped, body: untyped): untyped =
  result = newStmtList()
  # result.add(getUserShapeProc(head, body))
  result.add(getUserShapeMacro(head, body))

macro text* (head: untyped): untyped =
  # context: CanvasContext2d, textStr: cstring, x: float, y: float
  let textStr = $head[0]
  let x = intVal(head[1]).float
  let y = intVal(head[2]).float
  result = fmt"""
context.font = "30px Arial"
context.strokeText("{textStr}", {x}, {y})
context.fillText("{textStr}", {x}, {y})
""".parseStmt

macro rect* (head: untyped): untyped =
  let x = intVal(head[0]).float
  let y = intVal(head[1]).float
  let width = intVal(head[2]).float
  let height = intVal(head[3]).float
  result = fmt"""
context.rect({x}, {y}, {width}, {height})
context.fill()
""".parseStmt