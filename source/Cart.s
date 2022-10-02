#ifdef __arm__

#include "Shared/EmuSettings.h"
#include "ARM6809/ARM6809mac.h"
#include "YieArVideo/YieArVideo.i"

	.global machineInit
	.global loadCart
	.global m6809Mapper
	.global emuFlags
	.global cartFlags
	.global romStart
	.global vromBase0
	.global vromBase1
	.global promBase

	.global ROM_Space
	.global testState


	.syntax unified
	.arm

	.section .rodata
	.align 2

rawRom:
/*
	.incbin "yiear/407_i08.10d"
	.incbin "yiear/407_i07.8d"
// gfx1
	.incbin "yiear/407_c01.6h"
	.incbin "yiear/407_c02.7h"
// gfx2
	.incbin "yiear/407_d05.16h"
	.incbin "yiear/407_d06.17h"
	.incbin "yiear/407_d03.14h"
	.incbin "yiear/407_d04.15h"
// Prom
	.incbin "yiear/407c10.1g"
// VLM data
	.incbin "yiear/407_c09.8b"
*/
/*
	.incbin "yiear/407_g08.10d"
	.incbin "yiear/407_g07.8d"
// gfx1
	.incbin "yiear/407_c01.6h"
	.incbin "yiear/407_c02.7h"
// gfx2
	.incbin "yiear/407_d05.16h"
	.incbin "yiear/407_d06.17h"
	.incbin "yiear/407_d03.14h"
	.incbin "yiear/407_d04.15h"
// Prom
	.incbin "yiear/407c10.1g"
// VLM data
	.incbin "yiear/407_c09.8b"
*/
	.align 2
;@----------------------------------------------------------------------------
machineInit: 	;@ Called from C
	.type   machineInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	bl gfxInit
//	bl ioInit
	bl soundInit
//	bl cpuInit

	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------

	.section .ewram,"ax"
	.align 2
;@----------------------------------------------------------------------------
loadCart: 		;@ Called from C:  r0=rom number, r1=emuflags
	.type   loadCart STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r0-r1,r4-r11,lr}

//	ldr r3,=rawRom
	ldr r3,=ROM_Space

	ldmfd sp!,{r0-r1}
	str r0,romNum
	str r1,emuFlags
								;@ r3=rombase til end of loadcart so DON'T FUCK IT UP
	str r3,romStart				;@ Set rom base
	add r0,r3,#0x8000			;@ 0x8000
	str r0,vromBase0			;@ Background
	add r0,r0,#0x4000
	str r0,vromBase1			;@ Sprites
	add r0,r0,#0x10000
	str r0,promBase				;@ Colour prom
	add r0,r0,#0x20
	str r0,vlmBase				;@ VLM speech data

	ldr r4,=MEMMAPTBL_
	ldr r5,=RDMEMTBL_
	ldr r6,=WRMEMTBL_
	ldr r7,=mem6809R0
	ldr r8,=rom_W
	mov r0,#0
tbLoop1:
	add r1,r3,r0,lsl#13
	str r1,[r4,r0,lsl#2]
	str r7,[r5,r0,lsl#2]
	str r8,[r6,r0,lsl#2]
	add r0,r0,#1
	cmp r0,#0x88
	bne tbLoop1

	ldr r7,=empty_R
	ldr r8,=empty_W
tbLoop2:
	str r3,[r4,r0,lsl#2]
	str r7,[r5,r0,lsl#2]
	str r8,[r6,r0,lsl#2]
	add r0,r0,#1
	cmp r0,#0x100
	bne tbLoop2

	ldr r7,=VLM_R
	ldr r8,=VLM_W
	mov r0,#0xF9				;@ empty
	str r7,[r5,r0,lsl#2]		;@ RdMem
	str r8,[r6,r0,lsl#2]		;@ WrMem

	ldr r7,=VLM_R
	ldr r8,=empty_W
	mov r0,#0xFE				;@ Graphic
	str r1,[r4,r0,lsl#2]		;@ MemMap
	str r7,[r5,r0,lsl#2]		;@ RdMem
	str r8,[r6,r0,lsl#2]		;@ WrMem

	ldr r1,=emuRAM-0x1000
	ldr r7,=IO_R
	ldr r8,=IO_W
	mov r0,#0xFF				;@ IO, gfx
	str r1,[r4,r0,lsl#2]		;@ MemMap
	str r7,[r5,r0,lsl#2]		;@ RdMem
	str r8,[r6,r0,lsl#2]		;@ WrMem


	bl gfxReset
	bl ioReset
	bl soundReset
	bl cpuReset

	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	ldr r1,vlmBase
	mov r2,#0x2000				;@ ROM size
	blx VLM5030_set_rom

	ldmfd sp!,{r4-r11,lr}
	bx lr


;@----------------------------------------------------------------------------
//	.section itcm
;@----------------------------------------------------------------------------

;@----------------------------------------------------------------------------
m6809Mapper:		;@ Rom paging..
;@----------------------------------------------------------------------------
	ands r0,r0,#0xFF			;@ Safety
	bxeq lr
	stmfd sp!,{r3-r8,lr}
	ldr r5,=MEMMAPTBL_
	ldr r2,[r5,r1,lsl#2]!
	ldr r3,[r5,#-1024]			;@ RDMEMTBL_
	ldr r4,[r5,#-2048]			;@ WRMEMTBL_

	mov r5,#0
	cmp r1,#0xF9
	movmi r5,#12

	add r6,m6809optbl,#m6809ReadTbl
	add r7,m6809optbl,#m6809WriteTbl
	add r8,m6809optbl,#m6809MemTbl
	b m6809MemAps
m6809MemApl:
	add r6,r6,#4
	add r7,r7,#4
	add r8,r8,#4
m6809MemAp2:
	add r3,r3,r5
	sub r2,r2,#0x2000
m6809MemAps:
	movs r0,r0,lsr#1
	bcc m6809MemApl				;@ C=0
	strcs r3,[r6],#4			;@ readmem_tbl
	strcs r4,[r7],#4			;@ writemem_tb
	strcs r2,[r8],#4			;@ memmap_tbl
	bne m6809MemAp2

;@------------------------------------------
m6809Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
	reEncodePC

	ldmfd sp!,{r3-r8,lr}
	bx lr

;@----------------------------------------------------------------------------

romNum:
	.long 0						;@ RomNumber
romInfo:						;@ Keep emuflags/BGmirror together for savestate/loadstate
emuFlags:
	.byte 0						;@ EmuFlags      (label this so Gui.c can take a peek) see EmuSettings.h for bitfields
//scaling:
	.byte SCALED				;@ (display type)
	.byte 0,0					;@ (sprite follow val)
cartFlags:
	.byte 0 					;@ CartFlags
	.space 3

romStart:
	.long 0
vromBase0:
	.long 0
vromBase1:
	.long 0
promBase:
	.long 0
vlmBase:
	.long 0
	.pool

	.section .bss
WRMEMTBL_:
	.space 256*4
RDMEMTBL_:
	.space 256*4
MEMMAPTBL_:
	.space 256*4
ROM_Space:
	.space 0x20020

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
