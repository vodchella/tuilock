package tuilock

import l "core:sys/linux"


main :: proc()
{
    pid, err := l.fork()
    if err != .NONE {
        if pid != 0 {
            panic("fork: %v", err)
        }
        l.exit(1)
    }

    if pid == 0 {
        set_io_vt(TARGET_VT)
        activate_vt(TARGET_VT)
        gui_draw_screen()
    }
}
