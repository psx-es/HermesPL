#define PATHSTR_LEN						0x9

#ifdef FW_355

	#define BASE						0xef48

	#define syscall_table				0x346570

	#define strncmp						0x4e6d8
	#define strcpy						0x4e684
	#define strlen						0x4e6ac
	#define alloc						0x60b78
	#define free						0x60fb4

	#define memory_patch_func			0x2b329c
	#define pathdup_from_user			0x18dc68

	#define memcpy						0x7c3a4
	#define memset						0x4e4d8

	#define perm_patch_func				0x0e7f0

#elif defined(FW_341)

	#define BASE						0x50b3c

	#define syscall_table				0x2eb128

	#define strncmp						0x4d344
	#define strcpy						0x4d2f0
	#define strlen						0x4d318
	#define alloc						0x62088
	#define free						0x624c8

	#define memory_patch_func			0x4e81c
	#define pathdup_from_user			0x1b3b3c

	#define memcpy						0x7c01c
	#define memset						0x4d144

	#define perm_patch_func             0x0505d0

#endif
