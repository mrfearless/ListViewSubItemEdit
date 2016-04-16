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
	mov		wc.style, 0 ;CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
	mov		wc.lpszMenuName, IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	;Invoke LoadIcon, NULL, IDI_APPLICATION
	Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
	mov hIcoMain, eax ; main application icon
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
	            
	            Invoke ListViewGetItemClicked, hTESTLV, lParam, Addr iItem, Addr iSubItem
	            .IF eax == TRUE
	            ;mov ecx, lParam
	            ;mov eax, (NMITEMACTIVATE ptr [ecx]).iItem
	            ;mov iItem, eax
                
                
	            ;    mov eax, (NMITEMACTIVATE ptr [ecx]).iSubItem
	            ;    mov iSubItem, eax

	                
	                PrintDec iItem
	                PrintDec iSubItem
	            
	        
;	            ;PrintText 'NM_CLICK'
;    			invoke GetCursorPos, addr lvhi.pt
;    			invoke ScreenToClient, hTESTLV, addr lvhi.pt
;    			invoke SendMessage,hTESTLV,LVM_SUBITEMHITTEST,0, Addr lvhi ; returns the column and item that was clicked in lvhi
;    			
;    			;PrintDec lvhi.pt.x
;    			;PrintDec lvhi.pt.y
;    			
;    			Invoke SendMessage, hTESTLV, LVM_GETITEMCOUNT, 0, 0
;    			.IF (eax > lvhi.iItem)	            ;
;	                mov eax, lvhi.iItem
;	                mov iItem, eax
;	                mov eax, lvhi.iSubItem
;	                mov iSubItem, eax
	                
;	                PrintDec iItem
;	                PrintDec iSubItem
	            
	            ;Invoke ListViewGetSubItemClicked, hTESTLV, Addr iItem, Addr iSubItem
	            ;.IF eax == TRUE

	                
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
		
		.ELSEIF eax == IDC_TESTBUTTON
		    lea ebx, nmia
		    
		    mov eax, hTESTLV
		    mov [ebx].NMITEMACTIVATE.hdr.hwndFrom, eax
		    mov [ebx].NMITEMACTIVATE.hdr.code, NM_CLICK
		    
		    mov eax, 2
		    mov [ebx].NMITEMACTIVATE.iItem, eax
		    
		    mov eax, 2
		    mov [ebx].NMITEMACTIVATE.iSubItem, eax
		    
		    Invoke SendMessage, hWin, WM_NOTIFY, hTESTLV, Addr nmia
		    
			
		.ENDIF
    
    .ELSEIF eax == WM_SIZE
        .IF wParam != SIZE_MINIMIZED
            mov eax, lParam
            shr eax, 16
            sub eax, 205d
            mov ebx, lParam
            and ebx, 0FFFFh
            sub ebx, 40d
            Invoke SetWindowPos, hTESTLV, HWND_TOP, 0, 0, ebx, eax, SWP_NOMOVE + SWP_NOZORDER
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
    
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 130, CTEXT("Superpower")
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 130, CTEXT("Student Name")
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 60,  CTEXT("Age")
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 100d, CTEXT("Sex")
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 100d,  CTEXT("Classroom")
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 130d, CTEXT("Teacher")
    Invoke ListViewInsertColumn, hLV, LVCFMT_LEFT, 130d, CTEXT("Progress")
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

