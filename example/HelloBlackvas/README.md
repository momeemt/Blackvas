# example/HelloBlackvas

Hi! Let's get started with Blackvas.

## shapes

```nim
shapes:
  shape MyShape:
    rect(100, 100, 40, 20)
    rect(200, 100, 40, 20)
    rect(100, 230, 20, 20)
    rect(120, 250, 100, 20)
    rect(220, 230, 20, 20)
```

You can define a new **shape** in the shapes macro with the shape macro.

This code treats a shape containing 5 squares as a single **shape**.

## style

```nim
style:
  @id1 {
    color: PrimaryColor.blue
  }
```

In the style macro, you can define styles just like CSS. In this case, we'll draw all shapes with an ID of "id1" in blue.

## view

```nim
view:
  MyShape:
    @id = id1
```

Only the shape you call in the view macro will be drawn on the screen. In this case, a MyShape with an ID of "id1" is drawn on the screen. By the way, the shapes are drawn in order from the top, so the bottom shape is displayed at the top of the screen.