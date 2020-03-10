'*******************************************************************************************
'
'   raylib [textures] example - Bunnymark
'
'   This example has been created using raylib 1.6 (www.raylib.com)
'   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
'
'   Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
'
'*******************************************************************************************
#include once "../raylib.bi"

#define MAX_BUNNIES 50000

' This is the maximum amount of elements (quads) per batch
' NOTE: This value is defined in [rlgl] module and can be changed there

#define MAX_BATCH_ELEMENTS  8192

type Bunny
	as Vector2 position, speed
	as Color color
end type

const screenWidth = 800
const screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark")

dim as Texture2D texBunny = LoadTexture("resources/wabbit_alpha.png")

dim as Bunny ptr bunnies = allocate(MAX_BUNNIES * sizeOf(Bunny))

dim as integer bunniesCount = 0

SetTargetFPS(60)

while not WindowShouldClose()
	if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then
		' Create more bunnies
		for i as integer = 1 to 100
			if(bunniesCount < MAX_BUNNIES) then
				with bunnies[ bunniesCount ]
					.position = GetMousePosition()
					.speed.x = GetRandomValue(-250, 250) / 60.0!
					.speed.y = GetRandomValue(-250, 250) / 60.0!
					.color = Color(GetRandomValue(50, 240), GetRandomValue(80, 240), GetRandomValue(100, 240), 255)
				end with
				bunniesCount += 1
			end if
		next
	end if

	' Update bunnies
	for i as integer = 0 to bunniesCount - 1
		with bunnies[ i ]
			.position.x += .speed.x
			.position.y += .speed.y
			if(_
				((.position.x + texBunny.width / 2) > GetScreenWidth()) orElse _
				((.position.x + texBunny.width / 2) < 0)) then
				.speed.x *= -1
			end if
		 
			if(_
				((.position.y + texBunny.height / 2) > GetScreenHeight()) orElse _
				((.position.y + texBunny.height / 2 - 40) < 0)) then	 
				.speed.y *= -1
			end if
		end with
	next
 
	' Render
	BeginDrawing()
	ClearBackground(RAYWHITE)
 
	for i as integer = 0 to bunniesCount - 1
		' NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
		' a draw call is launched and buffer starts being filled again;
		' before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
		' Process of sending data is costly and it could happen that GPU data has not been completely
		' processed for drawing while new data is tried to be sent (updating current in-use buffers)
		' it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
		with bunnies[i]
			DrawTexture(texBunny, .position.x, .position.y, .color)
		end with
	next

	DrawRectangle(0, 0, screenWidth, 40, BLACK)
	DrawText(FormatText("bunnies: %i", bunniesCount), 120, 10, 20, GREEN)
	DrawText(_
		FormatText("batched draw calls: %i", _
		1 + bunniesCount / MAX_BATCH_ELEMENTS), _
		320, 10, 20, MAROON)
 
	DrawFPS(10, 10)
 
	EndDrawing()
wend

deallocate(bunnies)

UnloadTexture(texBunny)
CloseWindow()
