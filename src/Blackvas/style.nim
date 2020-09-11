## style.nim
## 
## canvasグラフィックスのスタイルを提供します。

import macros

macro style*(body: untyped): untyped =
  ## style文は、定義したStyleをパースし仮想Canvasに書き込みます。
  result = """
import tables, json
var blackvasStyleMap = initTable[string, initTable[string, string]()]()
""".parseStmt
  for sentence in body:
    sentence.expectKind(nnkCommand)
    let cmdPrefix = repr sentence[0]
    var name = repr sentence[1]

    if cmdPrefix == "class":
      name = "." & name
    elif cmdPrefix == "id":
      name = "#" & name
    elif cmdPrefix == "shape":
      discard

    result.add quote do:
      virtualCanvas["styles"].add(`name`, %* [])

    for node in sentence[2]:
      let
        styleName = repr node[0]
        styleValue = node[1]
      if styleValue.len == 2:
        # Primary.color 形式
        result.add nnkStmtList.newTree(
          nnkCall.newTree(
            nnkDotExpr.newTree(
              nnkBracketExpr.newTree(
                nnkBracketExpr.newTree(
                  newIdentNode("virtualCanvas"),
                  newLit("styles")
                ),
                newStrLitNode(name)
              ),
              newIdentNode("add")
            ),
            nnkPrefix.newTree(
              newIdentNode("%*"),
              nnkTableConstr.newTree(
                nnkExprColonExpr.newTree(
                  newLit("style"),
                  newStrLitNode(styleName)
                ),
                nnkExprColonExpr.newTree(
                  newLit("value"),
                  newNimNode(nnkPrefix).add(
                    ident("$"),
                    newDotExpr(
                      ident($styleValue[0]),
                      ident($styleValue[1])
                    )
                  )
                )
              )
            )
          )
        )
        # result.add quote do:
        #   var styleJson = %* { "style": `styleName`, "color": styleValueStr }
        #   virtualCanvas["styles"].add(`name`, styleJson)
      else:
        result.add quote do:
          let styleValueStr = repr `styleValue`
          var styleJson = %* { "style": `styleName`, "value": styleValueStr }
          virtualCanvas["styles"][`name`].add(styleJson)
