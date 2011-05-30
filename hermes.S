/*
 * hermes.S -- PS3 Jailbreak payload
 *
 * Copyright (C) Youness Alaoui (KaKaRoTo)
 * Copyright (C) Aaron Lindsay (Aaron')
 * Copyright (C) (subdub)
 * Copyright (C) (Hermes)
 * Copyright (C) Miguel Boton (Waninkoko)
 * Copyright (C) (D_Skywalk)
 * Copyright (C) (Noltari)
 *
 * This software is distributed under the terms of the GNU General Public
 * License ("GPL") version 3, as published by the Free Software Foundation.
 *
 * This payload is a modified version of the original PSJailbreak's payload.
 * The people behind PSJailbrak are the original authors and copyright holders
 * of the code they wrote.
 *
 *******************************************************************************
 *
 * Note some developers with close source projects that does not respect the GPL
 *
 * If you benefit from this code, then you SHOULD contribute back.
 * And it is very clear how I expect you to contribute back - by providing full
 * access to the COMPLETE system which is using my code. At the core of GPL, the
 * intention is that someone else should be able to make modifications to such a
 * system and build other things from it.
 *
 * No source? Syscall8 and new hook is not welcomed in your disturbing projects.
 * I am not interested in any line from your source, but scene play together... 
 *
 * - D_Skywalk, syscall8 + hook_table for 3.55 developer -
 *
 ********************************************************************************
 */

#include "firmware_symbols.h"
#include "macros.h"

/**
	Syscall 8 Version
*/
#define SYS8_VERSION 0x102

/*
	Returns
*/
.org 0
return1:
	li		%r3, 1
	blr
return0:
	li		%r3, 0
	blr

/*
	Syscall Descriptors
*/
syscall8_desc:
	QUAD_ABS(syscall8);
syscall36_desc:
	QUAD_ABS(syscall36);

/*
	Open Hook
*/
.org 0x20
open_hook:
	//Overwriten by the jump.
	mr		%r29, %r3 

	MEM_BASE(%r31)

	LOAD_LABEL2(%r27, %r31, str_open_cmp)
	ld		%r26, 0(%r27)
	//If open_table is null go to optimized hook sky.
	cmpldi	%r26, 0 
	beq		open_hook_opt

open_table_loop:
	//Hermes loop with love :D
	mr		%r3, %r29 //restore ptr? (loop)
	ld		%r4, 0(%r26)  // get compare path (%r27 open_table and %r26 contains the 1st ptr)
	cmpldi	%r4, 0 // check null ptr
	beq		open_hook_opt // null? then we finished...

	lwz		%r5, 16(%r26) // get len of compare path
	bl		ABS(strncmp)

	cmpldi	%r3, 0 // if ptr is null
	bne		open_table_nextvalue

	lwz		%r5, 16(%r26) 
	add		%r4, %r29, %r5 // &open_path[compare_path_len]

	ld		%r3, 8(%r26) // get new path
	mr		%r29, %r3    // changes open_path
	lwz		%r5, 20(%r26) // get len of new path

	add		%r3, %r3, %r5 // prepare for copy

	bl		ABS(strcpy)
	b		return_org_open_func

open_table_nextvalue:
	addi	%r26, %r26, 24
	b		open_table_loop

open_hook_opt:
check_path_dvd:
	LOAD_LABEL2(%r4, %r31, dev_bdvd)
	li		%r5, PATHSTR_LEN
	bl		ABS(strncmp)
	cmpldi	%r3, 0
	bne		check_path_app //if not bdvd check app_home

	LOADI_LABEL2(%r31, buffer)

	ld		%r3, 0(%r31)
	cmpldi	%r3, 0
	beq		return_org_open_func //if null exit
	ld		%r3, 8(%r31)  //buffer + 1? save len?
	addi	%r4, %r29, PATHSTR_LEN
	bl		ABS(strcpy)
	ld		%r29, 0(%r31)
	b		return_org_open_func //process finished ok, go out now :D

