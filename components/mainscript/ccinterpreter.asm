INCLUDE "telefang.inc"

;Control codes are as follows:
;E1: Local state change (1 byte follows)
;E2: Newline
;E3: Change text speed (1 byte follows)
;E5: Jump to new location (farptr follows)
;EA: Disable VWF.
;EB: Enable VWF.
;ED: Change the value of W_MainScript_TilesDrawn mid-render (1 byte follows). Be careful though. If you set W_MainScript_TilesDrawn to a value that isn't on the current line of text then expect rendering weirdness.
;EE: Makes the ED control code's value relative to the value of W_MainScript_TilesDrawn as it was during the EE code's last use.
;EF: Makes the ED control code's value absolute again.
;F0: If placed between the first and second question option it will automatically add the relevant space and second arrow position. Only use for short question options.


MainScript_StateOpcode EQU $45C8

SECTION "Main Script Relative Positioning Offset", WRAM0[$C7CC]
W_MainScript_ADVICE_RelativePositionOffset:: ds 1

SECTION "Main Script Arrow Mode", WRAM0[$CB45]
W_MainScript_ADVICE_VerticalArrowEnabled:: ds 1

SECTION "Main Script Control Code Interpreter", ROMX[$413C], BANK[$B]
MainScript_CCInterpreter::
	ld a, [W_MainScript_TextPtr]
	ld l, a
	ld a, [W_MainScript_TextPtr + 1]
	ld h, a
	call MainScript_LoadFromBank
	jp MainScript_ADVICE_StoreCurrentLetter
	
.table

; This table represents control codes E0 to FF.
; IMPORTANT: Every function called from this table must open with "pop hl" or shit will break.

	dw MainScript_CCInterpreter_ReturnCC ; E0
	dw MainScript_CCInterpreter_LocalStateJumpCC ; E1
	dw MainScript_CCInterpreter_NewlineCC ; E2
	dw MainScript_CCInterpreter_TextSpeedCC ; E3
	dw MainScript_ADVICE_ConditionalNewlineCC ; E4
	dw MainScript_CCInterpreter_JumpCC ; E5
	dw MainScript_CCInterpreter_DefaultCC ; E6
	dw MainScript_CCInterpreter_OpcodeE7 ; E7
	dw MainScript_CCInterpreter_DefaultCC ; E8
	dw MainScript_CCInterpreter_ThirdPersonCheckCC ; E9
	dw MainScript_CCInterpreter_VWFdisableCC ; EA
	dw MainScript_CCInterpreter_VWFenableCC ; EB
	dw MainScript_CCInterpreter_FarJumpCC ; EC
	dw MainScript_CCInterpreter_CursorCC ; ED
	dw MainScript_CCInterpreter_CursorRelativeOffsetCC ; EE
	dw MainScript_CCInterpreter_CursorResetRelativeOffsetCC ; EF
	dw MainScript_ADVICE_PositionSecondArrowByCC ; F0
	dw MainScript_CCInterpreter_EnableVerticalArrowModeCC ; F1
	dw MainScript_CCInterpreter_DefaultCC ; F2
	dw MainScript_CCInterpreter_DefaultCC ; F3
	dw MainScript_CCInterpreter_DefaultCC ; F4
	dw MainScript_CCInterpreter_DefaultCC ; F5
	dw MainScript_CCInterpreter_DefaultCC ; F6
	dw MainScript_CCInterpreter_DefaultCC ; F7
	dw MainScript_CCInterpreter_DefaultCC ; F8
	dw MainScript_CCInterpreter_DefaultCC ; F9
	dw MainScript_CCInterpreter_DefaultCC ; FA
	dw MainScript_CCInterpreter_DefaultCC ; FB
	dw MainScript_CCInterpreter_DefaultCC ; FC
	dw MainScript_CCInterpreter_DefaultCC ; FD
	dw MainScript_CCInterpreter_DefaultCC ; FE
	dw MainScript_CCInterpreter_DefaultCC ; FF
	
.COMEFROM_StoreCurrentLetter
	push af
	ld a, [W_MainScript_TilesDrawn]
	ld [W_MainScript_SecondAnswerTile], a
	pop af
	
.readTableAndJump
	cp $E0
	jr c, .regularText
	push hl
	push af
	ld hl, .table
	and $1F
	add a, a
	add a, l
	ld l, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	jp [hl]

