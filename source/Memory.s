#ifdef __arm__

#include "ARM6809/ARM6809.i"

	.global empty_IO_R
	.global empty_R
	.global empty_W
	.global rom_W
	.global ram6809W
	.global mem6809R0
	.global mem6809R2
	.global mem6809R4
	.global mem6809R5
	.global mem6809R6
	.global mem6809R7

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
empty_IO_R:					;@ Read bad IO address (error)
;@----------------------------------------------------------------------------
	mov r11,r11					;@ No$GBA debugg
	mov r0,#0x10
	bx lr
;@----------------------------------------------------------------------------
empty_R:					;@ Read bad address (error)
;@----------------------------------------------------------------------------
	mov r11,r11					;@ No$GBA debugg
	mov r0,#0
	bx lr
;@----------------------------------------------------------------------------
empty_W:					;@ Write bad address (error)
;@----------------------------------------------------------------------------
	mov r11,r11					;@ No$GBA debugg
	mov r0,#0xBA
	bx lr
;@----------------------------------------------------------------------------
rom_W:						;@ Write ROM address (error)
;@----------------------------------------------------------------------------
	mov r11,r11					;@ No$GBA debugg
	mov r0,#0xB0
	bx lr
;@----------------------------------------------------------------------------

#ifdef NDS
	.section .itcm						;@ For the NDS ARM9
#elif GBA
	.section .iwram, "ax", %progbits	;@ For the GBA
#endif
	.align 2
;@----------------------------------------------------------------------------
ram6809W:					;@ Ram write ($5000-$5FFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+8]
	strb r0,[r1,addy]
	bx lr

;@----------------------------------------------------------------------------
mem6809R0:					;@ Mem read ($0000-$1FFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R1:					;@ Mem read ($2000-$3FFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+4]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R2:					;@ Mem read ($4000-$5FFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+8]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R3:					;@ Mem read ($6000-$7FFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+12]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R4:					;@ Mem read ($8000-$9FFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+16]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R5:					;@ Mem read ($A000-$BFFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+20]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R6:					;@ Mem read ($C000-$DFFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+24]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
mem6809R7:					;@ Mem read ($E000-$FFFF)
;@----------------------------------------------------------------------------
	ldr r1,[m6809ptr,#m6809MemTbl+28]
	ldrb r0,[r1,addy]
	bx lr
;@----------------------------------------------------------------------------
;@mem6809R:					;@ Mem read ($0000-$FFFF)
;@----------------------------------------------------------------------------
;@	add r2,m6809ptr,#m6809MemTbl
;@	ldr r1,[r2,r1,lsr#11]			;@ r1=addy & 0xe000
;@	ldrb r0,[r1,addy]
;@	bx lr
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
