## methods.nim
## 
## 定義したプロシージャをグローバルに公開します。

import macros

macro methods*(body: untyped): untyped =
  result = body