.regularText
	ld a, [W_MainScript_WaitFrames]
	or a
	jr z, .noWaiting
	dec a
	jp nz, MainScript_ContinueWaiting
	
.noWaiting
	push hl
	ld a, [W_MainScript_TextSpeed]
	ld [W_MainScript_WaitFrames], a
	ld a, [W_MainScript_TilesDrawn]
	ld b, a
	ld a, [W_MainScript_TileBaseIdx]
	add a, b
	call LCDC_TileIdx2Ptr
	call MainScript_ADVICE_NewlineFixup
	ld a, c
	call MainScript_DrawLetter
	pop hl
	call MainScript_ADVICE_VWFNextTile
	jp MainScript_ADVICE_AutomaticNewline

MainScript_CCInterpreter_DefaultCC::
; Fallback for unused control codes.
	pop hl
	jp MainScript_Moveup
	
MainScript_CCInterpreter_ReturnCC::
; Control Code E0
	pop hl
	ld a, [W_MainScript_CodePtrSpill]
	ld [W_MainScript_TextPtr], a
	ld a, [W_MainScript_CodePtrSpill + 1]
	ld [W_MainScript_TextPtr + 1], a
	call MainScript_Moveup
	call MainScript_Moveup
	jp MainScript_EndOpcode.skipNewlineCheck

MainScript_CCInterpreter_LocalStateJumpCC::
; Control Code E1
	pop hl
   
.j2StateOpcode
	jp MainScript_ADVICE_StateOpcode
	
MainScript_CCInterpreter_NewlineCC::
; Control Code E2
	pop hl
	jp MainScript_ADVICE_NewlineVWFReset
	
MainScript_CCInterpreter_TextSpeedCC::
; Control Code E3
	pop hl
	call MainScript_LoadFromBank
	ld [W_MainScript_TextSpeed], a
	call MainScript_Moveup
	jp MainScript_EndOpcode.skipNewlineCheck
	
MainScript_CCInterpreter_JumpCC::
; Control Code E5
	pop hl
	ld a, [W_MainScript_TextPtr + 1]
	ld [W_MainScript_CodePtrSpill + 1], a
	ld a, [W_MainScript_TextPtr]
	ld [W_MainScript_CodePtrSpill], a
	call MainScript_Jump2Operand
	ret
	
MainScript_CCInterpreter_OpcodeE7::
; Control Code E7
;Don't know what this does yet.
	pop hl
	call $422F
	jp MainScript_EndOpcode.checkIfSkipping
	
MainScript_CCInterpreter_ThirdPersonCheckCC::
; Control Code E9
	pop hl
	call MainScript_Moveup
	jp MainScript_EndOpcode.skipNewlineCheck
	
MainScript_CCInterpreter_CursorCC::
; Control Code ED
	pop hl
	jp MainScript_ADVICE_RepositionCursorByCC
	
MainScript_CCInterpreter_CursorRelativeOffsetCC::
; Control Code EE
	pop hl
	ld a, [W_MainScript_TilesDrawn]
	jr MainScript_CCInterpreter_CursorSetRelativeOffset
	
MainScript_CCInterpreter_CursorResetRelativeOffsetCC::
; Control Code EF
	pop hl
	xor a
	
MainScript_CCInterpreter_CursorSetRelativeOffset::
	ld [W_MainScript_ADVICE_RelativePositionOffset], a
	jp MainScript_EndOpcode.skipNewlineCheck
	

;Appears to be some kind of recovery routine.
;Gets jumped to for nonprintable ASCII, does some weird crap
SECTION "Main Script Control Code Interpreter 2", ROMX[$42BE], BANK[$B]
MainScript_LowControlCode::
    ld b, 0
.loc_42C0
    call MainScript_LoadFromBank
    cp $E1
    jr c, .loc_42E2
    cp $E1
    jr nz, .loc_42D6
    ld a, b
    or a
    jr z, .loc_42D1
    xor a
    ret

.loc_42D1
    call MainScript_CCInterpreter_LocalStateJumpCC.j2StateOpcode
    xor a
    ret
    
.loc_42D6
    cp $E2
    jr nz, .loc_42E0
    ld a, b
    or a
    jr nz, .loc_42E2
    xor a
    ret

.loc_42E0
    jr .loc_42C0

.loc_42E2
    inc b
    ld a, b
    cp 1
    jr z, .loc_42C0
    or a
    ret

