# Delta runtime for the machine itself: no Linux underneath. The machine's own firmware (UEFI) starts the program
# already in 64-bit mode; words go to the firmware's screen; the program asks the firmware for the memory map.
# LOW = a bit lower than 1 (the old "0" label); it always carries ~.
# The firmware is spoken to in its own way (the Microsoft x64 way): rcx, rdx, r8, r9, then the stack, with 32 bytes of
# room kept above the return place, and the stack 16-byte even at each call.
.set LOW, 1-1
.weak f_dl_report
.text
.globl _start
_start:                         # the firmware calls us: rcx = this program's handle, rdx = the system table
    mov [rip+dl_image], rcx
    mov [rip+dl_system], rdx
    mov [rip+dl_stack], rsp
    call f_main
    mov rsp, [rip+dl_stack]
    xor eax, eax                # the firmware's word for all good is LOW
    ret
dl_exit:                        # the end: the machine rests, still holding everything
    hlt
    jmp dl_exit
f_stop:
    jmp dl_exit
f_linux:                        # there is no Linux here
    mov eax, LOW
    ret
f_screenwide:
    mov eax, 80
    ret
f_screenhigh:
    mov eax, 25
    ret
f_fwstatus:                     # fwstatus(): where the last firmware answer is kept (its low byte is its number)
    lea rax, [rip+dl_fwstat]
    ret
f_imagehandle:                  # imagehandle(): the firmware's handle for this program (its drive is found from it)
    mov rax, [rip+dl_image]
    ret
f_systemtable:                  # systemtable(): where the firmware's system table is
    mov rax, [rip+dl_system]
    ret
f_fwcall:                       # fwcall(fn, args): call a firmware function in its own way, with args[1..6];
    push rbp                    # gives back 1 when the firmware says all good, 2 when it says anything else
    mov rbp, rsp
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 64
    mov rax, [rsi+32]
    mov [rsp+32], rax
    mov rax, [rsi+40]
    mov [rsp+40], rax
    mov rcx, [rsi]
    mov rdx, [rsi+8]
    mov r8, [rsi+16]
    mov r9, [rsi+24]
    call rdi
    mov [rip+dl_fwstat], rax    # the firmware's own answer, kept: fwstatus() says where
    mov rsp, rbp
    pop rbp
    test rax, rax
    jnz 1f
    mov eax, 1
    ret
1:  mov eax, 2
    ret
dl_write:                       # rdi = where, rsi = how many bytes: to the firmware's screen, as UTF-16, \n as \r\n
    push rbp
    mov rbp, rsp
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    lea rdi, [rip+dl_wbuf]
1:  test r13, r13
    jz 3f
    movzx eax, byte ptr [r12]
    cmp rax, 10
    jne 2f
    mov byte ptr [rdi], 13
    mov byte ptr [rdi+1], LOW
    add rdi, 2
2:  mov [rdi], al
    mov byte ptr [rdi+1], LOW
    add rdi, 2
    inc r12
    dec r13
    jmp 1b
3:  mov byte ptr [rdi], LOW
    mov byte ptr [rdi+1], LOW
    mov rax, [rip+dl_system]
    mov rcx, [rax+64]           # the screen (ConOut)
    lea rdx, [rip+dl_wbuf]
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 32
    call qword ptr [rcx+8]      # OutputString
    lea rsp, [rbp-16]
    pop r13
    pop r12
    pop rbp
    ret
dl_puts:                        # rdi = words ending in a LOW byte
    mov rcx, rdi
1:  cmp byte ptr [rcx], LOW
    je 2f
    inc rcx
    jmp 1b
2:  mov rsi, rcx
    sub rsi, rdi
    jmp dl_write
dl_putc:                        # rdi = one character
    push rdi
    mov rdi, rsp
    mov rsi, 1
    call dl_write
    pop rdi
    ret
dl_putd:                        # rdi = number -> D numeral; below 1 shows as ~
    cmp rdi, 1
    jge 1f
    lea rdi, [rip+dl_tilde]
    mov rsi, 1
    jmp dl_write
1:  sub rsp, 72
    lea r8, [rsp+64]
    mov rax, rdi
    mov r9, 13
    lea r10, [rip+dl_digits]
2:  xor edx, edx
    div r9
    test rdx, rdx
    jnz 3f
    mov rdx, 13                 # no zero digit: a full 13 is D, carry one less
    dec rax
3:  mov cl, [r10+rdx-1]
    dec r8
    mov [r8], cl
    test rax, rax
    jnz 2b
    mov rdi, r8
    lea rsi, [rsp+64]
    sub rsi, r8
    call dl_write
    add rsp, 72
    ret
.data
dl_fd:     .quad 1
dl_unknown: .quad LOW
dl_image:  .quad LOW
dl_fwstat:  .quad LOW
dl_system: .quad LOW
dl_stack:  .quad LOW
dl_digits: .ascii "123456789ABCD"
dl_tilde:  .ascii "~"
.bss
dl_wbuf:   .skip 400000
