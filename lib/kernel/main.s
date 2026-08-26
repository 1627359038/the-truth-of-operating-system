	.file	"main.c"
	.intel_syntax noprefix
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	lea	ecx, 4[esp]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR -4[ecx]
	push	ebp
	mov	ebp, esp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	push	ebx
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x78,0x6
	.cfi_escape 0x10,0x3,0x2,0x75,0x7c
	call	__x86.get_pc_thunk.bx
	add	ebx, OFFSET FLAT:_GLOBAL_OFFSET_TABLE_
	sub	esp, 12
	push	107
	call	put_char@PLT
	add	esp, 16
	sub	esp, 12
	push	101
	call	put_char@PLT
	add	esp, 16
	sub	esp, 12
	push	114
	call	put_char@PLT
	add	esp, 16
	sub	esp, 12
	push	110

	add	esp, 16
	sub	esp, 12
	push	101
	call	put_char@PLT
	add	esp, 16
	sub	esp, 12
	push	108
	call	put_char@PLT
	add	esp, 16
.L2:
	nop
	jmp	.L2
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.section	.text.__x86.get_pc_thunk.bx,"axG",@progbits,__x86.get_pc_thunk.bx,comdat
	.globl	__x86.get_pc_thunk.bx
	.hidden	__x86.get_pc_thunk.bx
	.type	__x86.get_pc_thunk.bx, @function
__x86.get_pc_thunk.bx:
.LFB1:
	.cfi_startproc
	mov	ebx, DWORD PTR [esp]
	ret
	.cfi_endproc
.LFE1:
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
