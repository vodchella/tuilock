package pam

import "core:c"


SUCCESS         :: 0
OPEN_ERR        :: 1
SYMBOL_ERR      :: 2
SERVICE_ERR     :: 3
SYSTEM_ERR      :: 4
BUF_ERR         :: 5
CONV_ERR        :: 19

PROMPT_ECHO_OFF :: 1
PROMPT_ECHO_ON  :: 2
ERROR_MSG       :: 3
TEXT_INFO       :: 4

SILENT          :: 0x8000


foreign import libpam "system:pam"

Handle :: distinct rawptr

Message :: struct {
    msg_style: c.int,
    msg:       cstring,
}

Response :: struct {
    resp:      cstring,
    resp_retcode: c.int,
}

Auth_Data :: struct {
    username: cstring,
    password: cstring,
}

Conversation_Proc :: proc "c" (
    num_msg:  c.int,
    msg:      [^]^Message,
    response: ^^Response,
    appdata:  rawptr,
) -> c.int

Conversation :: struct {
    conv:        Conversation_Proc,
    appdata_ptr: rawptr,
}

foreign libpam {
    pam_start :: proc(
        service_name: cstring,
        user:         cstring,
        conversation: ^Conversation,
        handle:       ^^Handle,
    ) -> c.int ---
    pam_end :: proc(handle: ^Handle, status: c.int) -> c.int ---
    pam_authenticate :: proc(handle: ^Handle, flags:  c.int) -> c.int ---
    pam_acct_mgmt :: proc(handle: ^Handle, flags:  c.int) -> c.int ---
}
