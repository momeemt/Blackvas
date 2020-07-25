import macros
import strformat

proc newShapeDef(shapeNameIdent: NimNode): NimNode =
  result = quote:
    proc `shapeNameIdent`() =
      discard

macro shapes*(): untyped =
  discard

macro shape*(head: untyped, body: untyped): untyped =
  for indexI, i in head:
    if i.len() > 1:
        for indexJ, j in i:
          if j.len() > 1:
            for indexK, k in j:
              echo fmt"head[{repr(indexI)}][{repr(indexJ)}][{repr(indexK)}]={repr(k)}"
          else:
            echo fmt"head[{repr(indexI)}][{repr(indexJ)}]={repr(j)}"
    else:
      echo fmt"head[{repr(indexI)}]={repr(i)}"

  for indexI, i in body:
    if i.len() > 1:
        for indexJ, j in i:
          if j.len() > 1:
            for indexK, k in j:
              echo fmt"body[{repr(indexI)}][{repr(indexJ)}][{repr(indexK)}]={repr(k)}"
          else:
            echo fmt"body[{repr(indexI)}][{repr(indexJ)}]={repr(j)}"
    else:
      echo fmt"body[{repr(indexI)}]={repr(i)}"
  echo "\n"


#[
  settings:
    discard

  shapes:
    shape helloCanvas:
      font "38pt Arial"
      fillStyle "coornflowerblue"
      strokeStyle "blue"
      text "Hello Canvas"
      position (width / 2 - 150, height / 2 + 15)
    
    shape hey:
      text "hey"

  events:
    discard

  view:
    hey
]#