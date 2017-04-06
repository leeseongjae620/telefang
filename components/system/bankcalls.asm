;Banksafe versions of functions that switch banks on their own or exist in other
;banks. These functions restore the previous bank in different ways, not all of
;which are safe to recursively use. Only a few actually read and stack the
;current bank; others assume W_PreviousBank (only set by the state machines...)
;is valid. In practice this doesn't seem to matter for most functions...

SECTION "Banked Call Helper WRAM", WRAM0[$CB26]
W_System_BankedArg: ds 1

SECTION "Banked Call Helpers 0", ROM0[$04A7]
Banked_LCDC_PaletteFadeCGB::
    ld a, BANK(LCDC_PaletteFadeCGB)
    rst $10
    call LCDC_PaletteFadeCGB
    push af
    rst $18
    pop af
    ret

Banked_LoadMaliasGraphics::
    call LoadMaliasGraphics
    rst $18
    ret

Banked_CGBLoadBackgroundPalette::
    call CGBLoadBackgroundPalette
    rst $18
    ret

Banked_CGBLoadObjectPalette::
    call CGBLoadObjectPalette
    rst $18
    ret

Banked_SGBLoadPalette::
    push af
    ld a, 3
    rst $10
    pop af
    call $4320
    rst $18
    ret

Banked_RLEDecompressTMAP0::
    ld [W_System_BankedArg], a
    ld a, [W_CurrentBank]
    push af
    ld a, [W_System_BankedArg]
    call RLEDecompressTMAP0
    pop af
    rst $10
    ret

Banked_RLEDecompressAttribsTMAP0::
    ld [W_System_BankedArg], a
    ld a, [W_CurrentBank]
    push af
    ld a, [W_System_BankedArg]
    call RLEDecompressAttribsTMAP0
    pop af
    rst $10
    ret

Banked_RLEDecompressAttribsTMAP1::
    ld [W_System_BankedArg], a
    ld a, [W_CurrentBank]
    push af
    ld a, [W_System_BankedArg]
    call RLEDecompressAttribsTMAP1
    pop af
    rst $10
    ret

Banked_RLEDecompressTMAP1::
    ld [W_System_BankedArg], a
    ld a, [W_CurrentBank]
    push af
    ld a, [W_System_BankedArg]
    call RLEDecompressTMAP1
    pop af
    rst $10
    ret

Banked_LCDC_SetupPalswapAnimation::
    call LCDC_SetupPalswapAnimation
    rst $18
    ret

Banked_LCDC_PaletteFade::
    call LCDC_PaletteFade
    push af
    rst $18
    pop af
    ret

Banked_Battle_LoadDenjuuPortrait::
    call Battle_LoadDenjuuPortrait
    rst $18
    ret
    
SECTION "Banked Call Helpers Number Niiiiininininine", ROM0[$538]
Banked_LCDC_LoadGraphicIntoVRAM::
    rst $10
    call LCDC_LoadGraphicIntoVRAM
    rst $18
    ret
    
    ;Another banksafe function, but I don't know what it is yet.
    call $1887 ;AKA the first year Groundhog Day was observed
    rst $18
    ret
    
Banked_Status_LoadUIGraphics::
    call Status_LoadUIGraphics
    rst $18
    ret

SECTION "Banked Call Helpers", ROM0[$0560]
Banked_MainScript_DrawStatusText::
    call MainScript_DrawStatusText
    rst $18
    ret

Banked_MainScript_DrawName75::
    call MainScript_DrawName75
    rst $18
    ret

Banked_MainScript_DrawShortName::
    call MainScript_DrawShortName
    rst $18
    ret
    
SECTION "Banked Call Helpers 5 - The bankening", ROM0[$0588]
Banked_Sound_PlaySample::
    call Sound_PlaySample
    rst $18
    ret

Banked_Battle_LoadSpeciesData::
    push af
    ld a, $75
    rst $10
    pop af
    call Battle_LoadSpeciesData
    rst $18
    ret

Banked_MainScript_DrawHabitatString::
    ld a, $75
    rst $10
    call MainScript_DrawHabitatString
    rst $18
    ret

Banked_MainScript_DrawStatusEffectString::
    ld a, $75
    rst $10
    call MainScript_DrawStatusEffectString
    rst $18
    ret
    
Banked_Status_LoadDenjuuEvolutionIndicator::
    call Status_LoadDenjuuEvolutionIndicator
    rst $18
    ret
    
Banked_Status_LoadDenjuuTypeIcon::
    call Status_LoadDenjuuTypeIcon
    rst $18
    ret
    
Banked_Status_LoadDenjuuTypeIconPalette::
    call Status_LoadDenjuuTypeIconPalette
    rst $18
    ret

SECTION "Banked Call Helpers 6", ROM0[$05D9]
Banked_Battle_LoadNextLevelExp::
    push af
    ld a, $27
    rst $10
    pop af
    call Battle_LoadNextLevelExp
    rst $18
    ret

SECTION "Banked Call Helpers 4", ROM0[$05ED]
Banked_Battle_LoadLevelupData::
    push af
    ld a, $27
    rst $10
    pop af
    call Battle_LoadLevelupData
    rst $18
    ret

SECTION "Banked Call Helpers 2", ROM0[$0609]
Banked_PauseMenu_InitializeCursor::
    ld a, [W_CurrentBank]
    push af
    ld a, [W_PauseMenu_SelectedCursorType]
    call PauseMenu_InitializeCursor
    pop af
    rst $10
    ret
    
Banked_PauseMenu_IterateCursorAnimation::
    ld a, [W_CurrentBank]
    push af
    call PauseMenu_IterateCursorAnimation
    pop af
    rst $10
    ret
    
Banked_LoadBattlePhrase::
    ld a, $75 ;Symbolic representation of bank suspended until disassembly
              ;of battle system
    rst $10
    call StringTable_LoadBattlePhrase
    rst $18
    ret

SECTION "Banked Call Helpers 8", ROM0[$0650]
Banked_Status_DrawPhoneNumber::
    push af
    ld a, BANK(Status_DrawPhoneNumber)
    rst $10
    pop af
    call Status_DrawPhoneNumber
    rst $18
    ret

Banked_SaveClock_LoadDenjuuNickname::
    ld a, [W_CurrentBank]
    push af
    ld a, BANK(SaveClock_LoadDenjuuNickname)
    rst $10
    call SaveClock_LoadDenjuuNickname
    pop af
    rst $10
    ret
    
SECTION "Banked Call Helpers 3", ROM0[$2FC7]
Banked_MainScript_DrawLetter::
    push af
    ld a, [W_CurrentBank]
    ld [W_LCDC_LastBank], a
    ld a, $B
    rst $10
    pop af
    call MainScript_DrawLetter
    ld a, [W_LCDC_LastBank]
    rst $10
    ret