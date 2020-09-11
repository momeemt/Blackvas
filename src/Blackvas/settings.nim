## settings.nim
## 
## Blackvasの設定事項を読み込み、パースします。

import macros

var
  canvasId* = "MyCanvas"
  height*: float = 1000
  width*: float = 1000

macro settings*(body: untyped): untyped =
  result = newStmtList()
  for i in body:
    let identNode = i[0]
    if (identNode == newIdentNode("width")):
      result.add(
        newAssignment(
          newDotExpr(
            newIdentNode("Blackvas"),
            newIdentNode("width")
          ),
          i[1]
        )
      )
    elif (identNode == newIdentNode("height")):
      result.add(
        newAssignment(
          newDotExpr(
            newIdentNode("Blackvas"),
            newIdentNode("height")
          ),
          i[1]
        )
      )
    elif (identNode == newIdentNode("id")):
      result.add(
        newAssignment(
          newDotExpr(
            newIdentNode("Blackvas"),
            newIdentNode("canvasId")
          ),
          i[1]
        )
      )