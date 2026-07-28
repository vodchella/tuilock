package tuilock

import "core:os"
import l "core:sys/linux"


main :: proc()
{
    pid, err := l.fork()
    is_child := pid == 0
    if err != .NONE {
        if !is_child {
            panic("fork", err)
        }
        os.exit(cast(int) err)
    }

    if is_child {
        set_io_vt(TARGET_VT)
        activate_vt(TARGET_VT)
        gui_draw_screen()
        return
    }

    status: u32
    usage: l.RUsage

    _, err = l.waitpid(pid, &status, {}, &usage)
    if err != .NONE {
        panic("waitpid failed", err)
    }
    if l.WIFEXITED(status) {
        os.exit(cast(int) l.WEXITSTATUS(status))
    }
    if l.WIFSIGNALED(status) {
        os.exit(128 + cast(int) l.WTERMSIG(status))
    }
    os.exit(1)
}
