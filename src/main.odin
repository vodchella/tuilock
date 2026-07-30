package tuilock

import "core:sys/linux"


main :: proc()
{
    pid := fork()
    if pid == 0 {
        cfg := init_configs()
        vt_switch(cfg.target_vt)
        vt_ignore_term_signals()
        gui_draw_screen(cfg)
        vt_switch(1, false)
        return
    }
    wait_pid_and_exit(pid)
}
