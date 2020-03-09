#include once "../raylib.bi"

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