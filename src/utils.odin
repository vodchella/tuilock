package tuilock

import "core:fmt"
import "core:c/libc"
import "core:os"
import "core:strings"
import l "core:sys/linux"


panic :: proc(msg: string, err: l.Errno, args: ..any)
{
    text := strings.clone_from_cstring(libc.strerror(cast(i32) err))
    fmt.eprintfln("TUILock: %s: %v (%s)", fmt.tprintf(msg, ..args), err, text)
    os.exit(cast(int) err)
}

set_io_vt :: proc(vt_number: int)
{
    _, err := l.setsid()
    if err != .NONE {
        panic("setsid", err)
    }

    fd: l.Fd
    tty_path := fmt.tprintf("/dev/tty%d", vt_number)
    fd, err = l.open(strings.clone_to_cstring(tty_path), {.RDWR})
    if err != .NONE {
        panic("open %s", err, tty_path)
    }
    defer l.close(fd)

    io_res := cast(int) l.ioctl(fd, TIOCSCTTY, 1)
    if io_res < 0 {
        panic("TIOCSCTTY", l.Errno(-io_res))
    }

    l.dup2(fd, l.STDIN_FILENO)
    l.dup2(fd, l.STDOUT_FILENO)
    l.dup2(fd, l.STDERR_FILENO)
}

activate_vt :: proc(vt_number: int)
{
    fd, err := l.open("/dev/console", {.RDWR})
    if err != .NONE {
        panic("open /dev/console", err)
    }
    defer l.close(fd)

    io_res := cast(int) l.ioctl(fd, VT_ACTIVATE, uintptr(vt_number))
    if io_res < 0 {
        panic("VT_ACTIVATE", l.Errno(-io_res))
    }

    io_res = cast(int) l.ioctl(fd, VT_WAITACTIVE, uintptr(vt_number) )
    if io_res < 0 {
        panic("VT_WAITACTIVE", l.Errno(-io_res))
    }
}
