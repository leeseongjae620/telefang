INCLUDE "telefang.inc"

SECTION "Active Save File", SRAM[$A000], BANK[2]
S_SaveClock_StatisticsArray:: REPT M_SaveClock_MaxDenjuuContacts
	ds M_SaveClock_DenjuuStatSize
	ENDR
	
SECTION "Active Save File 2", SRAM[$B200], BANK[2]
S_SaveClock_NicknameArray:: REPT M_SaveClock_MaxDenjuuContacts
	ds M_SaveClock_DenjuuNicknameSize
	ENDR