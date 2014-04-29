/*

##########################################################
Sublime 4 Autohotkey
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

gosub, init
global GOTOS := {}
GoTo_AutoExecute(1)
FileRemoveDir, gotocache, 1
return

;-------------- CONFIGURE THE HOTKEYS HERE -------------------------------------------------------------------

#if Winactive("ahk_class PX_WINDOW_CLASS") and Instr( Win_GetTitle("ahk_class PX_WINDOW_CLASS") , ".ahk" )
	F1::RunHelp()	;F1 chm Help
	F9::TooltipHelp()	;Tooltip Syntax Help
	F7::Goto_Main_Gui()	;Shortcut for GoTo GUI
#if

#If Winactive("ahk_class PX_WINDOW_CLASS")
	^n::NewAHK()	;Ctrl+N for new Ahk file
#If

;-------------                            ---------------------------------------------------------------------

issublimethere:
	If !WinExist("ahk_class PX_WINDOW_CLASS")
	{
		Process,close,%lqpid%
		Exitapp
	}
Return

TooltipHelp(){
	ToolTip
	BlockInput, Sendandmouse
	
	cjconst := Cjcontrol(0)
	
	oldclip := ClipboardAll
	Send, +{Home}^c{Right}
	copiedcode := Clipboard	
	Send, +{End}^c{Left}
	copiedcode2 := Clipboard
	if ( ( !Instr(copiedcode2, " ") ? Strlen(copiedcode2) : Instr(copiedcode2, " ") ) > ( !Instr(copiedcode2, "(") ? Strlen(copiedcode2) : Instr(copiedcode2, "(") ) )
		needles := "=|+|-|*|?|:|(|% |%	|\|/|,|!|<|>|.| "
	else
		needles := "%|=|."
	
	copiedcode := Ltrim( (temp_pos := SuperInstr(copiedcode, needles, 0, false, 0)) ? Substr(copiedcode, temp_pos+1) : copiedcode )
	copiedcode .= copiedcode2

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
	
	if cjconst
		Cjcontrol(1)

	IfNotEqual, realcomand
	{
		Hotkey, ~LButton,toolrem,On
		Hotkey, ~Enter,toolrem,On
		Hotkey, Esc, toolrem, On
		ToolTip, %realcomand%
	}
}

RunHelp(){
	static PID
	Tooltip
	BlockInput, Sendandmouse
	cjconst := Cjcontrol(0)
	
	oldclip := ClipboardAll
	Send, +{Home}^c{Right}
	copiedcode := Clipboard	
	Send, +{End}^c{Left}
	copiedcode2 := Clipboard
	if ( ( !Instr(copiedcode2, " ") ? Strlen(copiedcode2) : Instr(copiedcode2, " ") ) > ( !Instr(copiedcode2, "(") ? Strlen(copiedcode2) : Instr(copiedcode2, "(") ) )
		needles := "=|+|-|*|?|:|(|% |%	|\|/|,|!|<|>|.| "
	else
		needles := "%|=|."
	
	copiedcode := Ltrim( (temp_pos := SuperInstr(copiedcode, needles, 0, false, 0)) ? Substr(copiedcode, temp_pos+1) : copiedcode )
	copiedcode .= copiedcode2
	comand := RegExReplace(copiedcode, "([A-Z]*)(,|`t| |\()(.*)", $1)
	
	BlockInput, off
	Clipboard := oldclip
	
	if cjconst
		Cjcontrol(1)
	;;Running
	IfNotEqual, comand
	{
		if WinExist("AutoHotkey Help") && PID
			Process, Close, % PID
		Run, Autohotkey.chm,,Max, PID
		WinWait, AutoHotkey Help
		WinActivate, AutoHotkey Help
		WinWaitActive, AutoHotkey Help
		SendMessage, 0x1330, 1,, SysTabControl321
		SendMessage, 0x130C, 1,, SysTabControl321
		SendPlay, +{Home}%comand%{enter}
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
	;Process, close, sublime_text.exe  ;- dont close ST
	ExitApp
return

me:
	Text := "Sublime 4 Autohotkey by Avi Aryan `nversion " vrsn "`n`n"
	. "F1 -> Context-Sensitive Help`n"
	. "F9 -> Tooltip Syntax Help`n"
	. "F7 -> GoTo keywords"
	MsgBox, 64, About, %Text%
Return

updt:
	URLDownloadToFile, https://raw.github.com/aviaryan/Sublime4Autohotkey/master/Avis_Sublime4Autohotkey/Version.txt,%a_scriptdir%/currentversion.txt
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
	Hotkey, Esc, toolrem, Off
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

scedit:
	run, %sublimepath% "%A_ScriptFullPath%"
Return

help:
	BrowserRun("http://avi-win-tips.blogspot.com/2013/06/su4ahkguide.html")
return

launcher:
	cl_lq.runlabel("ShowGUI", 0)
return

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

Win_GetTitle(WinTitle){
	WinGetTitle, temp, %WinTitle%
	return temp
}

;############################# init ################################################

init:

#SingleInstance ignore
SetBatchLines, -1
Sendmode, Play
SetWorkingDir, %A_ScriptDir%

RunWait, "autohotkey.exe" "system/portable-correct.ahk"		;Correct portabalistaion

FileCreateDir, temp
OnExit, qt

vrsn := 2.6 , Web := "http://www.avi-win-tips.blogspot.com/2013//06/su4ahk.html"

FileDelete, temp\*.ahk
global sublimepath := Substr(A_scriptdir, 1, Instr(A_scriptdir, "\", false, 0)) "sublime_text.exe"

Menu, Tray, NoStandard
try {
	Menu, Tray, Icon,%  Substr(A_scriptdir, 1, Instr(A_scriptdir, "\", false, 0)) "Sublime 4 Autohotkey.exe"
}
Menu, Tray, Tip, Sublime4Autohotkey v%vrsn%
Menu, tray, add, Sublime4Autohotkey, me
Menu, Tray, Add, Launcher	Alt+A (Def), launcher
Menu, Tray, Add
Menu, Tray, Add, Open Me For Editing, scedit
Menu, Tray, Add
Menu, Tray, Add, Check for Updates, updt
Menu, Tray, Add, See online Help, help
Menu, Tray, Add, Quit,qt
Menu, Tray, Default, Sublime4Autohotkey

SetTimer, issublimethere, 1000

run, Autohotkey.exe "helpers\launchq\launchq.ahk",,, lqpid
cl_lq := new talk("LaunchQ.ahk")
return

;######################################################################################

#include, %A_ScriptDir%\helpers\lib\talk.ahk
#include, %A_scriptdir%\helpers\goto\goto.ahk
#Include, %A_scriptdir%\helpers\lib\ClipjumpCommunicator.ahk