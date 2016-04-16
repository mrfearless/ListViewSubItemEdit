IFDEF LVSIELIB
;.486                        ; force 32 bit code
;.model flat, stdcall        ; memory model & calling convention
;option casemap :none        ; case sensitive
ENDIF
.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

;DEBUG32 EQU 1

IFDEF DEBUG32
    PRESERVEXMMREGS equ 1
    includelib M:\Masm32\lib\Debug32.lib
    DBG32LIB equ 1
    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
    include M:\Masm32\include\debug32.inc
ENDIF

include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include uxtheme.inc
include comctl32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib uxtheme.lib
includelib comctl32.lib


IFNDEF LVSIELIB
    include Listview.inc
    includelib Listview.lib
    LVSIELIBEND TEXTEQU <>
ELSE
    LVSIELIBEND TEXTEQU <END>
ENDIF

include ListViewSubItemEdit.inc


LVSIE_CreateEditControl     PROTO :DWORD                                            ; Main API function to create a control in the listview subitem

; Edit control procs
LVSIE_EditControlProc       PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    
LVSIE_LVEditControlProc     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

; Combo control procs
LVSIE_ComboControlProc      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
LVSIE_LVComboControlProc    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

; Experimental tab to next cell
LVSIE_SetNextItem           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
LVSIE_GetNextCell           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD


IFDEF LVSIELIB
ListViewGetItemRect         PROTO :DWORD, :DWORD, :DWORD
ListViewGetSubItemRect      PROTO :DWORD, :DWORD, :DWORD
ListViewGetItemText		    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ListViewSetItemText		    PROTO :DWORD, :DWORD, :DWORD, :DWORD
ListViewGetColumnWidth      PROTO :DWORD, :DWORD
ListViewGetColumnFormat     PROTO :DWORD, :DWORD
ListViewGetColumnCount      PROTO :DWORD
ListViewGetItemCount        PROTO :DWORD
ListViewEnsureSubItemVisible PROTO :DWORD, :DWORD
ENDIF


LVSIEDATA               STRUCT
    iItem               DD ?
    iSubItem            DD ?
    hListview           DD ?
    hHeader             DD ?
    hParent             DD ?
    hControl            DD ? ; can be combo etc ?
    dwControlType       DD ?    
    lpControlInitProc   DD ? ; any init to be done, or null go ahead anyhow? ret true to continue or false to exit control and destroy it
    lpControlProc       DD ? ; if user wants to handle themselves? subclass listview as well to pass wm_command and wm_notify back to this proc?
    lpControlEndProc    DD ? ; validation etc? if null just update subitem anyhow? true to exit or false to continue
    lParam              DD ? ; custom value to pass to it, for user to use in init or finish proc
    dwAllowWraparound   DD ?
    dwControlRect       RECT <?,?,?,?>
    dwChangesToSave     DD ?
    szText              DB 256 DUP (?)
LVSIEDATA               ENDS

IFNDEF MOUSEINPUT
MOUSEINPUT              STRUCT
   _dx                  DWORD ?
   dy                   DWORD ?
   mouseData            DWORD ?
   dwFlags              DWORD ?
   time                 DWORD ?
   dwExtraInfo          DWORD ?
MOUSEINPUT              ENDS
ENDIF
IFNDEF KEYBDINPUT
KEYBDINPUT              STRUCT
    wVk                 WORD ?
    wScan               WORD ?
    dwFlags             DWORD ?
    time                DWORD ?
    dwExtraInfo         DWORD ?
KEYBDINPUT              ENDS
ENDIF
IFNDEF HARDWAREINPUT
HARDWAREINPUT           STRUCT
    uMsg                DWORD ?
    wParamL             WORD ?
    wParamH             WORD ?
HARDWAREINPUT           ENDS
ENDIF
IFNDEF INPUT
INPUT                   STRUCT
    dwType               DWORD ?
        union
        mi              MOUSEINPUT <>
        ki              KEYBDINPUT <>
        hi              HARDWAREINPUT <>
        ends
INPUT                   ENDS
ENDIF

.CONST
;constants for dwType
INPUT_MOUSE     equ 0
INPUT_KEYBOARD  equ 1
INPUT_HARDWARE  equ 2

LVSIE_RIGHT             EQU 0
LVSIE_LEFT              EQU 1
LVSIE_DOWN              EQU 2
LVSIE_UP                EQU 3


.DATA
szLVSIEEditClass        DB 'Edit',0
lvsienmia               NMITEMACTIVATE <>

.DATA?



.CODE


;-------------------------------------------------------------------------------------
; Handles setup of listview subitem editing
;-------------------------------------------------------------------------------------
ListViewSubItemEdit PROC USES EBX ECX lpLVSIE:DWORD
    LOCAL iItem:DWORD
    LOCAL iSubItem:DWORD
    LOCAL hListview:DWORD
    LOCAL hParent:DWORD
    LOCAL hControl:DWORD
    LOCAL dwControlType:DWORD
    LOCAL lParam:DWORD
    LOCAL hinstance:DWORD
    LOCAL SubClassData:DWORD
    LOCAL rect:RECT

    Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, SIZEOF LVSIEDATA
    .IF eax == NULL
        mov eax, NULL
        ret
    .ENDIF
    mov SubClassData, eax
    mov ecx, eax
    
    ; save passed structure info to our own subclass data
    mov ebx, lpLVSIE
    mov eax, [ebx].LVSUBITEMEDIT.iItem
    mov [ecx].LVSIEDATA.iItem, eax
    mov eax, [ebx].LVSUBITEMEDIT.iSubItem
    mov [ecx].LVSIEDATA.iSubItem, eax
    mov eax, [ebx].LVSUBITEMEDIT.hListview
    mov [ecx].LVSIEDATA.hListview, eax
    mov eax, [ebx].LVSUBITEMEDIT.hParent
    mov [ecx].LVSIEDATA.hParent, eax
    mov eax, [ebx].LVSUBITEMEDIT.dwControlType
    mov dwControlType, eax
    mov [ecx].LVSIEDATA.dwControlType, eax
    mov eax, [ebx].LVSUBITEMEDIT.lpControlInitProc
    mov [ecx].LVSIEDATA.lpControlInitProc, eax
    mov eax, [ebx].LVSUBITEMEDIT.lpControlProc
    mov [ecx].LVSIEDATA.lpControlProc, eax
    mov eax, [ebx].LVSUBITEMEDIT.lpControlEndProc
    mov [ecx].LVSIEDATA.lpControlEndProc, eax
    mov eax, [ebx].LVSUBITEMEDIT.lParam
    mov [ecx].LVSIEDATA.lParam, eax
    mov eax, [ebx].LVSUBITEMEDIT.dwAllowWraparound
    mov [ecx].LVSIEDATA.dwAllowWraparound, eax
    
    mov eax, dwControlType
    .IF eax == LVSIC_EDIT
    
        Invoke GetDlgItem, hListview, 1
        .IF eax != NULL
            IFDEF DEBUG32
            PrintText 'GetDlgItem, hListview, 1 found'
            PrintDec eax
            ENDIF
        .ENDIF
    
        Invoke LVSIE_CreateEditControl, SubClassData
    .ENDIF

    .IF eax == NULL
        Invoke GlobalFree, SubClassData
        mov eax, NULL
        ret
    .ENDIF
    
    ret

