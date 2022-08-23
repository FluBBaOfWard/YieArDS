#ifdef __arm__

#include "Shared/nds_asm.h"
#include "Equates.h"
#include "ARM6809/ARM6809.i"
#include "YieArVideo/YieArVideo.i"

	.global gfxInit
	.global gfxReset
	.global paletteInit
	.global paletteTxAll
	.global refreshGfx
	.global endFrame
	.global gfxState
	.global gFlicker
	.global gTwitch
	.global g_scaling
	.global g_gfxMask
	.global vblIrqHandler
	.global yStart

	.global yieAr_0
	.global yieArRam_0R
	.global yieArRam_0W
	.global yieAr_0W
	.global emuRAM


	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
gfxInit:					;@ Called from machineInit
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=OAM_BUFFER1			;@ No stray sprites please
	mov r1,#0x200+SCREEN_HEIGHT
	mov r2,#0x100
	bl memset_
	adr r0,scaleParms
	bl setupSpriteScaling

	ldr r0,=g_gammaValue
	ldrb r0,[r0]
	bl paletteInit				;@ Do palette mapping

	bl yieArInit

	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
scaleParms:					;@  NH     FH     NV     FV
	.long OAM_BUFFER1,0x0000,0x0100,0xff01,0x0120,0xfee1
;@----------------------------------------------------------------------------
gfxReset:					;@ Called with CPU reset
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=gfxState
	mov r1,#5					;@ 5*4
	bl memclr_					;@ Clear GFX regs

	mov r1,#REG_BASE
	ldr r0,=0x00FF				;@ Start-end
	strh r0,[r1,#REG_WIN0H]
	mov r0,#0x00C0				;@ Start-end
	strh r0,[r1,#REG_WIN0V]
	mov r0,#0x0000
	strh r0,[r1,#REG_WINOUT]

	ldr r0,=m6809SetNMIPin
	ldr r1,=m6809SetIRQPin
	ldr r2,=emuRAM
	bl yieArReset0
	bl bgInit

	bl paletteTxAll				;@ Transfer palette

	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
bgInit:					;@ BG tiles
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=BG_GFX+0x8000		;@ r0 = NDS BG tileset
	ldr r1,=vromBase0
	ldr r1,[r1]					;@ r1 = even bytes
	mov r2,#0x1000				;@ Length
	bl convertTilesYieAr

	ldr r0,=vromBase1
	ldr r0,[r0]					;@ r1 = even bytes
	str r0,[koptr,#spriteRomBase]

	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
paletteInit:		;@ r0-r3 modified.
	.type paletteInit STT_FUNC
;@ Called by ui.c:  void paletteInit(u8 gammaVal);
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	mov r7,#0xE0
	ldr r6,=MAPPED_RGB
	mov r4,#0x200				;@ Yie Ar bgr
	sub r4,r4,#2
noMap:							;@ Map bbgggrrr  ->  0bbbbbgggggrrrrr
	and r0,r7,r4,lsl#4			;@ Red ready
	bl gPrefix
	mov r5,r0

	and r0,r7,r4,lsl#1			;@ Green ready
	bl gPrefix
	orr r5,r5,r0,lsl#5

	and r0,r7,r4,lsr#1			;@ Blue ready
	bl gPrefix
	orr r5,r5,r0,lsl#10

	strh r5,[r6,r4]
	subs r4,r4,#2
	bpl noMap

	ldmfd sp!,{r4-r7,lr}
	bx lr

;@----------------------------------------------------------------------------
gPrefix:
	orr r0,r0,r0,lsr#3
	orr r0,r0,r0,lsr#3
;@----------------------------------------------------------------------------
gammaConvert:	;@ Takes value in r0(0-0xFF), gamma in r1(0-4),returns new value in r0=0x1F
;@----------------------------------------------------------------------------
	rsb r2,r0,#0x100
	mul r3,r2,r2
	rsbs r2,r3,#0x10000
	rsb r3,r1,#4
	orr r0,r0,r0,lsl#8
	mul r2,r1,r2
	mla r0,r3,r0,r2
	mov r0,r0,lsr#13

	bx lr
;@----------------------------------------------------------------------------
paletteTxAll:				;@ Called from ui.c
	.type paletteTxAll STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r5}

	ldr r2,=promBase			;@ Proms
	ldr r2,[r2]
	ldr r3,=MAPPED_RGB
	ldr r4,=EMUPALBUFF
	add r5,r4,#0x200
	mov r1,#0x10
noMap2:
	ldrb r0,[r2],#1
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r5],#2
	subs r1,r1,#1
	bne noMap2

	mov r1,#0x10
noMap3:
	ldrb r0,[r2],#1
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r4],#2
	subs r1,r1,#1
	bne noMap3

	ldmfd sp!,{r4-r5}
	bx lr

;@----------------------------------------------------------------------------
vblIrqHandler:
	.type vblIrqHandler STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}
	bl calculateFPS

	ldrb r0,g_scaling
	cmp r0,#UNSCALED
	moveq r6,#0
	ldrne r6,=0x80000000 + ((GAME_HEIGHT-SCREEN_HEIGHT)*0x10000) / (SCREEN_HEIGHT-1)		;@ NDS 0x2B10 (was 0x2AAB)
	ldrbeq r8,yStart
	movne r7,#0
	add r7,r7,#0x10
	mov r7,r7,lsl#16
	orr r7,r7,#(GAME_WIDTH-SCREEN_WIDTH)/2

	ldr r0,gFlicker
	eors r0,r0,r0,lsl#31
	str r0,gFlicker
	addpl r6,r6,r6,lsl#16

	ldr r5,=SCROLLBUFF
	mov r4,r5

	mov r12,#SCREEN_HEIGHT
