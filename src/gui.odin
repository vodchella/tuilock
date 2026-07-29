#+feature using-stmt
package tuilock

import "core:fmt"
import "ncurses"


gui_draw_screen :: proc(cfg: Configs)
{
    using ncurses

    datetime := get_current_datetime_string(cfg.time_format)
    defer delete(datetime)

    fmt.printf("%s[2J%s[H", ASCII_ESC, ASCII_ESC)
    initscr()
    keypad(stdscr, true)
    rows, cols := getmaxyx(stdscr)

    if has_colors() {
        start_color()
        init_pair(THEME_BACKGROUND, cfg.theme_background, cfg.theme_background)
        init_pair(THEME_TIME,       cfg.theme_time,       cfg.theme_background)
    }

    bkgd(' ' | COLOR_PAIR(THEME_BACKGROUND))

    attron(COLOR_PAIR(THEME_TIME))
    mvprintw(0, (cols - cast(i32) len(datetime)) / 2, "%s", datetime)
    attroff(COLOR_PAIR(THEME_TIME))

    refresh()
    getch()
    endwin()
}
