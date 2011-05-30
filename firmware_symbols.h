#ifdef FW_355

	#define BASE						0xef48

	#define PATHSTR_LEN					0x9

	#define SYS8_PERMH4					0

	#define strncmp						0x4e6d8
	#define strcpy						0x4e684
	#define strlen						0x4e6ac
	#define alloc						0x60b78
	#define free						0x60fb4

	#define memory_patch_func			0x2b329c
	#define pathdup_from_user			0x18dc68
//	#define open_mapping_table_ext		0x7fff00

	#define memcpy						0x7c3a4
	#define memset						0x4e4d8
//	#define copy_from_user				0x0f8c0
//	#define copy_to_user				0x0f6a4

//	#define alloc_and_copy_from_user	0x18de28
//	#define strdup_from_user			0x192b8c
//	#define strdup						0x192b8c

	#define perm_patch_func				0x0e7f0
//	#define rtoc_entry_1				0x1030
//	#define rtoc_entry_2				-0x5b80

#elif defined(FW_341)

//	#define BASE						0x7ff000
	#define BASE						0xef48

	#define SYS8_PERMH4					1

	#define PATHSTR_LEN					0xa

	#define strncmp						0x4d344
	#define strcpy						0x4d2f0
	#define strlen						0x4d318
	#define alloc						0x62088
	#define free						0x624c8

	#define memory_patch_func			0x4e81c
	#define pathdup_from_user			0x1b3b3c
//	#define open_mapping_table_ext		???

	#define memcpy						0x7c01c
	#define memset						0x4d144
//	#define copy_from_user				0xe26c
//	#define copy_to_user				0xe050

//	#define alloc_and_copy_from_user	0x1b3cfc
//	#define strdup_from_user			0x1b8a60
//	#define strdup						0x1b8a60

	#define perm_patch_func             0x0505d0
//	#define rtoc_entry_1				0xf08
//	#define rtoc_entry_2				-0x6a00

#endif
