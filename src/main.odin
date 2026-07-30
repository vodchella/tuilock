package tuilock

import "core:os"
import "core:sys/linux"


main :: proc()
{
    pid, err := linux.fork()
    is_child := pid == 0
    if err != .NONE {
        if !is_child {
            panic("fork", err)
        }
        os.exit(cast(int) err)
    }

    if is_child {
        cfg := init_configs()
        vt_switch(cfg.target_vt)
        vt_ignore_term_signals()
        gui_draw_screen(cfg)
        // vt_switch(1)  // EPERM
        return
    }

    wait_pid_and_exit(pid)
}