ListViewSubItemEdit ENDP


;-------------------------------------------------------------------------------------
; Create edit control for listview subitem editing
;-------------------------------------------------------------------------------------
LVSIE_CreateEditControl PROC USES EBX lpSubClassData
    LOCAL iItem:DWORD
    LOCAL iSubItem:DWORD
    LOCAL hListview:DWORD
    LOCAL hHeader:DWORD
    LOCAL hParent:DWORD
    LOCAL hControl:DWORD
    LOCAL lParam:DWORD
    LOCAL hinstance:DWORD
    LOCAL lpszItemText:DWORD
    LOCAL rect:RECT
    LOCAL dwStyle:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    ; Get information from our data 
    mov ebx, lpSubClassData
    mov eax, [ebx].LVSIEDATA.iItem
    mov iItem, eax
    mov eax, [ebx].LVSIEDATA.iSubItem
    mov iSubItem, eax
    mov eax, [ebx].LVSIEDATA.hListview
    mov hListview, eax
    mov eax, [ebx].LVSIEDATA.hParent
    mov hParent, eax
    lea eax, [ebx].LVSIEDATA.szText
    mov lpszItemText, eax

    ; Get area to put our editbox in
 	.IF iSubItem == 0 ; LVM_GETSUBITEMRECT doesnt work with iSubItem == 0 so we calc it another way
	    mov rect.left, LVIR_BOUNDS
	    Invoke ListViewGetItemRect, hListview, iItem, Addr rect
	    Invoke ListViewGetColumnWidth, hListview, 0
	    mov rect.right, eax
	.ELSE
    	mov eax, iSubItem
    	mov rect.top, eax
    	mov rect.left, LVIR_BOUNDS
    	Invoke ListViewGetSubItemRect, hListview, iItem, Addr rect
    .ENDIF

    ; Adjust area to fit our control perfectly
	dec rect.bottom
	dec rect.right
	inc rect.left
	inc rect.left
	mov eax, rect.right
	sub eax, rect.left
	mov rect.right, eax
	mov eax, rect.bottom
	sub eax, rect.top
	mov rect.bottom, eax
    
    ; Set editbox style based on column format: left or right aligned or centered
    mov eax, WS_CLIPCHILDREN+WS_CHILD+WS_VISIBLE+ES_AUTOHSCROLL
    mov dwStyle, eax
    Invoke ListViewGetColumnFormat, hListview, iSubItem
    and eax, LVCFMT_LEFT + LVCFMT_RIGHT + LVCFMT_CENTER
    .IF eax == LVCFMT_LEFT	
        or dwStyle, ES_LEFT
    .ELSEIF eax == LVCFMT_RIGHT	
        or dwStyle, ES_RIGHT
    .ELSEIF eax == LVCFMT_CENTER
        or dwStyle, ES_CENTER
    .ENDIF
	
	; Create our editbox control
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, Addr szLVSIEEditClass, NULL, dwStyle, 
           rect.left, rect.top, rect.right, rect.bottom, hListview, 1, hinstance, NULL	
    .IF eax == NULL
        ret
    .ENDIF
    
    ; If control created succesfully we fill in some info into our subclass data area
    mov hControl, eax
    invoke SetFocus, hControl ; do this before any subclassing, that way if an existing control exists, for whatever reason, setting focus on this, should destroy old one.
    
    mov ebx, lpSubClassData
    mov eax, hControl
    mov [ebx].LVSIEDATA.hControl, eax
    mov eax, rect.bottom
    mov [ebx].LVSIEDATA.dwControlRect.bottom, eax
    Invoke ListViewGetItemText, hListview, iItem, iSubItem, lpszItemText, SIZEOF LVSIEDATA.szText
    
    ; Get listview header, mainly for notification if user resizes a column whilst control is displaying (it will size according to new col size - and closes as focus has been lost)
    Invoke SendMessage, hListview, LVM_GETHEADER, NULL, NULL
    mov hHeader, eax
    mov ebx, lpSubClassData
    mov [ebx].LVSIEDATA.hHeader, eax

    ; Get font from listview and set editbox to same    
	invoke SendMessage, hListview, WM_GETFONT, 0, 0
	invoke SendMessage, hControl, WM_SETFONT, eax, 0 ; set font same as listview has
	invoke SetWindowPos, hControl, HWND_TOP, 0,0,0,0, SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE
    Invoke SetWindowSubclass, hControl, Addr LVSIE_EditControlProc, 0, lpSubClassData
    Invoke SetWindowSubclass, hListview, Addr LVSIE_LVEditControlProc, 0, lpSubClassData

    ; Final stuff for control before setting focus and calling initdialog for it (we use intidialog to call users lpControlInitProc if specified)
	Invoke SendMessage, hControl, WM_SETTEXT, 0, lpszItemText
	Invoke SendMessage, hControl, EM_SETMARGINS, EC_LEFTMARGIN + EC_RIGHTMARGIN, 00010001h
	Invoke SendMessage, hControl, EM_SETSEL, 0, -1
	Invoke SendMessage, hControl, WM_INITDIALOG, 0, 0
	.IF eax == FALSE ; if user returned false from their lpControlInitProc we destroy editbox and return
	    xor eax, eax
	.ELSE
        mov eax, hControl ; else control is created and handle is passed back for user to use if required
        ;PrintDec hControl
    .ENDIF
    
    ret