check_path_app:
	mr		%r3, %r29

	LOAD_LABEL2(%r4, %r31, app_home)
	li		%r5, PATHSTR_LEN
	bl		ABS(strncmp)
	cmpldi	%r3, 0
	bne		return_org_open_func

	LOADI_LABEL2(%r31, buffer)

	ld		%r3, 0(%r31)
	cmpldi	%r3, 0
	beq		return_org_open_func //if null exit
	ld		%r3, 8(%r31)  //buffer + 1? save len?
	addi	%r4, %r29, PATHSTR_LEN
	bl		ABS(strcpy)
	ld		%r29, 0(%r31)

return_org_open_func: // end
	mr		%r3, %r29 // overwrite
	b		ABS(memory_patch_func)

syscall36:
	stdu	%sp, -0xD0(%sp)
	mflr	%r0
	std		%r0, 0xE0(%sp)
	std		%r31, 0xC8(%sp)
	addi	%r4, %sp, 0x70
	bl		ABS(pathdup_from_user) // strdup %r3 from userspace and store the new pointer into %r1[0x70]
	MEM_BASE(%r31)
	LOADI_LABEL2(%r31, buffer)
	ld		%r3, 0(%r31)
	cmpdi	%r3, 0 // if game_path != NULL: free(game_path)
	beq		l_game_path_null
	li		%r4, 0x27
	bl		ABS(free)

l_game_path_null:
	li		%r4, 0x27
	li		%r3, 0x800
	bl		ABS(alloc)    // alloc (2048)
	std		%r3, 0(%r31)
	ld		%r4, 0x70(%sp)
	bl		ABS(strcpy)
	ld		%r3, 0x70(%sp)
	li		%r4, 0x27
	bl		ABS(free)
	ld		%r3, 0(%r31)
	bl		ABS(strlen)
	ld		%r4, 0(%r31)
	add		%r3, %r4, %r3
	std		%r3, 8(%r31)
	li		%r3, 0    // return 0
	ld		%r31, 0xC8(%sp)
	ld		%r0, 0xE0(%sp)
	addi	%sp, %sp, 0xD0
	mtlr	%r0
	blr

/*
	Syscall 8 Table
*/
syscall8_table:
	//0: disable.
	QUAD_ABS(sys8_disable)
	//1: enable.
	QUAD_ABS(sys8_enable)
	//2: memcpy
	QUAD_ABS(sys8_memcpy)
	//3: memset
	QUAD_ABS(sys8_memset)
	//4: call
	QUAD_ABS(sys8_call)
	//5: alloc
	QUAD_ABS(sys8_alloc)
	//6: free
	QUAD_ABS(sys8_free)
	//7: panic.
	QUAD_ABS(sys8_panic)
	//8: perm_mode.
	QUAD_ABS(sys8_perm_mode)
	//9: open_table
	QUAD_ABS(sys8_open_table)
	//10: config
	QUAD_ABS(sys8_config)
	//11: lv1call
	QUAD_ABS(sys8_lv1call)

/*
	Syscall 8
*/
syscall8:
	mflr	%r0
	stdu	%sp, -0xA0(%sp)
	std		%r27, 0x78(%sp)
	std		%r28, 0x80(%sp)
	std		%r29, 0x88(%sp)
	std		%r30, 0x90(%sp)
	std		%r31, 0x98(%sp)
	std		%r0, 0xB0(%sp)

	MEM_BASE(%r31)

	LOAD_LABEL2(%r27, %r31, save_syscall_values)
	
	lwz     %r28, 0(%r27)	   // stealth mode
	cmplwi  %r28, 0x0
	beq	    syscall8_ok	   // if not stealth mode work normally

	cmplwi  %r28, 8
	bge	    syscall8_stealth // if stealth mode >=8 ignore all
	
	cmpldi  %r3, 1	           // test for command == 1
    bne	    syscall8_stealth

	cmpldi  %r4, 0	           // compare if key is 0 to skip count times
    beq	    syscall8_skip_count

	addi	%r28, %r28, 1	  // stealth_mode++ (count times)
	stw     %r28, 0(%r27)

 syscall8_skip_count:

	ld      %r28,  8(%r27)	   // get key and compares if same key
	cmpld	%r4, %r28
    bne	    syscall8_stealth
	li	    %r28, 1
	stw     %r28, 0(%r27) // stealth mode
	
	LOAD_ABS(%r4, %r31, syscall_table)

	ld      %r28,  16(%r27)
	std     %r28,  6*8(%r4) // patch syscall 6 to enable

	ld      %r28,  24(%r27)
	std     %r28,  7*8(%r4) // patch syscall 7 to enable
	
	LOAD_LABEL2(%r28, %r31, syscall36_desc)
	std     %r28, 36*8(%r4) // patch syscall 36 to enable

	li	    %r28, 0
	stw     %r28, 0(%r27) // stealth mode off
	
	li	    %r3, SYS8_VERSION
	b	    syscall8_end

