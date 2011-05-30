/*
 * hermes.S -- PS3 Jailbreak payload
 *
 * Copyright (C) Hermes
 * Copyright (C) D_Skywalk
 * Copyright (C) Noltari
 *
 * This software is distributed under the terms of the GNU General Public
 * License ("GPL") version 3, as published by the Free Software Foundation.
 *
 * This payload is a modified version of the original PSJailbreak's payload.
 * The people behind PSJailbrak are the original authors and copyright holders
 * of the code they wrote.
 */

#include "firmware_symbols.h"
#include "macros.h"

/**
	Syscall 8 Version
*/
#define SYS8_VERSION 0x7

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
syscalls:
	QUAD_ABS(syscall8);
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

	//Hermes stealth code not supported yet -> Syscall Switch
	andi.	%r3, %r3, 0xff
	cmpldi	%r3, 12
	bge		syscall8_stealth

	MEM_BASE(%r31)
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
	Syscall 8 Disable -> NOT WORKING
*/
sys8_disable:
	b syscall8_unsupported

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

/**
	Syscall 8 Perm Mode
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
	Syscall 8 Config -> NOT WORKING
*/
sys8_config:
	b syscall8_unsupported

/**
	Syscall 8 LV1Call
		system_call_2(8, 11, input_reg_table, output_reg_table)
*/
sys8_lv1call:
	b syscall8_unsupported

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
	.quad 0
str_open_cmp:
	.quad 0
