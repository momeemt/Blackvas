import macros
import strformat

macro events*(head, body: untyped): untyped =
  discard