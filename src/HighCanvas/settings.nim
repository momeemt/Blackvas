import macros
import strformat

macro settings*(head, body: untyped): untyped =
  discard