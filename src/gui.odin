#+feature using-stmt
package tuilock

import "core:fmt"
import "ncurses"


gui_draw_screen :: proc()
{
    using ncurses

    msg :: "This is TUILock!"
    fmt.printf("%s[2J%s[H", ASCII_ESC, ASCII_ESC)

    initscr()
    keypad(stdscr, true)
    row, col := getmaxyx(stdscr)
    mvprintw(row / 2, (col - len(msg)) / 2, "%s", msg)
    refresh()

    getch()
    endwin()
}
