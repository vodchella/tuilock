package tuilock

import "core:sys/linux"


main :: proc()
{
    pid := fork()
    if pid == 0 {
        vt  := vt_get_active()
        cfg := configs_init()
        locker_pid := start_killable_process(cfg.locker_cmd)

        vt_switch(cfg.target_vt)
        ignore_term_signals()
        gui_draw_screen(cfg)
        vt_switch(vt, false)

        pgid := cast(linux.Pid) -locker_pid
        linux.kill(pgid, .SIGKILL)
        return
    }
    wait_pid_and_exit(pid)
}
