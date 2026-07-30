#+private file
#+feature using-stmt
package tuilock

import "core:fmt"
import "core:strings"
import "ncurses"


Field_Kind :: enum {
    Username,
    Password,
}

Text_Field :: struct {
    label:    string,
    buffer:   [64]u8,
    length:   int,
    password: bool,
    y:        i32,
    value_x:  i32,
}

Login_Dialog :: struct {
    height:       i32,
    width:        i32,
    greet:        string,
    window:       ^ncurses.Window,
    active_field: Field_Kind,
    username:     Text_Field,
    password:     Text_Field,
    message:      string,
}


@(private)
gui_draw_screen :: proc(cfg: Configs)
{
    using ncurses

    fmt.printf("%s[2J%s[H", ASCII_ESC, ASCII_ESC)
    initscr()
    cbreak()
    noecho()
    keypad(stdscr, true)
    curs_set(1)

    if has_colors() {
        start_color()
        init_pair(THEME_BACKGROUND, cfg.theme_background, cfg.theme_background)
        init_pair(THEME_TIME,       cfg.theme_time,       cfg.theme_background)
        init_pair(THEME_DIALOG,     cfg.theme_dialog,     cfg.theme_dialog)
        init_pair(THEME_BORDER,     cfg.theme_border,     cfg.theme_dialog)
        init_pair(THEME_GREET,      cfg.theme_greet,      cfg.theme_dialog)
        init_pair(THEME_PROMPT,     cfg.theme_prompt,     cfg.theme_dialog)
        init_pair(THEME_INPUT,      cfg.theme_input,      cfg.theme_dialog)
    }

    rows, cols := getmaxyx(stdscr)
    gui_fill_background()
    gui_draw_time(cfg, rows, cols)
    refresh()

    dialog := dialog_init(cfg, rows, cols)
    defer delwin(dialog.window)

    running := true
    for running {
        gui_draw_dialog(&dialog)
        key := wgetch(dialog.window)
        running = handle_key(&dialog, key)
    }

    endwin()
}

gui_fill_background :: proc()
{
    using ncurses
    bkgd(' ' | COLOR_PAIR(THEME_BACKGROUND))
}

gui_draw_time :: proc(cfg: Configs, rows, cols: i32)
{
    using ncurses

    datetime := get_current_datetime_string(cfg.time_format)
    defer delete(datetime)
    put_text(stdscr, 0, (cols - cast(i32) len(datetime)) / 2, datetime, THEME_TIME)
}

gui_draw_field :: proc(win: ^ncurses.Window, field: ^Text_Field, active: bool) {
    using ncurses

    if active { wattron(win, A_BOLD) }
    put_text(win, field.y, 2, field.label, THEME_PROMPT)
    if active { wattroff(win, A_BOLD) }

    value  := string(field_value(field))
    output := field.password ? strings.repeat("*", len(value)) : value
    defer if field.password { delete(output) }
    put_text(win, field.y, field.value_x, output, THEME_INPUT)
}

gui_draw_dialog :: proc(dialog: ^Login_Dialog) {
    using ncurses

    win := dialog.window
    werase(win)

    wattron(win, COLOR_PAIR(THEME_BORDER))
    box(win, 0, 0)
    wattroff(win, COLOR_PAIR(THEME_BORDER))

    greet_x := (dialog.width - cast(i32) len(dialog.greet)) / 2
    put_text(win, 2, greet_x, dialog.greet, THEME_GREET)
    put_text(win, 0, 2, " Authenticate to unlock: ", THEME_BORDER)

    gui_draw_field(win, &dialog.username, dialog.active_field == .Username)
    gui_draw_field(win, &dialog.password, dialog.active_field == .Password)

    if len(dialog.message) > 0 {
        put_text(win, 7, 2, dialog.message, THEME_BORDER)
    }

    field := dialog_active_field(dialog)
    cursor_x := field.value_x + cast(i32) field.length
    wmove(win, field.y, cursor_x)

    wrefresh(win)
}

// ------------------------------------------------------------------------

dialog_init :: proc(cfg: Configs, rows, cols: i32) -> (dialog: Login_Dialog)
{
    using ncurses

    start_y := max(0, (rows - cfg.dialog_height) / 2)
    start_x := max(0, (cols - cfg.dialog_width) / 2)
    win := newwin(cfg.dialog_height, cfg.dialog_width, start_y, start_x)
    wbkgd(win, ' ' | COLOR_PAIR(THEME_DIALOG))
    keypad(win, true)

    dialog = Login_Dialog {
        window       = win,
        width        = cfg.dialog_width,
        height       = cfg.dialog_height,
        greet        = cfg.dialog_greet,
        active_field = .Username,
        username     = Text_Field {
            label    = "Username:",
            password = false,
            y        = 4,
            value_x  = 13,
        },
        password     = Text_Field {
            label    = "Password:",
            password = true,
            y        = 5,
            value_x  = 13,
        },
    }
    return
}

dialog_active_field :: proc(dialog: ^Login_Dialog) -> ^Text_Field {
    switch dialog.active_field {
    case .Username:
        return &dialog.username
    case .Password:
        return &dialog.password
    }
    return nil
}

dialog_switch_field :: proc(dialog: ^Login_Dialog) {
    dialog.active_field = dialog.active_field == .Username ? .Password : .Username
}

dialog_submit :: proc(dialog: ^Login_Dialog) {
    switch dialog.active_field {
    case .Username:
        dialog.active_field = .Password
    case .Password:
        username := string(field_value(&dialog.username))
        dialog.message = fmt.tprintf(
            "Submitted user '%s', password length: %d",
            username,
            dialog.password.length,
        )
    }
}

// ------------------------------------------------------------------------

field_add_char :: proc(field: ^Text_Field, ch: u8) {
    if field.length >= len(field.buffer) {
        return
    }
    field.buffer[field.length] = ch
    field.length += 1
}

field_remove_char :: proc(field: ^Text_Field) {
    if field.length == 0 {
        return
    }
    field.length -= 1
    field.buffer[field.length] = 0
}

field_value :: proc(field: ^Text_Field) -> []u8 {
    return field.buffer[:field.length]
}

// ------------------------------------------------------------------------

handle_key :: proc(dialog: ^Login_Dialog, key: i32) -> bool {
    using ncurses
    switch key {
    case '\t':
        dialog_switch_field(dialog)
    case '\n', '\r', KEY_ENTER:
        dialog_submit(dialog)
    case KEY_BACKSPACE, 127, 8:
        field_remove_char(dialog_active_field(dialog))
    case 27:
        return false
    case:
        if key < 32 || key > 126 {
            return true
        }
        field_add_char(dialog_active_field(dialog), cast(u8) key)
    }
    return true
}

put_text :: proc(win: ^ncurses.Window, y, x: i32, text: string, theme: i32) {
    using ncurses

    wattron(win, COLOR_PAIR(theme))
    c_text := strings.clone_to_cstring(text)
    defer delete(c_text)
    ncurses.mvwaddstr(win, y, x, c_text)
    wattroff(win, COLOR_PAIR(theme))
}