LVSIE_CreateEditControl ENDP


;-------------------------------------------------------------------------------------
; Listview requires LVS_EX_FULLROWSELECT for it to pick up each item clicked
;-------------------------------------------------------------------------------------
LVSIE_EditControlProc PROC USES EBX ECX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL hListview:DWORD
    LOCAL iItem:DWORD
    LOCAL iSubItem:DWORD
    LOCAL lpControlInitProc:DWORD
    LOCAL lpControlProc:DWORD
    LOCAL hHeader:DWORD
    LOCAL hControl:DWORD
    LOCAL rect:RECT
    LOCAL dwAllowWraparound:DWORD
    
    ; if user provided us with a proc for handling stuff themselves we call that first before doing anything
    mov eax, uMsg
    ;.IF eax == WM_DESTROY || eax == WM_NCDESTROY || eax == WM_KILLFOCUS || eax == WM_INITDIALOG || eax == WM_NOTIFY || eax == WM_COMMAND; prevent user from these for safety 
    ;.ELSE
    .IF eax == WM_CHAR || eax == WM_KEYDOWN || eax == WM_COMMAND
        mov ebx, dwRefData
        mov eax, [ebx].LVSIEDATA.lpControlProc
        mov lpControlProc, eax
        .IF eax != NULL
            ;mov eax, [ebx].LVSIEDATA.hControl
            ;mov hControl, eax
            mov eax, [ebx].LVSIEDATA.iItem
            mov iItem, eax
            mov eax, [ebx].LVSIEDATA.iSubItem
            mov iSubItem, eax
            push iSubItem
            push iItem
            push lParam
            push wParam
            push uMsg
            push hWin ;hControl
            call lpControlProc
            .IF eax == FALSE ; if user returned false, then they didnt want the normal messages to go through.
                ret
            .ENDIF
        .ENDIF
    .ENDIF
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Offset LVSIE_LVEditControlProc, uIdSubclass ; remove our temp subclass of listview (it was just for our WM_NOTIFY and WM_COMMAND events)
        .IF dwRefData != NULL
            Invoke GlobalFree, dwRefData ; Free the memory we allocated for our subclass data when we created control, dont need it anymore
        .ENDIF
        Invoke RemoveWindowSubclass, hWin, Offset LVSIE_EditControlProc, uIdSubclass ; remove editbox subclass before we leave it.

    .ELSEIF eax == WM_INITDIALOG
        mov ebx, dwRefData
        mov eax, [ebx].LVSIEDATA.lpControlInitProc
        mov lpControlInitProc, eax 
        
        .IF eax != NULL
            mov eax, [ebx].LVSIEDATA.iItem
            mov iItem, eax
            mov eax, [ebx].LVSIEDATA.iSubItem
            mov iSubItem, eax
            mov eax, [ebx].LVSIEDATA.hListview
            mov hListview, eax
            mov eax, [ebx].LVSIEDATA.hControl
            ;mov hControl, eax
            ;mov eax, [ebx].LVSIEDATA.lParam
            ;PrintDec hWin
             ; call user's lpControlInitProc
            push eax
            push iSubItem
            push iItem
            push hWin ;hControl
            push hListview
            call lpControlInitProc  ; same as if we done this: Invoke SubItemControlInitProc, hLV, hControl, dwItem, dwSubItem, lParam
            .IF eax == FALSE ; if they returned false then we dont go ahead with control and we destroy it and exit
                Invoke SendMessage, hWin, WM_CLOSE, 0, 0
                ret
            .ENDIF
            ret
        .ENDIF

    .ELSEIF eax == WM_COMMAND
		mov eax, wParam
		shr eax, 16
	    .IF eax == EN_CHANGE ; tell control something changes, so save is needed
            mov ebx, dwRefData
            mov eax, TRUE
            mov [ebx].LVSIEDATA.dwChangesToSave, eax
	    .ENDIF

    .ELSEIF eax == WM_NOTIFY
        mov ebx, dwRefData
        mov eax, [ebx].LVSIEDATA.hHeader
        mov hHeader, eax
        
        mov ecx, lParam
        mov ebx, [ecx].NMHDR.hwndFrom
        mov eax, [ecx].NMHDR.code
        
        .IF ebx == hHeader ; if user has decided to resize a column header that our control is in...
            .IF eax == HDN_ITEMCHANGEDW
                mov ebx, dwRefData
                mov eax, [ebx].LVSIEDATA.hControl
                mov hControl, eax                
                ;mov eax, [ebx].LVSIEDATA.iSubItem
