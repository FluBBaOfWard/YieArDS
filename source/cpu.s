#ifdef __arm__

#include "Shared/nds_asm.h"
#include "ARM6809/ARM6809mac.h"
#include "YieArVideo/YieArVideo.i"

#define CYCLE_PSL (96)

	.global frameTotal
	.global waitMaskIn
	.global waitMaskOut
	.global m6809CPU0

	.global run
	.global stepFrame
	.global cpuInit
	.global cpuReset

	.syntax unified
	.arm

#ifdef GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text						;@ For anything else
#endif
	.align 2
;@----------------------------------------------------------------------------
run:						;@ Return after X frame(s)
	.type   run STT_FUNC
;@----------------------------------------------------------------------------
	ldrh r0,waitCountIn
	add r0,r0,#1
	ands r0,r0,r0,lsr#8
	strb r0,waitCountIn
	bxne lr
	stmfd sp!,{r4-r11,lr}

;@----------------------------------------------------------------------------
runStart:
;@----------------------------------------------------------------------------
	ldr r0,=EMUinput
	ldr r0,[r0]

	ldr r2,=yStart
	ldrb r1,[r2]
	tst r0,#0x200				;@ L?
	subsne r1,#1
	movmi r1,#0
	tst r0,#0x100				;@ R?
	addne r1,#1
	cmp r1,#GAME_HEIGHT-SCREEN_HEIGHT
	movpl r1,#GAME_HEIGHT-SCREEN_HEIGHT
	strb r1,[r2]

	bl refreshEMUjoypads		;@ Z=1 if communication ok

	bl yaRunFrame

	ldr r1,=fpsValue
	ldr r0,[r1]
	add r0,r0,#1
	str r0,[r1]

	ldr r1,frameTotal
	add r1,r1,#1
	str r1,frameTotal

	ldrh r0,waitCountOut
	add r0,r0,#1
	ands r0,r0,r0,lsr#8
	strb r0,waitCountOut
	ldmfdeq sp!,{r4-r11,lr}		;@ Exit here if doing single frame:
	bxeq lr						;@ Return to rommenu()
	b runStart

;@----------------------------------------------------------------------------
stepFrame:					;@ Return after 1 frame
	.type   stepFrame STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}

	bl yaRunFrame

	ldr r1,frameTotal
	add r1,r1,#1
	str r1,frameTotal

	ldmfd sp!,{r4-r11,lr}
	bx lr

;@----------------------------------------------------------------------------
cyclesPerScanline:	.long 0
frameTotal:			.long 0		;@ Let Gui.c see frame count for savestates
waitCountIn:		.byte 0
waitMaskIn:			.byte 0
waitCountOut:		.byte 0
waitMaskOut:		.byte 0

;@----------------------------------------------------------------------------
yaRunFrame:					;@ Yie Ar Kung-Fu
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr m6809ptr,=m6809CPU0
	add r0,m6809ptr,#m6809Regs
	ldmia r0,{m6809f-m6809pc,m6809sp}	;@ Restore M6809 state
;@----------------------------------------------------------------------------
yaFrameLoop:
;@----------------------------------------------------------------------------
	mov r0,#CYCLE_PSL
	bl m6809RunXCycles
	ldr koptr,=yieAr_0
	bl yiearDoScanline
	cmp r0,#0
	bne yaFrameLoop
;@----------------------------------------------------------------------------
	add r0,m6809ptr,#m6809Regs
	stmia r0,{m6809f-m6809pc,m6809sp}	;@ Save M6809 state
	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
bloHack:		;@ BLO -7 (0x25 0xF9), speed hack.
;@----------------------------------------------------------------------------
	ldrsb r0,[m6809pc],#1
	tst m6809f,#PSR_C
	beq skipBlo
	add m6809pc,m6809pc,r0
	cmp r0,#-7
	andeq cycles,cycles,#CYC_MASK
skipBlo:
	fetch 3
;@----------------------------------------------------------------------------
cpuInit:			;@ Called by machineInit
;@----------------------------------------------------------------------------
	ldr r0,=m6809CPU0
	b m6809Init
;@----------------------------------------------------------------------------
cpuReset:		;@ Called by loadcart/resetGame
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

;@---Speed - 1.536MHz / 60Hz			;Yie Ar.
	ldr r0,=CYCLE_PSL
	str r0,cyclesPerScanline

;@--------------------------------------
	ldr m6809ptr,=m6809CPU0

	mov r0,m6809ptr
	bl m6809Reset

	mov r0,m6809ptr
	adr r2,bloHack
	mov r1,#0x25
	bl m6809PatchOpcode

	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
#ifdef NDS
	.section .dtcm, "ax", %progbits		;@ For the NDS
#elif GBA
	.section .iwram, "ax", %progbits	;@ For the GBA
#endif
	.align 2
;@----------------------------------------------------------------------------
m6809CPU0:
	.space m6809Size
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
