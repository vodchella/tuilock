package tuilock

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import "core:sys/posix"
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

get_current_datetime_string :: proc(format: string) -> string
{
    formatc := strings.clone_to_cstring(format)
    defer delete(formatc)

    buf: [64]u8
    t  := libc.time(nil)
    tm := libc.localtime(&t)
    libc.strftime(&buf[0], len(buf), formatc, tm)
    return strings.clone_from_cstring(cstring(&buf[0]))
}

get_current_username :: proc() -> (username: string)
{
    uid := posix.getuid()
    pw  := posix.getpwuid(uid)
    if pw != nil {
        username = strings.clone_from_cstring(pw.pw_name)
    }
    return
}

get_original_username :: proc() -> (username: string)
{
    alloc := context.allocator
    if username = os.get_env("SUDO_USER", alloc); username != "" {
        return
    }
    return get_current_username()
}
