;--------loader and kernel------------------------------------------------------
LOADER_BASE_ADDR    equ 0x900
LOADER_START_SECTOR equ 0x2
PAGE_DIR_TABLE_POS  equ 0x100000
KERNEL_START_SECTOR equ 0x9
KERNEL_BIN_BASE_ADDR equ 0x70000
KERNEL_ENTRY_POINT   equ 0xc0001500
PT_NULL 	     equ 0
;--------gdt descripter---------------------------------------------------------
DESC_G_4K equ (1 << 23)
DESC_D_32 equ (1 << 22)
DESC_L    equ (0 << 21)
DESC_AVL  equ (0 << 20)
;----------------------
DESC_LIMIT_CODE2  equ (0xF << 16)
DESC_LIMIT_DATA2  equ (DESC_LIMIT_CODE2)
DESC_LIMIT_VIDEO2 equ (0x0 << 16)
;----------------------
DESC_P     equ (1 << 15)
DESC_DPL_0 equ (0 << 13)
DESC_DPL_1 equ (1 << 13)
DESC_DPL_2 equ (2 << 13)
DESC_DPL_3 equ (3 << 13)
;----------------------
DESC_S_CODE equ (1 << 12)
DESC_S_DATA equ (DESC_S_CODE)
DESC_S_sys  equ (0 << 12)

DESC_TYPE_CODE equ (0x8 << 8)
DESC_TYPE_DATA equ (0x2 << 8)
;----------------------
DESC_CODE_HIGH4  equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_CODE2  + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
DESC_DATA_HIGH4  equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_DATA2  + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
DESC_VIDEO_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0B
;-----seclector------------------------------------------------------------------
RPL0   equ 00b
RPL1   equ 01b
RPL2   equ 10b
RPL3   equ 11b
TI_GDT equ 000b
TI_LDT equ 100b
;----page attribute---------------------------------------------------------------
PG_P     equ 1b
PG_RW_R  equ 00b
PG_RW_W  equ 10b
PG_US_S  equ 000b
PG_US_U  equ 100b
;---------------------------------------------------------------------------------


