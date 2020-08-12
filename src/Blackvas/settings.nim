import macros
import strformat

macro settings*(body: untyped): untyped =
  discard