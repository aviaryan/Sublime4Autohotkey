/*

##########################################################
Sublime 4 Autohotkey
v2.0
##########################################################

Copyright 2013 Avi Aryan  
  
Licensed under the Apache License, Version 2.0 (the "License");  
you may not use this file except in compliance with the License.  
You may obtain a copy of the License at  
  
http://www.apache.org/licenses/LICENSE-2.0  
  
Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS,  
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  
See the License for the specific language governing permissions and  
limitations under the License. 

*/

;============================= CONFIGURE =================================

IsHk := "F1"   ;launchs Help
Helper := "F9"   ;gives Syntax of current command

;=========================================================================

#SingleInstance force
SetBatchLines, -1
Sendmode, Play
SetWorkingDir, %A_ScriptDir%

RunWait, "autohotkey.exe" "system/portable-correct.ahk"		;Correct portabalistaion

FileCreateDir, temp
OnExit, qt

vrsn := 2.0 , Web := "http://www.avi-win-tips.blogspot.com/2013//06/su4ahk.html"

FileDelete, temp\*.ahk
global sublimepath := Substr(A_scriptdir, 1, Instr(A_scriptdir, "\", false, 0)) "sublime_text.exe"

Menu, Tray, NoStandard
Menu, Tray, Icon,%  Substr(A_scriptdir, 1, Instr(A_scriptdir, "\", false, 0)) "\Sublime 4 Autohotkey.exe"
Menu, Tray, Tip, Sublime4Autohotkey v%vrsn%
Menu, tray, add, Sublime4Autohotkey, me
Menu, Tray, Add, Launcher	Alt+A, launcher
Menu, Tray, Add
Menu, Tray, Add, Open Me For Editing, scedit
Menu, Tray, Add
Menu, Tray, Add, Check for Updates, updt
Menu, Tray, Add, Quit,qt
Menu, Tray, Default, Sublime4Autohotkey

SetTimer, sublimeahkcheck,400
SetTimer, issublimethere, 1000

run, Autohotkey.exe "helpers\launchq\launchq.ahk",,, lqpid

cl_lq := new talk("LaunchQ.ahk")
return

#IfWinActive, ahk_class PX_WINDOW_CLASS
{
	^n::NewAHK()
}

sublimeahkcheck:
	IfWinActive, ahk_class PX_WINDOW_CLASS
	{
		WinGetTitle,curload
		if !Instr(curload, ".ahk")
		{
			Hotkey,%Helper%,Help,Off
			Hotkey, %ISHK%, Intsen, Off
		}
		else
		{
			Hotkey,%Helper%,Help,On
			Hotkey, %ISHK%, Intsen, On
		}
	}
	Else
	{
		Hotkey, %ISHK%, Intsen, Off
		Hotkey,%Helper%,Help,Off
	}
Return

issublimethere:
	IfWinnotExist, ahk_class PX_WINDOW_CLASS
	{
		Process,close,%lqpid%
		Exitapp
	}
Return

TooltipHelp(){
	ToolTip
	BlockInput, Sendandmouse
	
	oldclip := ClipboardAll
	Send, +{Home}^c{Right}
	copiedcode := Ltrim( (temp_pos := SuperInstr(Clipboard, "=|+|-|*|?|:|(|% |%	", 0, false, 0)) ? Substr(Clipboard, temp_pos+1) : Clipboard )
	Send, +{End}^c{Left}
	copiedcode .= Clipboard
	comand := RegExReplace(copiedcode, "([A-Z]*)(,|`t| |\()(.*)", $1)

	if (comand == "loop")
		realcomand := loopspecial(140)
	else
	{
		Loop
		{
			FileReadLine,cl,%A_ScriptDir%/System/commands.txt, %A_Index%
			if ErrorLevel = 1
				break
			StringGetPos, pos, cl, %comand%, L
			if (pos == 0)
			{
				realcomand := cl
				Break
			}
		}
	}
	blockinput, off
	Clipboard := oldclip

	IfNotEqual, realcomand
	{
		Hotkey, ~LButton,toolrem,On
		Hotkey, ~Enter,toolrem,On
		ToolTip, %realcomand%
	}
}

RunHelp(){
	Tooltip
	BlockInput, Sendandmouse
	
	oldclip := ClipboardAll
	Send, +{Home}^c{Right}
	copiedcode := Ltrim( (temp_pos := SuperInstr(Clipboard, "=|+|-|*|?|:|(|% |%	", 0, false, 0)) ? Substr(Clipboard, temp_pos+1) : Clipboard )
	Send, +{End}^c{Left}
	copiedcode .= Clipboard
	comand := RegExReplace(copiedcode, "([A-Z]*)(,|`t| |\()(.*)", $1)
	BlockInput, off
	Clipboard := oldclip
	;;Running
	IfNotEqual, comand
	{
		Run, Autohotkey.chm,,Max
		WinWait, AutoHotkey Help
		WinActivate, AutoHotkey Help
		WinWaitActive, AutoHotkey Help
		Send, !n
		SendPlay, !w%comand%{enter}
	}
}

NewAHK(){
	loop
	{
		IfnotExist, %a_scriptdir%/temp/default%a_index%.ahk
		{
			saveindex := a_index
			break
		}
	}
	FileAppend, %emptyvar%, %A_ScriptDir%/temp/default%saveindex%.ahk
	run, "%sublimepath%" "%A_ScriptDir%/temp/default%saveindex%.ahk"
}

qt:
	Process, close, %lqpid%
	Process, close, sublime_text.exe
	ExitApp
return

me:
	Text := "Sublime 4 Autohotkey by Avi Aryan `nversion " vrsn
	MsgBox, 64, About, %Text%
Return

updt:
	URLDownloadToFile,https://raw.github.com/avi-aryan/Sublime4Autohotkey/master/Avis_Sublime4Autohotkey/Version.txt,%a_scriptdir%/currentversion.txt
	FileRead,version,%a_scriptdir%/currentversion.txt
	IfGreater, version, %vrsn%
	{
		MsgBox, 48, Update Available, A new update is available.`nYour Version - %vrsn%`nCurrent Version - %version%`n`nGo to %web%
			IfMsgBox OK
				BrowserRun(web)
	}
	else
		MsgBox, 64, , No Updates Available!
Return

toolrem:
	Hotkey,~Lbutton,toolrem,Off
	Hotkey,~Enter,toolrem,Off
	ToolTip
Return

loopspecial(no){
	loop, 5
	{
		FileReadLine, cl, %A_ScriptDir%/commands.txt,% no+A_Index-1
		realcomand .= cl "`n"
	}
	return RTrim(realcomand, "`n")
}


help:
	TooltipHelp()
Return

Intsen:
	RunHelp()
Return

scedit:
	run, %sublimepath% "%A_ScriptFullPath%"
Return

launcher:
	cl_lq.runlabel("ShowGUI")
return

SuperInstr(Hay, Needles, return_min=true, Case=false, Startpoint=1, Occurrence=1){
	
	pos := return_min*Strlen(Hay)
	if return_min
	{
		loop, parse, Needles,|
			if ( pos > (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) )
				pos := ( var = 0 ? pos : var )
	}
	else
	{
		loop, parse, Needles,|
			if ( (var := Instr(Hay, A_LoopField, Case, startpoint, Occurrence)) > pos )
				pos := var
	}
	return pos
}

BrowserRun(site){
RegRead, OutputVar, HKCR, http\shell\open\command 
IfNotEqual, Outputvar
{
	StringReplace, OutputVar, OutputVar,"
	SplitPath, OutputVar,,OutDir,,OutNameNoExt, OutDrive
	run,% OutDir . "\" . OutNameNoExt . ".exe" . " """ . site . """"
}
else
	run,% "iexplore.exe" . " """ . site . """"	;internet explorer
}

#include, %A_ScriptDir%\helpers\lib\talk.ahk