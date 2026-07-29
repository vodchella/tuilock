package tuilock

import "ncurses"


VT_ACTIVATE   :: u32(0x5606)
VT_WAITACTIVE :: u32(0x5607)
TIOCSCTTY     :: u32(0x540E)
ASCII_ESC     :: "\x1b"

THEME_BACKGROUND    :: 1
THEME_TIME          :: 2


Configs :: struct {
    target_vt:        int,
    time_format:      string,
    theme_background: i16,
    theme_container:  i16,
    theme_time:       i16,
}

init_configs :: proc() -> (cfg: Configs)
{
    cfg.target_vt        = 8
    cfg.time_format      = "%a, %d %b %Y - %H:%M"
    cfg.theme_background = ncurses.COLOR_BLACK
    cfg.theme_container  = ncurses.COLOR_BLACK
    cfg.theme_time       = ncurses.COLOR_LIGHT_RED
    return
}
