import macros
import strformat

macro events*(body: untyped): untyped =
  discard