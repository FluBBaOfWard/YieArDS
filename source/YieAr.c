#include <nds.h>

#include "YieAr.h"
#include "Gfx.h"
#include "Sound.h"
#include "YieArVideo/YieArVideo.h"
#include "SN76496/SN76496.h"
#include "ARM6809/ARM6809.h"


int packState(void *statePtr) {
	int size = 0;
	size += yiearSaveState(statePtr+size, &yieAr_0);
	size += sn76496SaveState(statePtr+size, &SN76496_0);
	size += m6809SaveState(statePtr+size, &m6809OpTable);
	return size;
}

void unpackState(const void *statePtr) {
	int size = 0;
	size += yiearLoadState(&yieAr_0, statePtr+size);
	size += sn76496LoadState(&SN76496_0, statePtr+size);
	m6809LoadState(&m6809OpTable, statePtr+size);
}

int getStateSize() {
	int size = 0;
	size += yiearGetStateSize();
	size += sn76496GetStateSize();
	size += m6809GetStateSize();
	return size;
}

static const ArcadeRom yiearRoms[10] = {
	// ROM_REGION( 0x10000, "maincpu", 0 )
	{"407_i08.10d", 0x4000, 0xe2d7458b},
	{"407_i07.8d",  0x4000, 0x7db7442e},
	// ROM_REGION( 0x04000, "gfx1", 0 )
	{"407_c01.6h",  0x2000, 0xb68fd91d},
	{"407_c02.7h",  0x2000, 0xd9b167c6},
	// ROM_REGION( 0x10000, "gfx2", 0 )
	{"407_d05.16h", 0x4000, 0x45109b29},
	{"407_d06.17h", 0x4000, 0x1d650790},
	{"407_d03.14h", 0x4000, 0xe6aa945b},
	{"407_d04.15h", 0x4000, 0xcc187c22},
	// ROM_REGION( 0x0020, "proms", 0 )
	{"407c10.1g",   0x0020, 0xc283d71f},
	// ROM_REGION( 0x2000, "vlm", 0 )  /* 8k for the VLM5030 data */
	{"407_c09.8b",  0x2000, 0xf75a1539},
};

static const ArcadeRom yiear2Roms[10] = {
	// ROM_REGION( 0x10000, "maincpu", 0 )
	{"407_g08.10d", 0x4000, 0x49ecd9dd},
	{"407_g07.8d",  0x4000, 0xbc2e1208},
	// ROM_REGION( 0x04000, "gfx1", 0 )
	{"407_c01.6h",  0x2000, 0xb68fd91d},
	{"407_c02.7h",  0x2000, 0xd9b167c6},
	// ROM_REGION( 0x10000, "gfx2", 0 )
	{"407_d05.16h", 0x4000, 0x45109b29},
	{"407_d06.17h", 0x4000, 0x1d650790},
	{"407_d03.14h", 0x4000, 0xe6aa945b},
	{"407_d04.15h", 0x4000, 0xcc187c22},
	// ROM_REGION( 0x0020, "proms", 0 )
	{"407c10.1g",   0x0020, 0xc283d71f},
	// ROM_REGION( 0x2000, "vlm", 0 )  /* 8k for the VLM5030 data */
	{"407_c09.8b",  0x2000, 0xf75a1539},
};

const ArcadeGame games[GAME_COUNT] = {
	{"yiear",  "Yie Ar Kung-Fu (program code I)", 10, yiearRoms},
	{"yiear2", "Yie Ar Kung-Fu (program code G)", 10, yiear2Roms},
};
