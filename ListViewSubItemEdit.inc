

;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item Edit Prototypes
;------------------------------------------------------------------------------------------------------------------------------------------------------------
ListViewSubItemEdit         PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, dwItem, dwSubItem, lpLVSUBITEMEDIT. Pointer to structure containing information needed to create subitem edit control
ListViewGetItemClicked      PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, lParam, lpdwItem, lpdwSubItem. Returns iItem + iSubItem in the buffers. EAX == TRUE if clicked item/subitem
ListViewInsertColumn        PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, dwFormat, dwWidth, lpszColumnText
ListViewInsertItem		    PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, dwItem, lpszItemText, dwImageListIndex
ListViewInsertSubItem	    PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, dwItem, dwSubItem, lpszSubItemText

;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item Edit Structure
;------------------------------------------------------------------------------------------------------------------------------------------------------------
LVSUBITEMEDIT               STRUCT
    dwControlType           DD ?    ; (Required) see table below for types. Note not all supported yet.
    lpControlInitProc       DD ?    ; (Optional) pointer to custom function for initilization. Return true to continue or false - which exits control and destroys it
    lpControlProc           DD ?    ; (Optional) pointer to custom callback proc for handling WM_CHAR, WM_KEYDOWN and WM_COMMAND. Return true to continue or false to prevent. 
    lpControlValidProc      DD ?    ; (Optional) pointer to custom function for validation of control before it closes. Return true to continue or false to prevent.
    dwOptions               DD ?    ; Combination of option flags, see below for more info.
    lParam                  DD ?    ; (Optional) custom value to pass, for use in lpControlInitProc and lpControlValidProc proc
LVSUBITEMEDIT               ENDS


.CONST
;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item custom message:
;------------------------------------------------------------------------------------------------------------------------------------------------------------
LVSIEM_SETSTYLE             EQU WM_USER + 1


;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item Options: One from each catgory. If dwOptions == 0 then default of LVSIO_NAV_ALL or LVSIO_WRAP_ALL or LVSIO_NOTIFY_NMCLICK is applied
;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Navigation Key options:
LVSIO_DEFAULT               EQU 0 ; LVSIS_NAV_ALL + LVSIS_WRAP_ALL + LVSIS_NOTIFY_NMCLICK
LVSIO_NAV_NONE              EQU 1
LVSIO_NAV_TABS              EQU 2
LVSIO_NAV_ARROWS            EQU 8
LVSIO_NAV_ALL               EQU LVSIO_NAV_TABS or LVSIO_NAV_ARROWS

; Wraparound options:
LVSIO_WRAP_NONE             EQU 10h
LVSIO_WRAP_HORZ             EQU 20h
LVSIO_WRAP_VERT             EQU 80h
LVSIO_WRAP_ALL              EQU LVSIO_WRAP_HORZ + LVSIO_WRAP_VERT

; Notification message to send when navigating to next/prev/up/down subitem:
LVSIO_NOTIFY_NMCLICK        EQU 400h    ; WN_NOTIFY with NM_CLICK
LVSIO_NOTIFY_NMDBLCLK       EQU 800h    ; WN_NOTIFY with NM_DBLCLK
LVSIO_NOTIFY_NMRCLICK       EQU 1000h   ; WN_NOTIFY with NM_RCLICK
LVSIO_NOTIFY_NMRDBLCLK      EQU 2000h   ; WN_NOTIFY with NM_RDBLCLK



;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item Controls
;------------------------------------------------------------------------------------------------------------------------------------------------------------
LVSIC_INVALID               EQU -1  ; Invalid item
LVSIC_EDIT                  EQU  0  ; Edit
LVSIC_COMBO                 EQU  1  ; Dropdownlist
LVSIC_EDITCOMBO             EQU  2  ; Dropdown(editable)
LVSIC_STATIC                EQU  3  ; Not editable text
LVSIC_TEXT                  EQU       LVSIC_STATIC
LVSIC_COLOR                 EQU  4  ; Color
LVSIC_FONT                  EQU  5  ; Font
LVSIC_FILE                  EQU  6  ; File select dialog
LVSIC_FOLDER                EQU  7  ; Folder select dialog
LVSIC_CHECK                 EQU  8  ; BOOL
LVSIC_IP                    EQU  9  ; IP Address
LVSIC_DATE                  EQU 10  ; Date
LVSIC_TIME                  EQU 11  ; Time
LVSIC_DATETIME              EQU 12  ; Date & Time


