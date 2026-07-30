#+feature using-stmt
package tuilock

import "ncurses"


Configs :: struct {
    locker_cmd:       []string,
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

configs_init :: proc() -> (cfg: Configs)
{
    using ncurses
    cfg.locker_cmd       = {"i3lock", "--color=282828"}
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