MainScript_EndOpcode:: ;2C2EA $42EA
	call MainScript_Moveup
	jp MainScript_ADVICE_EndOpcodeNewlineCheck
	
	;TODO: The following code until .checkIfSkipping is dead
	cp 2
	jr nc, .moreThan1Newline
	jr MainScript_EndOpcode.checkIfSkipping
	
.moreThan1Newline
	and 1
	jr nz, .oneOrLessNewlines
	ld a, 2
	ld [W_MainScript_State], a
	ld a, 0
	ld [W_MainScript_WaitFrames], a
	jr MainScript_EndOpcode.checkIfSkipping
	
.oneOrLessNewlines
	ld a, [W_MainScript_FramesCount]
	ld [W_MainScript_WaitFrames], a
	ld a, 3
	ld [W_MainScript_State], a
	jr MainScript_EndOpcode.checkIfSkipping
	
.skipNewlineCheck:
	call MainScript_Moveup
   
.checkIfSkipping:
	ld a, [W_MainScript_TextSpeed]
	or a
	jp z, MainScriptMachine
	ld a, [W_MainScript_ContinueBtnPressed]
	or a
	jp nz, MainScriptMachine
	ld a, [H_JPInput_HeldDown]
	and M_JPInput_B
	jp nz, MainScriptMachine
	ld a, [H_JPInput_Changed]
	and M_JPInput_A
	jr z, .finished
	ld a, 1
	ld [W_MainScript_ContinueBtnPressed], a
	
.finished
	ret

MainScript_Moveup::
	ld a, [W_MainScript_TextPtr + 1]
	ld c, a
	ld a, [W_MainScript_TextPtr]
	add a, 1
	ld [W_MainScript_TextPtr], a
	ld a, 0
	adc a, c
	ld [W_MainScript_TextPtr + 1], a
	ret

MainScript_ContinueWaiting::
	ld [W_MainScript_WaitFrames], a
	ret

;Stores all of the patches we added to the main script routines.
;"Advice" is a term from Aspect-Oriented Programming.
SECTION "Main Script Patch Advice", ROMX[$7D00], BANK[$B]
MainScript_ADVICE_VWFReset:
	push af
	ld a, 0
	ld [W_MainScript_VWFLetterShift], a
	ld a, 2
	ld [W_MainScript_VWFOldTileMode], a
	pop af
	ret
	
	ds 2
MainScript_ADVICE_StateOpcode:
	call MainScript_ADVICE_VWFReset
	ld a, 0
	ld [W_MainScript_VWFMainScriptHack], a
	jp MainScript_StateOpcode
	
	ds 2
MainScript_ADVICE_StoreCurrentLetter:
	ld [W_MainScript_VWFCurrentLetter], a
	or a
	jp nz, MainScript_CCInterpreter.readTableAndJump
	jp MainScript_CCInterpreter.COMEFROM_StoreCurrentLetter
	
;Not ENTIRELY sure what this does.
;Appears to move us back 2 tiles, then move the graphics pointer back by like
;16 tiles.
MainScript_ADVICE_NewlineFixup:
	ld a, [W_MainScript_VWFMainScriptHack]
	cp 1
	ret nz
	ld a, [W_MainScript_TilesDrawn]
	dec a
	ld a, [W_MainScript_TilesDrawn]
	dec a
	ld [W_MainScript_TilesDrawn], a
	push bc
	ld bc, $FFF0
	add hl, bc
	pop bc
	ret
	
MainScript_ADVICE_VWFNextTile:
	ld a, [W_MainScript_VWFOldTileMode]
	cp 1
	ld a, [W_MainScript_TilesDrawn]
	jr c, .noIncrement
	inc a
	ld [W_MainScript_TilesDrawn], a
	
.noIncrement
	cp $10
	ret nz
	ld a, 1
	ld [W_MainScript_VWFMainScriptHack], a
	ld a, [W_MainScript_TilesDrawn]
	inc a
	ld [W_MainScript_TilesDrawn], a
	ret
	
MainScript_CCInterpreter_VWFdisableCC::
; Control Code EA
; Disable variable-width font rendering.
	pop hl
	ld a, 1
	ld [W_MainScript_VWFDisable], a
	jp MainScript_EndOpcode.skipNewlineCheck
	
