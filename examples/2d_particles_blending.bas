'*******************************************************************************************
'
'   raylib example - particles blending
'
'   This example has been created using raylib 1.7 (www.raylib.com)
'   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
'
'   Copyright (c) 2017 Ramon Santamaria (@raysan5)
'
'*******************************************************************************************

#include once "../raylib.bi"

#define MAX_PARTICLES 200

' Particle structure with basic data
type Particle
	as Vector2 position
	as Color color
	as single alpha, size, rotation
	as boolean active
end type

const screenWidth = 800
const screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - particles blending")

' Particles pool, reuse them!
dim as Particle mouseTail(0 to MAX_PARTICLES - 1)

' Initialize particles
for i as integer = 0 to MAX_PARTICLES - 1
	with mouseTail(i)
		.position = Vector2(0, 0)
		.color = Color(GetRandomValue(0, 255), GetRandomValue(0, 255), GetRandomValue(0, 255), 255)
		.alpha = 1.0!
		.size = GetRandomValue(1, 30) / 20.0!
		.rotation = GetRandomValue(0, 360)
		.active = false
	end with
next

dim as single gravity = 3.0!

dim as Texture2D smoke = LoadTexture("resources/smoke.png")

dim as long blending = BLEND_ALPHA

SetTargetFPS(60)

do while(not WindowShouldClose())
	'Activate one particle every frame and Update active particles.
	'NOTE: Particles initial position should be mouse position when activated
	'NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
	'NOTE: When a particle disappears, active = false and it can be reused.
	for i as integer = 0 to MAX_PARTICLES - 1
		with mouseTail(i)
			if(not .active) then
				.active = true
				.alpha = 1.0!
				.position = GetMousePosition()
			 
				exit for
			end if
		end with
	next
 
	for i as integer = 0 to MAX_PARTICLES - 1
		with mouseTail(i)
			if(.active) then
				.position.y += gravity
				.alpha -= 0.01!
			 
				if(.alpha <= 0.0!) then .active = false
			 
				.rotation += 5.0!
			end if
		end with
	next
 
	if(IsKeyPressed(KEY_SPACE)) then blending = iif(blending = BLEND_ALPHA, BLEND_ADDITIVE, BLEND_ALPHA)
 
	' Render
	BeginDrawing()
	ClearBackground(DARKGRAY)
 
	BeginBlendMode(blending)
 
	' Draw active particles
	for i as integer = 0 to MAX_PARTICLES - 1
	 
		with mouseTail(i)
			if(.active) then
				DrawTexturePro(smoke, _
					Rectangle(0, 0, smoke.width, smoke.height), _
					Rectangle(.position.x, .position.y, smoke.width * .size, smoke.height * .size), _
					Vector2(smoke.width * .size / 2, smoke.height * .size / 2), _
					.rotation, Fade(.color, .alpha))
			end if
		end with
	next
 
	EndBlendMode()
 
	DrawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, BLACK)
 
	if(blending = BLEND_ALPHA) then
		DrawText("ALPHA BLENDING", 290, screenHeight - 40, 20, BLACK)
	else
		DrawText("ADDITIVE BLENDING", 280, screenHeight - 40, 20, RAYWHITE)
	end if

	EndDrawing()
loop

UnloadTexture(smoke)

CloseWindow()
