package tuilock

import "core:fmt"


gui_draw_screen :: proc()
{
    fmt.printf("%s[2J%s[H", ASCII_ESC, ASCII_ESC)
    fmt.printfln("This is TUILock!")
}
