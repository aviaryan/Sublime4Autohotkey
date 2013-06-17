/*
The file makes sure the portability of Sublime 4 Autohotkey is maintained
*/

#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

FileRead,path,path.ini

if (path != A_scriptdir)
{
	FileDelete,path.ini
	FileAppend,%A_scriptdir%,path.ini	;correct path
	
	avisdir := Substr(A_scriptdir, 1, Instr(A_scriptdir, "\", false, 0))	;avis_sublime4autohotkey
	FileRemoveDir, avisdir\helpers\launchq\q-settings	;the build path is corrected via Sublime 4 Autohotkey.exe
}
