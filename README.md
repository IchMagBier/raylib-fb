# raylib-fb v3.0

FreeBasic bindings for [raylib](https://www.raylib.com/).

## Example

``` bmax
#include "raylib.bi"

const screenWidth = 800
const screenHeight = 450
InitWindow(screenWidth, screenHeight, "Hello World")
SetTargetFPS(60)
while not WindowShouldClose()
	BeginDrawing()
		ClearBackground(RAYWHITE)
		DrawText("Hello World from raylib and FB!", 230, 200, 20, GRAY)
	EndDrawing()
wend
CloseWindow()
```

![Bild](https://github.com/IchMagBier/raylib-fb/blob/master/hello-world.png)