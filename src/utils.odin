package tuilock

import "core:fmt"
import l "core:sys/linux"


panic :: proc(msg: string)
{
    fmt.eprintfln("TUILock failure: {}", msg)
    l.exit(1)
}
