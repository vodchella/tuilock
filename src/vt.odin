package tuilock

import "core:fmt"
import "core:strings"
import "core:sys/linux"


@(private = "file")
VT_ACTIVATE   :: 0x5606
@(private = "file")
VT_WAITACTIVE :: 0x5607
@(private = "file")
VT_GETSTATE   :: 0x5603
@(private = "file")
TIOCSCTTY     :: 0x540E

@(private = "file")
VT_Stat :: struct {
    v_active: u16,
    v_signal: u16,
    v_state:  u16,
}

vt_get_active:: proc() -> int
{
    fd, err := linux.open("/dev/tty0", {.RDWR})
    if err != .NONE {
        panic("open /dev/tty0", err)
    }
    defer linux.close(fd)

    state: VT_Stat
    io_res := linux.ioctl(fd, VT_GETSTATE, cast(uintptr) &state)
    if io_res < 0 {
        panic("ioctl VT_GETSTATE", cast(linux.Errno) -io_res)
    }

    return cast(int) state.v_active
}

vt_switch :: proc(vt_number: int, set_io: bool = true)
{
    if set_io {
        vt_set_io(vt_number)
    }
    vt_activate(vt_number)
}

@(private = "file")
vt_set_io :: proc(vt_number: int)
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
        panic("ioctl TIOCSCTTY", cast(linux.Errno) -io_res)
    }

    linux.dup2(fd, linux.STDIN_FILENO)
    linux.dup2(fd, linux.STDOUT_FILENO)
    linux.dup2(fd, linux.STDERR_FILENO)
}

@(private = "file")
vt_activate :: proc(vt_number: int)
{
    fd, err := linux.open("/dev/console", {.RDWR})
    if err != .NONE {
        panic("open /dev/console", err)
    }
    defer linux.close(fd)

    io_res := cast(int) linux.ioctl(fd, VT_ACTIVATE, cast(uintptr) vt_number)
    if io_res < 0 {
        panic("ioctl VT_ACTIVATE", cast(linux.Errno) -io_res)
    }

    io_res = cast(int) linux.ioctl(fd, VT_WAITACTIVE, cast(uintptr) vt_number)
    if io_res < 0 {
        panic("ioctl VT_WAITACTIVE", cast(linux.Errno) -io_res)
    }
}
