'******************************************************************************************
'
'   raylib [text] example - TTF loading and usage
'
'   This example has been created using raylib 1.3.0 (www.raylib.com)
'   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
'
'   Copyright (c) 2015 Ramon Santamaria (@raysan5)
'
'******************************************************************************************

#include once "../raylib.bi"

#if defined(PLATFORM_DESKTOP)
	#define GLSL_VERSION 330
#else ' PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
	#define GLSL_VERSION 100
#endif

const screenWidth = 800
const screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - SDF fonts")

dim as string msg = "Signed Distance Fields"


' Default font generation from TTF font
dim as Font fontDefault

with fontDefault
	.baseSize = 16
	.charsCount = 95
	'Parameters:
	'	font size: 16
	'	no chars array provided (0)
	'	chars count: 95 (autogenerate chars array)
	.chars = LoadFontData("resources/AnonymousPro-Bold.ttf", 16, 0, 95, FONT_DEFAULT)
	'Parameters:
	'	chars count: 95
	'	font size: 16
	'	chars padding in image: 4 px
	'	pack method: 0 (default)
	dim as Image atlas = GenImageFontAtlas(fontDefault.chars, @fontDefault.recs, 95, 16, 4, 0)
	.texture = LoadTextureFromImage(atlas)
	UnloadImage(atlas)
end with

' SDF font generation from TTF font
dim as Font fontSDF

with fontSDF
	.baseSize = 16
	.charsCount = 95
	'Parameters:
	'	font size: 16
	'	no chars array provided (0)
	'	chars count: 0 (defaults to 95)
	.chars = LoadFontData("resources/AnonymousPro-Bold.ttf", 16, 0, 0, FONT_SDF)
	'Parameters:
	'	chars count: 95
	'	font size: 16
	'	chars padding in image: 0 px
	'	pack method: 1 (Skyline algorythm)
	dim as Image atlas = GenImageFontAtlas(.chars, @.recs, 95, 16, 0, 1)
 	.texture = LoadTextureFromImage(atlas)
	UnloadImage(atlas)
end with

' Load SDF required shader (we use default vertex shader)
dim as Shader shader = LoadShader(0, FormatText("fonts/resources/shaders/glsl%i/sdf.fs", GLSL_VERSION))

' Required for SDF font
SetTextureFilter(fontSDF.texture, FILTER_BILINEAR)

var fontPosition = Vector2(40, screenHeight / 2 - 50), textSize = Vector2(0, 0)

dim as single fontSize = 16

' 0 - fontDefault, 1 - fontSDF
dim as integer currentFont = 0           

SetTargetFPS(60)

while not WindowShouldClose()
	' Update
	fontSize += GetMouseWheelMove() * 8.0!
 
	fontSize = iif(fontSize < 6.0!, 6.0!, fontSize)
	currentFont = iif(IsKeyDown(KEY_SPACE), 1, 0)
 
	if(currentFont = 0) then
	textSize = MeasureTextEx(fontDefault, strPtr(msg), fontSize, 0)
	else
	textSize = MeasureTextEx(fontSDF, strPtr(msg), fontSize, 0)
	end if
 
	fontPosition.x = GetScreenWidth() / 2 - textSize.x / 2
	fontPosition.y = GetScreenHeight() / 2 - textSize.y / 2 + 80
 
	' Render
	BeginDrawing()
 
	ClearBackground(RAYWHITE)
 
	if(currentFont = 1) then
		'NOTE: SDF fonts require a custom SDf shader to compute fragment color
		'Activate SDF font shader
		BeginShaderMode(shader)
		DrawTextEx(fontSDF, strPtr(msg), fontPosition, fontSize, 0, BLACK)
		 
		' Activate our default shader for next drawings
		EndShaderMode()
		 
		DrawTexture(fontSDF.texture, 10, 10, BLACK)
	else
		DrawTextEx(fontDefault, strPtr(msg), fontPosition, fontSize, 0, BLACK)
		DrawTexture(fontDefault.texture, 10, 10, BLACK)
	end if
 
	if(currentFont = 1) then
		DrawText("SDF!", 320, 20, 80, RED)
	else
		DrawText("default font", 315, 40, 30, GRAY)
	end if
 
	DrawText("FONT SIZE: 16.0", GetScreenWidth() - 240, 20, 20, DARKGRAY)
	DrawText(FormatText("RENDER SIZE: %02.02f", fontSize), GetScreenWidth() - 240, 50, 20, DARKGRAY)
	DrawText("Use MOUSE WHEEL to SCALE TEXT!", GetScreenWidth() - 240, 90, 10, DARKGRAY)
	DrawText("HOLD SPACE to USE SDF FONT VERSION!", 340, GetScreenHeight() - 30, 20, MAROON)
 
	EndDrawing()
wend

UnloadFont(fontDefault)
UnloadFont(fontSDF)
UnloadShader(shader)

CloseWindow()
