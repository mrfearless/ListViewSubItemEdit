# ListViewSubItemEdit for Masm

[![Join the chat at https://gitter.im/mrfearless/ListViewSubItemEdit](https://badges.gitter.im/mrfearless/ListViewSubItemEdit.svg)](https://gitter.im/mrfearless/ListViewSubItemEdit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

fearless 2016 - [www.LetTheLight.in](http://www.LetTheLight.in)

## Overview

![Image of LVSIE](https://github.com/mrfearless/ListViewSubItemEdit/blob/master/lvsie.png)

ListViewSubItemEdit is a library (for Masm, but may work with other compilers) containing functions to easily allow you to edit items and subitems in a listview. 

It dynamically creates a specified child control (edit, combo etc) in the place of the item and subitem that was clicked. 
Once the child control loses focus - user moved to another control or clicked another part of the listview, the information in the child control updates the associated item/subitem, if any changes where made.
A user pressing escape will cancel any modification and the child control will be destroyed. If a user presses tab or enter, any changes will be saved back to the original item/subitem of the listview.

v1.0.0.3 - Last updated: 18/04/2016 - Fix for exceptions masked by FaultTolerantHeap on Win7

## Whats included in this release

* ListViewSubItemEdit.inc
* ListViewSubItemEdit.lib
* readme.txt

## How to use

* Copy the ListViewSubItemEdit.lib to your masm32\lib folder
* Copy the ListViewSubItemEdit.inc to your masm32\include folder
* Add a line in your source code:
```
    include ListViewSubItemEdit.inc
    includelib ListViewSubItemEdit.lib
```
For example of usage see the ListViewSubItemEdit.inc file or download the LVSIETest RadASM Project


## Sites of interest

* [RadASM IDE](http://www.oby.ro/rad_asm/)
* [Masm32](http://www.masm32.com/masmdl.htm)
* [x64dbg](https://github.com/x64dbg/x64dbg)


## My other projects
* [x64dbg-plugin-sdk-for-masm](https://bitbucket.org/mrfearless/x64dbg-plugin-sdk-for-masm)
* [x64dbg-plugin-sdk-for-jwasm64](https://bitbucket.org/mrfearless/x64dbg-plugin-sdk-for-jwasm64)
* [jwasm64-with-radasm](https://bitbucket.org/mrfearless/jwasm64-with-radasm)
* [debug64-for-jwasm64](https://bitbucket.org/mrfearless/debug64-for-jwasm64)
* [zlibextract](https://bitbucket.org/mrfearless/zlibextract)



