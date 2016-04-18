=========================================================================================

 README & LICENSE

 ListViewSubItemEdit v1.0.0.3 by fearless

 Copyright (c) 2016 by KSR aka fearless

 All Rights Reserved

 http://www.LetTheLight.in

 This software is provided 'as-is', without any express or implied warranty. In no
 event will the author be held liable for any damages arising from the use of this
 software.

 Permission is granted to anyone to use this software for any non-commercial program.
 If you use the library in an application, an acknowledgement in the application or
 documentation is appreciated but not required. 

 You are allowed to make modifications to the source code, but you must leave the
 original copyright notices intact and not misrepresent the origin of the software.
 It is not allowed to claim you wrote the original software. Modified files must have
 a clear notice that the files are modified, and not in the original state. This includes
 the name of the person(s) who modified the code. 

 If you want to distribute or redistribute any portion of this package, you will need
 to include the full package in it's original state, including this license and all
 the copyrights. 

 While distributing this package (in it's original state) is allowed, it is not allowed
 to charge anything for this. You may not sell or include the package in any commercial
 package without having permission of the author. Neither is it allowed to redistribute
 any of the package's components with commercial applications.


=========================================================================================


 ----------------------------------------------------------------------------------------
 OVERVIEW
 ----------------------------------------------------------------------------------------
 ListViewSubItemEdit is a library containing functions to easily allow you to edit items 
 and subitems in a listview.

 It dynamically creates a specified child control (edit, combo etc) in the place of the
 item and subitem. Once the child control loses focus - user moved to another control or
 clicked another part of the listview, the information in the child control updates the
 associated item/subitem, if any changes where made.
 
 A user pressing escape will cancel any modification and the child control will be 
 destroyed. If a user presses tab or enter, any changes will be saved back to the orignal
 item/subitem of the listview.
 
 ----------------------------------------------------------------------------------------
 HISTORY
 ----------------------------------------------------------------------------------------

 v1.0.0.3
 --------
 Release    - FaultTolerantHeap masking crashes. Fixes exceptions occuring as a result of
              not handling WM_INITIDIALOG correctly
            - Added WM_SIZE to listview subclass to set focus to listview and destroy 
              edit control when listview is being resized (from parent resize)
 Todo       - Change dwWrapAround and other 'features' to a dwStyle flag and combine
              constants to define what actions are desired by user: allow key navigation
              (tab + shift-tab and/or shift-up + shift-down or none), fake nm_doubleclick
              or fake nm_click or both. Read only columns (subitems), key nav to skip
              to next/prev valid subitem? skip columns of 0 size to next/prev valid
              subitem? highlight cell instead of row? (allow for f2 to edit, which sends
              nm_doubleclick instead) plus few other ideas.


 v1.0.0.2
 --------
 Release    - Tidied up main edit control proc and sub routines for various bits.
            - Changed validation and save code to call user validation routine (if exist)
              from Enter, Tab, Shift-Tab, Shift-Up and Shift-Down instead of from
              WM_KILLFOCUS, this way we still have a chance to keep user in editbox
              and alert them to an error or something perhaps if entered text is not
              correct. This is up to the user to decide how to process as per the idea
              behind calling the user specified validation routine.
            - Added a notification once text succesfully updated. Calls WM_NOTIFY with
              LVN_ITEMCHANGED. iItem and iSubItem filled in for appropriate cell and
              uChanged flag is set to LVIF_TEXT to indicate text has been changed.
              
 v1.0.0.1 
 --------
 Release    - Updated code to lose focus when listview column resize or scrollbars moved.
              This prevents ugly drawing artifacts when editbox is still visible.
            - Added new code to simulate NM_CLICK to allow for tab, shift-tab, shift-up &
              shift-down to allow user to move next, previous, up or down and activate
              editbox for appropriate item and subitem.
            - Added function ListViewEnsureSubItemVisible to help with the keyboard nav

 Todo       - Rework callbacks with WM_CHAR etc as they cant modify wParam and pass this
              back currently, so no way to adjust a key stroke to auto uppercase it for
              example. Needs more thought on how to accomplish this properly.

 
 v1.0.0.0 
 --------
 Release    - Initial release and commit to github


 ----------------------------------------------------------------------------------------
 HOW TO USE
 ----------------------------------------------------------------------------------------
 
 Copy the ListViewSubItemEdit.lib to your masm32\lib folder
 Copy the ListViewSubItemEdit.inc to your masm32\include folder

 Include the following in your project:

    Include ListViewSubItemEdit.inc
    Includelib ListViewSubItemEdit.lib

 
 Quick Overview
 --------------
 For example of usage see the ListViewSubItemEdit.inc file

 ----------------------------------------------------------------------------------------
 NOTES
 ---------------------------------------------------------------------------------------- 

 Also included with this control are three RadASM api files: masmApiCall.api.txt
 masmApiConst.api.txt, and masmMessage.api.txt if you so wish to add these to your own 
 existing api files. Edit these files with a text editor and paste the contents to the
 appropriate files found in your RadASM installation.
 
=========================================================================================
