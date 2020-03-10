'*******************************************************************************************
'
'   raylib [models] example - Models loading
'
'   raylib supports multiple models file formats:
'
'     - OBJ > Text file, must include vertex position-texcoords-normals information,
'             if files references some .mtl materials file, it will be loaded (or try to)
'     - GLTF > Modern text/binary file format, includes lot of information and it could
'              also reference external files, raylib will try loading mesh and materials data
'     - IQM > Binary file format including mesh vertex data but also animation data,
'             raylib can load .iqm animations. 
'
'   This example has been created using raylib 2.6 (www.raylib.com)
'   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
'
'   Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
'
'*******************************************************************************************
#include once "../raylib.bi"

const screenWidth = 800
const screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - models loading")

' Define the camera to look into our 3d world
dim as Camera camera

with camera
	.position = Vector3(50, 50, 50)
	.target = Vector3(0, 10, 0)
	.up = Vector3(0, 1, 0)
	.fovy = 45
	.type = CAMERA_PERSPECTIVE
end with

const as string resPath = "resources/"

dim as Model model = LoadModel(resPath + "models/castle.obj")
dim as Texture2D texture = LoadTexture(resPath + "models/castle_diffuse.png")

model.materials[0].maps[MAP_DIFFUSE].texture = texture

var position = Vector3(0, 0, 0)

dim as BoundingBox bounds = MeshBoundingBox(model.meshes[0])
' NOTE: bounds are calculated from the original size of the model,
' if model is scaled on drawing, bounds must be also scaled

SetCameraMode(camera, CAMERA_FREE)

dim as boolean selected = false

SetTargetFPS(60)

while not WindowShouldClose()
	' Update
	UpdateCamera(@camera)
 
	' Load new models/textures on drag&drop
	if(IsFileDropped()) then
		dim as long count = 0
		dim as zstring ptr ptr droppedFiles = GetDroppedFiles(@count)
	 
		' Only support one file dropped
		if(count = 1) then
			' Model file formats supported
			if(_
				IsFileExtension(droppedFiles[0], ".obj") orElse _
				IsFileExtension(droppedFiles[0], ".gltf") orElse _
				IsFileExtension(droppedFiles[0], ".iqm")) then
			 
				UnloadModel(model)
				model = LoadModel(droppedFiles[0])
				model.materials[0].maps[ MAP_DIFFUSE ].texture = texture
			 
				bounds = MeshBoundingBox(model.meshes[0])
			elseif(IsFileExtension(droppedFiles[0], ".png")) then
				' Unload current model texture and load new one
				UnloadTexture(texture)
				texture = LoadTexture(droppedFiles[0])
				model.materials[0].maps[ MAP_DIFFUSE ].texture = texture
			end if
		end if
	 
		' Clear internal buffers
		ClearDroppedFiles()
	end if
 
	' Select model on mouse click
	if(IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) then
		' Check collision between ray and box
		if(CheckCollisionRayBox(GetMouseRay(GetMousePosition(), camera), bounds)) then 
			selected = not selected
		else
			selected = false
		end if
	end if
 
	' Render
	BeginDrawing()
	ClearBackground(RAYWHITE)
 
	BeginMode3D(camera)
 
		DrawModel(model, position, 1, WHITE)
		DrawGrid(20, 10)
 
		if selected then 
			' Draw selection box
			DrawBoundingBox(bounds, GREEN)
		end if
 
	EndMode3D()
 
	DrawText("Drag & drop model to load mesh/texture.", 10, GetScreenHeight() - 20, 10, DARKGRAY)
 
	if(selected) then DrawText("MODEL SELECTED", GetScreenWidth() - 110, 10, 10, GREEN)
 
	DrawText("(c) Castle 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY)
 
	DrawFPS(10, 10)
 
	EndDrawing()
wend

UnloadTexture(texture)
UnloadModel(model)

CloseWindow()