;                mov iSubItem, eax
;                mov ecx, lParam
;                mov ebx, (NMHEADER PTR [ecx]).iItem
;                .IF ebx <= iSubItem ; does it match our column for the one our control is in?
;                    mov ebx, dwRefData
;                    mov eax, [ebx].LVSIEDATA.hListview
;                    mov hListview, eax                  
;                    mov eax, [ebx].LVSIEDATA.hControl
;                    mov hControl, eax
;                    ; Fetch some values for adjusting our control
;;                    mov eax, [ebx].LVSIEDATA.dwControlRect.bottom
;;                    mov rect.bottom, eax
;;                    Invoke ListViewGetColumnWidth, hListview, iSubItem
;;                    dec eax
;;                    mov rect.right, eax
;                    ; Do the actual adjustment of control
                    Invoke SetWindowPos, hControl, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOZORDER +SWP_HIDEWINDOW + SWP_NOCOPYBITS + SWP_NOSENDCHANGING ;+ SWP_NOREDRAW
                ;.ENDIF
            .ENDIF
        .ENDIF   

    .ELSEIF eax == WM_GETDLGCODE
        mov eax, DLGC_WANTALLKEYS ;DLGC_WANTCHARS
        ret
    
    .ELSEIF eax == WM_SETTEXT || eax == WM_PASTE || eax == WM_CUT
        mov ebx, dwRefData
        mov eax, TRUE
        mov [ebx].LVSIEDATA.dwChangesToSave, eax ; tell control we DO have something to save
        
    .ELSEIF eax == WM_KILLFOCUS
        mov ebx, dwRefData
        mov eax, [ebx].LVSIEDATA.dwChangesToSave
        .IF eax == TRUE ; check if something has changed, and if so we save the text back
            mov ebx, dwRefData
            mov eax, [ebx].LVSIEDATA.iItem
            mov iItem, eax
            mov eax, [ebx].LVSIEDATA.iSubItem
            mov iSubItem, eax
            mov eax, [ebx].LVSIEDATA.hListview
            mov hListview, eax
            lea ebx, [ebx].LVSIEDATA.szText
            Invoke GetWindowText, hWin, ebx, MAX_PATH
            Invoke ListViewSetItemText, hListview, iItem, iSubItem, ebx
        .ENDIF
        ;mov ebx, dwRefData
        ;mov eax, [ebx].LVSIEDATA.hListview
        ;mov hListview, eax        
        ;.IF wParam != eax
        ;    Invoke SetFocus, eax
        ;.ENDIF
        ;mov ebx, dwRefData
        ;mov eax, [ebx].LVSIEDATA.hControl
        ;.IF eax != NULL
        ;    Invoke DestroyWindow, eax
        ;.ENDIF
  		Invoke DestroyWindow, hWin

    .ELSEIF eax == WM_CHAR
        mov eax, wParam ; character stored in eax
        .IF al == VK_BACK ; allow backspace key
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            ret
        .ENDIF
    
    .ELSEIF eax == WM_KEYDOWN
        .IF wParam == VK_ESCAPE
            mov ebx, dwRefData
            mov eax, FALSE
            mov [ebx].LVSIEDATA.dwChangesToSave, eax ; tell control we DONT have something to save
            Invoke SendMessage, hWin, WM_CLOSE, 0, 0
            ret
        
        .ELSEIF wParam == VK_DOWN || wParam == VK_UP
            Invoke GetKeyState, VK_SHIFT
            AND eax, 08000h
            .IF eax == 08000h
                mov ebx, dwRefData
                mov eax, TRUE
                mov [ebx].LVSIEDATA.dwChangesToSave, eax ; tell control we DO have something to save
                mov eax, [ebx].LVSIEDATA.iItem
                mov iItem, eax
                mov eax, [ebx].LVSIEDATA.iSubItem
                mov iSubItem, eax
                mov eax, [ebx].LVSIEDATA.hListview
                mov hListview, eax
                ;mov eax, [ebx].LVSIEDATA.hControl
                ;mov hControl, eax
                mov eax, [ebx].LVSIEDATA.hHeader
                mov hHeader, eax
                mov eax, [ebx].LVSIEDATA.dwAllowWraparound
                mov dwAllowWraparound, eax
                
                .IF wParam == VK_DOWN
                    mov eax, LVSIE_DOWN
                .ELSE
                    mov eax, LVSIE_UP
                .ENDIF
                Invoke LVSIE_SetNextItem, hListview, iItem, iSubItem, dwAllowWraparound, eax
                .IF eax == TRUE
                    Invoke SendMessage, hWin, WM_CLOSE, 0, 0
                    ret
                .ENDIF
            .ENDIF
        
        .ELSEIF wParam == VK_TAB
            mov ebx, dwRefData
            mov eax, TRUE
            mov [ebx].LVSIEDATA.dwChangesToSave, eax ; tell control we DO have something to save
            mov eax, [ebx].LVSIEDATA.iItem
            mov iItem, eax
            mov eax, [ebx].LVSIEDATA.iSubItem
            mov iSubItem, eax
            mov eax, [ebx].LVSIEDATA.hListview
            mov hListview, eax
            ;mov eax, [ebx].LVSIEDATA.hControl
            ;mov hControl, eax
            mov eax, [ebx].LVSIEDATA.hHeader
            mov hHeader, eax
            mov eax, [ebx].LVSIEDATA.dwAllowWraparound
            mov dwAllowWraparound, eax
            ;Invoke LVSIE_GetNextCell, hListview, hHeader, hWin, iItem, iSubItem, dwAllowWraparound ;hControl

            Invoke GetKeyState, VK_SHIFT
            AND eax, 08000h
            .IF eax == 08000h
                mov eax, LVSIE_LEFT
            .ELSE
                mov eax, LVSIE_RIGHT
            .ENDIF
            Invoke LVSIE_SetNextItem, hListview, iItem, iSubItem, dwAllowWraparound, eax
            .IF eax == TRUE
                Invoke SendMessage, hWin, WM_CLOSE, 0, 0
                ret
            .ENDIF
        
        .ELSEIF wParam == VK_RETURN
            mov ebx, dwRefData
            mov eax, TRUE
            mov [ebx].LVSIEDATA.dwChangesToSave, eax ; tell control we DO have something to save
            Invoke SendMessage, hWin, WM_CLOSE, 0, 0
            ret
        
        .ELSE
            ;PrintDec wParam
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            ret
        .ENDIF            
            
    .ENDIF
    
    
    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam 

    ret

LVSIE_EditControlProc ENDP


;-------------------------------------------------------------------------------------
; Listview subclass to forward on wm_command and wm_notify events for LVSIE_EditControlProc
;-------------------------------------------------------------------------------------
LVSIE_LVEditControlProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL nScrollCode:DWORD
    LOCAL nPos:DWORD
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Offset LVSIE_LVEditControlProc, uIdSubclass
        
    .ELSEIF eax == WM_COMMAND || eax == WM_NOTIFY ; pass this back to our editbox proc
        Invoke LVSIE_EditControlProc, hWin, uMsg, wParam, lParam, uIdSubclass, dwRefData
    
    .ELSEIF eax == WM_HSCROLL || eax == WM_VSCROLL ; set focus to listview to destroy our control otherwise weird stuff happends (similar to listview col resizing)
        mov ebx, dwRefData
        mov eax, [ebx].LVSIEDATA.hListview
        Invoke SetFocus, eax
         
