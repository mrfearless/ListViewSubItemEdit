;.386
;.model flat,stdcall
;option casemap:none
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

include LVSIETest.inc





.code

start:

	Invoke GetModuleHandle,NULL
	mov hInstance, eax
	Invoke GetCommandLine
	mov CommandLine, eax
	Invoke InitCommonControls
	mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, offset icc
	
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize, sizeof WNDCLASSEX
	mov		wc.style, CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
	mov		wc.lpszMenuName, IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	Invoke LoadIcon, NULL, IDI_APPLICATION
	;Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
	;mov hIcoMain, eax ; main application icon
	mov		wc.hIcon, eax
	mov		wc.hIconSm, eax
	Invoke LoadCursor, NULL, IDC_ARROW
	mov		wc.hCursor,eax
	Invoke RegisterClassEx, addr wc
	Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
	mov hWnd, eax
	Invoke ShowWindow, hWnd, SW_SHOWNORMAL
	Invoke UpdateWindow, hWnd
	
	.WHILE TRUE
		invoke GetMessage,addr msg,NULL,0,0
        .BREAK .if !eax

        Invoke IsDialogMessage, hWnd, addr msg ; add in a reference to our currently selected child dialog so we can do tabbing between controls etc.
        .IF eax == 0
            invoke TranslateMessage,addr msg
            invoke DispatchMessage,addr msg
        .ENDIF
	.ENDW
	mov eax,msg.wParam			
	
;	.WHILE TRUE
;		invoke GetMessage, addr msg, NULL, 0, 0
;	  .BREAK .if !eax
;		Invoke TranslateMessage, addr msg
;		Invoke DispatchMessage, addr msg
;	.ENDW
;	mov eax, msg.wParam
	ret
WinMain endp


;-------------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;-------------------------------------------------------------------------------------
WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL lvhi:LVHITTESTINFO
	
	mov eax, uMsg
	.IF eax == WM_INITDIALOG
		push hWin
		pop hWnd
		; Init Stuff Here
	    Invoke GetDlgItem, hWin, IDC_TESTLV
	    mov hTESTLV, eax		
		
        Invoke TestLVInit, hTESTLV
        Invoke TestLVLoadData, hTESTLV		

    .ELSEIF eax == WM_NOTIFY
        mov ecx, lParam
        mov ebx, [ecx].NMHDR.hwndFrom
        mov eax, [ecx].NMHDR.code
        
        .IF ebx == hTESTLV

	        .IF eax == NM_CLICK ; right click popup
;	            ;PrintText 'NM_CLICK'
;    			invoke GetCursorPos, addr lvhi.pt
;    			invoke ScreenToClient, hTESTLV, addr lvhi.pt
;    			invoke SendMessage,hTESTLV,LVM_SUBITEMHITTEST,0, Addr lvhi ; returns the column and item that was clicked in lvhi
;    			
;    			;PrintDec lvhi.pt.x
;    			;PrintDec lvhi.pt.y
;    			
;    			Invoke SendMessage, hTESTLV, LVM_GETITEMCOUNT, 0, 0
;    			.IF (eax > lvhi.iItem)	            
;	                mov eax, lvhi.iItem
;	                mov iItem, eax
;	                mov eax, lvhi.iSubItem
;	                mov iSubItem, eax
	            
	            Invoke ListViewGetSubItemClicked, hTESTLV, Addr iItem, Addr iSubItem
	            .IF eax == TRUE
	                
	                ;PrintDec iItem
	                ;PrintDec iSubItem
	                
	                lea ebx, lvsie
	                mov eax, iItem
	                mov [ebx].LVSUBITEMEDIT.iItem, eax
	                mov eax, iSubItem
	                mov [ebx].LVSUBITEMEDIT.iSubItem, eax
	                mov eax, hTESTLV
	                mov [ebx].LVSUBITEMEDIT.hListview, eax
	                mov eax, hWin
	                mov [ebx].LVSUBITEMEDIT.hParent, eax
	                mov eax, LVSIC_EDIT
	                mov [ebx].LVSUBITEMEDIT.dwControlType, eax
	                lea eax, TestEditInitProc ; or mov eax, offset TestEditInitProc
	                mov [ebx].LVSUBITEMEDIT.lpControlInitProc, eax
	                lea eax, TestEditProc
	                mov [ebx].LVSUBITEMEDIT.lpControlProc, eax
	                mov eax, TRUE
	                mov [ebx].LVSUBITEMEDIT.dwAllowWraparound, eax
	                Invoke ListViewSubItemEdit, Addr lvsie
	                
	            .ELSE
	                ;PrintText 'ListViewGetSubItemClicked Failed'
	            .ENDIF
	        
	        .ELSEIF eax == NM_SETFOCUS
	            ;PrintText 'NM_SETFOCUS'
	        
	        .ELSEIF eax == NM_KILLFOCUS
	            ;PrintText 'NM_KILLFOCUS'
	        
	        .ENDIF
	        
        .ENDIF
		
	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
		.IF eax == IDM_FILE_EXIT
			Invoke SendMessage,hWin,WM_CLOSE,0,0
			
		.ELSEIF eax == IDM_HELP_ABOUT
			Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
			
		.ENDIF

	.ELSEIF eax == WM_CLOSE
		Invoke DestroyWindow,hWin
		
	.ELSEIF eax == WM_DESTROY
		Invoke PostQuitMessage,NULL
		
	.ELSE
		Invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp



