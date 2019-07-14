#NoEnv
#SingleInstance Force
#Persistent
SendMode Input
; Проверка елси скрипт был запущен от имени админа
if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
{
    try
    {
        Run *RunAs "%A_ScriptFullPath%" /restart
		ExitApp
    }
}

Gui, Font, s10
Gui, Add, Text, x20 y20 w280 h30, Деинсталяция ASM.
Gui, Font, s8
Gui, Add, Button, x300 y150 w70 h23 gInstall vInstall, Удалить
Gui, Add, Button, x220 y150 w70 h23 gCancel vCancel, Отменить
Gui, Add, Text, x20 y60 w200 h23 vCurrentAction, Вы уверены что хотите удалить ASM?
Gui, Add, CheckBox, x20 y100 w250 h23 vDeleteLib, Удалить библиотеку скриптов?
Gui, Add, Progress, x20 y100 w350 h30 vprogressBar, 0
GuiControl, Hide, progressBar
Gui, Color, ffffcc
Gui, Show, AutoSize, Деинсталяция ASM.
return

Install:
Loop {
    try {
        RegRead, InstallDir, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, InstallDir
        if ErrorLevel {
            throw
        }
        if FileExist(InstallDir . "\delete.bat") {
                FileDelete, %InstallDir%\delete.bat
        }
        FileAppend, :delete, %InstallDir%\delete.bat
        GuiControlGet, DeleteLib,,DeleteLib
        if DeleteLib {
            RegRead, LibraryDir, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM, LibraryDir
            if ErrorLevel {
                throw
            }
            FileAppend, `r`nrmdir /q /s "%LibraryDir%" `r`nif exist "%LibraryDir%" goto delete, %InstallDir%\delete.bat
        }
        FileAppend, `r`nrmdir /q /s "%InstallDir%" `r`nif exist "%InstallDir%" goto delete, %InstallDir%\delete.bat
        RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\DoshikSoft\ASM
        RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DoshikSoft-ASM
        Run, %InstallDir%\delete.bat,, Hide
        ExitApp
    } catch {
        MsgBox, 50, Ошибка, Ошибка во время удаления.
        IfMsgBox, Abort
            ExitApp
        IfMsgBox, Retry
            continue
    }
    break
}
return

Cancel:
GuiClose:
MsgBox, 292, Удаление ASM, Вы уверены что хотите прекратить удаление?
IfMsgBox, Yes
	ExitApp
return