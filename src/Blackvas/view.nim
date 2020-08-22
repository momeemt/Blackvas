## view.nim
## 
## canvasグラフィックスをDOMに適用するための機能を提供します。

import macros

macro view*(body: untyped): untyped =
  ## DOM要素にグラフィックスを適用します。
  # result = quote do:
  #   import dom
  #   proc onLoad (e: dom.Event) =
  #     let blackvas = document.getElementById("Blackvas")
  #     var canvas = dom.document.createElement("canvas").Canvas
  #     canvas.id = Blackvas.canvasId
  #     canvas.height = Blackvas.height
  #     canvas.width = Blackvas.width
  #     blackvas.appendChild(canvas)
  #     var context = canvas.getContext2d()
  #   window.onload = onLoad
  # echo treeRepr(result)
  result = newStmtList()
  result.add(
    newNimNode(nnkImportStmt).add(
      ident("dom")
    ),
    newNimNode(nnkProcDef).add(
      ident("onLoad"),
      newEmptyNode(),
      newEmptyNode(),
      newNimNode(nnkFormalParams).add(
        newEmptyNode(),
        newNimNode(nnkIdentDefs).add(
          ident("e"),
          newDotExpr(
            ident("dom"),
            ident("Event")
          ),
          newEmptyNode()
        )
      ),
      newEmptyNode(),
      newEmptyNode(),
      newStmtList(
        newNimNode(nnkCommand).add(
          ident("echo"),
          newStrLitNode("Hello, Blackvas :)")
        ),
        newNimNode(nnkVarSection).add(
          newNimNode(nnkIdentDefs).add(
            ident("blackvas"),
            newEmptyNode(),
            newNimNode(nnkCall).add(
              newDotExpr(
                newDotExpr(
                  ident("dom"),
                  ident("document")
                ),
                ident("getElementById")
              ),
              newStrLitNode("Blackvas")
            )
          )
        ),
        newNimNode(nnkVarSection).add(
          newIdentDefs(
            newIdentNode("canvas"),
            newEmptyNode(),
            newDotExpr(
              newCall(
                newDotExpr(
                  newDotExpr(
                    newIdentNode("dom"),
                    newIdentNode("document")
                  ),
                  newIdentNode("createElement")
                ),
                newStrLitNode("canvas")
              ),
              newIdentNode("Canvas")
            )
          )
        ),
        newAssignment(
          newDotExpr(
            ident("canvas"),
            ident("id")
          ),
          newDotExpr(
            ident("Blackvas"),
            ident("canvasId")
          )
        ),
        newAssignment(
          newDotExpr(
            ident("canvas"),
            ident("height")
          ),
          newDotExpr(
            ident("Blackvas"),
            ident("height")
          )
        ),
        newAssignment(
          newDotExpr(
            ident("canvas"),
            ident("width")
          ),
          newDotExpr(
            ident("Blackvas"),
            ident("width")
          )
        ),
        newCall(
          newDotExpr(
            ident("blackvas"),
            ident("appendChild")
          ),
          ident("canvas")
        ),
        newNimNode(nnkVarSection).add(
          newIdentDefs(
            newIdentNode("context"),
            newEmptyNode(),
            newCall(
              newDotExpr(
                newIdentNode("canvas"),
                newIdentNode("getContext2d")
              )
            )
          )
        ),
        copyNimTree(body)
      )
    )
  )
  result.add(
    newStmtList(
      newAssignment(
        newDotExpr(
          ident("window"),
          ident("onload")
        ),
        ident("onLoad")
      )
    )
  )