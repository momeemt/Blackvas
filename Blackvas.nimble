# Package

version       = "0.2.1"
author        = "Momeemt"
description   = "declarative UI framework for building Canvas"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["cli"]
bin           = @["cli/blackvas_cli"]
binDir        = "src/bin"
installExt    = @["nim"]
backend       = "c"

# Dependencies

requires "nim >= 1.2.6"
requires "cligen >= 1.2.0"