#ifdef __arm__

#include "SN76496/SN76496.i"

	.global soundInit
	.global soundReset
	.global VblSound2
	.global setMuteSoundGUI
	.global setMuteSoundGame
	.global SN_0_W
	.global VLM_R
	.global VLM_YA_W
	.global VLMData_W

	.global sn76496_0
	.extern pauseEmulation


	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
soundInit:
	.type soundInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

//	ldr r0,=sn76496_0
//	ldr r1,=FREQTBL
//	bl sn76496Init				;@ Sound

	ldmfd sp!,{lr}
//	bx lr

;@----------------------------------------------------------------------------
soundReset:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r1,=sn76496_0
	mov r0,#1
	bl sn76496Reset				;@ Sound
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
setMuteSoundGUI:
	.type   setMuteSoundGUI STT_FUNC
;@----------------------------------------------------------------------------
	ldr r1,=pauseEmulation		;@ Output silence when emulation paused.
	ldrb r0,[r1]
	strb r0,muteSoundGUI
	bx lr
;@----------------------------------------------------------------------------
setMuteSoundGame:			;@ For System E ?
;@----------------------------------------------------------------------------
	strb r0,muteSoundGame
	bx lr
;@----------------------------------------------------------------------------
VblSound2:					;@ r0=length, r1=pointer
;@----------------------------------------------------------------------------
;@	mov r11,r11

	ldr r2,muteSound
	cmp r2,#0
	bne silenceMix
	stmfd sp!,{r0,r1,r4,lr}

	ldr r1,pcmPtr0
	ldr r2,=sn76496_0
	bl sn76496Mixer

	ldmfd sp,{r0}
	ldr r1,pcmPtr1
	mov r2,r0,lsr#3
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx vlm5030_update_callback

	ldmfd sp,{r0,r1}
	ldr r12,pcmPtr0
	ldr r3,pcmPtr1
mixLoop:
	ldrsh r4,[r3]
	tst r0,#4
	addne r3,r3,#2

	ldrsh r2,[r12],#2
	add r2,r4,r2,asr#2
	mov r2,r2,asr#1
	strh r2,[r1],#2

	ldrsh r2,[r12],#2
	add r2,r4,r2,asr#2
	mov r2,r2,asr#1
	strh r2,[r1],#2

	ldrsh r2,[r12],#2
	add r2,r4,r2,asr#2
	mov r2,r2,asr#1
	strh r2,[r1],#2

	ldrsh r2,[r12],#2
	add r2,r4,r2,asr#2
	mov r2,r2,asr#1
	strh r2,[r1],#2

	subs r0,r0,#4
	bhi mixLoop

	ldmfd sp!,{r0,r1,r4,lr}
	bx lr

silenceMix:
	mov r12,r0,lsr#1
	mov r2,#0
silenceLoop:
	subs r12,r12,#1
	strpl r2,[r1],#4
	bhi silenceLoop

	bx lr

;@----------------------------------------------------------------------------
SN_0_W:
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	ldr r1,=sn76496_0
	bl sn76496W
	ldmfd sp!,{r3,lr}
	bx lr

;@----------------------------------------------------------------------------
VLM_R:
;@----------------------------------------------------------------------------
	cmp r12,#0x0000
	bne empty_R
	stmfd sp!,{r3,lr}
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx VLM5030_BSY
	cmp r0,#0
	movne r0,#1
	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
VLM_YA_W:
;@----------------------------------------------------------------------------
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r0,r1,r3,lr}
	mov r1,r1,lsr#1
	and r1,r1,#1
	blx VLM5030_ST

	ldmfd sp!,{r0,r1}
	mov r1,r1,lsr#2
	and r1,r1,#1
	blx VLM5030_RST
	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
VLMData_W:
;@----------------------------------------------------------------------------
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r3,lr}
	blx VLM5030_WRITE8
	ldmfd sp!,{r3,pc}

;@----------------------------------------------------------------------------
pcmPtr0:	.long WAVBUFFER
pcmPtr1:	.long WAVBUFFER+0x800

muteSound:
muteSoundGUI:
	.byte 0
muteSoundGame:
	.byte 0
	.space 2

	.section .bss
	.align 2
sn76496_0:
	.space snSize
WAVBUFFER:
	.space 0x1000
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
