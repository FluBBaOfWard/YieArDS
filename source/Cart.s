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
	.global mainCpu
	.global soundCpu
	.global vromBase0
	.global vromBase1
	.global promBase
	.global vlmBase

	.global ROM_Space
	.global testState


	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
machineInit: 	;@ Called from C
	.type   machineInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	bl gfxInit
//	bl ioInit
	bl soundInit
	bl cpuInit

	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------

	.section .ewram,"ax"
	.align 2
;@----------------------------------------------------------------------------
loadCart: 		;@ Called from C:  r0=rom number, r1=emuflags
	.type   loadCart STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}
	str r0,romNum
	str r1,emuFlags

	bl doCpuMappingYieAr

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
doCpuMappingYieAr:
;@----------------------------------------------------------------------------
	adr r2,yieArMapping
	b do6809MainCpuMapping
;@----------------------------------------------------------------------------
yieArMapping:						;@ Yie Ar Kung-Fu
	.long emptySpace, VLM_R, empty_W							;@ IO
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emuRAM-0x1000, YieArIO_R, YieArIO_W					;@ Graphic
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long 0, mem6809R4, rom_W									;@ ROM
	.long 1, mem6809R5, rom_W									;@ ROM
	.long 2, mem6809R6, rom_W									;@ ROM
	.long 3, mem6809R7, rom_W									;@ ROM
;@----------------------------------------------------------------------------
do6809MainCpuMapping:
;@----------------------------------------------------------------------------
	ldr r0,=m6809CPU0
	ldr r1,=mainCpu
	ldr r1,[r1]
;@----------------------------------------------------------------------------
m6809Mapper:		;@ Rom paging.. r0=cpuptr, r1=romBase, r2=mapping table.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}

	add r7,r0,#m6809MemTbl
	add r8,r0,#m6809ReadTbl
	add lr,r0,#m6809WriteTbl

	mov r6,#8
m6809M2Loop:
	ldmia r2!,{r3-r5}
	cmp r3,#0x100
	addmi r3,r1,r3,lsl#13
	rsb r0,r6,#8
	sub r3,r3,r0,lsl#13

	str r3,[r7],#4
	str r4,[r8],#4
	str r5,[lr],#4
	subs r6,r6,#1
	bne m6809M2Loop
;@------------------------------------------
m6809Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
	reEncodePC
	ldmfd sp!,{r4-r8,lr}
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
mainCpu:
	.long 0
soundCpu:
cpu2Start:
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
ROM_Space:
	.space 0x20020
emptySpace:
	.space 0x2000
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
