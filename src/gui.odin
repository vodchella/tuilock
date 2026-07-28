#+feature using-stmt
package tuilock

import "core:fmt"
import "ncurses"


gui_draw_screen :: proc()
{
    using ncurses

    datetime := get_current_datetime_string()
    defer delete(datetime)

    fmt.printf("%s[2J%s[H", ASCII_ESC, ASCII_ESC)
    initscr()
    keypad(stdscr, true)
    row, col := getmaxyx(stdscr)

    if has_colors() {
        start_color()
        init_pair(1, COLOR_LIGHT_RED, COLOR_BLACK)
    }

    attron(COLOR_PAIR(1))
    mvprintw(0, (col - cast(i32) len(datetime)) / 2, "%s", datetime)
    attroff(COLOR_PAIR(1))

    refresh()
    getch()
    endwin()
}
