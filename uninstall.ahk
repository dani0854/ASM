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
return

Cancel:
GuiClose:
MsgBox, 292, Установщик ASM, Вы уверены что хотите прекратить установку?
IfMsgBox, Yes
	ExitApp
return