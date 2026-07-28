package tuilock

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import linux "core:sys/linux"


panic :: proc(msg: string, err: linux.Errno, args: ..any)
{
    err_desc := strings.clone_from_cstring(libc.strerror(cast(i32) err))
    fmt.eprintfln("TUILock: %s: %v (%s)", fmt.tprintf(msg, ..args), err, err_desc)
    os.exit(cast(int) err)
}

wait_pid_and_exit :: proc(pid: linux.Pid)
{
    status: u32
    usage: linux.RUsage

    _, err := linux.waitpid(pid, &status, {}, &usage)
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
