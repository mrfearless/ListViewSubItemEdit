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

include Listview.inc
includelib Listview.lib

include ..\ListViewSubItemEdit.asm


;-----------------------------------------------------------------------------------------
; LVSIETest Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
TestLVInit              PROTO :DWORD
TestLVLoadData          PROTO :DWORD
TestEditInitProc        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
TestEditProc            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

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


szLVBHdr0                   DB '#',0
szLVBHdr1                   DB 'Bif Entry Offset',0
szLVBHdr2                   DB 'Bif Filename',0
szLVBHdr3                   DB 'Bif Filesize',0
szLVBHdr4                   DB 'Bif Location',0
szLVBHdr5                   DB 'Bif Filename Offset',0
szLVBHdr6                   DB 'Bif Filename Length',0

szBDItem1                   DB 'BIF_ENTRY structure',0
szBDItem2                   DB 'BIF_FILE_SIZE',0
szBDItem3                   DB 'BIF_FILENAME_OFFSET',0
szBDItem4                   DB 'BIF_FILENAME_LENGTH',0
szBDItem5                   DB 'BIF_FILE_LOCATION',0
szBDBytes                   DB ' Bytes',0
szBDOffset1                 DB '+ 0x0',0 ;BIF_ENTRY structure
szBDOffset2                 DB '+ 0x0',0 ;BIF_FILE_SIZE 
szBDOffset3                 DB '+ 0x4',0 ;BIF_FILENAME_OFFSET
szBDOffset4                 DB '+ 0x8',0 ;BIF_FILENAME_LENGTH
szBDOffset5                 DB '+ 0xA',0 ;BIF_FILE_LOCATION
szBDSize1                   DB '14 Bytes',0 ;BIF_ENTRY structure
szBDSize11                  DB '12 Bytes',0 ;BIF_ENTRY structure
szBDSize2                   DB '4 Bytes',0 ;BIF_FILE_SIZE 
szBDSize3                   DB '4 Bytes',0 ;BIF_FILENAME_OFFSET
szBDSize4                   DB '2 Bytes',0 ;BIF_FILENAME_LENGTH
szBDSize41                  DB '4 Bytes',0 ;BIF_FILENAME_LENGTH
szBDSize5                   DB '2 Bytes',0 ;BIF_FILE_LOCATION


lvsie                       LVSUBITEMEDIT <>
nmia                        NMITEMACTIVATE <>

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