syscall8_ok:
	andi.	%r3, %r3, 0xff
	cmpldi	%r3, 12
	bge	syscall8_unsupported

	LOAD_LABEL2(%r27, %r31, syscall8_table)
	sldi	%r28, %r3, 3
	add		%r27, %r27, %r28

	ld		%r29, 0(%r27)

	//Move param registers.
	mr		%r3, %r4
	mr		%r4, %r5
	mr		%r5, %r6

	//Jump to register address with link.
	bl		syscall8_bl

/*
	Syscall 8 End
*/
syscall8_end:
	ld		%r27, 0x78(%sp)
	ld		%r28, 0x80(%sp)
	ld		%r29, 0x88(%sp)
	ld		%r30, 0x90(%sp)
	ld		%r31, 0x98(%sp)
	ld		%r0, 0xB0(%sp)
	addi	%sp, %sp, 0xA0
	mtlr	%r0
	blr

/*
	Syscall 8 Stealth
*/
syscall8_stealth:
	lis		%r3, -0x7FFF
	ori		%r3, %r3, 3
	b		syscall8_end

/*
	Syscall 8 Unsupported
*/
syscall8_unsupported:
	li		%r3, -1
	b		syscall8_end

/*
	Syscall 8 BL
*/
syscall8_bl:
	mtctr	%r29
	bctr

/**
	Syscall 8 Disable
		system_call_2(8, 0, key)
*/
sys8_disable:
	LOAD_LABEL2(%r27, %r31, save_syscall_values)

	//Save key.
	std		%r3,  8(%r27)
	li		%r28, 1

	//Stealth mode.
	stw		%r28, 0(%r27)

	LOAD_ABS(%r4, %r31, syscall_table)

	//Get "not implemented" Syscall addr.
	ld		%r3, 37*8(%r4)

	//Patch Syscall 6 to not implemented saving its addr.
	ld		%r28, 6*8(%r4)
	std		%r3,  6*8(%r4)
	std		%r28,  16(%r27)

	//Patch Syscall 7 to not implemented saving its addr.
	ld		%r28, 7*8(%r4)
	std		%r3,  7*8(%r4)
	std		%r28,  24(%r27)

	//Patch Syscall 36 to not implemented.
	std		%r3, 36*8(%r4)

	li		%r3, 0
	blr

/**
	Syscall 8 Enable
		system_call_2(8, 1, key)
*/
sys8_enable:
	li		%r3, SYS8_VERSION
	blr

/**
	Syscall 8 Memcpy
		system_call_4(8, 2, dest, src, len)
*/
sys8_memcpy:
	b		ABS(memcpy)

/**
	Syscall 8 Memset
		system_call_4(8, 3, dest, dat, len)
*/
sys8_memset:
	b		ABS(memset)

/**
	Syscall 8 Call
		system_call_4(8, 4, addr, param1, param2)
*/
sys8_call:
	mtctr	%r3
	mr		%r3, %r4
	mr		%r4, %r5
	bctr

/**
	Syscall 8 Alloc
		system_call_3(8, 5, size, pool)
*/
sys8_alloc:
	b		ABS(alloc)

/**
	Syscall 8 Free
		system_call_3(8, 6, ptr, pool)
*/
sys8_free:
	b		ABS(free)

/**
	Syscall 8 Panic
		system_call_1(8, 7)
*/
sys8_panic:
	li		%r3, 0
	li		%r11, 0xFF
	sc		1
	blr

/**
	Syscall 8 Perm Mode -> NOT WORKING
		system_call_2(8, 8, perm)
*/
sys8_perm_mode:
	b syscall8_unsupported

