package tuilock

import "core:os"
import linux "core:sys/linux"


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
        vt_switch(TARGET_VT)
        gui_draw_screen()
        return
    }

    wait_pid_and_exit(pid)
}
