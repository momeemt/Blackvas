# Blackvas ([EN](/README.md) / Ja)
![](blackvas.png)  

**Blackvas**はCanvas (HTML5 APIの一つ) を構築するための宣言的UIフレームワークです。  
従来のJavaScriptで書かれたCanvas実装から**冗長さ**や**手続き的命令**を排除し、さらにイベントやアニメーションにおける便利なプロシージャを提供します。  
スタイリングはCSSのプロパティを参考に実装しており、原色や和色などをカラーコードを利用しないで呼び出すことができます。  
JavaScript DOMの知識はなるべく必要ないように設計しており、学習コストを軽減しています。  
付属する **Blackvas CLI** を利用することで **Nimble** などNim固有の知識がなくてもすぐにプロジェクトを開始できます。  

## Shape
**Shape** は図形やテキストなどのオブジェクトを一つの形として扱うための仕組みです。  

```nim
shapes:
  shape MyShape:
    rect(100, 100, 40, 40)
```

**shapes**はshapeで定義した図形を扱うための処理を行うため、必ず**shape文はshapes文の中で使わなければいけません**。  
**MyShape**はこのshapeの名前として扱われます。  
shape文は単なる形の定義するための文であり、**Webページに反映することはできません**。

## View
**View** は定義したShapeをHTMLページに反映するための仕組みです。  

```nim
view:
  MyShape()
```

shape文で定義したのち、プロシージャのように呼び出すことでページに反映することができます。  

## Style
**Style** はスタイル要素を定義するための仕組みです。

```nim
style:
  id myId:
    color = Primary.red
```

**id**は、viewに描画するshape１つにつき１つ割り当てられます。  

```nim
view:
  MyShape:
    id = "myId"
```

idは、viewでshapeを適用する時に与えることができます。

## Data
**Data** は変数を定義するための仕組みですが、現在はスコープなど特別な機能は実装しておらず、グローバルに公開されます。

## Methods
**Methods** はプロシージャを定義するための仕組みです。  
ここでは、クリックイベントによってidを変更することを示します。  

```nim
methods:
  proc changeId(): (string, string) =
    if rand(1) >= 0.5:
      result = ("id", "id1")
    else:
      result = ("id", "id2")

view:
  MyShape:
    @click = changeId
```