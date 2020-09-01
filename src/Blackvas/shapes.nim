import macros, strformat, math

macro shapes*(body: untyped): untyped =
  result = body

proc getUserShapeProc (name, body: NimNode): string =
  var nodeStr = ""
  for i in body:
    nodeStr &= fmt"{repr(i)}" & "\n"
  result = nodeStr

proc getAddEventListenerLambda (eventName: string, procContent: NimNode): NimNode =
  result = newCall(
    newDotExpr(
      ident("canvas"),
      ident("addEventListener")
    ),
    newStrLitNode(eventName),
    newNimNode(nnkLambda).add(
      newEmptyNode(),
      newEmptyNode(),
      newEmptyNode(),
      newNimNode(nnkFormalParams).add(
        newEmptyNode(),
        newIdentDefs(
          ident("event"),
          ident("Event"),
          newEmptyNode()
        )
      ),
      newEmptyNode(),
      newEmptyNode(),
      newStmtList(
        copyNimTree(procContent)
      )
    )
  )

proc getUserShapeMacro (macroName, body: NimNode): NimNode =
  macroName.expectKind(nnkIdent)
  let shapeStructure = getUserShapeProc(macroName, body)
  # shapeで利用するcontext名
  let contextName = $macroName & "_context"

  result = quote do:
    import macros
    macro `macroName`*(body: untyped): untyped =
      result = newStmtList(
        newNimNode(nnkVarSection, (
          newIdentDefs(
            newStrLitNode(`contextName`),
            newEmptyNode(),
            newCall(
              newDotExpr(
                ident("canvas"),
                ident("getContext2d")
              )
            )
          )
        ))
      )
      dumpTree:
        `contextName`.fillStyle = value
      for i in body:
        if i.len == 2:
          if $(i[0][0]) == "@":
            let eventType = $(i[0][1])
            let callProc = $(i[1])
            case eventType:
              of "id":
                result.add quote("@@") do:
                  block scope:
                    let idKey = "@" & @@callProc
                    if blackvasStyleMap.hasKey(idKey):
                      for key, value in blackvasStyleMap[idKey]:
                        case key:
                        of "color":
                          ident(`contextName`).fillStyle = value
                        of "font":
                          `contextName`.font = value
                        of "textAlign":
                          `contextName`.textAlign = value
      result.add newNimNode(nnkBlockStmt).add(
        ident("shapeScope"),
        newStmtList(
          `shapeStructure`.parseStmt
        )
      )
      result.add quote do:
        echo "shape output"
      for i in body:
        if i.len == 2:
          if $(i[0][0]) == "@":
            let eventType = $(i[0][1])
            let callProc = $(i[1])
            case eventType:
            of "click":
              result.add getAddEventListenerLambda("click") do:
                newCall( callProc )
            of "mousedown":
              result.add getAddEventListenerLambda("mousedown") do:
                newCall ( callProc )
            of "mouseup":
              result.add getAddEventListenerLambda("mouseup") do:
                newCall ( callProc )
            of "focus":
              result.add getAddEventListenerLambda("focus") do:
                newCall ( callProc )

# ユーザー定義shapeを呼び出すためのmacroとprocを返すmacro
macro shape*(head: untyped, body: untyped): untyped =
  result = newStmtList()
  result.add(getUserShapeMacro(head, body))

macro text* (head: untyped): untyped =
  let textStr = $head[0]
  let x = intVal(head[1]).float
  let y = intVal(head[2]).float
  result = quote do:
    context.strokeText(`textStr`, `x`, `y`)
    context.fillText(`textStr`, `x`, `y`)

macro rect* (x, y, width, height: untyped): untyped =
  result = quote do:
    context.rect(`x`.float, `y`.float, `width`.float, `height`.float)
    context.fill()

macro triangle* (v1x, v1y, v2x, v2y, v3x, v3y: untyped): untyped =
  result = quote do:
    context.beginPath()
    context.moveTo(`v1x`.float, `v1y`.float)
    context.lineTo(`v2x`.float, `v2y`.float)
    context.lineTo(`v3x`.float, `v3y`.float)
    context.closePath()
    context.fill()

macro circle* (x, y, r: untyped): untyped =
  result = quote do:
    context.beginPath()
    context.arc(`x`.float, `y`.float, `r`.float, 0, 2 * math.PI)
    context.fill()
