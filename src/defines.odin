#+feature using-stmt
package tuilock

import "ncurses"


VT_ACTIVATE   :: u32(0x5606)
VT_WAITACTIVE :: u32(0x5607)
TIOCSCTTY     :: u32(0x540E)
ASCII_ESC     :: "\x1b"

THEME_BACKGROUND    :: 1
THEME_TIME          :: 2
THEME_DIALOG        :: 3
THEME_BORDER        :: 4
THEME_GREET         :: 5
THEME_PROMPT        :: 6
THEME_INPUT         :: 7


Configs :: struct {
    username:         string,
    target_vt:        int,
    time_format:      string,
    dialog_width:     i32,
    dialog_height:    i32,
    dialog_greet:     string,
    theme_background: i16,
    theme_time:       i16,
    theme_dialog:     i16,
    theme_border:     i16,
    theme_greet:      i16,
    theme_prompt:     i16,
    theme_input:      i16,
}

init_configs :: proc() -> (cfg: Configs)
{
    using ncurses
    cfg.username         = get_original_username()
    cfg.target_vt        = 8
    cfg.time_format      = "%a, %d %b %Y - %H:%M"
    cfg.dialog_width     = 64
    cfg.dialog_height    = 9
    cfg.dialog_greet     = "Enter the Void!"
    cfg.theme_background = COLOR_BLACK
    cfg.theme_time       = COLOR_LIGHT_RED
    cfg.theme_dialog     = COLOR_BLACK
    cfg.theme_border     = COLOR_GRAY
    cfg.theme_greet      = COLOR_YELLOW
    cfg.theme_prompt     = COLOR_GREEN
    cfg.theme_input      = COLOR_YELLOW
    return
}
