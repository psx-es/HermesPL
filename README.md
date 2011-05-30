Hermes Payload
==============

Open source implementation of Hermes payload, adapted from the work of D_Skywalk.


Note some developers with close source projects that does not respect the GPL
-----------------------------------------------------------------------------

If you benefit from this code, then you SHOULD contribute back.
And it is very clear how I expect you to contribute back - by providing full
access to the COMPLETE system which is using my code. At the core of GPL, the
intention is that someone else should be able to make modifications to such a
system and build other things from it.

No source? Syscall8 and new hook is not welcomed in your disturbing projects.
I am not interested in any line from your source, but scene play together... 

D_Skywalk, syscall8 + hook_table for 3.55 developer -


Firmwares
=========

Firmware 3.55
-------------
ef48: hermes_3_55.bin # Payload

55f14: 60000000 # Syscall 36 Patches

55f1c: 48000098 # Syscall 36 Patches

7af68: 60000000 # Syscall 36 Patches

7af7c: 60000000 # Syscall 36 Patches

55ea4: 60000000 # Fix 8001003D error

55f68: 3be00000 # Fix 8001003E error

2b3298: 4bd5bcd0 # Jump Hook

3465b0: 800000000000ef58 # syscall_8_desc - sys8

346690: 800000000000ef60 # syscall_map_open_desc - sys36
