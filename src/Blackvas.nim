#[
  contextを定義
  viewよりcanvasを描画
  updateで呼ぶ
]#






include Blackvas/[settings, view, methods, canvas, data, color, style, shapes]

macro Blackvas*(body: untyped): untyped =
  result = quote do:
    import dom
    # Forward declaration
    # ここで viewなどが吐き出す関数のforward宣言を先にしておく
    proc drawCanvasProc ()
    # End
    window.addEventListener("load",
      proc (event: Event) =
        echo "Hello, Blackvas ;)"
        drawCanvasProc()
    )
  result.add body