;		mov eax, wParam
;		shr eax, 16
;		mov nPos, eax
;		mov eax, wParam
;		and eax, 0FFFFh
;		mov nScrollCode, eax
;        
;        PrintDec nScrollCode
;        PrintDec nPos
    
    .ENDIF
    
    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
    ret

LVSIE_LVEditControlProc ENDP


;-------------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------------
LVSIE_SetNextItem PROC USES EBX hListview:DWORD, iItem:DWORD, iSubItem:DWORD, dwWrapAround:DWORD, dwDirection:DWORD
    LOCAL nTotalCols:DWORD
    LOCAL nTotalRows:DWORD
    LOCAL nNextItem:DWORD
    LOCAL nNextSubItem:DWORD
    LOCAL hLVParent:DWORD
    
    IFDEF DEBUG32
    PrintLine
    .IF dwDirection == 0
        PrintText 'Right'
    .ELSEIF dwDirection == 1
        PrintText 'Left'
    .ELSEIF dwDirection == 2
        PrintText 'Down'
    .ELSEIF dwDirection == 3
        PrintText 'Up'
    .ENDIF
    ENDIF
    
    Invoke GetParent, hListview
    mov hLVParent, eax
    
    Invoke ListViewGetColumnCount, hListview
    mov nTotalCols, eax
    Invoke ListViewGetItemCount, hListview
    mov nTotalRows, eax
    
    mov eax, dwDirection
    .IF eax == 0 ; right - default - tab
    
        mov eax, nTotalCols
        dec eax ; for 0 based cols
        mov ebx, iSubItem
        inc ebx
        .IF ebx <= eax
            mov nNextSubItem, ebx
            mov eax, iItem
            mov nNextItem, eax
        .ELSE
            .IF dwWrapAround == TRUE ; wrap to next line down, 0 subitem
                mov nNextSubItem, 0
                mov eax, nTotalRows
                dec eax ; for 0 based rows
                mov ebx, iItem
                inc ebx
                .IF ebx <= eax
                    mov nNextItem, ebx
                .ELSE
                    mov nNextItem, 0 ; at last cell so go back to 0,0
                .ENDIF
            .ELSE
                Invoke GetNextDlgTabItem, hLVParent, hListview, FALSE
                mov eax, FALSE
                ret
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == 1 ; left (back) - shift+tab
        
        mov eax, nTotalCols
        dec eax ; for 0 based cols
        mov ebx, iSubItem
        dec ebx
        .IF sdword ptr ebx >= 0
            mov nNextSubItem, ebx
            mov eax, iItem
            mov nNextItem, eax            
        .ELSE
            .IF dwWrapAround == TRUE ; wrap to next line up, total cols-1 subitem
                mov eax, nTotalCols
                dec eax ; for 0 based col count
                mov nNextSubItem, eax
                
                mov eax, nTotalRows
                dec eax ; for 0 based rows
                mov ebx, iItem
                dec ebx
                .IF sdword ptr ebx >= 0
                    mov nNextItem, ebx
                .ELSE
                    mov eax, nTotalRows
                    dec eax ; for 0 based row count
                    mov nNextItem, eax ; at first cell 0,0 so go back to totalrows-1, totalcols-1
                .ENDIF
            .ELSE
                Invoke GetNextDlgTabItem, hLVParent, hListview, TRUE
                mov eax, FALSE
                ret
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == 2 ; down
        mov eax, iSubItem
        mov nNextSubItem, eax
        
        mov eax, nTotalRows
        dec eax ; for 0 based rows
        mov ebx, iItem
        inc ebx
        .IF ebx <= eax
            mov nNextItem, ebx
        .ELSE
            .IF dwWrapAround == TRUE ; wrap to first line
                mov nNextItem, 0
             .ELSE
                mov eax, FALSE
                ret
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == 3 ; up
        mov eax, iSubItem
        mov nNextSubItem, eax

        mov eax, nTotalRows
        dec eax ; for 0 based rows
        mov ebx, iItem
        dec ebx
        .IF sdword ptr ebx >= 0
            mov nNextItem, ebx
        .ELSE
            .IF dwWrapAround == TRUE ; wrap to last line
                mov eax, nTotalRows
                dec eax ; for 0 based row count
                mov nNextItem, eax
             .ELSE
                mov eax, FALSE
                ret
            .ENDIF
        .ENDIF
    
    .ENDIF

    IFDEF DEBUG32
    PrintDec nNextItem
    PrintDec nNextSubItem
    ENDIF
    
    Invoke SendMessage, hListview, LVM_ENSUREVISIBLE, nNextItem, TRUE
    Invoke ListViewEnsureSubItemVisible, hListview, nNextSubItem
    
    ; generate our fake NM_CLICK to activate next cell
    lea ebx, lvsienmia
    mov eax, hListview
    mov [ebx].NMITEMACTIVATE.hdr.hwndFrom, eax
    mov [ebx].NMITEMACTIVATE.hdr.code, NM_CLICK
    mov eax, nNextItem
    mov [ebx].NMITEMACTIVATE.iItem, eax
    mov eax, nNextSubItem
    mov [ebx].NMITEMACTIVATE.iSubItem, eax
    
    Invoke SendMessage, hLVParent, WM_NOTIFY, hListview, Addr lvsienmia
    mov eax, TRUE
    ret

LVSIE_SetNextItem ENDP


