package tuilock

import "core:fmt"
import l "core:sys/linux"


TIOCSCTTY :: u32(0x540E)


panic :: proc(msg: string)
{
    fmt.eprintfln("TUILock failure: {}", msg)
    l.exit(1)
}

main :: proc()
{
    err: l.Errno
    pid: l.Pid
    pid, err = l.fork()
    if err != .NONE {
        if pid != 0 {
            panic("fork")
        } else {
            l.exit(1)
        }
    }

    if pid == 0 {
        _, err = l.setsid()
        if err != .NONE {
            panic("setsid")
        }

        fd: l.Fd
        fd, err = l.open("/dev/tty8", {.RDWR})
        if err != .NONE {
            panic("open /dev/tty8")
        }
        defer l.close(fd)

        io_res := cast(int) l.ioctl(fd, TIOCSCTTY, 1)
        if io_res < 0 {
            panic(fmt.tprintf("TIOCSCTTY: %v", l.Errno(-io_res)))
        }

        l.dup2(fd, l.STDIN_FILENO)
        l.dup2(fd, l.STDOUT_FILENO)
        l.dup2(fd, l.STDERR_FILENO)

        fmt.printfln("This is TUILock!")
    }
}
