#ifdef __arm__

#include "SN76496/SN76496.i"

	.global soundInit
	.global soundReset
	.global VblSound2
	.global setMuteSoundGUI
	.global setMuteSoundGame
	.global SN_0_W
	.global VLM_R
	.global VLM_W

	.global SN76496_0
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

//	ldr snptr,=SN76496_0
//	ldr r1,=FREQTBL
//	bl sn76496Init				;@ Sound

	ldmfd sp!,{lr}
//	bx lr

;@----------------------------------------------------------------------------
soundReset:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr snptr,=SN76496_0
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
	stmfd sp!,{r0,r1,r4,lr}

	ldr r2,muteSound
	cmp r2,#0
	bne silenceMix

	mov r0,r0,lsl#1
	ldr r1,pcmPtr0
	ldr snptr,=SN76496_0
	bl sn76496Mixer

	ldmfd sp,{r0}
	ldr r1,pcmPtr1
	mov r2,r0,lsr#3
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx vlm5030_update_callback

	ldmfd sp,{r0,r1}
	ldr r2,pcmPtr0
	ldr r3,pcmPtr1
mixLoop:
	ldrsh r12,[r3],#2
	mov r12,r12,lsl#15

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4

	ldr r4,[r2],#4
	adds r4,r4,r4,lsl#16
	mov r4,r4,rrx
	add r4,r12,r4,asr#2
	mov r4,r4,lsr#16
	orr r4,r4,r4,lsl#16
	subs r0,r0,#1
	strpl r4,[r1],#4
	bgt mixLoop

	ldmfd sp!,{r0,r1,r4,lr}
	bx lr

silenceMix:
	ldmfd sp!,{r0,r1}
	mov r12,r0
	mov r2,#0
silenceLoop:
	subs r12,r12,#1
	strpl r2,[r1],#4
	bhi silenceLoop

	ldmfd sp!,{r4,lr}
	bx lr

;@----------------------------------------------------------------------------
SN_0_W:
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	ldr snptr,=SN76496_0
	bl sn76496W
	ldmfd sp!,{r3,lr}
	bx lr

;@----------------------------------------------------------------------------
VLM_W:
;@----------------------------------------------------------------------------
	cmp r12,#0x4A00
	bne notVLMPins
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
notVLMPins:
	cmp r12,#0x4B00
	bne empty_W
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r3,lr}
	blx VLM5030_WRITE8
	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
VLM_R:
;@----------------------------------------------------------------------------
	cmp r12,#0x0000
	bne empty_R
vlmBusy:
	stmfd sp!,{r3,lr}
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx VLM5030_BSY
	cmp r0,#0
	movne r0,#1
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
SN76496_0:
	.space snSize
WAVBUFFER:
	.space 0x1000
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