;-------------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------------
LVSIE_GetNextCell PROC hListview:DWORD, hHeader:DWORD, hControl:DWORD, iItem:DWORD, iSubItem:DWORD, dwWrapAround:DWORD
    LOCAL nTotalCols:DWORD
    LOCAL nTotalRows:DWORD
    LOCAL nNextItem:DWORD
    LOCAL nNextSubItem:DWORD
    LOCAL nLVRowHeight:DWORD
    LOCAL nLVHdrHeight:DWORD
    LOCAL nYpos:DWORD
    LOCAL nXpos:DWORD
    LOCAL nCol:DWORD
    LOCAL pInputs[3]:INPUT
    LOCAL rect:RECT
    LOCAL rectcontrol:RECT
    LOCAL pt:POINT
    LOCAL ptbefore:POINT
    LOCAL nWidth:DWORD

    Invoke ListViewGetColumnCount, hListview
    mov nTotalCols, eax
    Invoke ListViewGetItemCount, hListview
    mov nTotalRows, eax

    ;PrintDec nTotalCols
    ;PrintDec nTotalRows
    
    mov rect.left, LVIR_BOUNDS
    invoke ListViewGetItemRect, hListview, 0, Addr rect
    
    mov eax, rect.bottom
    mov ebx, rect.top
    sub eax, ebx
    inc eax
    mov nLVRowHeight, eax
    
    mov eax, nTotalCols
    dec eax ; for 0 based cols
    mov ebx, iSubItem
    inc ebx
    .IF ebx <= eax
        mov nNextSubItem, ebx
        Invoke GetWindowRect, hControl, Addr rectcontrol
        Invoke GetWindowRect, hListview, Addr rect

        Invoke ListViewGetColumnWidth, hListview, nNextSubItem
        .IF eax != 0
            mov nWidth, eax
            shr eax, 1
            add eax, rectcontrol.right
            mov ebx, rect.right
            .IF eax >= ebx
                mov eax, rect.right
                mov ebx, rectcontrol.right
                sub eax, ebx
                shr eax, 1
                add eax, rectcontrol.right
            .ELSE
                mov eax, nWidth
                shr eax, 1
                add eax, rectcontrol.right
            .ENDIF
            
            mov nXpos, eax
            mov eax, rectcontrol.top
            add eax, 4
            mov nYpos, eax
           
            mov eax, TRUE
        
        .ELSE ; col is hidden so try next one over
            mov eax, FALSE
        .ENDIF

    .ELSE
        mov eax, FALSE
    .ENDIF

    .IF eax == FALSE
        .IF dwWrapAround == TRUE
            mov nNextSubItem, 0
            mov eax, nTotalRows
            dec eax ; for 0 based rows
            mov ebx, iItem
            inc ebx
            .IF ebx <= eax
                mov nNextItem, ebx
            .ELSE
                mov nNextItem, 0
            .ENDIF
        .ELSE
            mov eax, FALSE
            ret
        .ENDIF

        Invoke GetClientRect, hHeader, Addr rect
        mov eax, rect.bottom
        mov nLVHdrHeight, eax
    
        ;PrintDec nLVHdrHeight
        
        .IF nNextItem != 0
            
            ; got next item and subitem
            ; calc itemrect for this new item
            ;PrintDec nNextItem
            mov eax, nNextItem
            mov ebx, nLVRowHeight
            mul ebx
            add eax, nNextItem
            add eax, nLVHdrHeight
            mov nYpos, eax
        .ELSE
            mov eax, nLVHdrHeight
            mov ebx, nLVRowHeight
            shr ebx, 1
            add eax, ebx
            mov nYpos, eax
        .ENDIF
        ; we have y pos of where click is to go
    
        mov nCol, 0
        mov eax, 0
        mov nXpos, 0
        .WHILE eax < nNextSubItem
            Invoke ListViewGetColumnWidth, hListview, nCol
            add nXpos, eax
        .ENDW
        Invoke ListViewGetColumnWidth, hListview, nNextSubItem
        .IF eax != 0
            shr eax, 1
        .ENDIF
        add nXpos, eax
        inc nXpos
        ; we have x pos of where click is to go
        Invoke GetWindowRect, hListview, Addr rect
        mov eax, rect.left
        add eax, nXpos
        mov nXpos, eax
    
        mov eax, rect.top
        add eax, nYpos
        mov nYpos, eax

    .ENDIF
    
    mov eax, nXpos
    mov pt.x, eax
    mov eax, nYpos
    mov pt.y, eax
    
    ;Invoke ListViewEnsureVisible, hListview, nNextItem
    
    invoke SetCursorPos, pt.x, pt.y
    invoke mouse_event, MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN,pt.x,pt.y,NULL,NULL
    invoke mouse_event, MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP,pt.x,pt.y,NULL,NULL
    ;invoke SetCursorPos, ptbefore.x, ptbefore.y
    ;invoke mouse_event, MOUSEEVENTF_MOVE,ptbefore.x,ptbefore.y,NULL,NULL
;    Invoke RtlZeroMemory, addr pInputs, SIZEOF INPUT*3
;    
;    
;    mov pInputs[SIZEOF INPUT*0].INPUT.dwType, INPUT_MOUSE
;    mov pInputs[SIZEOF INPUT*1].INPUT.dwType, INPUT_MOUSE
;    mov pInputs[SIZEOF INPUT*2].INPUT.dwType, INPUT_MOUSE
;    
;    mov eax, nXpos ;pt.x ;nXpos
;    mov pInputs[SIZEOF INPUT *0].INPUT.mi._dx, eax
;    mov pInputs[SIZEOF INPUT *1].INPUT.mi._dx, eax
;    mov pInputs[SIZEOF INPUT *2].INPUT.mi._dx, eax
;    mov eax, nYpos ;pt.y ;nYpos
;    mov pInputs[SIZEOF INPUT *0].INPUT.mi.dy, eax
;    mov pInputs[SIZEOF INPUT *1].INPUT.mi.dy, eax
;    mov pInputs[SIZEOF INPUT *2].INPUT.mi.dy, eax
;    
;    mov pInputs[SIZEOF INPUT *0].INPUT.mi.MOUSEINPUT.mouseData, 0
;    mov pInputs[SIZEOF INPUT *1].INPUT.mi.MOUSEINPUT.mouseData, 0
;    mov pInputs[SIZEOF INPUT *2].INPUT.mi.MOUSEINPUT.mouseData, 0
;
;
;    mov pInputs[SIZEOF INPUT *0].INPUT.mi.MOUSEINPUT.dwFlags, MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN;+ + MOUSEEVENTF_ABSOLUTE
;    mov pInputs[SIZEOF INPUT *1].INPUT.mi.MOUSEINPUT.dwFlags, MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN ;MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_ABSOLUTE
;    mov pInputs[SIZEOF INPUT *2].INPUT.mi.MOUSEINPUT.dwFlags, MOUSEEVENTF_LEFTUP
;    
;    mov pInputs[SIZEOF INPUT *0].INPUT.mi.MOUSEINPUT.time, 0
;    mov pInputs[SIZEOF INPUT *1].INPUT.mi.MOUSEINPUT.time, 0
;    mov pInputs[SIZEOF INPUT *2].INPUT.mi.MOUSEINPUT.time, 0
;    
;    mov pInputs[SIZEOF INPUT *0].INPUT.mi.MOUSEINPUT.dwExtraInfo, 0
;    mov pInputs[SIZEOF INPUT *1].INPUT.mi.MOUSEINPUT.dwExtraInfo, 0
;    mov pInputs[SIZEOF INPUT *2].INPUT.mi.MOUSEINPUT.dwExtraInfo, 0
;
;    Invoke SendInput, 3, Addr pInputs, SIZEOF INPUT*3
    
    ret