;    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem1, 0
;    Invoke ListViewSetItemParam, hLV, nIndex, 0
;    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset1
;    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize1
;    inc nIndex
;    
;    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem2, 0
;    Invoke ListViewSetItemParam, hLV, nIndex, 1
;    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset2
;    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize2
;    inc nIndex
;    
;    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem3, 0
;    Invoke ListViewSetItemParam, hLV, nIndex, 2
;    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset3
;    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize3    
;    inc nIndex
;
;    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem4, 0
;    Invoke ListViewSetItemParam, hLV, nIndex, 3
;    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset4
;    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize4
;    inc nIndex
;
;    Invoke ListViewInsertItem, hLV, nIndex, Addr szBDItem5, 0
;    Invoke ListViewSetItemParam, hLV, nIndex, 4
;    Invoke ListViewInsertSubItem, hLV, nIndex, 1, Addr szBDOffset5
;    Invoke ListViewInsertSubItem, hLV, nIndex, 2, Addr szBDSize5  
;    inc nIndex

    ; Load up data in listview, each students details
    Invoke ListViewInsertItem, hLV, 0, CTEXT("Levitation"), 0
    Invoke ListViewInsertSubItem, hLV, 0, 1, CTEXT("Bob Smith")
    Invoke ListViewInsertSubItem, hLV, 0, 2, CTEXT("12")
    Invoke ListViewInsertSubItem, hLV, 0, 3, CTEXT("M")
    Invoke ListViewInsertSubItem, hLV, 0, 4, CTEXT("Hut 4")
    Invoke ListViewInsertSubItem, hLV, 0, 5, CTEXT("Mr. Jones")
    Invoke ListViewInsertSubItem, hLV, 0, 6, CTEXT("Needs more work")
    
    Invoke ListViewInsertItem, hLV, 1, CTEXT("Lightning Hands"), 0
    Invoke ListViewInsertSubItem, hLV, 1, 1, CTEXT("Sally Jamison")
    Invoke ListViewInsertSubItem, hLV, 1, 2, CTEXT("11")
    Invoke ListViewInsertSubItem, hLV, 1, 3, CTEXT("F")
    Invoke ListViewInsertSubItem, hLV, 1, 4, CTEXT("Room 6")
    Invoke ListViewInsertSubItem, hLV, 1, 5, CTEXT("Mrs. Abignail")
    Invoke ListViewInsertSubItem, hLV, 1, 6, CTEXT("Destined to rule the world")
    
    Invoke ListViewInsertItem, hLV, 2, CTEXT("Fire-breathing"), 0
    Invoke ListViewInsertSubItem, hLV, 2, 1, CTEXT("Henry Sellers")
    Invoke ListViewInsertSubItem, hLV, 2, 2, CTEXT("10")
    Invoke ListViewInsertSubItem, hLV, 2, 3, CTEXT("M")
    Invoke ListViewInsertSubItem, hLV, 2, 4, CTEXT("Main Hall")
    Invoke ListViewInsertSubItem, hLV, 2, 5, CTEXT("Mr. Blue")
    Invoke ListViewInsertSubItem, hLV, 2, 6, CTEXT("Potion X112 working well")
    
    Invoke ListViewInsertItem, hLV, 3, CTEXT("Telepathy"), 0
    Invoke ListViewInsertSubItem, hLV, 3, 1, CTEXT("Kevin Arnold")
    Invoke ListViewInsertSubItem, hLV, 3, 2, CTEXT("13")
    Invoke ListViewInsertSubItem, hLV, 3, 3, CTEXT("M")
    Invoke ListViewInsertSubItem, hLV, 3, 4, CTEXT("Room 8")
    Invoke ListViewInsertSubItem, hLV, 3, 5, CTEXT("Mrs. Abignail")
    Invoke ListViewInsertSubItem, hLV, 3, 6, CTEXT("Progress is fine")

    Invoke ListViewInsertItem, hLV, 4, CTEXT("X-RAY Vision"), 0
    Invoke ListViewInsertSubItem, hLV, 4, 1, CTEXT("Jessica Orange")
    Invoke ListViewInsertSubItem, hLV, 4, 2, CTEXT("12")
    Invoke ListViewInsertSubItem, hLV, 4, 3, CTEXT("F")
    Invoke ListViewInsertSubItem, hLV, 4, 4, CTEXT("Hut 2")
    Invoke ListViewInsertSubItem, hLV, 4, 5, CTEXT("Mr. Jones")
    Invoke ListViewInsertSubItem, hLV, 4, 6, CTEXT("Needs more work")    

    Invoke ListViewInsertItem, hLV, 5, CTEXT("Telepathy"), 0
    Invoke ListViewInsertSubItem, hLV, 5, 1, CTEXT("Little Timmy")
    Invoke ListViewInsertSubItem, hLV, 5, 2, CTEXT(" 8")
    Invoke ListViewInsertSubItem, hLV, 5, 3, CTEXT("M")
    Invoke ListViewInsertSubItem, hLV, 5, 4, CTEXT("Room 6")
    Invoke ListViewInsertSubItem, hLV, 5, 5, CTEXT("Mrs. Abignail")
    Invoke ListViewInsertSubItem, hLV, 5, 6, CTEXT("Potion X112 working well") 
       
    Invoke ListViewInsertItem, hLV, 6, CTEXT("Empathy"), 0
    Invoke ListViewInsertSubItem, hLV, 6, 1, CTEXT("Joanna Stapleton")
    Invoke ListViewInsertSubItem, hLV, 6, 2, CTEXT("11")
    Invoke ListViewInsertSubItem, hLV, 6, 3, CTEXT("F")
    Invoke ListViewInsertSubItem, hLV, 6, 4, CTEXT("Art Room")
    Invoke ListViewInsertSubItem, hLV, 6, 5, CTEXT("Dr. Octavious")
    Invoke ListViewInsertSubItem, hLV, 6, 6, CTEXT("Needs more work")   
    
    Invoke ListViewInsertItem, hLV, 7, CTEXT("Demon Eyes"), 0
    Invoke ListViewInsertSubItem, hLV, 7, 1, CTEXT("Kurt Englund")
    Invoke ListViewInsertSubItem, hLV, 7, 2, CTEXT("14")
    Invoke ListViewInsertSubItem, hLV, 7, 3, CTEXT("M")
    Invoke ListViewInsertSubItem, hLV, 7, 4, CTEXT("Annex B")
    Invoke ListViewInsertSubItem, hLV, 7, 5, CTEXT("Dr. Samantha")
    Invoke ListViewInsertSubItem, hLV, 7, 6, CTEXT("Progress is fine")             
   

    ret

TestLVLoadData ENDP


;------------------------------------------------------------------------------
; TestEditInitProc
;------------------------------------------------------------------------------
TestEditInitProc PROC hLV:DWORD, hControl:DWORD, dwItem:DWORD, dwSubItem:DWORD, lParam:DWORD
    LOCAL szString[MAX_PATH]:BYTE
    
    ;PrintDec hLV
    ;PrintDec hControl
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
		
		;PrintDec eax
		;PrintDec lParam
		;PrintDec wNotifyCode
        mov eax, TRUE
        ret
    .else
        mov eax, TRUE
        ret
    .endif
    xor eax,eax
    ret

TestEditProc ENDP


end start








































