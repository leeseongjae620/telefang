SECTION "rst $0", ROM0[$0]
JumpAAtHL:
    pop hl
    add a
    rst $28
    ld a, [hli]
    ld h, [hl]
    ld l, a
    jp hl

SECTION "rst $8", ROM0[$8]
    reti

SECTION "rst $10", ROM0[$10]
    jp $049e

SECTION "rst $18", ROM0[$18]
    ld a, [$c423]
    rst $10
    ret

SECTION "rst $20", ROM0[$20]
    jp $0476

SECTION "rst $28", ROM0[$28]

SECTION "rst $30", ROM0[$30]
    add a
    rst $28
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ret

SECTION "rst $38", ROM0[$38]
SnapHL: ; http://www.catb.org/jargon/html/S/snap.html
    ld a, [hli]
    ld l, [hl]
    ld h, a
    ret

SECTION "vblank interrupt", ROM0[$40]
    jp $02e7

SECTION "lcd interrupt", ROM0[$48]
    jp $0324

SECTION "timer interrupt", ROM0[$50]
    reti

SECTION "serial interrupt", ROM0[$58]
    jp $1cb4

SECTION "joypad interrupt", ROM0[$60]
    reti

SECTION "start", ROM0[$100]
    nop
    jp $150

SECTION "bank 1", ROMX[$4000], BANK[$1]
    ds $4000 ; bank 1 is empty