scrolLoop2:
	mov r0,r7
	stmia r4!,{r0,r7}
	adds r6,r6,r6,lsl#16
	addcs r7,r7,#0x10000
	subs r12,r12,#1
	bne scrolLoop2


	mov r6,#REG_BASE
	strh r6,[r6,#REG_DMA0CNT_H]	;@ DMA0 stop

	add r1,r6,#REG_DMA0SAD
	mov r2,r5					;@ Setup DMA buffer for scrolling:
	ldmia r2!,{r4-r5}			;@ Read
	add r3,r6,#REG_BG0HOFS		;@ DMA0 always goes here
	stmia r3,{r4-r5}			;@ Set 1st value manually, HBL is AFTER 1st line
	ldr r4,=0x96600002			;@ noIRQ hblank 32bit repeat incsrc inc_reloaddst, 2 word
	stmia r1,{r2-r4}			;@ DMA0 go

	add r1,r6,#REG_DMA3SAD

	ldr r2,dmaOamBuffer			;@ DMA3 src, OAM transfer:
	mov r3,#OAM					;@ DMA3 dst
	mov r4,#0x84000000			;@ noIRQ 32bit incsrc incdst
	orr r4,r4,#24*2				;@ 24 sprites * 2 longwords
	stmia r1,{r2-r4}			;@ DMA3 go

	ldr r2,=EMUPALBUFF			;@ DMA3 src, Palette transfer:
	mov r3,#BG_PALETTE			;@ DMA3 dst
	mov r4,#0x84000000			;@ noIRQ 32bit incsrc incdst
	orr r4,r4,#0x100			;@ 256 words (1024 bytes)
	stmia r1,{r2-r4}			;@ DMA3 go

	mov r0,#0x0011
	ldrb r1,g_gfxMask
	bic r0,r0,r1
	strh r0,[r6,#REG_WININ]

	blx scanKeys
	ldmfd sp!,{r4-r8,pc}


;@----------------------------------------------------------------------------
gFlicker:		.byte 1
				.space 2
gTwitch:		.byte 0

g_scaling:		.byte SCALED
g_gfxMask:		.byte 0
yStart:			.byte 0
				.byte 0
;@----------------------------------------------------------------------------
refreshGfx:					;@ Called from C when changing scaling.
	.type refreshGfx STT_FUNC
;@----------------------------------------------------------------------------
	adr koptr,yieAr_0
;@----------------------------------------------------------------------------
endFrame:					;@ Called just before screen end (~line 240)	(r0-r2 safe to use)
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}

	mov r0,#BG_GFX
	bl convertTileMapYieAr
	ldr r0,tmpOamBuffer
	bl convertSpritesYieAr
;@--------------------------

	ldr r0,dmaOamBuffer
	ldr r1,tmpOamBuffer
	str r0,tmpOamBuffer
	str r1,dmaOamBuffer

	mov r0,#1
	str r0,oamBufferReady

	ldr r0,=windowTop			;@ Load wTop, store in wTop+4.......load wTop+8, store in wTop+12
	ldmia r0,{r1-r3}			;@ Load with increment after
	stmib r0,{r1-r3}			;@ Store with increment before

	ldmfd sp!,{r3,lr}
	bx lr

;@----------------------------------------------------------------------------
DMA0BUFPTR:			.long 0

tmpOamBuffer:		.long OAM_BUFFER1
dmaOamBuffer:		.long OAM_BUFFER2

oamBufferReady:		.long 0
emuPaletteReady:	.long 0
;@----------------------------------------------------------------------------
yieArReset0:			;@ r0=periodicIrqFunc, r1=frameIrqFunc
;@----------------------------------------------------------------------------
	adr koptr,yieAr_0
	b yieArReset
;@----------------------------------------------------------------------------
yieArRam_0R:				;@ Ram read (0x5000-0x5FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,yieAr_0
	bl yieArRam_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
yieArRam_0W:				;@ Ram write (0x5000-0x5FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,yieAr_0
	bl yieArRam_W
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
yieAr_0W:					;@ I/O write  (0x4000)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,yieAr_0
	bl yieAr_W
	ldmfd sp!,{addy,pc}

;@----------------------------------------------------------------------------
yieAr_0:
	.space yieArSize

gfxState:
adjustBlend:
	.long 0
windowTop:
	.long 0
wTop:
	.long 0,0,0		;@ Windowtop  (this label too)   L/R scrolling in unscaled mode

	.byte 0
	.byte 0
	.byte 0,0

	.section .bss
OAM_BUFFER1:
	.space 0x400
OAM_BUFFER2:
	.space 0x400
DMA0BUFF:
	.space 0x200
SCROLLBUFF:
	.space 0x400*2				;@ Scrollbuffer.
MAPPED_RGB:
	.space 0x400
EMUPALBUFF:
	.space 0x400
emuRAM:
	.space 0x1000
	.space SPRBLOCKCOUNT*4

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