LVSIE_GetNextCell ENDP






;----------------------------------------------------------------------------------------------------------------------------------
; Only included if LVSILIB is defined. Otherwise functions are used from the Listview.lib
;----------------------------------------------------------------------------------------------------------------------------------
IFDEF LVSIELIB

;**************************************************************************
; Gets the text of the specified item and subitem. 
;**************************************************************************
ListViewGetItemText PROC PUBLIC hListview:DWORD, nItemIndex:DWORD, nSubItemIndex:DWORD, lpszItemText:DWORD, lpszItemTextSize:DWORD
	LOCAL LVItem:LV_ITEM
	mov LVItem.imask, LVIF_TEXT
	mov eax, nItemIndex
	mov LVItem.iItem, eax	
	mov eax, nSubItemIndex
	mov LVItem.iSubItem, eax
    mov eax, lpszItemText
	mov LVItem.pszText, eax	
	mov eax, lpszItemTextSize
	mov LVItem.cchTextMax, eax	
	invoke SendMessage, hListview, LVM_GETITEMTEXT, nItemIndex, Addr LVItem
	ret
ListViewGetItemText ENDP

;**************************************************************************
; Sets the text of the specified item and subitem. 
;**************************************************************************
ListViewSetItemText PROC PUBLIC hListview:DWORD, nItemIndex:DWORD, nSubItemIndex:DWORD, lpszItemText:DWORD
	LOCAL LVItem:LV_ITEM
	mov LVItem.imask, LVIF_TEXT
	mov eax, nItemIndex
	mov LVItem.iItem, eax
	mov eax, nSubItemIndex
	mov LVItem.iSubItem, eax
    mov eax, lpszItemText
	mov LVItem.pszText, eax
	Invoke lstrlen, lpszItemText
	mov LVItem.cchTextMax, eax	
	mov LVItem.lParam, 0	
	invoke SendMessage, hListview, LVM_SETITEMTEXT, nItemIndex, Addr LVItem
	ret
ListViewSetItemText ENDP

;**************************************************************************
; Gets the bounding rect of the specified item. 
;
; The left member of the rect must be set before calling, to one of these:
;
; LVIR_BOUNDS       Returns the bounding rectangle of the entire item, 
;                   including the icon and label.
; LVIR_ICON         Returns the bounding rectangle of the icon / smallicon
; LVIR_LABEL        Returns the bounding rectangle of the item text.
; LVIR_SELECTBOUNDS Returns the union of the LVIR_ICON and LVIR_LABEL 
;                   rectangles, but excludes columns in report view.
;
;**************************************************************************
ListViewGetItemRect PROC PUBLIC hListview:DWORD, nItemIndex:DWORD, dwPtrRect:DWORD
	invoke SendMessage, hListview, LVM_GETITEMRECT, nItemIndex, dwPtrRect
	ret
ListViewGetItemRect ENDP

;**************************************************************************
; Gets the bounding rect of the specified subitem. 
;
; The left member of the rect must be set before calling, to one of these:
;
; LVIR_BOUNDS       Returns the bounding rectangle of the entire item, 
;                   including the icon and label.
; LVIR_ICON         Returns the bounding rectangle of the icon / smallicon
; LVIR_LABEL        Returns the bounding rectangle of the item text.
; LVIR_SELECTBOUNDS Returns the union of the LVIR_ICON and LVIR_LABEL 
;                   rectangles, but excludes columns in report view.
;
;**************************************************************************
ListViewGetSubItemRect PROC PUBLIC hListview:DWORD, nItemIndex:DWORD, dwPtrRect:DWORD
	invoke SendMessage, hListview, LVM_GETSUBITEMRECT, nItemIndex, dwPtrRect
	ret
ListViewGetSubItemRect ENDP

;**************************************************************************
; Returns the width of the specified column in eax, or 0 otherwise
;**************************************************************************
ListViewGetColumnWidth PROC PUBLIC hListview:DWORD, nCol:DWORD
	invoke SendMessage, hListview, LVM_GETCOLUMNWIDTH, nCol, 0
	ret
ListViewGetColumnWidth ENDP

;**************************************************************************
; Gets the format of a colum.

; Returns one of the following in eax: 

; LVCFMT_CENTER	Text is centered.
; LVCFMT_LEFT	Text is left-aligned.
; LVCFMT_RIGHT	Text is right-aligned.
; or -1 if invalid
; nCol is 0 based column index
;**************************************************************************
ListViewGetColumnFormat PROC PUBLIC hListview:DWORD, nCol:DWORD
    LOCAL LVC:LV_COLUMN
	mov LVC.imask, LVCF_FMT
	Invoke SendMessage, hListview, LVM_GETCOLUMN, nCol, Addr LVC
	.IF eax == TRUE
        mov eax, LVC.fmt
    .ELSE
        mov eax, -1
	.ENDIF
	ret  
ListViewGetColumnFormat ENDP

;**************************************************************************	
; Gets column count and returns it in eax
;**************************************************************************	
ListViewGetColumnCount PROC PUBLIC hListview:DWORD
    Invoke SendMessage, hListview, LVM_GETHEADER, NULL, NULL
    Invoke SendMessage, eax, HDM_GETITEMCOUNT, NULL, NULL
    ret
ListViewGetColumnCount ENDP

;**************************************************************************	
; Gets the item count (total rows) and returns it in eax
;**************************************************************************	
ListViewGetItemCount PROC PUBLIC hListview:DWORD
    Invoke SendMessage, hListview, LVM_GETITEMCOUNT, 0, 0
    ret
ListViewGetItemCount ENDP

