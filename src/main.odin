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
        set_io_vt(TARGET_VT)
        activate_vt(TARGET_VT)
        gui_draw_screen()
        return
    }

    status: u32
    usage: linux.RUsage

    _, err = linux.waitpid(pid, &status, {}, &usage)
    if err != .NONE {
        panic("waitpid", err)
    }
    if linux.WIFEXITED(status) {
        os.exit(cast(int) linux.WEXITSTATUS(status))
    }
    if linux.WIFSIGNALED(status) {
        os.exit(128 + cast(int) linux.WTERMSIG(status))
    }
    os.exit(1)
}