;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Notes and example
;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Optional call back and custom procedures prototypes:
;
; lpControlInitProc         PROC hListview:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
; lpControlProc             PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, dwItem:DWORD, dwSubItem:DWORD
; lpControlValidProc        PROC hListview:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
;
; Pass the address of the custom callback by using one of the following. Assume in our examples we have a TestInitProc and a TestProc
;
;
; TestInitProc              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
; TestProc                  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
;
; TestInitProc              PROC hListview:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
; TestProc                  PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, dwItem:DWORD, dwSubItem:DWORD
; TestValidProc             PROC hListview:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
;
;
; .DATA
; lvsie     LVSUBITEMEDIT <>

; .DATA
; iItem     DD ?
; iSubItem  DD ?
; hListview DD ?
;
; .CODE
;
;    .
;    .
;    .
;
;
;    .ELSEIF eax == WM_NOTIFY
;        mov ecx, lParam
;        mov ebx, [ecx].NMHDR.hwndFrom
;        mov eax, [ecx].NMHDR.code
;        .IF ebx == hListview
;	        .IF eax == NM_CLICK 
;	            Invoke ListViewGetItemClicked, hListview, lParam, Addr iItem, Addr iSubItem
;	            .IF eax == TRUE ; user did click some item/subitem in our listview, so go ahead and display our control
;                    lea ebx, lvsie

;                    mov [ebx].LVSUBITEMEDIT.dwControlType, LVSIC_EDIT
;                    lea eax, TestInitProc ; or mov eax, offset TestInitProc
;                    mov [ebx].LVSUBITEMEDIT.lpControlInitProc, eax
;                    mov eax, offset TestProc ; or lea eax, TestProc
;                    mov [ebx].LVSUBITEMEDIT.lpControlProc, eax
;                    mov [ebx].LVSUBITEMEDIT.dwAllowWraparound, TRUE
;                    Invoke ListViewSubItemEdit, hListivew, iItem, iSubItem, Addr lvsie 
;
;                    ; TestInitProc gets called just before control is shown
;                    ; TestProc gets called for handling WM_CHAR, WM_KEYDOWN and WM_COMMAND messages.
;                    ; TestProc allows user to override specific chars and keys, for example to make a hex only editbox control or just allow letters
;                    ; TestValidProc gets called user presses enter or has changed data and control loses focus via mouse or nav keys
;                .ENDIF
;            .ENDIF
;        .ENDIF
; 
;    .
;    .
;    .
;
;
;---------------------------------------------------------------------------------------------------
;
;
;    TestInitProc PROC hLV:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
;        ; do any initialzation here.
;        mov eax, TRUE
;        ret
;    TestInitProc ENDP
;    
;    TestProc PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, dwItem:DWORD, dwSubItem:DWORD
;        .if uMsg==WM_CHAR
;            mov eax,wParam
;            .if (al>="0" && al<="9") || al==VK_BACK
;                mov eax, TRUE
;                ret
;    
;            .elseif (al>="a" && al<="z") || (al>="A" && al<="Z") || al == ' '     
;                .IF dwSubItem == 0 || dwSubItem >= 3
;                    mov eax, TRUE
;                    ret
;                .ENDIF
;            .else
;                Invoke GetKeyState, VK_CONTROL ; check for ctrl+x, ctrl+c, ctrl+v
;                and eax, 08000h
;                .IF eax == 08000h
;                    mov eax, wParam
;                    .if al == 03h || al == 18h ||  al == 16h ; ctrl + x, ctrl + c, ctrl+v
;                        mov eax, TRUE
;                        ret
;                    .endif
;                .endif
;            .endif
;        .else
;            mov eax, TRUE
;            ret
;        .endif
;        xor eax,eax
;        ret
;    TestProc ENDP

;------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------