/**
	Syscall 8 Open Table
		system_call_2(8, 9, ptr)
*/
sys8_open_table:
	mr		%r4, %r3
	LOAD_LABEL2(%r27, %r31, str_open_cmp)
	ld		%r3, 0(%r27)
	std		%r4, 0(%r27)
	blr

/**
	Syscall 8 Config -> HALF WORKING
		system_call_1(8, 10, mode)
*/
sys8_config:
	cmplwi	%r3, 0
	beq		sys8_config_retailxml
	cmplwi	%r3, 1
	beq		sys8_config_debugxml
	cmplwi	%r3, 2
	beq		sys8_config_freeredirect
	cmplwi	%r3, 3
	beq		sys8_config_unpatchsfo
	cmplwi	%r3, 4
	beq		sys8_config_patchsfo
	b syscall8_unsupported

sys8_config_retailxml: //NOT WORKING.
	b syscall8_unsupported
sys8_config_debugxml: //NOT WORKING.
	b syscall8_unsupported
sys8_config_freeredirect:
	mflr	%r0
	stdu	%sp, -0xA0(%sp)
	std		%r0, 0xB0(%sp)
	std		%r27, 0x78(%sp)
	std		%r31, 0x98(%sp)
	MEM_BASE(%r31)
	// free device memory
	LOAD_LABEL2(%r27, %r31, buffer)
	ld		%r3, 0(%r27)
	cmpldi	%r3, 0
	beq		sys8_config_freeredirect2
	li		%r4, 0x27
	bl		ABS(free)
	li		%r3, 0
	std		%r3, 0(%r27)
	std		%r3, 8(%r27)
sys8_config_freeredirect2:
	LOAD_LABEL2(%r27, %r31, buffer2)
	ld		%r3, 0x0(%r27)
	cmpldi	%r3, 0
	beq		sys8_config_freeredirect3
	li		%r4, 0x27
	bl		ABS(free)
	li		%r3, 0
	std		%r3, 0(%r27)
sys8_config_freeredirect3:
	LOAD_LABEL2(%r27, %r31, str_open_cmp)
	std		%r3, 0(%r27)
	ld		%r27, 0x78(%sp)
	ld		%r31, 0x98(%sp)
	ld		%r0, 0xB0(%sp)
	addi	%sp, %sp, 0xA0
	mtlr	%r0
	blr    
sys8_config_unpatchsfo: //NOT WORKING.
	b syscall8_unsupported
sys8_config_patchsfo: //NOT WORKING.
	b syscall8_unsupported

/**
	Syscall 8 LV1Call
		system_call_2(8, 11, input_reg_table, output_reg_table)
*/
sys8_lv1call:
	mflr	%r0
	stdu	%sp, -0xA0(%sp)
	std		%r0, 0xB0(%sp)

	std		%r4, 0x60(%sp)

	ld		%r4, 0x08(%r3)
	ld		%r5, 0x10(%r3)
	ld		%r6, 0x18(%r3)
	ld		%r7, 0x20(%r3)
	ld		%r8, 0x28(%r3)
	ld		%r9, 0x30(%r3)
	ld		%r10,0x38(%r3)
	ld		%r11,0x40(%r3)
	ld		%r3, 0x00(%r3)

	sc		1

	ld		%r11, 0x60(%sp)

	std		%r3, 0x00(%r11)
	std		%r4, 0x08(%r11)
	std		%r5, 0x10(%r11)
	std		%r6, 0x18(%r11)
	std		%r7, 0x20(%r11)
	std		%r8, 0x28(%r11)
	std		%r9, 0x30(%r11)
	std		%r10,0x38(%r11)

	ld		%r0, 0xB0(%sp)
	addi	%sp, %sp, 0xA0
	mtlr	%r0
	blr

/*
	Strings
*/
dev_bdvd:
	.string "/dev_bdvd"
app_home:
	.string "/app_home"

/*
	Buffers
*/
buffer:
	.quad 0
buffer2:
	.quad 0
str_open_cmp:
	.quad 0
save_syscall_values:
	.quad 0 //Stealth Mode.
	.quad 0 //Key.
	.quad 0 //Syscall 6.
	.quad 0 //Syscall 7.
