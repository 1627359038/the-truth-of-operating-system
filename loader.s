%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ  LOADER_BASE_ADDR

;------------data section--------------------------
GDT_BASE:		dd 0x00000000
			dd 0x00000000
CODE_DESC:		dd 0x0000FFFF
			dd DESC_CODE_HIGH4
DATA_STACK_DESC:	dd 0x0000FFFF
			dd DESC_DATA_HIGH4
VIDEO_DESC:		dd 0x80000007
			dd DESC_VIDEO_HIGH4

GDT_SIZE	equ 	$ - GDT_BASE
GDT_LIMIT	equ	GDT_SIZE - 1
times 60 dq 0
SELECTOR_CODE   equ	(0x0001 << 3) + TI_GDT + RPL0
SELECTOR_DATA   equ	(0x0002 << 3) + TI_GDT + RPL0
SELECTOR_VIDEO  equ 	(0x0003 << 3) + TI_GDT + RPL0

total_mem_bytes dd 	0

gdt_ptr		dw 	GDT_LIMIT
		dd 	GDT_BASE
;loadermsg	db	'2 loader in real.'

ards_buf	times	244 db 0
ards_nr		dw	0

;--------------code section--------------------------------
loader_start:
;		mov sp,LOADER_BASE_ADDR
;		mov bp,loadermsg
;		mov cx,17
;		mov ax,0x1301
;		mov bx,0x001f
;		mov dx,0x1800
;		int 0x10

;----------access physic memory size------------
		xor ebx,ebx
		mov edx,0x534d4150
		mov di,ards_buf
.e820_mem_get_loop:
		mov eax,0x0000e820
		mov ecx,20
		int 0x15
		add di,cx
		inc word [ards_nr]
		cmp ebx,0
		jnz .e820_mem_get_loop

		mov cx,[ards_nr]
		mov ebx,ards_buf
		xor edx,edx
.find_max_mem_area:
		mov eax,[ex]
		add eax,[ebx+8]
		add ebx,20
		cmp edx,eax
		jge .next_ards
		mov edx,eax
.next_ards:
		loop .find_max_mem_area
		mov [total_mem_bytes],edx
		
;----------open A20 and go into Protect mode----------		
		in al,0x92
		or al,0000_0010B
		out 0x92,al

		lgdt [gdt_ptr]

		mov eax,cr0
		or  eax,0x00000001
		mov cr0,eax

		jmp dword SELECTOR_CODE:p_mode_start
.error_hlt:
		hlt

[bits 32]
p_mode_start:
		mov ax,SELECTOR_DATA
		mov ds,ax
		mov es,ax
		mov ss,ax
		mov esp,LOADER_STACK_TOP
		mov ax,SELECTOR_VIDEO
		mov gs,ax

		mov byte [gs:160],'P'
	;	mov byte [gs:161],0x07
	;	mov byte [gs:162],'r'
	;	mov byte [gs:163],0x07
	;	mov byte [gs:164],'o'
	;	mov byte [gs:165],0x07
	;	mov byte [gs:166],'t'
	;	mov byte [gs:167],0x07
	;	mov byte [gs:168],'e'
	;	mov byte [gs:169],0x07
	;	mov byte [gs:170],'c'
	;	mov byte [gs:171],0x07
	;	mov byte [gs:172],'t'
	;	mov byte [gs:173],0x07

;-------------load kernel---------------------------
		mov eax,KERNEL_START_SECTOR
		mov ebx,KERNEL_BIN_BASE_ADDR
		mov ecx,200
		call rd_disk_m_32

;-------------init memory paging-------------------
	
		call setup_page

		sgdt [gdt_ptr]
		
		mov ebx,[gdt_ptr + 2]
		or dword [ebx + 0x18 + 4],0xc0000000
		
		add dword [gdt_ptr + 2],0xc0000000
		add esp,0xc0000000
;---start paging--------------------------------------
		mov eax,PAGE_DIR_TABLE_POS
		mov cr3,eax

		mov eax,cr0
		or  eax,0x80000000
		mov cr0,eax

		lgdt [gdt_ptr]

		mov ax,SELECTOR_VIDEO
		mov gs,ax

		mov byte [gs:0xa0],'v'

	;	jmp $

