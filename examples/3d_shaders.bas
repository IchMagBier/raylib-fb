'*******************************************************************************************
'
'   raylib (shaders) example - Raymarching shapes generation
'
'   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
'         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
'
'   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
'         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
'         raylib comes with shaders ready for both versions, check raylib/shaders install folder
'
'   This example has been created using raylib 2.0 (www.raylib.com)
'   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
'
'   Copyright (c) 2018 Ramon Santamaria (@raysan5)
'
'*******************************************************************************************

#include "../raylib.bi"

#if defined(PLATFORM_DESKTOP)
	#define GLSL_VERSION            330
#else   ' PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
	#define GLSL_VERSION            100
#endif

' Initialization
'--------------------------------------------------------------------------------------
var screenWidth = 800
var screenHeight = 450
SetConfigFlags(FLAG_WINDOW_RESIZABLE)
InitWindow(screenWidth, screenHeight, "raylib (shaders) example - raymarching shapes")
dim as Camera camera
camera.position = Vector3(2.5, 2.5, 3)    ' Camera position
camera.target = Vector3(0, 0, 0.7)      ' Camera looking at point
camera.up = Vector3(0, 1, 0)          ' Camera up vector (rotation towards target)
camera.fovy = 65                               ' Camera field-of-view Y
SetCameraMode(camera, CAMERA_FREE)                 ' Set camera mode
' Load raymarching shader
' NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
dim as Shader shader = LoadShader(0, FormatText("resources/shaders/glsl%i/raymarching.fs", GLSL_VERSION))
' Get shader locations for required uniforms
dim as integer viewEyeLoc = GetShaderLocation(shader, "viewEye")
dim as integer viewCenterLoc = GetShaderLocation(shader, "viewCenter")
dim as integer runTimeLoc = GetShaderLocation(shader, "runTime")
dim as integer resolutionLoc = GetShaderLocation(shader, "resolution")
dim as single resolution(2) = {screenWidth, screenHeight}
SetShaderValue(shader, resolutionLoc, @resolution(0), UNIFORM_VEC2)
dim as single runTime = 0
SetTargetFPS(60)                       ' Set our game to run at 60 frames-per-second
'--------------------------------------------------------------------------------------
' Main game loop
while not WindowShouldClose()            ' Detect window close button or ESC key
	' Check if screen is resized
	'----------------------------------------------------------------------------------
	if IsWindowResized() then
		screenWidth = GetScreenWidth()
		screenHeight = GetScreenHeight()
		dim as single resolution(2) = {screenWidth, screenHeight}
		SetShaderValue(shader, resolutionLoc, @resolution(0), UNIFORM_VEC2)
	end if
	' Update
	'----------------------------------------------------------------------------------
	UpdateCamera(@camera)              ' Update camera
	dim as single cameraPos(3) = {camera.position.x, camera.position.y, camera.position.z}
	dim as single cameraTarget(3) = {camera.target.x, camera.target.y, camera.target.z}
	dim as single deltaTime = GetFrameTime()
	runTime += deltaTime
	' Set shader required uniform values
	SetShaderValue(shader, viewEyeLoc, @cameraPos(0), UNIFORM_VEC3)
	SetShaderValue(shader, viewCenterLoc, @cameraTarget(0), UNIFORM_VEC3)
	SetShaderValue(shader, runTimeLoc, @runTime, UNIFORM_FLOAT)
	'----------------------------------------------------------------------------------
	' Draw
	'----------------------------------------------------------------------------------
	BeginDrawing()
		ClearBackground(RAYWHITE)
		' We only draw a white full-screen rectangle,
		' frame is generated in shader using raymarching
		BeginShaderMode(shader)
			DrawRectangle(0, 0, screenWidth, screenHeight, WHITE)
		EndShaderMode()
		DrawText("(c) Raymarching shader by Iñigo Quilez. MIT License.", screenWidth - 280, screenHeight - 20, 10, BLACK)
	EndDrawing()
	'----------------------------------------------------------------------------------
wend
' De-Initialization
'--------------------------------------------------------------------------------------
UnloadShader(shader)           ' Unload shader
CloseWindow()                  ' Close window and OpenGL context
'--------------------------------------------------------------------------------------