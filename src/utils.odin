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

set_io_vt :: proc(vt_number: int)
{
    _, err := linux.setsid()
    if err != .NONE {
        panic("setsid", err)
    }

    fd: linux.Fd
    tty_path := fmt.tprintf("/dev/tty%d", vt_number)
    fd, err = linux.open(strings.clone_to_cstring(tty_path), {.RDWR})
    if err != .NONE {
        panic("open %s", err, tty_path)
    }
    defer linux.close(fd)

    io_res := cast(int) linux.ioctl(fd, TIOCSCTTY, 1)
    if io_res < 0 {
        panic("TIOCSCTTY", cast(linux.Errno) -io_res)
    }

    linux.dup2(fd, linux.STDIN_FILENO)
    linux.dup2(fd, linux.STDOUT_FILENO)
    linux.dup2(fd, linux.STDERR_FILENO)
}

activate_vt :: proc(vt_number: int)
{
    fd, err := linux.open("/dev/console", {.RDWR})
    if err != .NONE {
        panic("open /dev/console", err)
    }
    defer linux.close(fd)

    io_res := cast(int) linux.ioctl(fd, VT_ACTIVATE, cast(uintptr) vt_number)
    if io_res < 0 {
        panic("VT_ACTIVATE", cast(linux.Errno) -io_res)
    }

    io_res = cast(int) linux.ioctl(fd, VT_WAITACTIVE, cast(uintptr) vt_number)
    if io_res < 0 {
        panic("VT_WAITACTIVE", cast(linux.Errno) -io_res)
    }
}
