

;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item Edit Prototypes
;------------------------------------------------------------------------------------------------------------------------------------------------------------
ListViewSubItemEdit         PROTO :DWORD                        ; ptrLVSUBITEMEDIT. Pointer to structure containing information needed to create subitem edit control
ListViewGetItemClicked      PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, lParam, lpdwItem, lpSubItem. Returns iItem + iSubItem in the buffers. EAX == TRUE if clicked item/subitem
ListViewInsertColumn        PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, dwFormat, dwWidth, lpszColumnText
ListViewInsertItem		    PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, nItemIndex, lpszItemText, nImageListIndex
ListViewInsertSubItem	    PROTO :DWORD, :DWORD, :DWORD, :DWORD; hListview, nItemIndex, nSubItemIndex, lpszSubItemText

;------------------------------------------------------------------------------------------------------------------------------------------------------------
; Listview Sub Item Edit Structure
;------------------------------------------------------------------------------------------------------------------------------------------------------------
LVSUBITEMEDIT               STRUCT
    iItem                   DD ?    ; (Required) item clicked
    iSubItem                DD ?    ; (Required) subitem clicked
    hListview               DD ?    ; (Required) handle to listview
    hParent                 DD ?    ; (Required) handle to parent, usually hWin of the listview
    dwControlType           DD ?    ; (Required) see table below for types. Note not all supported yet.
    lpControlInitProc       DD ?    ; (Optional) pointer to custom function for initilization. Return true to continue or false - which exits control and destroys it
    lpControlProc           DD ?    ; (Optional) pointer to custom callback proc for handling WM_CHAR, WM_KEYDOWN and WM_COMMAND. Return true to continue or false to prevent. 
    lpControlValidProc      DD ?    ; (Optional) pointer to custom function for validation of control before it closes. Return true to continue or false to prevent.
    dwAllowWraparound       DD ?    ; (Optional) true or false to allow next/prev up/dn to wrap to next line/row etc - experimental!
    lParam                  DD ?    ; (Optional) custom value to pass, for use in lpControlInitProc proc
LVSUBITEMEDIT               ENDS


.CONST
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
;
; Pass the address of the custom callback by using one of the following. Assume in our examples we have a TestInitProc and a TestProc
;
;
; TestInitProc              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
; TestProc                  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
;
; TestInitProc              PROC hListview:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
; TestProc                  PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, dwItem:DWORD, dwSubItem:DWORD
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
;                    mov eax, iItem
;                    mov [ebx].LVSUBITEMEDIT.iItem, eax
;                    mov eax, iSubItem
;                    mov [ebx].LVSUBITEMEDIT.iSubItem, eax
;                    mov eax, hListview
;                    mov [ebx].LVSUBITEMEDIT.hListview, eax
;                    mov eax, hWin
;                    mov [ebx].LVSUBITEMEDIT.hParent, eax
;                    mov [ebx].LVSUBITEMEDIT.dwControlType, LVSIC_EDIT
;                    lea eax, TestInitProc ; or mov eax, offset TestInitProc
;                    mov [ebx].LVSUBITEMEDIT.lpControlInitProc, eax
;                    mov eax, offset TestProc ; or lea eax, TestProc
;                    mov [ebx].LVSUBITEMEDIT.lpControlProc, eax
;                    mov [ebx].LVSUBITEMEDIT.dwAllowWraparound, TRUE
;                    Invoke ListViewSubItemEdit, Addr lvsie 
;                    ; TestInitProc gets called just before control is shown
;                    ; TestProc gets called for handling WM_CHAR, WM_KEYDOWN and WM_COMMAND messages.
;                    ; this allows user to override specific chars and keys, for example to make a hex only editbox control or just allow letters
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













