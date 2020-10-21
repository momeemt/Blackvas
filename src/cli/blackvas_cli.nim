import createModule

when isMainModule:
  import cligen
  dispatchMulti(
    [createModule.create]
  )