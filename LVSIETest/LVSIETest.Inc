include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib masm32.lib

; test stuff
;include Listview.inc
;includelib Listview.lib
;include ..\ListViewSubItemEdit.asm


; ! required to include our ListViewSubItemEdit libraries for this to work
include ListViewSubItemEdit.inc
includelib ListViewSubItemEdit.lib

IFNDEF LVSUBITEMEDIT ; included for ease of use during coding if structure is present in same file radasm can show the elements of it
LVSUBITEMEDIT               STRUCT
    dwControlType           DD ?    ; (Required) see table below for types. Note not all supported yet.
    lpControlInitProc       DD ?    ; (Optional) pointer to custom function for initilization. Return true to continue or false - which exits control and destroys it
    lpControlProc           DD ?    ; (Optional) pointer to custom callback proc for handling WM_CHAR, WM_KEYDOWN and WM_COMMAND. Return true to continue or false to prevent. 
    lpControlValidProc      DD ?    ; (Optional) pointer to custom function for validation of control before it closes. Return true to continue or false to prevent.
    dwOptions               DD ?    ; Combination of option flags, see below for more info.
    lParam                  DD ?    ; (Optional) custom value to pass, for use in lpControlInitProc proc
LVSUBITEMEDIT               ENDS
ENDIF

;-----------------------------------------------------------------------------------------
; LVSIETest Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
TestLVInit              PROTO :DWORD
TestLVLoadData          PROTO :DWORD
TestEditInitProc        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TestEditProc            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TestEditValidProc       PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.CONST
;-----------------------------------------------------------------------------------------
; LVSIETest Constants
;-----------------------------------------------------------------------------------------
ICO_MAIN                EQU 101

; Main Dialog
IDD_DIALOG				EQU 1000
IDC_TESTLV              EQU 1001
IDC_TESTBUTTON          EQU 1002

; Main Menu 
IDM_MENU				EQU 10000
IDM_FILE_EXIT			EQU 10001
IDM_HELP_ABOUT			EQU 10101


.DATA
;-----------------------------------------------------------------------------------------
; LVSIETest Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'LTLI Dialog',0
AboutMsg				DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2014',0
lvsie                   LVSUBITEMEDIT <>
lvsie_data              LVSUBITEMEDIT <LVSIC_EDIT,NULL,NULL,NULL,TRUE,0>
szOne                   DB '01',0
sz99                    DB '99',0
;nmia                    NMITEMACTIVATE <>

.DATA?
;-----------------------------------------------------------------------------------------
; LVSIETest Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hTESTLV                 DD ?
iItem                   DD ?
iSubItem                DD ?
hIcoMain                DD ?





















