'******************************************************************************************
'
'   raylib [audio] example - Raw audio streaming
'
'   This example has been created using raylib 1.6 (www.raylib.com)
'   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
'
'   Example created by Ramon Santamaria (@raysan5) and reviewed by James Hofmann (@triplefox)
'
'   Copyright (c) 2015-2019 Ramon Santamaria (@raysan5) and James Hofmann (@triplefox)
'
'*******************************************************************************************

#include once "../raylib.bi"

#define MAX_SAMPLES			   512
#define MAX_SAMPLES_PER_UPDATE   4096

declare function memcpy(dest as any ptr, src as any ptr, len_ as uinteger) as any ptr

' Initialization
'--------------------------------------------------------------------------------------
const screenWidth = 800
const screenHeight = 450
InitWindow(screenWidth, screenHeight, "raylib [audio] example - raw audio streaming")
InitAudioDevice()			  ' Initialize audio device
' Init raw audio stream (sample rate: 22050, sample size: 16bit-short, channels: 1-mono)
dim as AudioStream stream = InitAudioStream(22050, 16, 1)
' Buffer for the single cycle waveform we are synthesizing
dim as short ptr audioData = allocate(sizeof(short)*MAX_SAMPLES)
' Frame buffer, describing the waveform when repeated over the course of a frame
dim as short ptr writeBuf = allocate(sizeof(short)*MAX_SAMPLES_PER_UPDATE)
PlayAudioStream(stream)		' Start processing stream buffer (no data loaded currently)
' Position read in to determine next frequency
dim as Vector2 mousePosition = Vector2(-100.0, -100.0)
' Cycles per second (hz)
dim as single frequency = 440.0
' Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
dim as single oldFrequency = 1.0
' Cursor to read and copy the samples of the sine wave buffer
dim as long readCursor = 0
' Computed size in samples of the sine wave
dim as long waveLength = 1
dim as Vector2 position = Vector2(0, 0)
SetTargetFPS(30)			   ' Set our game to run at 30 frames-per-second
'--------------------------------------------------------------------------------------
' Main game loop
while not WindowShouldClose()	' Detect window close button or ESC key
	' Update
	'----------------------------------------------------------------------------------
	' Sample mouse input.
	mousePosition = GetMousePosition()
	if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then frequency = 40.0 + mousePosition.y
	' Rewrite the sine wave.
	' Compute two cycles to allow the buffer padding, simplifying any modulation, resampling, etc.
	if frequency <> oldFrequency then
		' Compute wavelength. Limit size in both directions.
		dim as long oldWavelength = waveLength
		waveLength = 22050/frequency
		if waveLength > MAX_SAMPLES/2 then waveLength = MAX_SAMPLES/2
		if waveLength < 1 then waveLength = 1
		' Write sine wave.
		for i as integer = 0 to waveLength*2
			audioData[i] = sin(2*PI*i/waveLength)*32000
		next
		' Scale read cursor's position to minimize transition artifacts
		readCursor = (readCursor * (waveLength / oldWavelength))
		oldFrequency = frequency
	end if
	' Refill audio stream if required
	if IsAudioStreamProcessed(stream) then
		' Synthesize a buffer that is exactly the requested size
		dim as long writeCursor = 0
		while writeCursor < MAX_SAMPLES_PER_UPDATE
			' Start by trying to write the whole chunk at once
			dim as long writeLength = MAX_SAMPLES_PER_UPDATE-writeCursor
			' Limit to the maximum readable size
			dim as long readLength = waveLength-readCursor
			if writeLength > readLength then writeLength = readLength
			' Write the slice
			memcpy(writeBuf + writeCursor, audioData + readCursor, writeLength*sizeof(short))
			' Update cursors and loop audio
			readCursor = (readCursor + writeLength) mod waveLength
			writeCursor += writeLength
		wend
		' Copy finished frame to audio stream
		UpdateAudioStream(stream, writeBuf, MAX_SAMPLES_PER_UPDATE)
	end if
	'----------------------------------------------------------------------------------
	' Draw
	'----------------------------------------------------------------------------------
	BeginDrawing()
		ClearBackground(RAYWHITE)
		DrawText(FormatText("sine frequency: %i",frequency), GetScreenWidth() - 220, 10, 20, RED)
		DrawText("click mouse button to change frequency", 10, 10, 20, DARKGRAY)
		' Draw the current buffer state proportionate to the screen
		for i as integer = 0 to screenWidth
			position.x = i
			position.y = 250 + 50*audioData[i*MAX_SAMPLES/screenWidth]/32000
			DrawPixelV(position, RED)
		next
	EndDrawing()
	'----------------------------------------------------------------------------------
wend
' De-Initialization
'--------------------------------------------------------------------------------------
deallocate audioData		' Unload sine wave audioData
deallocate writeBuf			' Unload write buffer
CloseAudioStream(stream)   	' Close raw audio stream and delete buffers from RAM
CloseAudioDevice()		 	' Close audio device (music streaming is automatically stopped)
CloseWindow()			 	' Close window and OpenGL context
'--------------------------------------------------------------------------------------

function memcpy(dest as any ptr, src as any ptr, len_ as uinteger) as any ptr
	dim as ubyte ptr d = dest
	dim as ubyte ptr s = src
	while len_
		len_-=1
		*d=*s
		d+=1
		s+=1
	wend
	return dest
end function