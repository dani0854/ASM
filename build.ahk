#NoEnv

;Path to Ahk2Exe. If using standard compiler - RegExReplace(A_AhkPath,"[^\\]+\\?$") . "Compiler\Ahk2Exe.exe"
Ahk2Exe := "C:\repo\Ahk2Exe\Ahk2Exe.ahk"
;Path to bin
bin := "C:\repo\Ahk2Exe\Unicode 32-bit.bin"
;Path to ResourceHacker
ResourceHacker := "C:\Program Files (x86)\Resource Hacker\ResourceHacker.exe"

Files := ["asm", "install", "uninstall", "update"]


if FileExist(A_ScriptDir . "\build\Version.res") {
	FileDelete, %A_ScriptDir%\build\Version.res
}
RunWait, "%ResourceHacker%" -open "%A_ScriptDir%\src\Resources\Version.rc" -save "%A_ScriptDir%\build\Version.res" -action compile
RunWait, "%ResourceHacker%" -open "%bin%" -save "%bin%" -action addoverwrite -resource "%A_ScriptDir%\build\Version.res"
if FileExist(A_ScriptDir . "\build\Version.res") {
	FileDelete, %A_ScriptDir%\build\Version.res
}

for key, file in Files {
	RunWait, "%Ahk2Exe%" /in "%A_ScriptDir%\src\%file%.ahk" /out "%A_ScriptDir%\build\%file%.exe" /icon "%A_ScriptDir%\src\Resources\asm.ico" /bin "%bin%" /mpress 1
}


MsgBox, Done
ExitApp