;**************************************************************************	
; Get the item and subitem clicked.
; Returns true if an item and/or sub item have been clicked or false otherwise
; if true the buffers pointed to by lpdwItem and lpdwSubItem will contain
; the item and subitem clicked, otherwise they will contain -1
;
; Uses LVM_SUBITEMHITTEST to determine iItem and iSubItem.
; To fake NM_CLICK calls use ListViewGetItemClicked instead
; As that will use the NMITEMACTIVATE structure of NM_CLICK to retrieve
; the iItem and iSubItem values.
;**************************************************************************	
ListViewGetSubItemClicked PROC USES EBX hListview:DWORD, lpdwItem:DWORD, lpdwSubItem:DWORD
    LOCAL lvhi:LVHITTESTINFO
    

	Invoke GetCursorPos, Addr lvhi.pt
	Invoke ScreenToClient, hListview, addr lvhi.pt
	invoke SendMessage, hListview, LVM_SUBITEMHITTEST, 0, Addr lvhi ; returns the column and item that was clicked in lvhi
		
	Invoke SendMessage, hListview, LVM_GETITEMCOUNT, 0, 0
	.IF eax > lvhi.iItem ;0		
	    mov eax, lvhi.iItem
        mov ebx, lpdwItem
        .IF ebx != NULL
            mov [ebx], eax
        .ENDIF	 
	    mov eax, lvhi.iSubItem
        mov ebx, lpdwSubItem
        .IF ebx != NULL
            mov [ebx], eax
        .ENDIF	    
	    mov eax, TRUE
    .ELSE
        mov eax, -1
        mov ebx, lpdwItem
        .IF ebx != NULL
            mov [ebx], eax
        .ENDIF
        mov ebx, lpdwSubItem
        .IF ebx != NULL
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE
    .ENDIF
    ret

ListViewGetSubItemClicked ENDP


;**************************************************************************	
; Get the item and subitem clicked.
; Returns true if an item and/or sub item have been clicked or false otherwise
; if true the buffers pointed to by lpdwItem and lpdwSubItem will contain
; the item and subitem clicked, otherwise they will contain -1
;
; This is different than the ListViewGetSubItemClicked function, which uses
; LVM_SUBITEMHITTEST to determine iItem and iSubItem.
;
; This function uses the NMITEMACTIVATE structure of NM_CLICK to retrieve
; the iItem and iSubItem values.
; Thus allowing us to fake NM_CLICK calls if required (tab, shift-tab
; in listview to go forward, backward to next/prev subitem)
;
; It requires you pass the lParam value for it to work.
;
;**************************************************************************	
ListViewGetItemClicked PROC USES EBX ECX hListview:DWORD, lParam:DWORD, lpdwItem:DWORD, lpdwSubItem:DWORD
    LOCAL iItem:DWORD
    LOCAL iSubItem:DWORD
    
    mov ecx, lParam
    mov ebx, [ecx].NMHDR.hwndFrom
    mov eax, [ecx].NMHDR.code
        
    .IF ebx != hListview
        jmp ExitFalse
    .ENDIF
	.IF eax != NM_CLICK
	    jmp ExitFalse
	.ENDIF

	mov eax, (NMITEMACTIVATE ptr [ecx]).iItem
	mov iItem, eax
	mov eax, (NMITEMACTIVATE ptr [ecx]).iSubItem
	mov iSubItem, eax

ExitTrue:


    .IF eax == -1
        jmp ExitFalse
    .ENDIF
    mov eax, iItem
    mov ebx, lpdwItem
    .IF ebx != NULL
        mov [ebx], eax
    .ENDIF
    mov eax, iSubItem
    mov ebx, lpdwSubItem
    .IF ebx != NULL
        mov [ebx], eax
    .ENDIF
    
    mov eax, TRUE
    jmp Exit

ExitFalse:

    mov eax, -1
    mov ebx, lpdwItem
    .IF ebx != NULL
        mov [ebx], eax
    .ENDIF
    mov ebx, lpdwSubItem
    .IF ebx != NULL
        mov [ebx], eax
    .ENDIF
    mov eax, FALSE

Exit:    
    
    ret

ListViewGetItemClicked ENDP

;**************************************************************************	
; Ensures sub item is visible in listview
;**************************************************************************	
ListViewEnsureSubItemVisible PROC hListview:DWORD, nSubItemIndex:DWORD
    LOCAL rectlv:RECT
    LOCAL rectsubitem:RECT

    Invoke GetWindowLong, hListview, GWL_STYLE
    and eax, WS_HSCROLL
    .IF eax != WS_HSCROLL ; no scrollbar should mean we dont have to adjust anything for subitem
        ret
    .ENDIF

    ; Get area to put our editbox in
 	.IF nSubItemIndex == 0 ; LVM_GETSUBITEMRECT doesnt work with iSubItem == 0 so we calc it another way
	    mov rectsubitem.left, LVIR_BOUNDS
	    Invoke ListViewGetItemRect, hListview, 0, Addr rectsubitem
	    Invoke ListViewGetColumnWidth, hListview, 0
	    mov rectsubitem.right, eax
	.ELSE
    	mov eax, nSubItemIndex
    	mov rectsubitem.top, eax
    	mov rectsubitem.left, LVIR_BOUNDS
    	Invoke ListViewGetSubItemRect, hListview, 0, Addr rectsubitem
    .ENDIF

    Invoke GetClientRect, hListview, Addr rectlv
    
    mov eax, rectsubitem.right
    .IF eax > rectlv.right ;truerectlvright ;rectlv.right
        ;PrintText 'Need to move scrollbar right'
        mov eax, rectsubitem.right
        mov ebx, rectlv.right
        sub eax, ebx
        Invoke SendMessage, hListview, LVM_SCROLL, eax, 0
    .ELSE
        .IF sdword ptr rectsubitem.left < 0
            ;PrintText 'Need to move scrollbar left'
            mov eax, rectsubitem.left
            mov ebx, rectsubitem.right
            sub eax, ebx
            Invoke SendMessage, hListview, LVM_SCROLL, eax, 0
        .ENDIF
    .ENDIF
    ret

ListViewEnsureSubItemVisible ENDP

ENDIF

LVSIELIBEND


