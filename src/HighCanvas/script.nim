# script macroは宣言を区切るためだけに存在し、機能を持たない (2020/08開発時現在)

macro script* (body: untyped): untyped =
  result = body