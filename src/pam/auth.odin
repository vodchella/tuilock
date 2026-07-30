package pam

import "core:c"
import "core:c/libc"
import "core:strings"


cstring_dup :: proc "c" (s: cstring) -> cstring
{
    if s == nil {
        return nil
    }

    len := libc.strlen(s)
    dst := libc.malloc(len + 1)
    if dst == nil {
        return nil
    }

    libc.memcpy(dst, cast(rawptr) s, len + 1)

    return cast(cstring) dst
}

conversation_proc :: proc "c" (
    num_msg:   c.int,
    messages:  [^]^Message,
    responses:  ^^Response,
    appdata:   rawptr,
) -> c.int
{
    data := cast(^Auth_Data) appdata
    response_array := cast([^]Response) libc.calloc(
        cast(c.size_t)num_msg,
        size_of(Response),
    )

    if response_array == nil {
        return BUF_ERR
    }

    for i in 0..<int(num_msg) {
        message := messages[i]^

        switch message.msg_style {
        case PROMPT_ECHO_OFF:
            response_array[i].resp = cstring_dup(data.password)
        case PROMPT_ECHO_ON:
            response_array[i].resp = cstring_dup(data.username)
        case ERROR_MSG, TEXT_INFO:
            response_array[i].resp = nil
        case:
            free_responses(response_array, i)
            return CONV_ERR
        }

        if response_array[i].resp == nil &&
           (message.msg_style == PROMPT_ECHO_OFF ||
            message.msg_style == PROMPT_ECHO_ON) {
            free_responses(response_array, i + 1)
            return BUF_ERR
        }
    }

    responses^ = response_array
    return SUCCESS
}

free_responses :: proc "c" (responses: [^]Response, count: int)
{
    for i in 0..< count {
        if responses[i].resp != nil {
            libc.free(cast(rawptr) responses[i].resp)
        }
    }
    libc.free(responses)
}

auth :: proc(service_name: cstring, username, password: string) -> bool
{
    c_username := strings.clone_to_cstring(username)
    defer delete(c_username)

    c_password := strings.clone_to_cstring(password)
    defer delete(c_password)

    data := Auth_Data {
        username = c_username,
        password = c_password,
    }

    conv := Conversation {
        conv        = conversation_proc,
        appdata_ptr = &data,
    }

    handle: ^Handle

    status := pam_start(service_name, c_username, &conv, &handle)
    if status == SUCCESS {
        status = pam_authenticate(handle, SILENT)
    }
    if status == SUCCESS {
        status = pam_acct_mgmt(handle, SILENT)
    }
    if handle != nil {
        pam_end(handle, status)
    }

    return status == SUCCESS
}
