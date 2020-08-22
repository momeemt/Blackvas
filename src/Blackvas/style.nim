import macros

macro style*(body: untyped): untyped =
  result = newStmtList()
  result.add newNimNode(nnkImportStmt).add(
    ident("tables")
  )
  result.add newNimNode(nnkVarSection).add(
    newIdentDefs(
      ident("blackvasStyleMap"),
      newEmptyNode(),
      newCall(
        newNimNode(nnkBracketExpr).add(
          ident("initTable"),
          ident("string"),
          newCall(
            newNimNode(nnkBracketExpr).add(
              ident("initTable"),
              ident("string"),
              ident("string")
            )
          )
        )
      )
    )
  )
  for i in body:
    if (kind(i) != nnkCommand):
      error("To specify an id, prefix it with @. Also, if you specify a shape, make sure to call the correct name of the shape.")
    var identifykey = ""
      # idかshapeを格納
    if kind(i[0]) == nnkPrefix:
      identifykey = "@" & $i[0][1]
      # ここでstyleを連想配列で持つ
      # そのあと view で連想配列から読み込む
    elif kind(i[0]) == nnkIdent:
      identifykey = $i[0]
    for j in i[1]:
      if (kind(j) != nnkExprColonExpr):
        error("Attributes and values must be separated by colons.")
      let rightExpr: NimNode = 
        if kind(j[1]) == nnkStrLit:
          newStrLitNode($j[1])
        else:
          # PrimaryColor.red 形式
          newNimNode(nnkPrefix).add(
            ident("$"),
            newDotExpr(
              ident($j[1][0]),
              ident($j[1][1])
            )
          )
      result.add(
        newNimNode(nnkIfStmt).add(
          newNimNode(nnkElifBranch).add(
            newNimNode(nnkPrefix).add(
              ident("not"),
              newCall(
                newDotExpr(
                  ident("blackvasStyleMap"),
                  ident("hasKey")
                ),
                newStrLitNode(identifykey)
              )
            ),
            newStmtList(
              newAssignment(
                newNimNode(nnkBracketExpr).add(
                  ident("blackvasStyleMap"),
                  newStrLitNode(identifykey)
                ),
                newCall(
                  newNimNode(nnkBracketExpr).add(
                    ident("initTable"),
                    ident("string"),
                    ident("string")
                  )
                )
              )
            )
          )
        )
      )
      result.add(
        newAssignment(
          newNimNode(nnkBracketExpr).add(
            newNimNode(nnkBracketExpr).add(
              ident("blackvasStyleMap"),
              newStrLitNode(identifykey)
            ),
            newStrLitNode($j[0])
          ),
          rightExpr
        )
      )
  # echo treeRepr(result)
