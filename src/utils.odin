package tuilock

import "core:fmt"
import "core:strings"
import l "core:sys/linux"


panic :: proc(msg: string, args: ..any)
{
    fmt.eprintfln("TUILock failure: {}", fmt.tprintf(msg, ..args))
    l.exit(1)
}

set_io_vt :: proc(vt_number: int)
{
    _, err := l.setsid()
    if err != .NONE {
        panic("setsid: %v", err)
    }

    fd: l.Fd
    tty_path := fmt.tprintf("/dev/tty%d", vt_number)
    fd, err = l.open(strings.clone_to_cstring(tty_path), {.RDWR})
    if err != .NONE {
        panic("open %s: %v", tty_path, err)
    }
    defer l.close(fd)

    io_res := cast(int) l.ioctl(fd, TIOCSCTTY, 1)
    if io_res < 0 {
        panic("TIOCSCTTY: %v", l.Errno(-io_res))
    }

    l.dup2(fd, l.STDIN_FILENO)
    l.dup2(fd, l.STDOUT_FILENO)
    l.dup2(fd, l.STDERR_FILENO)
}

activate_vt :: proc(vt_number: int)
{
    fd, err := l.open("/dev/console", {.RDWR})
    if err != .NONE {
        panic("open /dev/console: %v", err)
    }
    defer l.close(fd)

    io_res := cast(int) l.ioctl(fd, VT_ACTIVATE, uintptr(vt_number))
    if io_res < 0 {
        panic("VT_ACTIVATE: %v", l.Errno(-io_res))
    }

    io_res = cast(int) l.ioctl(fd, VT_WAITACTIVE, uintptr(vt_number) )
    if io_res < 0 {
        panic("VT_WAITACTIVE: %v", l.Errno(-io_res))
    }
}