;------------------------------------------------------------------------------
; TestLVInit
;------------------------------------------------------------------------------
TestLVInit PROC hLV:DWORD
    
	mov eax, LVS_EX_FULLROWSELECT or LVS_EX_INFOTIP or LVS_EX_DOUBLEBUFFER  or LVS_EX_GRIDLINES or LVS_EX_FLATSB;or LVS_EX_FULLROWSELECT or LVS_EX_FLATSB  or LVS_EX_BORDERSELECTLVS_EX_FULLROWSELECT or LVS_EX_HEADERDRAGDROP  or
	Invoke SendMessage, hLV, LVM_SETEXTENDEDLISTVIEWSTYLE, eax, eax ; Do It
    
    Invoke ListViewInsertColumn, hLV, LVCFMT_RIGHT, 50d, Addr szLVBHdr0     ; Entry
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 100d, Addr szLVBHdr1     ; Entry Offset
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 200d, Addr szLVBHdr2     ; Filename
    Invoke ListViewInsertColumn, hLV, LVCFMT_RIGHT, 100d, Addr szLVBHdr3    ; Filesize
    Invoke ListViewInsertColumn, hLV, LVCFMT_RIGHT, 100d, Addr szLVBHdr4    ; File location
    Invoke ListViewInsertColumn, hLV, LVCFMT_RIGHT, 100d, Addr szLVBHdr5    ; Offset Bif Filename
    Invoke ListViewInsertColumn, hLV, LVCFMT_RIGHT, 100d, Addr szLVBHdr6    ; Length Bif Filename
    ;Invoke SendMessage, hLV, LVM_SETCOLUMNWIDTH, 4, LVSCW_AUTOSIZE_USEHEADER

    ret
TestLVInit ENDP



;------------------------------------------------------------------------------
; TestLVLoadData
;------------------------------------------------------------------------------
TestLVLoadData PROC hLV:DWORD
    LOCAL nIndex:DWORD
    mov nIndex, 0
    
    Invoke ListViewDeleteAll, hLV

    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem1, 0
    Invoke ListViewSetItemParam, hLV, nIndex, 0
    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset1
    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize1
    inc nIndex
    
    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem2, 0
    Invoke ListViewSetItemParam, hLV, nIndex, 1
    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset2
    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize2
    inc nIndex
    
    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem3, 0
    Invoke ListViewSetItemParam, hLV, nIndex, 2
    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset3
    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize3    
    inc nIndex

    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem4, 0
    Invoke ListViewSetItemParam, hLV, nIndex, 3
    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset4
    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize4
    inc nIndex

    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem5, 0
    Invoke ListViewSetItemParam, hLV, nIndex, 4
    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset5
    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize5  
    inc nIndex

    ret

TestLVLoadData ENDP


;------------------------------------------------------------------------------
; TestEditInitProc
;------------------------------------------------------------------------------
TestEditInitProc PROC hLV:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
    LOCAL szString[MAX_PATH]:BYTE
    
    PrintDec hLV
    PrintDec hControl
    ;PrintDec dwItem
    ;PrintDec dwSubItem
    ;PrintDec lParam
    
    ;Invoke GetWindowText, hControl, Addr szString, SIZEOF szString
    
    ;Invoke MessageBox, 0, Addr szString, Addr szString, MB_OK
    
    mov eax, TRUE
    ret

TestEditInitProc ENDP


TestEditProc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM,dwItem:DWORD,dwSubItem:DWORD
    LOCAL wNotifyCode:DWORD
    
    .if uMsg==WM_CHAR
        mov eax,wParam
        .if (al>="0" && al<="9") || al==VK_BACK
            ;.IF dwSubItem == 2 
                mov eax, TRUE
                ret
            ;.ENDIF

        .elseif (al>="a" && al<="z") || (al>="A" && al<="Z") || al == ' '     
            .IF dwSubItem == 0 || dwSubItem >= 3
                mov eax, TRUE
                ret
            .ENDIF
        .else
            Invoke GetKeyState, VK_CONTROL ; check for ctrl+x, ctrl+c, ctrl+v
            and eax, 08000h
            .IF eax == 08000h
                mov eax, wParam
                .if al == 03h || al == 18h ||  al == 16h ; ctrl + x, ctrl + c, ctrl+v
                    mov eax, TRUE
                    ret
                ;.else
                    ;PrintDec eax
                .endif
            .endif
        .endif
    
    .elseif uMsg == WM_COMMAND
		mov eax, wParam
		shr eax, 16
		mov wNotifyCode, eax
		mov eax, wParam
		and eax, 0FFFFh
		
		PrintDec eax
		PrintDec lParam
		PrintDec wNotifyCode
    
    .else
        mov eax, TRUE
        ret
    .endif
    xor eax,eax
    ret

TestEditProc ENDP


end start








































