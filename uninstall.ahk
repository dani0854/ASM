#NoEnv
#SingleInstance Force
#Persistent
SendMode Input
; �������� ���� ������ ��� ������� �� ����� ������
if not (A_IsAdmin or RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
{
    try
    {
        Run *RunAs "%A_ScriptFullPath%" /restart
		ExitApp
    }
}
Gui, Font, s10
Gui, Add, Text, x20 y20 w280 h30, ������������ ASM.
Gui, Font, s8
Gui, Add, Button, x300 y150 w70 h23 gInstall vInstall, �������
Gui, Add, Button, x220 y150 w70 h23 gCancel vCancel, ��������
Gui, Add, Text, x20 y60 w200 h23 vCurrentAction, �� ������� ��� ������ ������� ASM?
Gui, Add, CheckBox, x20 y100 w250 h23 vDeleteLib, ������� ���������� ��������?
Gui, Add, Progress, x20 y100 w350 h30 vprogressBar, 0
GuiControl, Hide, progressBar
Gui, Color, ffffcc
Gui, Show, AutoSize, ������������ ASM.
return

Install:
return

Cancel:
GuiClose:
MsgBox, 292, ���������� ASM, �� ������� ��� ������ ���������� ���������?
IfMsgBox, Yes
	ExitApp
return