MainScript_CCInterpreter_VWFenableCC::
; Control Code EB
; Enable variable-width font rendering.
	pop hl
	xor a
	ld [W_MainScript_VWFDisable], a
	jp MainScript_EndOpcode.skipNewlineCheck
	
MainScript_CCInterpreter_FarJumpCC::
; Control Code EC
; Jump to any string data in the ROM.
; Format:
; EC bb mm mm
; 
;  - where bb is the new ROM bank
;  - where mm mm is the new text ptr.
	pop hl
	ld a, [W_MainScript_TextPtr]
	ld l, a
	ld a, [W_MainScript_TextPtr + 1]
	ld h, a
	inc hl
	call MainScript_LoadFromBank
	push af
	call MainScript_Jump2Operand
	pop af
	ld [W_MainScript_TextBank], a
	ld a, [W_MainScript_TextPtr]
	ld l, a
	ld a, [W_MainScript_TextPtr + 1]
	ld h, a
	dec hl
	ld a, l
	ld [W_MainScript_TextPtr], a
	ld a, h
	ld [W_MainScript_TextPtr + 1], a
	jp MainScript_EndOpcode.skipNewlineCheck

MainScript_CCInterpreter_EnableVerticalArrowModeCC::
; Control Code F1
	pop hl
	ld a, 1
	ld [W_MainScript_ADVICE_VerticalArrowEnabled], a
	jp MainScript_ADVICE_ConditionalNewlineCC.checkIfFirstLine
	nop
	nop
	nop
	nop
	nop
   
MainScript_ADVICE_GetWindowTileCount::
	push bc
	;First we need to compute the tile count of the window...
	ld a, [W_MainScript_VWFNewlineWidth]
	and a
	jr nz, .compute_window_height
	
	ld a, M_MainScript_DefaultWindowWidth
	
.compute_window_height
	ld b, a
	ld a, [W_MainScript_VWFWindowHeight]
	and a
	jr nz, .compute_window_tilecount
	
	ld a, M_MainScript_DefaultWindowHeight
	
.compute_window_tilecount
	ld c, a
	xor a
	
.tilecount_mul_loop
	add a, b
	dec c
	jr nz, .tilecount_mul_loop
	
	pop bc
	ret

MainScript_ADVICE_NewlineVWFReset::
	call MainScript_ADVICE_VWFReset
	
	ld a, [W_MainScript_VWFNewlineWidth]
	and a
	jr nz, .countSetup
	
	;Most code doesn't set VWFNewlineWidth, so we special-case 0
	ld a, M_MainScript_DefaultWindowWidth
	
.countSetup
	ld b, a
	ld c, 2
	ld a, [W_MainScript_TilesDrawn]
	
.divLoop
	sub b
	jr c, .lineCountFound
	inc c
	jr .divLoop
	
.lineCountFound
	xor a
	
.mulLoop
	dec c
	jr z, .checkOverflow
	add b
	jr .mulLoop
	
.checkOverflow
	push af
	call MainScript_ADVICE_GetWindowTileCount
	ld b, a
	pop af
	
	cp b
	jr c, .noOverflow
	xor a
	
.noOverflow
	ld [W_MainScript_TilesDrawn], a
	
	ld a, [W_MainScript_NumNewlines]
	inc a
	ld [W_MainScript_NumNewlines], a
	jp MainScript_EndOpcode
MainScript_ADVICE_NewlineVWFReset_END::

;The default EndOpcode code doesn't support variable height windows, so we added
;support for it
MainScript_ADVICE_EndOpcodeNewlineCheck::
	ld a, [W_MainScript_VWFWindowHeight]
	cp 0
	jr nz, .window_height_selected
	ld a, M_MainScript_DefaultWindowHeight
	
.window_height_selected
	ld b, a
	ld a, [W_MainScript_NumNewlines]
	cp b
	jr nc, .moreThan1Newline
	jp MainScript_EndOpcode.checkIfSkipping
	
.moreThan1Newline
	sub b
	jr z, .run_idle_state
	jr nc, .moreThan1Newline
	ld a, [W_MainScript_FramesCount]
	ld [W_MainScript_WaitFrames], a
	ld a, 3
	ld [W_MainScript_State], a
	jp MainScript_EndOpcode.checkIfSkipping
	
.run_idle_state
	ld a, 2
	ld [W_MainScript_State], a
	ld a, 0
	ld [W_MainScript_WaitFrames], a
	jp MainScript_EndOpcode.checkIfSkipping
