#ifndef CART_HEADER
#define CART_HEADER

#ifdef __cplusplus
extern "C" {
#endif

extern u32 g_ROM_Size;
extern u32 g_emuFlags;
extern u8 g_cartFlags;

extern u8 ROM_Space[0x20020];
extern u8 *mainCpu;
extern u8 *soundCpu;
extern u8 *vromBase0;
extern u8 *vromBase1;
extern u8 *promBase;
extern u8 *vlmBase;
extern u8 testState[];

void machineInit(void);
void loadCart(int, int);
void ejectCart(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // CART_HEADER
