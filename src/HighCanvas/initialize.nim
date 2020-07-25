import types

proc initHighCanvas*(w: float, h: float): Canvas =
  result = Canvas(width: w, height: h)