MainScript_ADVICE_EndOpcodeNewlineCheck_END::

MainScript_ADVICE_AutomaticNewline::
	ld a, [W_MainScript_VWFNewlineWidth]
	and a
	jr nz, .loadOtherParameters
	
	;Most code doesn't set VWFNewlineWidth, so we special-case 0
	ld a, M_MainScript_DefaultWindowWidth
	
.loadOtherParameters
	ld b, a
	ld a, [W_MainScript_TilesDrawn]
	ld c, 0
	
	and a
	jr z, .noAutomaticNewline
	
	push af
	
	;Compute TilesDrawn % VWFNewlineWidth and use that to determine if we're on a
	;newline or not...
	
.modLoop
	sub b
	jr c, .doneDividing
	inc c
	jr .modLoop
	
.doneDividing
	add b
	cp 0
	jr nz, .checkWraparound
	;There used to be code to increment the newline count if we overflowed.
	;It's gone now, because it doesn't really make sense with VWF...
	
.checkWraparound
	
	;First we need to compute the tile count of the window...
	ld a, [W_MainScript_VWFNewlineWidth]
	and a
	jr nz, .compute_window_height
	
	ld a, M_MainScript_DefaultWindowWidth
	
.compute_window_height
	ld b, a
	ld a, [W_MainScript_VWFWindowHeight]
	and a
	jr nz, .compute_window_tilecount
	
	ld a, M_MainScript_DefaultWindowHeight
	
.compute_window_tilecount
	ld d, a
	xor a
	
.tilecount_mul_loop
	add a, b
	dec d
	jr nz, .tilecount_mul_loop
	
	ld b, a
	pop af
	cp b
	jr c, .noAutomaticNewline
	call MainScript_LowControlCode
	jr z, .noAutomaticNewline
	
.is_wrapped_around
	ld a, [W_MainScript_VWFWindowHeight]
	and a
	jr nz, .heightIsProperlySet
	ld a, M_MainScript_DefaultWindowHeight
	
.heightIsProperlySet
	cp c
	jr c, .noAutomaticNewline
	
	ld a, 0
	ld [W_MainScript_TilesDrawn], a
	jp MainScript_EndOpcode
	
   ;The moveup animation does not support nonstandard window widths
   ;so we don't trigger it if that's the case.
.maybeAutoNewline
	ld a, [W_MainScript_VWFNewlineWidth]
	and a
	jp z, MainScript_EndOpcode
	cp M_MainScript_DefaultWindowWidth
	jp z, MainScript_EndOpcode
	
	;Don't trigger the newline machinery if we're already full
.noAutomaticNewline
	jp MainScript_EndOpcode.skipNewlineCheck

MainScript_ADVICE_RepositionCursorByCC::
	call MainScript_LoadFromBank
	push bc
	ld b, a
	ld a, [W_MainScript_ADVICE_RelativePositionOffset]
	add a, b
	pop bc
	call MainScript_ADVICE_RepositionCursor
	call MainScript_Moveup
	jp MainScript_EndOpcode.skipNewlineCheck
	
MainScript_ADVICE_RepositionCursor::
	ld [W_MainScript_TilesDrawn], a
	xor a
	ld [W_MainScript_VWFLetterShift], a
	ld [W_MainScript_VWFCurrentLetter], a
	
.clearCompositeArea
	push hl
	ld hl, $CFD0
	push bc
	ld b, $10
	
.clearCompositeAreaLoop
	ld [hli], a
	dec b
	jr nz, .clearCompositeAreaLoop
	pop bc
	pop hl
	ret
	
SECTION "Main Script Patch Advice 2", ROMX[$7C89], BANK[$B]
MainScript_ADVICE_PositionSecondArrowByCC::
; Control Code F0
	pop hl
	ld a, [W_MainScript_TilesDrawn]
	inc a
	ld [W_MainScript_SecondAnswerTile], a
	inc a
	call MainScript_ADVICE_RepositionCursor
	jp MainScript_EndOpcode.skipNewlineCheck
	
MainScript_ADVICE_ConditionalNewlineCC::
; Control Code E4
	pop hl

.checkIfFirstLine
	ld a, [W_MainScript_TilesDrawn]
	or a
	jp nz, MainScript_ADVICE_NewlineVWFReset
	jp MainScript_EndOpcode.skipNewlineCheck
