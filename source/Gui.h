#ifndef GUI_HEADER
#define GUI_HEADER

#ifdef __cplusplus
extern "C" {
#endif

extern u8 g_gammaValue;

void setupGUI(void);
void enterGUI(void);
void exitGUI(void);
void quickSelectGame(void);
void nullUINormal(int key);
void nullUIDebug(int key);
void resetGame(void);

void uiNullNormal(void);
void uiFile(void);
void uiSettings(void);
void uiAbout(void);
void uiOptions(void);
void uiController(void);
void uiDisplay(void);
void uiDipswitches(void);
void uiLoadGame(void);

void controllerSet(void);
void swapABSet(void);

void scalingSet(void);
void gammaSet(void);
void bgrLayerSet(void);
void sprLayerSet(void);

void coinASet(void);
void coinBSet(void);
void difficultSet(void);
void bonusSet(void);
void demoSet(void);
void livesSet(void);
void cabinetSet(void);
void uprightSet(void);
void flipSet(void);
void serviceSet(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // GUI_HEADER