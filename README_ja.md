# Blackvas
BlackvasはHTML5 APIの一つであるCanvasAPIを、宣言的に扱えるように実装したライブラリです。
従来のようにJavaScriptから命令的に実装していた冗長なコードを、よりスッキリと見やすいコードに整えることができます。
また、CanvasのスタイルはCSSを作成して読み込むことで適応できるので、JavaScript DOMの知識は一切不要で、学習コストを軽減します。
Blackvasを扱うのに必要なのは、`initialize`、`view`、`exportShapes`の3つの概念のみです。

## initialize
Canvasグラフィックを開始するには、まず`init`マクロを利用して構成要素の初期化を行います。

### data

### shapes
`shapes`マクロを利用して、Canvasグラフィックの小さな構成を定義することができます。

### methods

### animations

## view
initializeで構築したCanvasグラフィックをDOM要素に適応します。

## exportShapes
initializeで構築したCanvasグラフィックを外部ファイル向けに出力します。`exportShapes`マクロを`view`マクロと共存させることはできません。