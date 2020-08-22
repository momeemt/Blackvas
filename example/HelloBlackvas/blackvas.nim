import ../../src/Blackvas

shapes:
  shape MyShape:
    rect(100, 100, 40, 20)
    rect(200, 100, 40, 20)
    rect(100, 230, 20, 20)
    rect(120, 250, 100, 20)
    rect(220, 230, 20, 20)

style:
  @id1 {
    color: PrimaryColor.blue
  }

view:
  MyShape:
    @id = id1