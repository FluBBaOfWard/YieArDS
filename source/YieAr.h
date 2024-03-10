#ifndef YIEAR_HEADER
#define YIEAR_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "Shared/ArcadeRoms.h"

#define GAME_COUNT (2)

extern const ArcadeRom yiearRoms[15];
extern const ArcadeRom yiear2Roms[15];

extern const ArcadeGame yiearGames[GAME_COUNT];

/// This runs all save state functions for each chip.
int packState(void *statePtr);

/// This runs all load state functions for each chip.
void unpackState(const void *statePtr);

/// Gets the total state size in bytes.
int getStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // YIEAR_HEADER