;---copy kernel.bin to lower address------------------------------------------------------
		jmp SELECTOR_CODE:enter_kernel
enter_kernel:
		call kernel_init
		mov esp,0xc009f000
		jmp KERNEL_ENTRY_POINT

;----------init kernel-------------------
kernel_init:
		xor eax,eax
		xor ebx,ebx
		xor ecx,ecx
		xor edx,edx
		
		mov dx,[KERNEL_BIN_BASE_ADDR + 42]
		mov ebx,[KERNEL_BIN_BASE_ADDR + 28]
		add ebx,KERNEL_BIN_BASE_ADDR
		mov cx,[KERNEL_BIN_BASE_ADDR + 44]
		
.each_segment:
		cmp byte [ebx + 0],PT_NULL
		je .PTNULL
		push dword [ebx + 16]
		mov eax,[ebx + 4]
		add eax,KERNEL_BIN_BASE_ADDR
		push eax
		push dword [ebx + 8]
		call mem_cpy
		add esp, 12
.PTNULL:
		add ebx,edx
		loop .each_segment
		ret
;---mem_cpy(dst, src, size)---------------
mem_cpy:
		cld
		push ebp
		mov ebp,esp
		push ecx
		mov edi,[ebp + 8]
		mov esi,[ebp + 12]
		mov ecx,[ebp + 16]
		rep movsb

		pop ecx
		pop ebp
		ret
;---read disk to memory----------------------------------------------------------------
rd_disk_m_32:
		push esi
		push edi
		push edx
		push eax
		push ebx
		push ecx

		mov esi,eax
		mov edi,ecx
;---step 1: set number of read-in sector---------
		mov dx,0x1f2
		mov al,cl
		out dx,al

		mov eax,esi
;---step 2: load LBA address into 0x1f3-0x1f6-----
		mov dx,0x1f3
		out dx,al
		
		mov dx,0x1f4
		shr eax,8
		out dx,al
		
		mov dx,0x1f5
		shr eax,8
		out dx,al

		mov dx,0x1f6
		shr eax,8
		and al,0x0f
		or  al,0xe0
		out dx,al
;---step 3: command read------------------------
		mov dx,0x1f7
		mov al,0x20
		out dx,al
;---step 4: check disk state--------------------
.not_ready:
		in  al,dx
		and al,0x88
		cmp al,0x08
		jnz .not_ready
;---step 5: read data from data port------------		
		mov eax,edi
		mov ecx,256
		mul ecx
		mov ecx,eax

		mov dx,0x1f0
		mov edi,ebx
.read_loop:
		in  ax,dx
		mov [edi],ax
		add edi,2
		loop .read_loop

		pop ecx
		pop ebx
		pop eax
		pop edx
		pop edi
		pop esi
		ret
;---init page dir table and page table-----------------------------------------
setup_page:
		mov ecx,4096
		xor esi,esi
.clear_dir:	
		mov byte [PAGE_DIR_TABLE_POS + esi],0
		inc esi
		loop .clear_dir

.create_pde:
		mov eax,PAGE_DIR_TABLE_POS
		add eax,0x1000
		mov ebx,eax
		or  eax,PG_US_U | PG_RW_W | PG_P
		mov [PAGE_DIR_TABLE_POS + 0x0],eax
		mov [PAGE_DIR_TABLE_POS + 0xc00],eax
		sub eax,0x1000
		mov [PAGE_DIR_TABLE_POS + 4092],eax

		mov ecx,256
		mov esi,0
		mov edx,PG_US_U | PG_RW_W | PG_P
.create_pte:
		mov [ebx + esi * 4],edx
		add edx,4096
		inc esi
		loop .create_pte

		mov eax,PAGE_DIR_TABLE_POS
		add eax,0x2000
		or  eax,PG_US_U | PG_RW_W | PG_P
		mov ebx,PAGE_DIR_TABLE_POS
		mov ecx,254
		mov esi,769
.create_kernel_pde:
		mov [ebx + esi * 4],eax
		inc esi
		add eax,0x1000
		loop .create_kernel_pde
		ret
;----------------------------------------------------------

