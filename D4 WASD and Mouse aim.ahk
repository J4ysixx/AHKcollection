
#NoEnv			        		
#Persistent		       			
#MaxHotkeysPerInterval, 500    
SendMode Input		        
SetKeyDelay -1
SetControlDelay -1
SetTitleMatchMode, 3            

; ====================================================================
; ============================== CONFIG ==============================
; ====================================================================
appName := "Diablo IV"		; needs to match game window title exactly
yCorrection := -36			; moves the coordinate (in pixels) of the center of the screen vertically (- up / + down), allows tweaking the skew of horizontal movement direction
xOffset := 10000			; horizontal coordinate of mouse click when moving left or right (it is located outside the screen, but game interprets it as clicking on the edge)
yOffset := 10000			; vertical coordinate of mouse click when moving up or down (it is located outside the screen, but game interprets it as clicking on the edge)
xStopOffset := 40			; amount of pixels from the center of the screen (horizontally), where the click to stop the character occurs
yStopOffset := 30			; amount of pixels from the center of the screen (vertically), where the click to stop the character occurs
timerTickTime := 20			; time interval (in  milliseconds) between each scan of 'WASD' input
postClickDelay := 100		; the length of pause (in milliseconds) after each click sent by the script; makes it less spammy, but also less responsive
; ====================================================================
; =========================== CONFIG END =============================
; ====================================================================

wTickTime := 0
aTickTime := 0
sTickTime := 0
dTickTime := 0

WinWaitActive, %appName%   	
Sleep 3000
SoundBeep
WinGetPos, xWin, yWin, wWin, hWin, A
xCenter := xWin + wWin / 2
yCenter := yWin + hWin / 2 + yCorrection

SetTimer, WASDscanner, %timerTickTime%
scriptPause := false




#If WinActive(appName)

~End::
	if (scriptPause)
	{
		SoundBeep, 5000, 10	
		SetTimer, WASDscanner, %timerTickTime%
	}
	else
	{
		SoundBeep, 1000, 10
		ControlClick, x%xCenter% y%yCenter%, A,, M, 1, NA
		SetTimer, WASDscanner, Off
	}
	scriptPause := !scriptPause
return



~w up::
~a up::
~s up::
~d up::
	if scriptPause
		return
	if isPressedAny()
		return
	strButton := StrReplace(A_ThisHotkey, "~", "")
	strButton := StrReplace(strButton, " up", "")
	Coord := getStopCoord(strButton)
	xCoord := Coord.x
	yCoord := Coord.y
	ControlClick, x%xCoord% y%yCoord%, A,, M, 1, NA
	Sleep, %postClickDelay%
return



WASDscanner:
	if !WinActive(appName) 
		return
	if (scriptPause)
		return
	UpdateTickTimesWASD()
	if !isPressedAny()
		return
	if GetKeyState("1", "P") Or GetKeyState("2", "P") Or GetKeyState("3", "P") Or GetKeyState("4", "P")
		return

	xTarget := horizontalDirEval()
	yTarget := verticalDirEval()

	ControlClick, x%xTarget% y%yTarget%, A,, M, 1, NA
	Sleep, %postClickDelay%
return



getStopCoord(key)
{
	Global
	Switch key
	{
		case "w":
			Coord := {x: xCenter, y: yCenter - yStopOffset}
		case "a":
			Coord := {x: xCenter - xStopOffset, y: yCenter}
		case "s":
			Coord := {x: xCenter, y: yCenter + yStopOffset}
		case "d":
			Coord := {x: xCenter + xStopOffset, y: yCenter}
	}
	return Coord
}

UpdateTickTimesWASD()
{
	Global
	if isPressed("w"){
		if (wTickTime == 0)
			wTickTime := A_TickCount
	} 
	else 
	{
		wTickTime := 0
	}
	
	if isPressed("a"){
		if (aTickTime == 0)
			aTickTime := A_TickCount
	} 
	else 
	{
		aTickTime := 0
	}
	
	if isPressed("s"){
		if (sTickTime == 0)
			sTickTime := A_TickCount
	} 
	else 
	{
		sTickTime := 0
	}
	
	if isPressed("d"){
		if (dTickTime == 0)
			dTickTime := A_TickCount
	} 
	else 
	{
		dTickTime := 0
	}
}

horizontalDirEval()
{
	Global
	if !(isPressed("a") or isPressed("d"))
		return xCenter
	
	if (isPressed("a") and isPressed("d"))
	{
		return (aTickTime >= dTickTime) ? (xCenter - xOffset) : (xCenter + xOffset)
	}
	
	if isPressed("a")
		return xCenter - xOffset
	
	if isPressed("d")
		return xCenter + xOffset
}

verticalDirEval()
{
	Global
	if !(isPressed("w") or isPressed("s"))
		return yCenter
	
	if (isPressed("w") and isPressed("s"))
	{
		return (wTickTime >= sTickTime) ? (yCenter - yOffset) : (yCenter + yOffset)
	}
	
	if isPressed("w")
		return yCenter - yOffset
	
	if isPressed("s")
		return yCenter + yOffset
}

isPressed(key)
{
	return GetKeyState(key, "P")
}

isPressedAny()
{
	return (isPressed("w") or isPressed("a") or isPressed("s") or isPressed("d"))
}
