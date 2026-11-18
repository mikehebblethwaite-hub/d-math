.intel_syntax noprefix
# Delta runtime 0.18: our own, straight to Linux. LOW = a bit lower than 1 (the old "0" label),
# it always carries ~ (static, radiation, outside forces, forces not yet known).
.set LOW, 1-1
.weak f_dl_report
.text
.globl _start
_start:
    mov rdi, [rsp]              # how many words on the command line
    lea rsi, [rsp+8]            # the words; argv[1] is the program itself
    call f_main
    push rax
    lea rcx, [rip+f_dl_report]      # D report, when the neighbour system is in this program
    test rcx, rcx
    jz 1f
    call f_dl_report
1:  pop rax
    mov rdi, rax
    cmp rax, 1                  # main gives 1 = all good; Linux calls that LOW
    jne dl_exit
    mov edi, LOW
dl_exit:
    mov eax, 60
    syscall
f_stop:                         # stop(n): end the program now with n
    jmp dl_exit
f_linux:                        # linux(n, a, b, c, d, e): ask Linux directly (a system call)
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov r10, r8
    mov r8, r9
    syscall
    cmp rax, 1                  # Linux says "it did not happen" with a number below 1: that is LOW here
    jge 1f
    mov eax, LOW
1:  ret
f_wait:                         # wait(ms): time runs on while the program rests (Linux nanosleep)
    mov rax, rdi
    xor edx, edx
    mov rcx, 1000
    div rcx
    imul rdx, rdx, 1000000
    push rdx
    push rax
    mov rdi, rsp
    xor esi, esi
    mov eax, 35
    syscall
    add rsp, 16
    mov eax, 1
    ret
f_screenwide:                   # screenwide(): letters across the terminal (Linux ioctl TIOCGWINSZ)
    mov r8, 2
    jmp 1f
f_screenhigh:                   # screenhigh(): lines down the terminal
    mov r8, LOW
1:  sub rsp, 16
    mov edi, 1
    mov esi, 0x5413
    mov rdx, rsp
    mov eax, 16
    syscall
    test rax, rax
    jnz 2f
    movzx eax, word ptr [rsp+r8]
    add rsp, 16
    cmp rax, 1
    jl 3f
    ret
2:  add rsp, 16
3:  mov eax, 80                 # not a terminal: the old standard 80 across
    test r8, r8
    jnz 4f
    mov eax, 24                 # and 24 down
4:  ret
dl_write:                       # rdi = where, rsi = how many bytes
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, [rip+dl_fd]
    mov eax, 1
    syscall
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
dl_unknown: .quad LOW           # ~ : all the unknown energy left in things broken down (always there, not known yet)
dl_digits: .ascii "123456789ABCD"
dl_tilde:  .ascii "~"

.text
f_fail:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S1]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S2]
    mov rsi, 2
    call dl_write
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S3]
    mov rsi, 1
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
    xor eax, eax
.Lret_fail:
    mov rsp, rbp
    pop rbp
    ret
f_failat:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_fail
    xor eax, eax
.Lret_failat:
    mov rsp, rbp
    pop rbp
    ret
f_failname:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S4]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S5]
    mov rsi, 2
    call dl_write
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rdi, rax
    call dl_puts
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S6]
    mov rsi, 1
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
    xor eax, eax
.Lret_failname:
    mov rsp, rbp
    pop rbp
    ret
f_same:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L2:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L4
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L4
    mov eax, 1
    jmp .L5
.L4:
    xor eax, eax
.L5:
    test rax, rax
    jz .L3
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L2
.L3:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    jmp .Lret_same
    xor eax, eax
.Lret_same:
    mov rsp, rbp
    pop rbp
    ret
f_starts:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L6:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L7
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L8
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_starts
.L8:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L6
.L7:
    mov rax, 1
    jmp .Lret_starts
    xor eax, eax
.Lret_starts:
    mov rsp, rbp
    pop rbp
    ret
f_intern:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rdi, [rbp-32]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L9:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L11
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 31
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 4096
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L12
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S7]
    mov rsi, 11
    call dl_write
    mov rdi, 125
    call dl_putd
    lea rdi, [rip+.S8]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S9]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L12:
    cqo
    idiv rcx
    mov rax, rdx
    pop rcx
    mov qword ptr [rcx], rax
.L10:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L9
.L11:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_hh]
    lea rax, [rip+g_hh]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
.L13:
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L14
    lea rax, [rip+g_hname]
    lea rax, [rip+g_hname]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    mov rax, 1
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
.L15:
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L17
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L19
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S10]
    mov rsi, 11
    call dl_write
    mov rdi, 130
    call dl_putd
    lea rdi, [rip+.S11]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S12]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S13]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S14]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L19:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L17
    mov eax, 1
    jmp .L18
.L17:
    xor eax, eax
.L18:
    test rax, rax
    jz .L16
    lea rax, [rbp-56]
    mov rax, [rax]
    lea rax, [rbp-56]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L15
.L16:
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L20
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L20
    mov eax, 1
    jmp .L21
.L20:
    xor eax, eax
.L21:
    test rax, rax
    jz .L22
    lea rax, [rbp-48]
    mov rax, [rax]
    jmp .Lret_intern
.L22:
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rip+g_hnext]
    lea rax, [rip+g_hnext]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L13
.L14:
    lea rax, [rip+g_nnames]
    mov rax, [rax]
    lea rax, [rip+g_nnames]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_hname]
    lea rax, [rip+g_hname]
    push rax
    lea rax, [rip+g_nnames]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_hname]
    push rax
    lea rax, [rip+g_nnames]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_hnext]
    lea rax, [rip+g_hnext]
    push rax
    lea rax, [rip+g_nnames]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_hnext]
    push rax
    lea rax, [rip+g_nnames]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_hh]
    lea rax, [rip+g_hh]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_hh]
    lea rax, [rip+g_hh]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_hh]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_nnames]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L23:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L25
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L24:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L23
.L25:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-64]
    mov rax, [rax]
    jmp .Lret_intern
    xor eax, eax
.Lret_intern:
    mov rsp, rbp
    pop rbp
    ret
f_word:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L26:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L27
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L26
.L27:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L28
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S15]
    mov rsi, 11
    call dl_write
    mov rdi, 141
    call dl_putd
    lea rdi, [rip+.S16]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S17]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S18]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S19]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L28:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_intern
    jmp .Lret_word
    xor eax, eax
.Lret_word:
    mov rsp, rbp
    pop rbp
    ret
f_newstr:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    mov rax, 1
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L29:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L30
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L29
.L30:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_newstr
    xor eax, eax
.Lret_newstr:
    mov rsp, rbp
    pop rbp
    ret
f_dotname:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
.L31:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L32
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L31
.L32:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    mov rax, 46
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L33:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L34
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L33
.L34:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    jmp .Lret_dotname
    xor eax, eax
.Lret_dotname:
    mov rsp, rbp
    pop rbp
    ret
f_isdig:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L35
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 57
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L35
    mov eax, 1
    jmp .L36
.L35:
    xor eax, eax
.L36:
    jmp .Lret_isdig
    xor eax, eax
.Lret_isdig:
    mov rsp, rbp
    pop rbp
    ret
f_isal:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L37
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 122
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L37
    mov eax, 1
    jmp .L38
.L37:
    xor eax, eax
.L38:
    test rax, rax
    jnz .L39
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 65
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L41
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 90
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L41
    mov eax, 1
    jmp .L42
.L41:
    xor eax, eax
.L42:
    test rax, rax
    jnz .L39
    xor eax, eax
    jmp .L40
.L39:
    mov eax, 1
.L40:
    test rax, rax
    jnz .L43
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 95
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L43
    xor eax, eax
    jmp .L44
.L43:
    mov eax, 1
.L44:
    jmp .Lret_isal
    xor eax, eax
.Lret_isal:
    mov rsp, rbp
    pop rbp
    ret
f_isaln:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isal
    test rax, rax
    jnz .L45
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isdig
    test rax, rax
    jnz .L45
    xor eax, eax
    jmp .L46
.L45:
    mov eax, 1
.L46:
    jmp .Lret_isaln
    xor eax, eax
.Lret_isaln:
    mov rsp, rbp
    pop rbp
    ret
f_addtok:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    lea rax, [rip+g_ntok]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tn]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_addtok:
    mov rsp, rbp
    pop rbp
    ret
f_escape:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 110
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L47
    mov rax, 10
    jmp .Lret_escape
.L47:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 116
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L48
    mov rax, 9
    jmp .Lret_escape
.L48:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 114
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L49
    mov rax, 13
    jmp .Lret_escape
.L49:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 92
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L50
    mov rax, 92
    jmp .Lret_escape
.L50:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 39
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L51
    mov rax, 39
    jmp .Lret_escape
.L51:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 34
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L52
    mov rax, 34
    jmp .Lret_escape
.L52:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 97
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L53
    mov rax, 7
    jmp .Lret_escape
.L53:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 101
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L54
    mov rax, 27
    jmp .Lret_escape
.L54:
    lea rax, [rip+.S20]
    push rax
    pop rdi
    call f_fail
    mov rax, 1
    jmp .Lret_escape
    xor eax, eax
.Lret_escape:
    mov rsp, rbp
    pop rbp
    ret
f_lexrange:
    push rbp
    mov rbp, rsp
    sub rsp, 208         
    mov [rbp-8], rdi
    mov [rbp-16], rsi
.L55:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L56
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L57
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L58
.L57:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L59
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 9
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L59
    xor eax, eax
    jmp .L60
.L59:
    mov eax, 1
.L60:
    test rax, rax
    jnz .L61
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L61
    xor eax, eax
    jmp .L62
.L61:
    mov eax, 1
.L62:
    test rax, rax
    jz .L63
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L64
.L63:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L65
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L65
    mov eax, 1
    jmp .L66
.L65:
    xor eax, eax
.L66:
    test rax, rax
    jz .L67
.L68:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L70
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L70
    mov eax, 1
    jmp .L71
.L70:
    xor eax, eax
.L71:
    test rax, rax
    jz .L69
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L68
.L69:
    jmp .L72
.L67:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L73
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L73
    mov eax, 1
    jmp .L74
.L73:
    xor eax, eax
.L74:
    test rax, rax
    jz .L75
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L76:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L78
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L80
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L80
    xor eax, eax
    jmp .L81
.L80:
    mov eax, 1
.L81:
    test rax, rax
    jz .L78
    mov eax, 1
    jmp .L79
.L78:
    xor eax, eax
.L79:
    test rax, rax
    jz .L77
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L82
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L82:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L76
.L77:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L83
.L75:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 35
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L84
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L85:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L86
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L85
.L86:
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
.L87:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_isal
    test rax, rax
    jz .L88
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L87
.L88:
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L89
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S21]
    mov rsi, 11
    call dl_write
    mov rdi, 184
    call dl_putd
    lea rdi, [rip+.S22]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S23]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S24]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S25]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L89:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_intern
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kinclude]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L90
.L91:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L93
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L93
    mov eax, 1
    jmp .L94
.L93:
    xor eax, eax
.L94:
    test rax, rax
    jz .L92
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L91
.L92:
    jmp .L95
.L90:
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kdefine]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L96
.L97:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 32
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L98
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L97
.L98:
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
.L99:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_isaln
    test rax, rax
    jz .L100
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L99
.L100:
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    lea rax, [rip+g_ndef]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_defname]
    lea rax, [rip+g_defname]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_defname]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L101
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S26]
    mov rsi, 11
    call dl_write
    mov rdi, 189
    call dl_putd
    lea rdi, [rip+.S27]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S28]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S29]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S30]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L101:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_intern
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_defs]
    lea rax, [rip+g_defs]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_defs]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L102:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L104
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L104
    mov eax, 1
    jmp .L105
.L104:
    xor eax, eax
.L105:
    test rax, rax
    jz .L103
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L102
.L103:
    lea rax, [rip+g_defe]
    lea rax, [rip+g_defe]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_defe]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L106
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S31]
    mov rsi, 11
    call dl_write
    mov rdi, 192
    call dl_putd
    lea rdi, [rip+.S32]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S33]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S34]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S35]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L106:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rip+g_defs]
    lea rax, [rip+g_defs]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_defe]
    lea rax, [rip+g_defe]
    push rax
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lexrange
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    lea rax, [rip+g_ntok]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L107
.L96:
    lea rax, [rip+.S36]
    push rax
    pop rdi
    call f_fail
.L107:
.L95:
    jmp .L108
.L84:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 34
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L109
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L110:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 34
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L111
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 80
    mov qword ptr [rcx], rax
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L112
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jnz .L112
    xor eax, eax
    jmp .L113
.L112:
    mov eax, 1
.L113:
    test rax, rax
    jz .L114
    lea rax, [rip+.S37]
    push rax
    pop rdi
    call f_fail
.L114:
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 92
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L115
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_escape
    pop rcx
    mov qword ptr [rcx], rax
.L115:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-80]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-72]
    mov rax, [rax]
    lea rax, [rbp-72]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L110
.L111:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 3
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
    jmp .L116
.L109:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 39
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L117
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 88
    mov qword ptr [rcx], rax
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    mov rax, 92
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L118
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-88]
    mov rax, [rax]
    lea rax, [rbp-88]
    push rax
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_escape
    pop rcx
    mov qword ptr [rcx], rax
.L118:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 39
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L119
    lea rax, [rip+.S38]
    push rax
    pop rdi
    call f_fail
.L119:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 1
    push rax
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
    jmp .L120
.L117:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isdig
    test rax, rax
    jnz .L121
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 36
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L121
    xor eax, eax
    jmp .L122
.L121:
    mov eax, 1
.L122:
    test rax, rax
    jz .L123
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 96
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 36
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L124
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L124:
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 104
    mov qword ptr [rcx], rax
.L125:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_isaln
    test rax, rax
    jnz .L127
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 46
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L127
    xor eax, eax
    jmp .L128
.L127:
    mov eax, 1
.L128:
    test rax, rax
    jz .L126
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L125
.L126:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 112
    mov qword ptr [rcx], rax
    lea rdi, [rbp-120]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    mov rax, 1
    mov rcx, rbp
    sub rcx, 128
    mov qword ptr [rcx], rax
    lea rax, [rbp-120]
    mov rax, [rax]
    lea rax, [rbp-120]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L129:
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L131
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L132
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 108
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L132
    mov eax, 1
    jmp .L133
.L132:
    xor eax, eax
.L133:
    test rax, rax
    jz .L134
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 76
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L134
    mov eax, 1
    jmp .L135
.L134:
    xor eax, eax
.L135:
    test rax, rax
    jz .L136
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 117
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L136
    mov eax, 1
    jmp .L137
.L136:
    xor eax, eax
.L137:
    test rax, rax
    jz .L138
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 85
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L138
    mov eax, 1
    jmp .L139
.L138:
    xor eax, eax
.L139:
    test rax, rax
    jz .L140
    lea rax, [rbp-128]
    mov rax, [rax]
    lea rax, [rbp-128]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L140:
.L130:
    lea rax, [rbp-120]
    mov rax, [rax]
    lea rax, [rbp-120]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L129
.L131:
    lea rax, [rbp-128]
    mov rax, [rax]
    test rax, rax
    jz .L141
    lea rax, [rip+.S39]
    push rax
    pop rdi
    call f_fail
.L141:
    lea rax, [rbp-120]
    mov rax, [rax]
    lea rax, [rbp-120]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L142:
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L144
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L145
    lea rax, [rip+.S40]
    push rax
    pop rdi
    call f_fail
.L145:
.L143:
    lea rax, [rbp-120]
    mov rax, [rax]
    lea rax, [rbp-120]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L142
.L144:
    lea rax, [rbp-120]
    mov rax, [rax]
    lea rax, [rbp-120]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L146:
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L148
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 136
    mov qword ptr [rcx], rax
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 46
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L149
    lea rax, [rip+.S41]
    push rax
    pop rdi
    call f_fail
.L149:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 144
    mov qword ptr [rcx], rax
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 49
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L150
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 57
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L150
    mov eax, 1
    jmp .L151
.L150:
    xor eax, eax
.L151:
    test rax, rax
    jz .L152
    lea rax, [rbp-144]
    mov rax, [rax]
    lea rax, [rbp-144]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 48
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L153
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S42]
    mov rsi, 11
    call dl_write
    mov rdi, 234
    call dl_putd
    lea rdi, [rip+.S43]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S44]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S45]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S46]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L153:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L154
.L152:
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 65
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L155
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 68
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L155
    mov eax, 1
    jmp .L156
.L155:
    xor eax, eax
.L156:
    test rax, rax
    jz .L157
    lea rax, [rbp-144]
    mov rax, [rax]
    lea rax, [rbp-144]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    mov rax, 65
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L158
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S47]
    mov rsi, 11
    call dl_write
    mov rdi, 235
    call dl_putd
    lea rdi, [rip+.S48]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S49]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S50]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S51]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L158:
    sub rax, rcx
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L159
.L157:
    lea rax, [rip+.S52]
    push rax
    pop rdi
    call f_fail
.L159:
.L154:
    lea rax, [rbp-112]
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    lea rax, [rbp-144]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L147:
    lea rax, [rbp-120]
    mov rax, [rax]
    lea rax, [rbp-120]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L146
.L148:
    mov rax, 1
    push rax
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L160
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S53]
    mov rsi, 11
    call dl_write
    mov rdi, 239
    call dl_putd
    lea rdi, [rip+.S54]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S55]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S56]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S57]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L160:
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
    jmp .L161
.L123:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 68
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L162
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L162
    mov eax, 1
    jmp .L163
.L162:
    xor eax, eax
.L163:
    test rax, rax
    jz .L164
    mov rax, 4
    push rax
    mov rax, 68
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 2
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L165
.L164:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isal
    test rax, rax
    jz .L166
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 152
    mov qword ptr [rcx], rax
.L167:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_isaln
    test rax, rax
    jz .L168
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L167
.L168:
    lea rdi, [rbp-160]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-160]
    mov rax, [rax]
    lea rax, [rbp-160]
    push rax
    lea rax, [rbp-152]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L169:
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L171
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 48
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L172
    lea rax, [rip+.S58]
    push rax
    pop rdi
    call f_fail
.L172:
.L170:
    lea rax, [rbp-160]
    mov rax, [rax]
    lea rax, [rbp-160]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L169
.L171:
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-152]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-152]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L173
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S59]
    mov rsi, 11
    call dl_write
    mov rdi, 247
    call dl_putd
    lea rdi, [rip+.S60]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S61]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S62]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S63]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L173:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_intern
    mov rcx, rbp
    sub rcx, 168
    mov qword ptr [rcx], rax
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S64]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jnz .L174
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S65]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jnz .L174
    xor eax, eax
    jmp .L175
.L174:
    mov eax, 1
.L175:
    test rax, rax
    jz .L176
    lea rax, [rip+.S66]
    push rax
    pop rdi
    call f_fail
.L176:
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S67]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jz .L177
    lea rax, [rip+.S68]
    push rax
    pop rdi
    call f_fail
.L177:
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S69]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jz .L178
    lea rax, [rip+.S70]
    push rax
    pop rdi
    call f_fail
.L178:
    lea rax, [rip+g_ndef]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 176
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 184
    mov qword ptr [rcx], rax
.L179:
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L181
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L181
    mov eax, 1
    jmp .L182
.L181:
    xor eax, eax
.L182:
    test rax, rax
    jz .L180
    lea rax, [rip+g_defname]
    lea rax, [rip+g_defname]
    push rax
    lea rax, [rbp-176]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L183
    lea rax, [rip+g_defs]
    lea rax, [rip+g_defs]
    push rax
    lea rax, [rbp-176]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_defe]
    lea rax, [rip+g_defe]
    push rax
    lea rax, [rbp-176]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lexrange
    lea rax, [rbp-184]
    mov rax, [rax]
    lea rax, [rbp-184]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L183:
    lea rax, [rbp-176]
    mov rax, [rax]
    lea rax, [rbp-176]
    push rax
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L184
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S71]
    mov rsi, 11
    call dl_write
    mov rdi, 254
    call dl_putd
    lea rdi, [rip+.S72]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S73]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S74]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S75]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L184:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L179
.L180:
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L185
    mov rax, 2
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-152]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L186
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S76]
    mov rsi, 11
    call dl_write
    mov rdi, 256
    call dl_putd
    lea rdi, [rip+.S77]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S78]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S79]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S80]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L186:
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
.L185:
    jmp .L187
.L166:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 192
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 200
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 208
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 45
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L188
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L188
    mov eax, 1
    jmp .L189
.L188:
    xor eax, eax
.L189:
    test rax, rax
    jz .L190
    lea rax, [rbp-208]
    mov rax, [rax]
    lea rax, [rbp-208]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L191
.L190:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 45
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L192
    lea rax, [rip+.S81]
    push rax
    pop rdi
    call f_fail
.L192:
.L191:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 61
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L193
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 33
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L193
    xor eax, eax
    jmp .L194
.L193:
    mov eax, 1
.L194:
    test rax, rax
    jnz .L195
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 60
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L195
    xor eax, eax
    jmp .L196
.L195:
    mov eax, 1
.L196:
    test rax, rax
    jnz .L197
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L197
    xor eax, eax
    jmp .L198
.L197:
    mov eax, 1
.L198:
    test rax, rax
    jz .L199
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 61
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L199
    mov eax, 1
    jmp .L200
.L199:
    xor eax, eax
.L200:
    test rax, rax
    jz .L201
    lea rax, [rbp-208]
    mov rax, [rax]
    lea rax, [rbp-208]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L201:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 38
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L202
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 38
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L202
    mov eax, 1
    jmp .L203
.L202:
    xor eax, eax
.L203:
    test rax, rax
    jnz .L204
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 124
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L206
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 124
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L206
    mov eax, 1
    jmp .L207
.L206:
    xor eax, eax
.L207:
    test rax, rax
    jnz .L204
    xor eax, eax
    jmp .L205
.L204:
    mov eax, 1
.L205:
    test rax, rax
    jnz .L208
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L210
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L210
    mov eax, 1
    jmp .L211
.L210:
    xor eax, eax
.L211:
    test rax, rax
    jnz .L208
    xor eax, eax
    jmp .L209
.L208:
    mov eax, 1
.L209:
    test rax, rax
    jz .L212
    lea rax, [rbp-208]
    mov rax, [rax]
    lea rax, [rbp-208]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L212:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L213
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L213
    xor eax, eax
    jmp .L214
.L213:
    mov eax, 1
.L214:
    test rax, rax
    jnz .L215
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L215
    xor eax, eax
    jmp .L216
.L215:
    mov eax, 1
.L216:
    test rax, rax
    jnz .L217
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 37
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L217
    xor eax, eax
    jmp .L218
.L217:
    mov eax, 1
.L218:
    test rax, rax
    jz .L219
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 61
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L219
    mov eax, 1
    jmp .L220
.L219:
    xor eax, eax
.L220:
    test rax, rax
    jz .L221
    lea rax, [rbp-208]
    mov rax, [rax]
    lea rax, [rbp-208]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L221:
    lea rax, [rbp-208]
    mov rax, [rax]
    test rax, rax
    jz .L222
    lea rax, [rbp-200]
    mov rax, [rax]
    lea rax, [rbp-200]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    lea rax, [rbp-192]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L223
.L222:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L223:
    mov rax, 4
    push rax
    lea rax, [rbp-200]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
.L187:
.L165:
.L161:
.L120:
.L116:
.L108:
.L83:
.L72:
.L64:
.L58:
    jmp .L55
.L56:
    xor eax, eax
.Lret_lexrange:
    mov rsp, rbp
    pop rbp
    ret
f_ec:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_out]
    lea rax, [rip+g_out]
    push rax
    lea rax, [rip+g_outn]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_out]
    push rax
    lea rax, [rip+g_outn]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_outn]
    mov rax, [rax]
    lea rax, [rip+g_outn]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    xor eax, eax
.Lret_ec:
    mov rsp, rbp
    pop rbp
    ret
f_es:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L224:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L225
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_ec
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L224
.L225:
    xor eax, eax
.Lret_es:
    mov rsp, rbp
    pop rbp
    ret
f_ed:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L226
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L227
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S82]
    mov rsi, 11
    call dl_write
    mov rdi, 275
    call dl_putd
    lea rdi, [rip+.S83]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S84]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L227:
    cqo
    idiv rcx
    push rax
    pop rdi
    call f_ed
.L226:
    lea rax, [rip+g_digs]
    mov rax, [rax]
    lea rax, [rip+g_digs]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L228
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S85]
    mov rsi, 11
    call dl_write
    mov rdi, 275
    call dl_putd
    lea rdi, [rip+.S86]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S87]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L228:
    cqo
    idiv rcx
    mov rax, rdx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_ec
    xor eax, eax
.Lret_ed:
    mov rsp, rbp
    pop rbp
    ret
f_en:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L229:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L230
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rdi
    call f_ec
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L229
.L230:
    xor eax, eax
.Lret_en:
    mov rsp, rbp
    pop rbp
    ret
f_ins:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+.S88]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_es
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    xor eax, eax
.Lret_ins:
    mov rsp, rbp
    pop rbp
    ret
f_insn:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+.S89]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    xor eax, eax
.Lret_insn:
    mov rsp, rbp
    pop rbp
    ret
f_insr:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rax, [rip+.S90]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_es
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    xor eax, eax
.Lret_insr:
    mov rsp, rbp
    pop rbp
    ret
f_newlab:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+g_labn]
    mov rax, [rax]
    lea rax, [rip+g_labn]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_labn]
    mov rax, [rax]
    jmp .Lret_newlab
    xor eax, eax
.Lret_newlab:
    mov rsp, rbp
    pop rbp
    ret
f_lab:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+.S91]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    lea rax, [rip+.S92]
    push rax
    pop rdi
    call f_es
    xor eax, eax
.Lret_lab:
    mov rsp, rbp
    pop rbp
    ret
f_jmp:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+.S93]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+.S94]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    xor eax, eax
.Lret_jmp:
    mov rsp, rbp
    pop rbp
    ret
f_strlab:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    lea rax, [rip+g_nstr]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_sp]
    lea rax, [rip+g_sp]
    push rax
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_sp]
    push rax
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_sl]
    lea rax, [rip+g_sl]
    push rax
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_sl]
    push rax
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    jmp .Lret_strlab
    xor eax, eax
.Lret_strlab:
    mov rsp, rbp
    pop rbp
    ret
f_lea_str:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+.S95]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+.S96]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    lea rax, [rip+.S97]
    push rax
    pop rdi
    call f_es
    xor eax, eax
.Lret_lea_str:
    mov rsp, rbp
    pop rbp
    ret
f_textlen:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L231:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L232
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L231
.L232:
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_textlen
    xor eax, eax
.Lret_textlen:
    mov rsp, rbp
    pop rbp
    ret
f_saytext:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L233
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_strlab
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+.S98]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lea_str
    lea rax, [rip+.S99]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+.S100]
    push rax
    pop rdi
    call f_ins
.L233:
    xor eax, eax
.Lret_saytext:
    mov rsp, rbp
    pop rbp
    ret
f_sayc:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L234:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L235
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L234
.L235:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_newstr
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L236
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S101]
    mov rsi, 11
    call dl_write
    mov rdi, 296
    call dl_putd
    lea rdi, [rip+.S102]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S103]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S104]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S105]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L236:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_saytext
    xor eax, eax
.Lret_sayc:
    mov rsp, rbp
    pop rbp
    ret
f_tofd2:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+.S106]
    push rax
    pop rdi
    call f_ins
    xor eax, eax
.Lret_tofd2:
    mov rsp, rbp
    pop rbp
    ret
f_sayline:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    call f_tofd2
    lea rax, [rip+.S107]
    push rax
    pop rdi
    call f_sayc
    lea rax, [rip+.S108]
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+.S109]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S110]
    push rax
    pop rdi
    call f_sayc
    xor eax, eax
.Lret_sayline:
    mov rsp, rbp
    pop rbp
    ret
f_bang:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+.S111]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S112]
    push rax
    pop rdi
    call f_ins
    xor eax, eax
.Lret_bang:
    mov rsp, rbp
    pop rbp
    ret
f_mkty:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    lea rdi, [rbp-56]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-56]
    mov rax, [rax]
    lea rax, [rbp-56]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L237:
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L239
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L240
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L240
    mov eax, 1
    jmp .L241
.L240:
    xor eax, eax
.L241:
    test rax, rax
    jz .L242
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L242
    mov eax, 1
    jmp .L243
.L242:
    xor eax, eax
.L243:
    test rax, rax
    jz .L244
    lea rax, [rip+g_tyd1]
    lea rax, [rip+g_tyd1]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L244
    mov eax, 1
    jmp .L245
.L244:
    xor eax, eax
.L245:
    test rax, rax
    jz .L246
    lea rax, [rip+g_tyd2]
    lea rax, [rip+g_tyd2]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L246
    mov eax, 1
    jmp .L247
.L246:
    xor eax, eax
.L247:
    test rax, rax
    jz .L248
    lea rax, [rip+g_tyd3]
    lea rax, [rip+g_tyd3]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L248
    mov eax, 1
    jmp .L249
.L248:
    xor eax, eax
.L249:
    test rax, rax
    jz .L250
    lea rax, [rbp-56]
    mov rax, [rax]
    jmp .Lret_mkty
.L250:
.L238:
    lea rax, [rbp-56]
    mov rax, [rax]
    lea rax, [rbp-56]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L237
.L239:
    lea rax, [rip+g_nty]
    mov rax, [rax]
    lea rax, [rip+g_nty]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tyd1]
    lea rax, [rip+g_tyd1]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tyd1]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tyd2]
    lea rax, [rip+g_tyd2]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tyd2]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tyd3]
    lea rax, [rip+g_tyd3]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tyd3]
    push rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nty]
    mov rax, [rax]
    jmp .Lret_mkty
    xor eax, eax
.Lret_mkty:
    mov rsp, rbp
    pop rbp
    ret
f_isthing:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L251
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L251
    mov eax, 1
    jmp .L252
.L251:
    xor eax, eax
.L252:
    test rax, rax
    jz .L253
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L253
    mov eax, 1
    jmp .L254
.L253:
    xor eax, eax
.L254:
    jmp .Lret_isthing
    xor eax, eax
.Lret_isthing:
    mov rsp, rbp
    pop rbp
    ret
f_size:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L255
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tyd1]
    lea rax, [rip+g_tyd1]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L255:
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L256
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tyd2]
    lea rax, [rip+g_tyd2]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L256:
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L257
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tyd3]
    lea rax, [rip+g_tyd3]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L257:
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L258
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L258
    mov eax, 1
    jmp .L259
.L258:
    xor eax, eax
.L259:
    test rax, rax
    jz .L260
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_thsize]
    lea rax, [rip+g_thsize]
    push rax
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L261
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S113]
    mov rsi, 11
    call dl_write
    mov rdi, 315
    call dl_putd
    lea rdi, [rip+.S114]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S115]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S116]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S117]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L261:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    jmp .Lret_size
.L260:
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L262
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L262
    mov eax, 1
    jmp .L263
.L262:
    xor eax, eax
.L263:
    test rax, rax
    jz .L264
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_size
.L264:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    jmp .Lret_size
    xor eax, eax
.Lret_size:
    mov rsp, rbp
    pop rbp
    ret
f_elem:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L265
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L266
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S118]
    mov rsi, 11
    call dl_write
    mov rdi, 321
    call dl_putd
    lea rdi, [rip+.S119]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S120]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S121]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S122]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L266:
    sub rax, rcx
    push rax
    lea rax, [rip+g_tyd2]
    lea rax, [rip+g_tyd2]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tyd3]
    lea rax, [rip+g_tyd3]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    jmp .Lret_elem
.L265:
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L267
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L268
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S123]
    mov rsi, 11
    call dl_write
    mov rdi, 322
    call dl_putd
    lea rdi, [rip+.S124]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S125]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S126]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S127]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L268:
    sub rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    jmp .Lret_elem
.L267:
    lea rax, [rip+.S128]
    push rax
    pop rdi
    call f_fail
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_elem
    xor eax, eax
.Lret_elem:
    mov rsp, rbp
    pop rbp
    ret
f_ptrto:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    jmp .Lret_ptrto
    xor eax, eax
.Lret_ptrto:
    mov rsp, rbp
    pop rbp
    ret
f_scalar:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    jmp .Lret_scalar
    xor eax, eax
.Lret_scalar:
    mov rsp, rbp
    pop rbp
    ret
f_at:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L269
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L269
    mov eax, 1
    jmp .L270
.L269:
    xor eax, eax
.L270:
    jmp .Lret_at
    xor eax, eax
.Lret_at:
    mov rsp, rbp
    pop rbp
    ret
f_atk:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L271
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L271
    mov eax, 1
    jmp .L272
.L271:
    xor eax, eax
.L272:
    jmp .Lret_atk
    xor eax, eax
.Lret_atk:
    mov rsp, rbp
    pop rbp
    ret
f_atop:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L273
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L273
    mov eax, 1
    jmp .L274
.L273:
    xor eax, eax
.L274:
    jmp .Lret_atop
    xor eax, eax
.Lret_atop:
    mov rsp, rbp
    pop rbp
    ret
f_op2:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .Lret_op2
    xor eax, eax
.Lret_op2:
    mov rsp, rbp
    pop rbp
    ret
f_need:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L275
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L276
.L275:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_failat
.L276:
    xor eax, eax
.Lret_need:
    mov rsp, rbp
    pop rbp
    ret
f_isflowword:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kstore]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L277
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kconduct]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L277
    xor eax, eax
    jmp .L278
.L277:
    mov eax, 1
.L278:
    test rax, rax
    jnz .L279
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kneighbours]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L279
    xor eax, eax
    jmp .L280
.L279:
    mov eax, 1
.L280:
    test rax, rax
    jnz .L281
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kspend]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L281
    xor eax, eax
    jmp .L282
.L281:
    mov eax, 1
.L282:
    test rax, rax
    jnz .L283
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktick]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L283
    xor eax, eax
    jmp .L284
.L283:
    mov eax, 1
.L284:
    test rax, rax
    jnz .L285
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kwear]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L285
    xor eax, eax
    jmp .L286
.L285:
    mov eax, 1
.L286:
    test rax, rax
    jnz .L287
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kmix]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L287
    xor eax, eax
    jmp .L288
.L287:
    mov eax, 1
.L288:
    test rax, rax
    jnz .L289
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kshrug]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L289
    xor eax, eax
    jmp .L290
.L289:
    mov eax, 1
.L290:
    test rax, rax
    jnz .L291
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kquiet]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L291
    xor eax, eax
    jmp .L292
.L291:
    mov eax, 1
.L292:
    jmp .Lret_isflowword
    xor eax, eax
.Lret_isflowword:
    mov rsp, rbp
    pop rbp
    ret
f_iskeyword:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kint]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L293
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kchar]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L293
    xor eax, eax
    jmp .L294
.L293:
    mov eax, 1
.L294:
    test rax, rax
    jnz .L295
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_klong]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L295
    xor eax, eax
    jmp .L296
.L295:
    mov eax, 1
.L296:
    test rax, rax
    jnz .L297
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kvoid]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L297
    xor eax, eax
    jmp .L298
.L297:
    mov eax, 1
.L298:
    test rax, rax
    jnz .L299
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kunsigned]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L299
    xor eax, eax
    jmp .L300
.L299:
    mov eax, 1
.L300:
    test rax, rax
    jnz .L301
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ksigned]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L301
    xor eax, eax
    jmp .L302
.L301:
    mov eax, 1
.L302:
    test rax, rax
    jnz .L303
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kconst]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L303
    xor eax, eax
    jmp .L304
.L303:
    mov eax, 1
.L304:
    test rax, rax
    jnz .L305
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kstatic]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L305
    xor eax, eax
    jmp .L306
.L305:
    mov eax, 1
.L306:
    test rax, rax
    jnz .L307
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kif]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L307
    xor eax, eax
    jmp .L308
.L307:
    mov eax, 1
.L308:
    test rax, rax
    jnz .L309
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kelse]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L309
    xor eax, eax
    jmp .L310
.L309:
    mov eax, 1
.L310:
    test rax, rax
    jnz .L311
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kwhile]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L311
    xor eax, eax
    jmp .L312
.L311:
    mov eax, 1
.L312:
    test rax, rax
    jnz .L313
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfor]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L313
    xor eax, eax
    jmp .L314
.L313:
    mov eax, 1
.L314:
    test rax, rax
    jnz .L315
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kreturn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L315
    xor eax, eax
    jmp .L316
.L315:
    mov eax, 1
.L316:
    test rax, rax
    jnz .L317
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kbreak]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L317
    xor eax, eax
    jmp .L318
.L317:
    mov eax, 1
.L318:
    test rax, rax
    jnz .L319
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kcontinue]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L319
    xor eax, eax
    jmp .L320
.L319:
    mov eax, 1
.L320:
    test rax, rax
    jnz .L321
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kmove]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L321
    xor eax, eax
    jmp .L322
.L321:
    mov eax, 1
.L322:
    test rax, rax
    jnz .L323
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfrom]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L323
    xor eax, eax
    jmp .L324
.L323:
    mov eax, 1
.L324:
    test rax, rax
    jnz .L325
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kto]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L325
    xor eax, eax
    jmp .L326
.L325:
    mov eax, 1
.L326:
    test rax, rax
    jnz .L327
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kand]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L327
    xor eax, eax
    jmp .L328
.L327:
    mov eax, 1
.L328:
    test rax, rax
    jnz .L329
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kthing]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L329
    xor eax, eax
    jmp .L330
.L329:
    mov eax, 1
.L330:
    test rax, rax
    jnz .L331
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kvessel]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L331
    xor eax, eax
    jmp .L332
.L331:
    mov eax, 1
.L332:
    test rax, rax
    jnz .L333
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfits]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L333
    xor eax, eax
    jmp .L334
.L333:
    mov eax, 1
.L334:
    test rax, rax
    jnz .L335
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isflowword
    test rax, rax
    jnz .L335
    xor eax, eax
    jmp .L336
.L335:
    mov eax, 1
.L336:
    jmp .Lret_iskeyword
    xor eax, eax
.Lret_iskeyword:
    mov rsp, rbp
    pop rbp
    ret
f_name:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L337
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_iskeyword
    test rax, rax
    jnz .L337
    xor eax, eax
    jmp .L338
.L337:
    mov eax, 1
.L338:
    test rax, rax
    jz .L339
    lea rax, [rip+.S129]
    push rax
    pop rdi
    call f_failat
.L339:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L340
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S130]
    mov rsi, 11
    call dl_write
    mov rdi, 347
    call dl_putd
    lea rdi, [rip+.S131]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S132]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S133]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S134]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L340:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    jmp .Lret_name
    xor eax, eax
.Lret_name:
    mov rsp, rbp
    pop rbp
    ret
f_findthing:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rdi, [rbp-16]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L341:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nth]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L343
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L344
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_findthing
.L344:
.L342:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L341
.L343:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findthing
    xor eax, eax
.Lret_findthing:
    mov rsp, rbp
    pop rbp
    ret
f_istype:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L345
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kint]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L347
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kchar]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L347
    xor eax, eax
    jmp .L348
.L347:
    mov eax, 1
.L348:
    test rax, rax
    jnz .L349
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_klong]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L349
    xor eax, eax
    jmp .L350
.L349:
    mov eax, 1
.L350:
    test rax, rax
    jnz .L351
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kvoid]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L351
    xor eax, eax
    jmp .L352
.L351:
    mov eax, 1
.L352:
    test rax, rax
    jnz .L353
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kunsigned]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L353
    xor eax, eax
    jmp .L354
.L353:
    mov eax, 1
.L354:
    test rax, rax
    jnz .L355
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ksigned]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L355
    xor eax, eax
    jmp .L356
.L355:
    mov eax, 1
.L356:
    test rax, rax
    jnz .L357
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kconst]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L357
    xor eax, eax
    jmp .L358
.L357:
    mov eax, 1
.L358:
    test rax, rax
    jnz .L359
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kstatic]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L359
    xor eax, eax
    jmp .L360
.L359:
    mov eax, 1
.L360:
    test rax, rax
    jnz .L361
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kthing]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L361
    xor eax, eax
    jmp .L362
.L361:
    mov eax, 1
.L362:
    test rax, rax
    jz .L345
    mov eax, 1
    jmp .L346
.L345:
    xor eax, eax
.L346:
    jmp .Lret_istype
    xor eax, eax
.Lret_istype:
    mov rsp, rbp
    pop rbp
    ret
f_basetype:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    lea rax, [rip+g_kthing]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L363
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_name
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findthing
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L364
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L365
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S135]
    mov rsi, 11
    call dl_write
    mov rdi, 361
    call dl_putd
    lea rdi, [rip+.S136]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S137]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S138]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S139]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L365:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S140]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S141]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L364:
    mov rax, 3
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    jmp .Lret_basetype
.L363:
.L366:
    lea rax, [rip+g_kunsigned]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L368
    lea rax, [rip+g_ksigned]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L368
    xor eax, eax
    jmp .L369
.L368:
    mov eax, 1
.L369:
    test rax, rax
    jnz .L370
    lea rax, [rip+g_kconst]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L370
    xor eax, eax
    jmp .L371
.L370:
    mov eax, 1
.L371:
    test rax, rax
    jnz .L372
    lea rax, [rip+g_kstatic]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L372
    xor eax, eax
    jmp .L373
.L372:
    mov eax, 1
.L373:
    test rax, rax
    jz .L367
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L366
.L367:
    mov rax, 1
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kint]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L374
    lea rax, [rip+g_klong]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L374
    xor eax, eax
    jmp .L375
.L374:
    mov eax, 1
.L375:
    test rax, rax
    jz .L376
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L377
.L376:
    lea rax, [rip+g_kchar]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L378
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 2
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L379
.L378:
    lea rax, [rip+g_kvoid]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L380
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 3
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L381
.L380:
    lea rax, [rip+.S142]
    push rax
    pop rdi
    call f_failat
.L381:
.L379:
.L377:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    jmp .Lret_basetype
    xor eax, eax
.Lret_basetype:
    mov rsp, rbp
    pop rbp
    ret
f_findlocal:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L382:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L383
    lea rax, [rip+g_ln]
    lea rax, [rip+g_ln]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L384
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_findlocal
.L384:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L385
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S143]
    mov rsi, 11
    call dl_write
    mov rdi, 373
    call dl_putd
    lea rdi, [rip+.S144]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S145]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S146]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S147]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L385:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L382
.L383:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findlocal
    xor eax, eax
.Lret_findlocal:
    mov rsp, rbp
    pop rbp
    ret
f_findglobal:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rdi, [rbp-16]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L386:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L388
    lea rax, [rip+g_gn]
    lea rax, [rip+g_gn]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L389
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_findglobal
.L389:
.L387:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L386
.L388:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findglobal
    xor eax, eax
.Lret_findglobal:
    mov rsp, rbp
    pop rbp
    ret
f_findfn:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rdi, [rbp-24]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L390:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L392
    lea rax, [rip+g_fnm]
    lea rax, [rip+g_fnm]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L393
    lea rax, [rip+g_fown]
    lea rax, [rip+g_fown]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L393
    mov eax, 1
    jmp .L394
.L393:
    xor eax, eax
.L394:
    test rax, rax
    jz .L395
    lea rax, [rbp-24]
    mov rax, [rax]
    jmp .Lret_findfn
.L395:
.L391:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L390
.L392:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findfn
    xor eax, eax
.Lret_findfn:
    mov rsp, rbp
    pop rbp
    ret
f_findfield:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rdi, [rbp-24]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L396:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L398
    lea rax, [rip+g_fdowner]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L399
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L399
    mov eax, 1
    jmp .L400
.L399:
    xor eax, eax
.L400:
    test rax, rax
    jz .L401
    lea rax, [rbp-24]
    mov rax, [rax]
    jmp .Lret_findfield
.L401:
.L397:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L396
.L398:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findfield
    xor eax, eax
.Lret_findfield:
    mov rsp, rbp
    pop rbp
    ret
f_load:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L402
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jnz .L402
    xor eax, eax
    jmp .L403
.L402:
    mov eax, 1
.L403:
    test rax, rax
    jz .L404
    jmp .Lret_load
.L404:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L405
    lea rax, [rip+.S148]
    push rax
    pop rdi
    call f_ins
    jmp .L406
.L405:
    lea rax, [rip+.S149]
    push rax
    pop rdi
    call f_ins
.L406:
    xor eax, eax
.Lret_load:
    mov rsp, rbp
    pop rbp
    ret
f_loadrcx:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L407
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jnz .L407
    xor eax, eax
    jmp .L408
.L407:
    mov eax, 1
.L408:
    test rax, rax
    jz .L409
    lea rax, [rip+.S150]
    push rax
    pop rdi
    call f_ins
    jmp .Lret_loadrcx
.L409:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L410
    lea rax, [rip+.S151]
    push rax
    pop rdi
    call f_ins
    jmp .L411
.L410:
    lea rax, [rip+.S152]
    push rax
    pop rdi
    call f_ins
.L411:
    xor eax, eax
.Lret_loadrcx:
    mov rsp, rbp
    pop rbp
    ret
f_storercx:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L412
    lea rax, [rip+.S153]
    push rax
    pop rdi
    call f_fail
.L412:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L413
    lea rax, [rip+.S154]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S155]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S156]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+.S157]
    push rax
    pop rdi
    call f_ins
    jmp .Lret_storercx
.L413:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L414
    lea rax, [rip+.S158]
    push rax
    pop rdi
    call f_ins
    jmp .L415
.L414:
    lea rax, [rip+.S159]
    push rax
    pop rdi
    call f_ins
.L415:
    xor eax, eax
.Lret_storercx:
    mov rsp, rbp
    pop rbp
    ret
f_local:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rdi, [rbp-24]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rip+g_sc]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L416:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L418
    lea rax, [rip+g_ln]
    lea rax, [rip+g_ln]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L419
    lea rax, [rip+.S160]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S161]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L419:
.L417:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L416
.L418:
    lea rax, [rip+g_frame]
    mov rax, [rax]
    lea rax, [rip+g_frame]
    push rax
    lea rax, [rip+g_frame]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L420
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S162]
    mov rsi, 11
    call dl_write
    mov rdi, 391
    call dl_putd
    lea rdi, [rip+.S163]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S164]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L420:
    cqo
    idiv rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    lea rax, [rip+g_nloc]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_ln]
    lea rax, [rip+g_ln]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_ln]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_lt]
    lea rax, [rip+g_lt]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_lt]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_lo]
    lea rax, [rip+g_lo]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_lo]
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_frame]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_frame]
    mov rax, [rax]
    jmp .Lret_local
    xor eax, eax
.Lret_local:
    mov rsp, rbp
    pop rbp
    ret
f_hidden:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+g_frame]
    mov rax, [rax]
    lea rax, [rip+g_frame]
    push rax
    lea rax, [rip+g_frame]
    mov rax, [rax]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_frame]
    mov rax, [rax]
    jmp .Lret_hidden
    xor eax, eax
.Lret_hidden:
    mov rsp, rbp
    pop rbp
    ret
f_part:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfield
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L421
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S165]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S166]
    mov rsi, 2
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S167]
    mov rsi, 14
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S168]
    mov rsi, 2
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L421:
    lea rax, [rip+g_fdoff]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L422
    lea rax, [rip+.S169]
    push rax
    lea rax, [rip+g_fdoff]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
.L422:
    lea rax, [rip+g_haslast]
    mov rax, [rax]
    lea rax, [rip+g_haslast]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_lastfoff]
    mov rax, [rax]
    lea rax, [rip+g_lastfoff]
    push rax
    lea rax, [rip+g_fdoff]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_lasttoff]
    mov rax, [rax]
    lea rax, [rip+g_lasttoff]
    push rax
    lea rax, [rip+g_thtilde]
    lea rax, [rip+g_thtilde]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    jmp .Lret_part
    xor eax, eax
.Lret_part:
    mov rsp, rbp
    pop rbp
    ret
f_place:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    lea rax, [rip+g_haslast]
    mov rax, [rax]
    lea rax, [rip+g_haslast]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findlocal
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L423
    lea rax, [rip+.S170]
    push rax
    lea rax, [rip+g_lo]
    lea rax, [rip+g_lo]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S171]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+g_lt]
    lea rax, [rip+g_lt]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    jmp .Lret_place
.L423:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L424
    lea rax, [rip+.S172]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    lea rax, [rip+.S173]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_gt]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    jmp .Lret_place
.L424:
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L425
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfield
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L425
    mov eax, 1
    jmp .L426
.L425:
    xor eax, eax
.L426:
    test rax, rax
    jz .L427
    lea rax, [rip+g_kself]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findlocal
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+.S174]
    push rax
    lea rax, [rip+g_lo]
    lea rax, [rip+g_lo]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S175]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_part
    jmp .Lret_place
.L427:
    lea rax, [rip+.S176]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S177]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_place
    xor eax, eax
.Lret_place:
    mov rsp, rbp
    pop rbp
    ret
f_joinstr:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    mov [rbp-8], rdi
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L428:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L429
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rdi, [rbp-48]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L430:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L432
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L433
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S178]
    mov rsi, 11
    call dl_write
    mov rdi, 430
    call dl_putd
    lea rdi, [rip+.S179]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S180]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S181]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S182]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L433:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L431:
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L430
.L432:
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L434:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L436
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L437
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S183]
    mov rsi, 11
    call dl_write
    mov rdi, 431
    call dl_putd
    lea rdi, [rip+.S184]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S185]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S186]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S187]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L437:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L435:
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L434
.L436:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L428
.L429:
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_joinstr
    xor eax, eax
.Lret_joinstr:
    mov rsp, rbp
    pop rbp
    ret
f_sayit:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L438
    lea rax, [rip+.S188]
    push rax
    pop rdi
    call f_failat
.L438:
    lea rdi, [rbp-8]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-8]
    push rax
    pop rdi
    call f_joinstr
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_curdl]
    mov rax, [rax]
    test rax, rax
    jz .L439
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_curfn]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S189]
    push rax
    pop rsi
    pop rdi
    call f_same
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L439
    mov eax, 1
    jmp .L440
.L439:
    xor eax, eax
.L440:
    test rax, rax
    jz .L441
    lea rax, [rip+.S190]
    push rax
    pop rdi
    call f_word
    push rax
    pop rdi
    call f_findglobal
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L441
    mov eax, 1
    jmp .L442
.L441:
    xor eax, eax
.L442:
    test rax, rax
    jz .L443
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    call f_newlab
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S191]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S192]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
.L443:
    lea rax, [rip+.S193]
    push rax
    pop rdi
    call f_ins
    mov rax, 1
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
.L444:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L445
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L446
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S194]
    mov rsi, 11
    call dl_write
    mov rdi, 451
    call dl_putd
    lea rdi, [rip+.S195]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S196]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S197]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S198]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L446:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 37
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L447
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L447
    mov eax, 1
    jmp .L448
.L447:
    xor eax, eax
.L448:
    test rax, rax
    jz .L449
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 108
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L450
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L450
    mov eax, 1
    jmp .L451
.L450:
    xor eax, eax
.L451:
    test rax, rax
    jz .L452
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L452
    mov eax, 1
    jmp .L453
.L452:
    xor eax, eax
.L453:
    test rax, rax
    jz .L454
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 100
    pop rcx
    mov qword ptr [rcx], rax
.L454:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 37
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L455
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    mov rax, 37
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L456
.L455:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L457
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 115
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L457
    mov eax, 1
    jmp .L458
.L457:
    xor eax, eax
.L458:
    test rax, rax
    jz .L459
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 99
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L459
    mov eax, 1
    jmp .L460
.L459:
    xor eax, eax
.L460:
    test rax, rax
    jz .L461
    lea rax, [rip+.S199]
    push rax
    pop rdi
    call f_failat
.L461:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_saytext
    mov rax, 44
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L462
    lea rax, [rip+.S200]
    push rax
    pop rdi
    call f_failat
.L462:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_assign
    lea rax, [rip+.S201]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L463
    lea rax, [rip+.S202]
    push rax
    pop rdi
    call f_ins
    jmp .L464
.L463:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    mov rax, 115
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L465
    lea rax, [rip+.S203]
    push rax
    pop rdi
    call f_ins
    jmp .L466
.L465:
    lea rax, [rip+.S204]
    push rax
    pop rdi
    call f_ins
.L466:
.L464:
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L456:
    jmp .L467
.L449:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L467:
    jmp .L444
.L445:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_saytext
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L468
    lea rax, [rip+.S205]
    push rax
    pop rdi
    call f_failat
.L468:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L469
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
.L469:
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_sayit
    xor eax, eax
.Lret_sayit:
    mov rsp, rbp
    pop rbp
    ret
f_inline:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L470:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L471
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L472
    mov rax, 44
    push rax
    lea rax, [rip+.S206]
    push rax
    pop rsi
    pop rdi
    call f_need
.L472:
    call f_assign
    lea rax, [rip+.S207]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L470
.L471:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 2
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kcopy]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L473
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 3
    pop rcx
    mov qword ptr [rcx], rax
.L473:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktowards]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L474
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 4
    pop rcx
    mov qword ptr [rcx], rax
.L474:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L475
    lea rax, [rip+.S208]
    push rax
    pop rdi
    call f_failat
.L475:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kcopy]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L476
    lea rax, [rip+.S209]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S210]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S211]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S212]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S213]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_inline
.L476:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktowards]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L477
    call f_newlab
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+.S214]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S215]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S216]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S217]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S218]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S219]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    call f_sayline
    lea rax, [rip+.S220]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S221]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S222]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S223]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S224]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S225]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S226]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S227]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_inline
.L477:
    lea rax, [rip+.S228]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S229]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kless]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L478
    call f_newlab
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+.S230]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S231]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S232]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S233]
    push rax
    pop rdi
    call f_ins
    call f_sayline
    lea rax, [rip+.S234]
    push rax
    pop rdi
    call f_sayc
    lea rax, [rip+.S235]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S236]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S237]
    push rax
    pop rdi
    call f_sayc
    lea rax, [rip+.S238]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S239]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S240]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S241]
    push rax
    pop rdi
    call f_ins
    jmp .L479
.L478:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kapart]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L480
    call f_newlab
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    lea rax, [rip+.S242]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S243]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S244]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    jmp .L481
.L480:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_klower]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L482
    lea rax, [rip+.S245]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S246]
    push rax
    pop rdi
    call f_ins
    jmp .L483
.L482:
    lea rax, [rip+.S247]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S248]
    push rax
    pop rdi
    call f_ins
.L483:
.L481:
.L479:
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_inline
    xor eax, eax
.Lret_inline:
    mov rsp, rbp
    pop rbp
    ret
f_label:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L484
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    lea rax, [rip+.S249]
    push rax
    pop rdi
    call f_es
.L484:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    xor eax, eax
.Lret_label:
    mov rsp, rbp
    pop rbp
    ret
f_methodcall:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L485
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S250]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S251]
    mov rsi, 2
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S252]
    mov rsi, 18
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S253]
    mov rsi, 2
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L485:
    lea rax, [rip+.S254]
    push rax
    pop rdi
    call f_ins
    mov rax, 1
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
.L486:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L487
    call f_assign
    lea rax, [rip+.S255]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L488
    mov rax, 44
    push rax
    lea rax, [rip+.S256]
    push rax
    pop rsi
    pop rdi
    call f_need
.L488:
    jmp .L486
.L487:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L489
    lea rax, [rip+.S257]
    push rax
    pop rdi
    call f_failat
.L489:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L490
    lea rax, [rip+.S258]
    push rax
    pop rdi
    call f_ins
.L490:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L491
    lea rax, [rip+.S259]
    push rax
    pop rdi
    call f_ins
.L491:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L492
    lea rax, [rip+.S260]
    push rax
    pop rdi
    call f_ins
.L492:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L493
    lea rax, [rip+.S261]
    push rax
    pop rdi
    call f_ins
.L493:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L494
    lea rax, [rip+.S262]
    push rax
    pop rdi
    call f_ins
.L494:
    lea rax, [rip+.S263]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S264]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_label
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    lea rax, [rip+g_frt]
    lea rax, [rip+g_frt]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    jmp .Lret_methodcall
    xor eax, eax
.Lret_methodcall:
    mov rsp, rbp
    pop rbp
    ret
f_call:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kshrug]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L495
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rip+.S265]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
.L495:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ksay]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L496
    call f_sayit
    jmp .Lret_call
.L496:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kless]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L497
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kapart]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L497
    xor eax, eax
    jmp .L498
.L497:
    mov eax, 1
.L498:
    test rax, rax
    jnz .L499
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_klower]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L499
    xor eax, eax
    jmp .L500
.L499:
    mov eax, 1
.L500:
    test rax, rax
    jnz .L501
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_khigher]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L501
    xor eax, eax
    jmp .L502
.L501:
    mov eax, 1
.L502:
    test rax, rax
    jnz .L503
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktowards]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L503
    xor eax, eax
    jmp .L504
.L503:
    mov eax, 1
.L504:
    test rax, rax
    jnz .L505
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kcopy]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L505
    xor eax, eax
    jmp .L506
.L505:
    mov eax, 1
.L506:
    test rax, rax
    jz .L507
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L507
    mov eax, 1
    jmp .L508
.L507:
    xor eax, eax
.L508:
    test rax, rax
    jz .L509
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_inline
    jmp .Lret_call
.L509:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L510
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L510
    mov eax, 1
    jmp .L511
.L510:
    xor eax, eax
.L511:
    test rax, rax
    jz .L512
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L512
    mov eax, 1
    jmp .L513
.L512:
    xor eax, eax
.L513:
    test rax, rax
    jz .L514
    lea rax, [rip+g_kself]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findlocal
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+.S266]
    push rax
    lea rax, [rip+g_lo]
    lea rax, [rip+g_lo]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S267]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_methodcall
    jmp .Lret_call
.L514:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L515:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L516
    call f_assign
    lea rax, [rip+.S268]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L517
    mov rax, 44
    push rax
    lea rax, [rip+.S269]
    push rax
    pop rsi
    pop rdi
    call f_need
.L517:
    jmp .L515
.L516:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L518
    lea rax, [rip+.S270]
    push rax
    pop rdi
    call f_failat
.L518:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L519
    lea rax, [rip+.S271]
    push rax
    pop rdi
    call f_ins
.L519:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L520
    lea rax, [rip+.S272]
    push rax
    pop rdi
    call f_ins
.L520:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L521
    lea rax, [rip+.S273]
    push rax
    pop rdi
    call f_ins
.L521:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L522
    lea rax, [rip+.S274]
    push rax
    pop rdi
    call f_ins
.L522:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L523
    lea rax, [rip+.S275]
    push rax
    pop rdi
    call f_ins
.L523:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L524
    lea rax, [rip+.S276]
    push rax
    pop rdi
    call f_ins
.L524:
    lea rax, [rip+.S277]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    lea rax, [rip+g_ncall]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_cnm]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cline]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L525
    lea rax, [rip+g_frt]
    lea rax, [rip+g_frt]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    jmp .Lret_call
.L525:
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_call
    xor eax, eax
.Lret_call:
    mov rsp, rbp
    pop rbp
    ret
f_primary:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L526
    lea rax, [rip+.S278]
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_primary
.L526:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L527
    lea rdi, [rbp-8]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-8]
    push rax
    pop rdi
    call f_joinstr
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_strlab
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+.S279]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lea_str
    lea rax, [rip+g_CHARP]
    mov rax, [rax]
    jmp .Lret_primary
.L527:
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L528
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_expr
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    mov rax, 41
    push rax
    lea rax, [rip+.S280]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rbp-32]
    mov rax, [rax]
    jmp .Lret_primary
.L528:
    mov rax, 126
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L529
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+.S281]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_primary
.L529:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L530
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 40
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L530
    mov eax, 1
    jmp .L531
.L530:
    xor eax, eax
.L531:
    test rax, rax
    jz .L532
    call f_call
    jmp .Lret_primary
.L532:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L533
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rdi
    call f_place
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rdi
    call f_load
    lea rax, [rbp-48]
    mov rax, [rax]
    jmp .Lret_primary
.L533:
    lea rax, [rip+.S282]
    push rax
    pop rdi
    call f_failat
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_primary
    xor eax, eax
.Lret_primary:
    mov rsp, rbp
    pop rbp
    ret
f_lvalue:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rdi, [rbp-8]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L534
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    call f_lvalue
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 41
    push rax
    lea rax, [rip+.S283]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .L535
.L534:
    mov rax, 126
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L536
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+.S284]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L537
.L536:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L538
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    call f_unary
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L539
.L538:
    call f_name
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_place
    pop rcx
    mov qword ptr [rcx], rax
.L539:
.L537:
.L535:
.L540:
    mov rax, 91
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L542
    mov rax, 46
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L542
    xor eax, eax
    jmp .L543
.L542:
    mov eax, 1
.L543:
    test rax, rax
    jnz .L544
    mov rax, 45
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L544
    xor eax, eax
    jmp .L545
.L544:
    mov eax, 1
.L545:
    test rax, rax
    jz .L541
    mov rax, 46
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L546
    mov rax, 45
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L546
    xor eax, eax
    jmp .L547
.L546:
    mov eax, 1
.L547:
    test rax, rax
    jz .L548
    mov rax, 45
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    test rax, rax
    jz .L549
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    pop rcx
    mov qword ptr [rcx], rax
.L549:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L550
    lea rax, [rip+.S285]
    push rax
    pop rdi
    call f_fail
.L550:
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L551
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S286]
    mov rsi, 11
    call dl_write
    mov rdi, 595
    call dl_putd
    lea rdi, [rip+.S287]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S288]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S289]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S290]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L551:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L552
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L552
    mov eax, 1
    jmp .L553
.L552:
    xor eax, eax
.L553:
    test rax, rax
    jz .L554
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 40
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L554
    mov eax, 1
    jmp .L555
.L554:
    xor eax, eax
.L555:
    test rax, rax
    jz .L556
    lea rax, [rbp-8]
    mov rax, [rax]
    jmp .Lret_lvalue
.L556:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    test rax, rax
    jz .L557
    lea rax, [rip+.S291]
    push rax
    pop rdi
    call f_ins
.L557:
    lea rdi, [rbp-48]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    mov rax, 126
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L558
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    lea rax, [rip+g_ktilde]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L559
.L558:
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    call f_name
    pop rcx
    mov qword ptr [rcx], rax
.L559:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_part
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L540
.L548:
    lea rax, [rip+g_haslast]
    mov rax, [rax]
    lea rax, [rip+g_haslast]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L560
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L561
    lea rax, [rip+.S292]
    push rax
    pop rdi
    call f_ins
    jmp .L562
.L561:
    lea rax, [rip+.S293]
    push rax
    pop rdi
    call f_fail
.L562:
.L560:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rip+.S294]
    push rax
    pop rdi
    call f_ins
    call f_expr
    mov rax, 93
    push rax
    lea rax, [rip+.S295]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+.S296]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L563
    lea rax, [rip+.S297]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    pop rsi
    pop rdi
    call f_insn
.L563:
    lea rax, [rip+.S298]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S299]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L540
.L541:
    lea rax, [rbp-8]
    mov rax, [rax]
    jmp .Lret_lvalue
    xor eax, eax
.Lret_lvalue:
    mov rsp, rbp
    pop rbp
    ret
f_postfix:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    call f_primary
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 91
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L564
    mov rax, 43
    push rax
    mov rax, 43
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L564
    mov eax, 1
    jmp .L565
.L564:
    xor eax, eax
.L565:
    test rax, rax
    jz .L566
    mov rax, 46
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L566
    mov eax, 1
    jmp .L567
.L566:
    xor eax, eax
.L567:
    test rax, rax
    jz .L568
    mov rax, 45
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L568
    mov eax, 1
    jmp .L569
.L568:
    xor eax, eax
.L569:
    test rax, rax
    jz .L570
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_postfix
.L570:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    call f_lvalue
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 46
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L571
    mov rax, 45
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L571
    xor eax, eax
    jmp .L572
.L571:
    mov eax, 1
.L572:
    test rax, rax
    jz .L573
    mov rax, 45
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    test rax, rax
    jz .L574
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S300]
    push rax
    pop rdi
    call f_ins
.L574:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L575
    lea rax, [rip+.S301]
    push rax
    pop rdi
    call f_fail
.L575:
    call f_name
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    mov rax, 40
    push rax
    lea rax, [rip+.S302]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L576
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S303]
    mov rsi, 11
    call dl_write
    mov rdi, 632
    call dl_putd
    lea rdi, [rip+.S304]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S305]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S306]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S307]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L576:
    sub rax, rcx
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_methodcall
    jmp .Lret_postfix
.L573:
    mov rax, 43
    push rax
    mov rax, 43
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L577
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+.S308]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_loadrcx
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L578
    lea rax, [rip+.S309]
    push rax
    pop rdi
    call f_ins
    jmp .L579
.L578:
    lea rax, [rip+.S310]
    push rax
    pop rdi
    call f_ins
.L579:
    jmp .L580
.L577:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_load
.L580:
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_postfix
    xor eax, eax
.Lret_postfix:
    mov rsp, rbp
    pop rbp
    ret
f_lvalueunary:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L581
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_unary
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    jmp .Lret_lvalueunary
.L581:
    call f_lvalue
    jmp .Lret_lvalueunary
    xor eax, eax
.Lret_lvalueunary:
    mov rsp, rbp
    pop rbp
    ret
f_unary:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 33
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L582
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_unary
    lea rax, [rip+.S311]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S312]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S313]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_unary
.L582:
    mov rax, 43
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L583
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_unary
    jmp .Lret_unary
.L583:
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L584
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L584
    mov eax, 1
    jmp .L585
.L584:
    xor eax, eax
.L585:
    test rax, rax
    jz .L586
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kint]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L588
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kchar]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L588
    xor eax, eax
    jmp .L589
.L588:
    mov eax, 1
.L589:
    test rax, rax
    jnz .L590
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_klong]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L590
    xor eax, eax
    jmp .L591
.L590:
    mov eax, 1
.L591:
    test rax, rax
    jnz .L592
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kvoid]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L592
    xor eax, eax
    jmp .L593
.L592:
    mov eax, 1
.L593:
    test rax, rax
    jz .L586
    mov eax, 1
    jmp .L587
.L586:
    xor eax, eax
.L587:
    test rax, rax
    jz .L594
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_basetype
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L595:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L596
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L595
.L596:
    mov rax, 41
    push rax
    lea rax, [rip+.S314]
    push rax
    pop rsi
    pop rdi
    call f_need
    call f_unary
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L597
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L597
    mov eax, 1
    jmp .L598
.L597:
    xor eax, eax
.L598:
    test rax, rax
    jz .L599
    lea rax, [rip+.S315]
    push rax
    pop rdi
    call f_ins
.L599:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_scalar
    jmp .Lret_unary
.L594:
    mov rax, 38
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L600
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_lvalueunary
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ptrto
    jmp .Lret_unary
.L600:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L601
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_unary
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rdi
    call f_load
    lea rax, [rbp-40]
    mov rax, [rax]
    jmp .Lret_unary
.L601:
    mov rax, 43
    push rax
    mov rax, 43
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L602
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_lvalueunary
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L603
    lea rax, [rip+.S316]
    push rax
    pop rdi
    call f_ins
    jmp .L604
.L603:
    lea rax, [rip+.S317]
    push rax
    pop rdi
    call f_ins
.L604:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rdi
    call f_load
    lea rax, [rbp-48]
    mov rax, [rax]
    jmp .Lret_unary
.L602:
    call f_postfix
    jmp .Lret_unary
    xor eax, eax
.Lret_unary:
    mov rsp, rbp
    pop rbp
    ret
f_divide:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    call f_newlab
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+.S318]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S319]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    call f_sayline
    lea rax, [rip+.S320]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S321]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S322]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-8]
    mov rax, [rax]
    test rax, rax
    jz .L605
    lea rax, [rip+.S323]
    push rax
    pop rdi
    call f_ins
.L605:
    xor eax, eax
.Lret_divide:
    mov rsp, rbp
    pop rbp
    ret
f_binop:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L606
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L607
    lea rax, [rip+.S324]
    push rax
    pop rdi
    call f_ins
    jmp .L608
.L607:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 37
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    push rax
    pop rdi
    call f_divide
.L608:
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_binop
.L606:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L609
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L610
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L610
    xor eax, eax
    jmp .L611
.L610:
    mov eax, 1
.L611:
    test rax, rax
    jz .L612
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_elem
    push rax
    pop rdi
    call f_size
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L613
    lea rax, [rip+.S325]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
.L613:
    lea rax, [rip+.S326]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L614
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    jmp .Lret_binop
.L614:
    lea rax, [rbp-24]
    mov rax, [rax]
    jmp .Lret_binop
.L612:
    lea rax, [rip+.S327]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_binop
.L609:
    lea rax, [rip+.S328]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 60
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L615
    lea rax, [rip+.S329]
    push rax
    pop rdi
    call f_ins
    jmp .L616
.L615:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L617
    lea rax, [rip+.S330]
    push rax
    pop rdi
    call f_ins
    jmp .L618
.L617:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 60
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L619
    lea rax, [rip+.S331]
    push rax
    pop rdi
    call f_ins
    jmp .L620
.L619:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 62
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L621
    lea rax, [rip+.S332]
    push rax
    pop rdi
    call f_ins
    jmp .L622
.L621:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 61
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L623
    lea rax, [rip+.S333]
    push rax
    pop rdi
    call f_ins
    jmp .L624
.L623:
    lea rax, [rip+.S334]
    push rax
    pop rdi
    call f_ins
.L624:
.L622:
.L620:
.L618:
.L616:
    lea rax, [rip+.S335]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_INT]
    mov rax, [rax]
    jmp .Lret_binop
    xor eax, eax
.Lret_binop:
    mov rsp, rbp
    pop rbp
    ret
f_level:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    lea rdi, [rbp-16]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L625
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    call f_unary
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L626
.L625:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L627
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S336]
    mov rsi, 11
    call dl_write
    mov rdi, 707
    call dl_putd
    lea rdi, [rip+.S337]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S338]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S339]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S340]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L627:
    sub rax, rcx
    push rax
    pop rdi
    call f_level
    pop rcx
    mov qword ptr [rcx], rax
.L626:
.L628:
    mov rax, 1
    test rax, rax
    jz .L629
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L630
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L631
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 42
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L633
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L633
    xor eax, eax
    jmp .L634
.L633:
    mov eax, 1
.L634:
    test rax, rax
    jnz .L635
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 37
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L635
    xor eax, eax
    jmp .L636
.L635:
    mov eax, 1
.L636:
    test rax, rax
    jz .L631
    mov eax, 1
    jmp .L632
.L631:
    xor eax, eax
.L632:
    test rax, rax
    jz .L637
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L637:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L638
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 43
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L638
    mov eax, 1
    jmp .L639
.L638:
    xor eax, eax
.L639:
    test rax, rax
    jz .L640
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L640:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L641
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 60
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L643
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 62
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L643
    xor eax, eax
    jmp .L644
.L643:
    mov eax, 1
.L644:
    test rax, rax
    jnz .L645
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 60
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L645
    xor eax, eax
    jmp .L646
.L645:
    mov eax, 1
.L646:
    test rax, rax
    jnz .L647
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 62
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L647
    xor eax, eax
    jmp .L648
.L647:
    mov eax, 1
.L648:
    test rax, rax
    jz .L641
    mov eax, 1
    jmp .L642
.L641:
    xor eax, eax
.L642:
    test rax, rax
    jz .L649
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L649:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L650
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 61
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L652
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 33
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L652
    xor eax, eax
    jmp .L653
.L652:
    mov eax, 1
.L653:
    test rax, rax
    jz .L650
    mov eax, 1
    jmp .L651
.L650:
    xor eax, eax
.L651:
    test rax, rax
    jz .L654
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L654:
.L630:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L655
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_level
.L655:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+.S341]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L656
    call f_unary
    jmp .L657
.L656:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L658
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S342]
    mov rsi, 11
    call dl_write
    mov rdi, 720
    call dl_putd
    lea rdi, [rip+.S343]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S344]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S345]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S346]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L658:
    sub rax, rcx
    push rax
    pop rdi
    call f_level
.L657:
    lea rax, [rip+.S347]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S348]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_binop
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L628
.L629:
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_level
    xor eax, eax
.Lret_level:
    mov rsp, rbp
    pop rbp
    ret
f_land:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov rax, 4
    push rax
    pop rdi
    call f_level
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
.L659:
    mov rax, 38
    push rax
    mov rax, 38
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L660
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_newlab
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+.S349]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S350]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    mov rax, 4
    push rax
    pop rdi
    call f_level
    lea rax, [rip+.S351]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S352]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S353]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S354]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S355]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L659
.L660:
    lea rax, [rbp-8]
    mov rax, [rax]
    jmp .Lret_land
    xor eax, eax
.Lret_land:
    mov rsp, rbp
    pop rbp
    ret
f_lor:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    call f_land
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
.L661:
    mov rax, 124
    push rax
    mov rax, 124
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L662
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_newlab
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+.S356]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S357]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    call f_land
    lea rax, [rip+.S358]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S359]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S360]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S361]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S362]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L661
.L662:
    lea rax, [rbp-8]
    mov rax, [rax]
    jmp .Lret_lor
    xor eax, eax
.Lret_lor:
    mov rsp, rbp
    pop rbp
    ret
f_assign:
    push rbp
    mov rbp, rsp
    sub rsp, 80          
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    call f_lor
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    mov rax, 63
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L663
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_newlab
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+.S363]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S364]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    call f_assign
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    mov rax, 58
    push rax
    lea rax, [rip+.S365]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+.S366]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    call f_assign
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rbp-40]
    mov rax, [rax]
    jmp .Lret_assign
.L663:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L664
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 61
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L665
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 43
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L665
    xor eax, eax
    jmp .L666
.L665:
    mov eax, 1
.L666:
    test rax, rax
    jnz .L667
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 42
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L667
    xor eax, eax
    jmp .L668
.L667:
    mov eax, 1
.L668:
    test rax, rax
    jnz .L669
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 47
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L669
    xor eax, eax
    jmp .L670
.L669:
    mov eax, 1
.L670:
    test rax, rax
    jnz .L671
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 37
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L671
    xor eax, eax
    jmp .L672
.L671:
    mov eax, 1
.L672:
    test rax, rax
    jz .L673
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L673:
.L664:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L674
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_assign
.L674:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    call f_lvalue
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S367]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_assign
    lea rax, [rip+.S368]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 61
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L675
    lea rax, [rip+.S369]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_loadrcx
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 43
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L676
    lea rax, [rip+.S370]
    push rax
    pop rdi
    call f_ins
    jmp .L677
.L676:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 42
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L678
    lea rax, [rip+.S371]
    push rax
    pop rdi
    call f_ins
    jmp .L679
.L678:
    lea rax, [rip+.S372]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S373]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 37
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    push rax
    pop rdi
    call f_divide
    lea rax, [rip+.S374]
    push rax
    pop rdi
    call f_ins
.L679:
.L677:
.L675:
    mov rax, 1
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L680
    lea rax, [rip+g_flowname]
    lea rax, [rip+g_flowname]
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L680
    mov eax, 1
    jmp .L681
.L680:
    xor eax, eax
.L681:
    test rax, rax
    jz .L682
    lea rax, [rbp-72]
    mov rax, [rax]
    lea rax, [rbp-72]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L682:
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    test rax, rax
    jz .L683
    lea rax, [rbp-72]
    mov rax, [rax]
    test rax, rax
    jz .L683
    mov eax, 1
    jmp .L684
.L683:
    xor eax, eax
.L684:
    test rax, rax
    jz .L685
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L685
    mov eax, 1
    jmp .L686
.L685:
    xor eax, eax
.L686:
    test rax, rax
    jz .L687
    lea rax, [rip+g_curdl]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L687
    mov eax, 1
    jmp .L688
.L687:
    xor eax, eax
.L688:
    test rax, rax
    jz .L689
    lea rax, [rip+.S375]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S376]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S377]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S378]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S379]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S380]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S381]
    push rax
    pop rdi
    call f_ins
.L689:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_storercx
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_assign
    xor eax, eax
.Lret_assign:
    mov rsp, rbp
    pop rbp
    ret
f_expr:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    call f_assign
    jmp .Lret_expr
    xor eax, eax
.Lret_expr:
    mov rsp, rbp
    pop rbp
    ret
f_vcheck:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+g_usesvessel]
    mov rax, [rax]
    test rax, rax
    jz .L690
    lea rax, [rip+g_curdl]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L690
    mov eax, 1
    jmp .L691
.L690:
    xor eax, eax
.L691:
    test rax, rax
    jz .L692
    lea rax, [rip+.S382]
    push rax
    pop rdi
    call f_ins
.L692:
    xor eax, eax
.Lret_vcheck:
    mov rsp, rbp
    pop rbp
    ret
f_toktext:
    push rbp
    mov rbp, rsp
    sub rsp, 1072        
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rdi, [rbp-32]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L693:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L695
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L696
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
.L697:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L698
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L697
.L698:
    jmp .L699
.L696:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L700
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    lea rdi, [rbp-1056]
    mov rcx, 1008
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 1064
    mov qword ptr [rcx], rax
.L701:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L702
    lea rax, [rbp-1064]
    mov rax, [rax]
    lea rax, [rbp-1064]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-1056]
    lea rax, [rbp-1056]
    push rax
    lea rax, [rbp-1064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-1056]
    push rax
    lea rax, [rbp-1064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L703
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S383]
    mov rsi, 11
    call dl_write
    mov rdi, 810
    call dl_putd
    lea rdi, [rip+.S384]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S385]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L703:
    cqo
    idiv rcx
    mov rax, rdx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 10
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L704
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S386]
    mov rsi, 11
    call dl_write
    mov rdi, 810
    call dl_putd
    lea rdi, [rip+.S387]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S388]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L704:
    cqo
    idiv rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L701
.L702:
.L705:
    lea rax, [rbp-1064]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L706
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_digs]
    mov rax, [rax]
    lea rax, [rip+g_digs]
    mov rax, [rax]
    push rax
    lea rax, [rbp-1056]
    lea rax, [rbp-1056]
    push rax
    lea rax, [rbp-1064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-1064]
    mov rax, [rax]
    lea rax, [rbp-1064]
    push rax
    lea rax, [rbp-1064]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L707
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S389]
    mov rsi, 11
    call dl_write
    mov rdi, 811
    call dl_putd
    lea rdi, [rip+.S390]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S391]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S392]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S393]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L707:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L705
.L706:
    jmp .L708
.L700:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L709
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 1072
    mov qword ptr [rcx], rax
    lea rax, [rbp-1072]
    mov rax, [rax]
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L710
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-1072]
    mov rax, [rax]
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L711
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S394]
    mov rsi, 11
    call dl_write
    mov rdi, 815
    call dl_putd
    lea rdi, [rip+.S395]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S396]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L711:
    cqo
    idiv rcx
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-1072]
    mov rax, [rax]
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L712
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S397]
    mov rsi, 11
    call dl_write
    mov rdi, 815
    call dl_putd
    lea rdi, [rip+.S398]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S399]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L712:
    cqo
    idiv rcx
    mov rax, rdx
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L713
.L710:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-1072]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L713:
.L709:
.L708:
.L699:
.L694:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L693
.L695:
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_pooln]
    mov rax, [rax]
    lea rax, [rip+g_pooln]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    jmp .Lret_toktext
    xor eax, eax
.Lret_toktext:
    mov rsp, rbp
    pop rbp
    ret
f_moveone:
    push rbp
    mov rbp, rsp
    sub rsp, 112         
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    call f_expr
    lea rax, [rip+.S400]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_kfrom]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L714
    lea rax, [rip+.S401]
    push rax
    pop rdi
    call f_failat
.L714:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    call f_lvalue
    lea rax, [rip+.S402]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_toktext
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kto]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L715
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L716
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S403]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S404]
    mov rsi, 2
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S405]
    mov rsi, 51
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S406]
    mov rsi, 8
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L716:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_strlab
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+.S407]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S408]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S409]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lea_str
    lea rax, [rip+.S410]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    lea rax, [rip+g_ncall]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_cnm]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S411]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cline]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .Lret_moveone
.L715:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    call f_lvalue
    lea rax, [rip+.S412]
    push rax
    pop rdi
    call f_ins
    call f_newlab
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 80
    mov qword ptr [rcx], rax
    lea rax, [rip+.S413]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S414]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S415]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S416]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S417]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S418]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S419]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    mov rax, 1
    mov rcx, rbp
    sub rcx, 88
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    test rax, rax
    jz .L717
    lea rax, [rip+g_flowname]
    lea rax, [rip+g_flowname]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L717
    mov eax, 1
    jmp .L718
.L717:
    xor eax, eax
.L718:
    test rax, rax
    jz .L719
    lea rax, [rbp-88]
    mov rax, [rax]
    lea rax, [rbp-88]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L719:
    lea rax, [rip+g_usesroom]
    mov rax, [rax]
    test rax, rax
    jz .L720
    lea rax, [rbp-88]
    mov rax, [rax]
    test rax, rax
    jz .L720
    mov eax, 1
    jmp .L721
.L720:
    xor eax, eax
.L721:
    test rax, rax
    jz .L722
    lea rax, [rip+g_curdl]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L722
    mov eax, 1
    jmp .L723
.L722:
    xor eax, eax
.L723:
    test rax, rax
    jz .L724
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    call f_newlab
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S420]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S421]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S422]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S423]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S424]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S425]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S426]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S427]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S428]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S429]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S430]
    push rax
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
.L724:
    lea rax, [rip+.S431]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S432]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S433]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L725
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S434]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S435]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S436]
    push rax
    pop rdi
    call f_newstr
    mov rcx, rbp
    sub rcx, 96
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    test rax, rax
    jz .L726
    lea rax, [rbp-96]
    mov rax, [rax]
    lea rax, [rbp-96]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L726:
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_strlab
    mov rcx, rbp
    sub rcx, 104
    mov qword ptr [rcx], rax
    lea rax, [rip+.S437]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S438]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lea_str
    lea rax, [rip+.S439]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    lea rax, [rip+g_ncall]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_cnm]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S440]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cline]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S441]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
.L725:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    call f_sayline
    lea rax, [rip+.S442]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+.S443]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S444]
    push rax
    pop rdi
    call f_ins
    call f_sayline
    lea rax, [rip+.S445]
    push rax
    pop rdi
    call f_sayc
    lea rax, [rip+.S446]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S447]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S448]
    push rax
    pop rdi
    call f_sayc
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    push rax
    pop rsi
    pop rdi
    call f_saytext
    lea rax, [rip+.S449]
    push rax
    pop rdi
    call f_sayc
    lea rax, [rip+.S450]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S451]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S452]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    xor eax, eax
.Lret_moveone:
    mov rsp, rbp
    pop rbp
    ret
f_moves:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L727:
    mov rax, 1
    test rax, rax
    jz .L728
    call f_moveone
    lea rax, [rip+g_kand]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L729
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L727
.L729:
    jmp .L728
    jmp .L727
.L728:
    mov rax, 59
    push rax
    lea rax, [rip+.S453]
    push rax
    pop rsi
    pop rdi
    call f_need
    xor eax, eax
.Lret_moves:
    mov rsp, rbp
    pop rbp
    ret
f_checkcount:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_tys]
    lea rax, [rip+g_tys]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L730
    lea rax, [rip+g_tynd]
    lea rax, [rip+g_tynd]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L730
    xor eax, eax
    jmp .L731
.L730:
    mov eax, 1
.L731:
    test rax, rax
    jnz .L732
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L732
    xor eax, eax
    jmp .L733
.L732:
    mov eax, 1
.L733:
    test rax, rax
    jz .L734
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S454]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S455]
    mov rsi, 3
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S456]
    mov rsi, 55
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L734:
    xor eax, eax
.Lret_checkcount:
    mov rsp, rbp
    pop rbp
    ret
f_decompose:
    push rbp
    mov rbp, rsp
    sub rsp, 2144        
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_haslast]
    mov rax, [rax]
    lea rax, [rip+g_haslast]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_lvalue
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    call f_hidden
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+.S457]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S458]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+g_haslast]
    mov rax, [rax]
    test rax, rax
    jz .L735
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    call f_hidden
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_lasttoff]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_lastfoff]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L736
    lea rax, [rip+.S459]
    push rax
    lea rax, [rip+g_lasttoff]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_lastfoff]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L737
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S460]
    mov rsi, 11
    call dl_write
    mov rdi, 895
    call dl_putd
    lea rdi, [rip+.S461]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S462]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S463]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S464]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L737:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_insn
.L736:
    lea rax, [rip+.S465]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S466]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
.L735:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_checkcount
    mov rax, 68
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    lea rax, [rip+.S467]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rdi, [rbp-1048]
    mov rcx, 1008
    mov eax, LOW
    rep stosb
    lea rdi, [rbp-2056]
    mov rcx, 1008
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 2064
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 2072
    mov qword ptr [rcx], rax
.L738:
    mov rax, 1
    test rax, rax
    jz .L739
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 2080
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L740
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L740
    xor eax, eax
    jmp .L741
.L740:
    mov eax, 1
.L741:
    test rax, rax
    jz .L742
    call f_unary
    lea rax, [rbp-2080]
    mov rax, [rax]
    lea rax, [rbp-2080]
    push rax
    call f_hidden
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S468]
    push rax
    lea rax, [rbp-2080]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S469]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rbp-2072]
    mov rax, [rax]
    lea rax, [rbp-2072]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L742:
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 2088
    mov qword ptr [rcx], rax
    call f_lvalue
    mov rcx, rbp
    sub rcx, 2096
    mov qword ptr [rcx], rax
    call f_hidden
    mov rcx, rbp
    sub rcx, 2104
    mov qword ptr [rcx], rax
    lea rax, [rip+.S470]
    push rax
    lea rax, [rbp-2104]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S471]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rbp-2096]
    mov rax, [rax]
    push rax
    lea rax, [rbp-2088]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_checkcount
    lea rax, [rbp-2064]
    mov rax, [rax]
    lea rax, [rbp-2064]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-1048]
    lea rax, [rbp-1048]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-1048]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-2104]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-2056]
    lea rax, [rbp-2056]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-2056]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-2080]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 43
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L743
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L738
.L743:
    jmp .L739
    jmp .L738
.L739:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-2072]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L744
    lea rax, [rbp-2072]
    mov rax, [rax]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L744
    mov eax, 1
    jmp .L745
.L744:
    xor eax, eax
.L745:
    test rax, rax
    jz .L746
    lea rax, [rip+.S472]
    push rax
    pop rdi
    call f_fail
.L746:
    mov rax, 126
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L747
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S473]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S474]
    mov rsi, 58
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S475]
    mov rsi, 1
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L747:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 59
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L748
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S476]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S477]
    mov rsi, 34
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S478]
    mov rsi, 67
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L748:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_newlab
    mov rcx, rbp
    sub rcx, 2112
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 2120
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 2128
    mov qword ptr [rcx], rax
    lea rdi, [rbp-2136]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rip+.S479]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S480]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S481]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S482]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S483]
    push rax
    lea rax, [rbp-2112]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-2072]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L749
    lea rax, [rip+.S484]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-2136]
    mov rax, [rax]
    lea rax, [rbp-2136]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L750:
    lea rax, [rbp-2136]
    mov rax, [rax]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L752
    lea rax, [rip+.S485]
    push rax
    lea rax, [rbp-2056]
    lea rax, [rbp-2056]
    push rax
    lea rax, [rbp-2136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S486]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S487]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S488]
    push rax
    lea rax, [rbp-2120]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S489]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S490]
    push rax
    lea rax, [rbp-2120]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rip+.S491]
    push rax
    pop rdi
    call f_ins
.L751:
    lea rax, [rbp-2136]
    mov rax, [rax]
    lea rax, [rbp-2136]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L750
.L752:
    lea rax, [rbp-2136]
    mov rax, [rax]
    lea rax, [rbp-2136]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L753:
    lea rax, [rbp-2136]
    mov rax, [rax]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L755
    lea rax, [rip+.S492]
    push rax
    lea rax, [rbp-2056]
    lea rax, [rbp-2056]
    push rax
    lea rax, [rbp-2136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S493]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S494]
    push rax
    lea rax, [rbp-1048]
    lea rax, [rbp-1048]
    push rax
    lea rax, [rbp-2136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S495]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S496]
    push rax
    pop rdi
    call f_ins
.L754:
    lea rax, [rbp-2136]
    mov rax, [rax]
    lea rax, [rbp-2136]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L753
.L755:
    jmp .L756
.L749:
    lea rax, [rip+.S497]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+.S498]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S499]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S500]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S501]
    push rax
    lea rax, [rbp-2120]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-2136]
    mov rax, [rax]
    lea rax, [rbp-2136]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L757:
    lea rax, [rbp-2136]
    mov rax, [rax]
    push rax
    lea rax, [rbp-2064]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L759
    lea rax, [rip+.S502]
    push rax
    lea rax, [rbp-1048]
    lea rax, [rbp-1048]
    push rax
    lea rax, [rbp-2136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S503]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S504]
    push rax
    pop rdi
    call f_ins
.L758:
    lea rax, [rbp-2136]
    mov rax, [rax]
    lea rax, [rbp-2136]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L757
.L759:
.L756:
    lea rax, [rip+.S505]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L760
    lea rax, [rip+.S506]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S507]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S508]
    push rax
    pop rdi
    call f_ins
.L760:
    lea rax, [rip+.S509]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S510]
    push rax
    lea rax, [rbp-2128]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-2112]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    call f_sayline
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    push rax
    pop rsi
    pop rdi
    call f_saytext
    lea rax, [rip+.S511]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-2120]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    call f_sayline
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    push rax
    pop rsi
    pop rdi
    call f_saytext
    lea rax, [rip+.S512]
    push rax
    pop rdi
    call f_sayc
    call f_bang
    lea rax, [rbp-2128]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    xor eax, eax
.Lret_decompose:
    mov rsp, rbp
    pop rbp
    ret
f_syn:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    lea rax, [rip+g_nsyn]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tk]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tv]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tn]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tl]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_syn:
    mov rsp, rbp
    pop rbp
    ret
f_synop:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 4
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    xor eax, eax
.Lret_synop:
    mov rsp, rbp
    pop rbp
    ret
f_synid:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 2
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_word
    push rax
    pop rsi
    pop rdi
    call f_syn
    xor eax, eax
.Lret_synid:
    mov rsp, rbp
    pop rbp
    ret
f_syncopy:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rdi, [rbp-24]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L761:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L763
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    lea rax, [rip+g_nsyn]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tk]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tv]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tn]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tl]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L762:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L761
.L763:
    xor eax, eax
.Lret_syncopy:
    mov rsp, rbp
    pop rbp
    ret
f_synnum:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov rax, 1
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    xor eax, eax
.Lret_synnum:
    mov rsp, rbp
    pop rbp
    ret
f_synstrat:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    lea rax, [rip+g_nsyn]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tk]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    mov rax, 3
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tv]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tn]
    lea rax, [rip+g_tn]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tn]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_tl]
    push rax
    mov rax, 278469
    push rax
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_synstrat:
    mov rsp, rbp
    pop rbp
    ret
f_synstr:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_toktext
    push rax
    pop rdi
    call f_synstrat
    xor eax, eax
.Lret_synstr:
    mov rsp, rbp
    pop rbp
    ret
f_synthing:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L764
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L764
    xor eax, eax
    jmp .L765
.L764:
    mov eax, 1
.L765:
    test rax, rax
    jnz .L766
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_iskeyword
    test rax, rax
    jnz .L766
    xor eax, eax
    jmp .L767
.L766:
    mov eax, 1
.L767:
    test rax, rax
    jz .L768
    lea rax, [rip+.S513]
    push rax
    pop rdi
    call f_fail
.L768:
    lea rax, [rip+.S514]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    mov rax, 38
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_synstr
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_synnum
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L769
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    jmp .L770
.L769:
    mov rax, 1
    push rax
    pop rdi
    call f_synnum
.L770:
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    xor eax, eax
.Lret_synthing:
    mov rsp, rbp
    pop rbp
    ret
f_synpart:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rax, [rip+.S515]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    mov rax, 38
    push rax
    pop rdi
    call f_synop
    mov rax, 2
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    mov rax, 46
    push rax
    pop rdi
    call f_synop
    mov rax, 2
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_dotname
    push rax
    pop rdi
    call f_synstrat
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_synnum
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    mov rax, 1
    push rax
    pop rdi
    call f_synnum
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    xor eax, eax
.Lret_synpart:
    mov rsp, rbp
    pop rbp
    ret
f_findtok:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rdi, [rbp-32]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L771:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L773
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L774
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L774
    mov eax, 1
    jmp .L775
.L774:
    xor eax, eax
.L775:
    test rax, rax
    jz .L776
    lea rax, [rbp-32]
    mov rax, [rax]
    jmp .Lret_findtok
.L776:
.L772:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L771
.L773:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findtok
    xor eax, eax
.Lret_findtok:
    mov rsp, rbp
    pop rbp
    ret
f_findop:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rdi, [rbp-32]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L777:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L779
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L780
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L780
    mov eax, 1
    jmp .L781
.L780:
    xor eax, eax
.L781:
    test rax, rax
    jz .L782
    lea rax, [rbp-32]
    mov rax, [rax]
    jmp .Lret_findop
.L782:
.L778:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L777
.L779:
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_findop
    xor eax, eax
.Lret_findop:
    mov rsp, rbp
    pop rbp
    ret
f_partend:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rdi, [rbp-32]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L783:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L785
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 40
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jnz .L786
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 91
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jnz .L786
    xor eax, eax
    jmp .L787
.L786:
    mov eax, 1
.L787:
    test rax, rax
    jz .L788
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L788:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 41
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jnz .L789
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 93
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jnz .L789
    xor eax, eax
    jmp .L790
.L789:
    mov eax, 1
.L790:
    test rax, rax
    jz .L791
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L792
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S516]
    mov rsi, 11
    call dl_write
    mov rdi, 971
    call dl_putd
    lea rdi, [rip+.S517]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S518]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S519]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S520]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L792:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L791:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L793
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L793
    mov eax, 1
    jmp .L794
.L793:
    xor eax, eax
.L794:
    test rax, rax
    jz .L795
    lea rax, [rbp-32]
    mov rax, [rax]
    jmp .Lret_partend
.L795:
.L784:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L783
.L785:
    lea rax, [rbp-16]
    mov rax, [rax]
    jmp .Lret_partend
    xor eax, eax
.Lret_partend:
    mov rsp, rbp
    pop rbp
    ret
f_flowwords:
    push rbp
    mov rbp, rsp
    sub rsp, 304         
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L796:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 59
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L797
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L798
    lea rax, [rip+.S521]
    push rax
    pop rdi
    call f_fail
.L798:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L796
.L797:
    lea rax, [rip+g_nsyn]
    mov rax, [rax]
    lea rax, [rip+g_nsyn]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rdi, [rbp-40]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kstore]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L799
.L800:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L801
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 44
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_partend
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kleak]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L802
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    jmp .L803
.L802:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L804
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L804
    xor eax, eax
    jmp .L805
.L804:
    mov eax, 1
.L805:
    test rax, rax
    jz .L806
    lea rax, [rip+.S522]
    push rax
    pop rdi
    call f_fail
.L806:
    lea rax, [rip+.S523]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
.L803:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L800
.L801:
    jmp .L807
.L799:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kmix]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L808
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 44
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_partend
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L809
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S524]
    mov rsi, 11
    call dl_write
    mov rdi, 1000
    call dl_putd
    lea rdi, [rip+.S525]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S526]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S527]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S528]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L809:
    sub rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L810
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L812
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S529]
    mov rsi, 11
    call dl_write
    mov rdi, 1000
    call dl_putd
    lea rdi, [rip+.S530]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S531]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S532]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S533]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L812:
    sub rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L810
    xor eax, eax
    jmp .L811
.L810:
    mov eax, 1
.L811:
    test rax, rax
    jz .L813
    lea rax, [rip+.S534]
    push rax
    pop rdi
    call f_fail
.L813:
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findlocal
    mov rcx, rbp
    sub rcx, 80
    mov qword ptr [rcx], rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findlocal
    mov rcx, rbp
    sub rcx, 88
    mov qword ptr [rcx], rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 96
    mov qword ptr [rcx], rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 104
    mov qword ptr [rcx], rax
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L814
    lea rax, [rbp-96]
    mov rax, [rax]
    lea rax, [rbp-96]
    push rax
    lea rax, [rip+g_lt]
    lea rax, [rip+g_lt]
    push rax
    lea rax, [rbp-80]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L815
.L814:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L816
    lea rax, [rbp-96]
    mov rax, [rax]
    lea rax, [rbp-96]
    push rax
    lea rax, [rip+g_gt]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L816:
.L815:
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L817
    lea rax, [rbp-104]
    mov rax, [rax]
    lea rax, [rbp-104]
    push rax
    lea rax, [rip+g_lt]
    lea rax, [rip+g_lt]
    push rax
    lea rax, [rbp-88]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L818
.L817:
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L819
    lea rax, [rbp-104]
    mov rax, [rax]
    lea rax, [rbp-104]
    push rax
    lea rax, [rip+g_gt]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L819:
.L818:
    mov rax, 13
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    mov rax, 13
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rbp
    sub rcx, 112
    mov qword ptr [rcx], rax
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L820
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L820
    mov eax, 1
    jmp .L821
.L820:
    xor eax, eax
.L821:
    test rax, rax
    jz .L822
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-96]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L823
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S535]
    mov rsi, 11
    call dl_write
    mov rdi, 1007
    call dl_putd
    lea rdi, [rip+.S536]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S537]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S538]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S539]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L823:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 120
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L824
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S540]
    mov rsi, 11
    call dl_write
    mov rdi, 1007
    call dl_putd
    lea rdi, [rip+.S541]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S542]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S543]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S544]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L824:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 128
    mov qword ptr [rcx], rax
    lea rdi, [rbp-136]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 144
    mov qword ptr [rcx], rax
    lea rax, [rbp-136]
    mov rax, [rax]
    lea rax, [rbp-136]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L825:
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L827
    lea rax, [rip+g_fdowner]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L828
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktilde]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L828
    mov eax, 1
    jmp .L829
.L828:
    xor eax, eax
.L829:
    test rax, rax
    jz .L830
    lea rax, [rbp-128]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfield
    mov rcx, rbp
    sub rcx, 152
    mov qword ptr [rcx], rax
    lea rax, [rbp-152]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L831
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L831
    mov eax, 1
    jmp .L832
.L831:
    xor eax, eax
.L832:
    test rax, rax
    jz .L833
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rbp-152]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L833
    mov eax, 1
    jmp .L834
.L833:
    xor eax, eax
.L834:
    test rax, rax
    jz .L835
    lea rax, [rbp-144]
    mov rax, [rax]
    lea rax, [rbp-144]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S545]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_synpart
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    pop rdi
    call f_synnum
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rip+.S546]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_synpart
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    pop rdi
    call f_synnum
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rip+.S547]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_synpart
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_synpart
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
.L835:
.L830:
.L826:
    lea rax, [rbp-136]
    mov rax, [rax]
    lea rax, [rbp-136]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L825
.L827:
    lea rax, [rbp-144]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L836
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S548]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S549]
    mov rsi, 2
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S550]
    mov rsi, 5
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S551]
    mov rsi, 32
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L836:
    jmp .L837
.L822:
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L838
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L838
    mov eax, 1
    jmp .L839
.L838:
    xor eax, eax
.L839:
    test rax, rax
    jz .L840
    lea rax, [rip+.S552]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    pop rdi
    call f_synnum
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rip+.S553]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    pop rdi
    call f_synnum
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rip+.S554]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    jmp .L841
.L840:
    lea rax, [rip+.S555]
    push rax
    pop rdi
    call f_fail
.L841:
.L837:
    jmp .L842
.L808:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kwear]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L843
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 68
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findop
    mov rcx, rbp
    sub rcx, 160
    mov qword ptr [rcx], rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L844
    lea rax, [rip+.S556]
    push rax
    pop rdi
    call f_fail
.L844:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L845
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S557]
    mov rsi, 11
    call dl_write
    mov rdi, 1026
    call dl_putd
    lea rdi, [rip+.S558]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S559]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S560]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S561]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L845:
    sub rax, rcx
    push rax
    mov rax, 126
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L846
    lea rax, [rip+.S562]
    push rax
    pop rdi
    call f_fail
.L846:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L847
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S563]
    mov rsi, 11
    call dl_write
    mov rdi, 1027
    call dl_putd
    lea rdi, [rip+.S564]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S565]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S566]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S567]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L847:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 168
    mov qword ptr [rcx], rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L848
    lea rax, [rip+.S568]
    push rax
    pop rdi
    call f_fail
.L848:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kby]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 176
    mov qword ptr [rcx], rax
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L849
    lea rax, [rip+.S569]
    push rax
    pop rdi
    call f_fail
.L849:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kper]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 184
    mov qword ptr [rcx], rax
    lea rax, [rbp-160]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 192
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 200
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 208
    mov qword ptr [rcx], rax
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L850
    lea rax, [rbp-192]
    mov rax, [rax]
    lea rax, [rbp-192]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-200]
    mov rax, [rax]
    lea rax, [rbp-200]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-208]
    mov rax, [rax]
    lea rax, [rbp-208]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L850:
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-192]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L851
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L853
    lea rax, [rbp-200]
    mov rax, [rax]
    push rax
    lea rax, [rbp-208]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L853
    mov eax, 1
    jmp .L854
.L853:
    xor eax, eax
.L854:
    test rax, rax
    jnz .L851
    xor eax, eax
    jmp .L852
.L851:
    mov eax, 1
.L852:
    test rax, rax
    jz .L855
    lea rax, [rip+.S570]
    push rax
    pop rdi
    call f_fail
.L855:
    lea rax, [rip+.S571]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-200]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L856
    lea rax, [rbp-200]
    mov rax, [rax]
    push rax
    lea rax, [rbp-208]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    jmp .L857
.L856:
    mov rax, 1
    push rax
    pop rdi
    call f_synnum
.L857:
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L858:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L859
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    mov rax, 43
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_partend
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S572]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L858
.L859:
    jmp .L860
.L843:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kquiet]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L861
    lea rax, [rip+.S573]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    jmp .L862
.L861:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kshrug]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L863
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfrom]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 216
    mov qword ptr [rcx], rax
    lea rax, [rbp-216]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jnz .L864
    lea rax, [rbp-216]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L864
    xor eax, eax
    jmp .L865
.L864:
    mov eax, 1
.L865:
    test rax, rax
    jz .L866
    lea rax, [rip+.S574]
    push rax
    pop rdi
    call f_fail
.L866:
    lea rax, [rip+.S575]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    mov rax, 38
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-216]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-216]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-216]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_synstr
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    jmp .L867
.L863:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktick]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L868
    lea rax, [rip+.S576]
    push rax
    pop rdi
    call f_word
    mov rcx, rbp
    sub rcx, 224
    mov qword ptr [rcx], rax
    lea rax, [rip+.S577]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rip+.S578]
    push rax
    pop rdi
    call f_synid
    mov rax, 2
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    mov rax, 61
    push rax
    pop rdi
    call f_synop
    mov rax, 1
    push rax
    pop rdi
    call f_synnum
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    mov rax, 2
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    mov rax, 60
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_synop
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L869
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    jmp .L870
.L869:
    mov rax, 1
    push rax
    pop rdi
    call f_synnum
.L870:
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    mov rax, 2
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    mov rax, 43
    push rax
    mov rax, 43
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rdi
    call f_synop
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 123
    push rax
    pop rdi
    call f_synop
    lea rax, [rip+.S579]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    mov rax, 2
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    mov rax, 125
    push rax
    pop rdi
    call f_synop
    jmp .L871
.L868:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kconduct]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L872
.L873:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L874
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 44
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_partend
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kloss]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 232
    mov qword ptr [rcx], rax
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jnz .L875
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L875
    xor eax, eax
    jmp .L876
.L875:
    mov eax, 1
.L876:
    test rax, rax
    jz .L877
    lea rax, [rip+.S580]
    push rax
    pop rdi
    call f_fail
.L877:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kper]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 240
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 248
    mov qword ptr [rcx], rax
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L878
    lea rax, [rbp-248]
    mov rax, [rax]
    lea rax, [rbp-248]
    push rax
    lea rax, [rbp-240]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L878:
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-248]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L879
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L881
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L881
    mov eax, 1
    jmp .L882
.L881:
    xor eax, eax
.L882:
    test rax, rax
    jnz .L879
    xor eax, eax
    jmp .L880
.L879:
    mov eax, 1
.L880:
    test rax, rax
    jz .L883
    lea rax, [rip+.S581]
    push rax
    pop rdi
    call f_fail
.L883:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L884
    lea rax, [rip+.S582]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 2
    push rax
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-248]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    jmp .L885
.L884:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 2
    push rax
    lea rax, [rbp-232]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-248]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 59
    push rax
    pop rdi
    call f_synop
.L885:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L873
.L874:
    jmp .L886
.L872:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kneighbours]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L887
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 58
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findop
    mov rcx, rbp
    sub rcx, 256
    mov qword ptr [rcx], rax
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jnz .L888
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L888
    xor eax, eax
    jmp .L889
.L888:
    mov eax, 1
.L889:
    test rax, rax
    jz .L890
    lea rax, [rip+.S583]
    push rax
    pop rdi
    call f_fail
.L890:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L891:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L892
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 44
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_partend
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 264
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 272
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 280
    mov qword ptr [rcx], rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L893
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S584]
    mov rsi, 11
    call dl_write
    mov rdi, 1076
    call dl_putd
    lea rdi, [rip+.S585]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S586]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S587]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S588]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L893:
    sub rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L894
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L896
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S589]
    mov rsi, 11
    call dl_write
    mov rdi, 1076
    call dl_putd
    lea rdi, [rip+.S590]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S591]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S592]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S593]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L896:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L894
    mov eax, 1
    jmp .L895
.L894:
    xor eax, eax
.L895:
    test rax, rax
    jz .L897
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L899
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S594]
    mov rsi, 11
    call dl_write
    mov rdi, 1076
    call dl_putd
    lea rdi, [rip+.S595]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S596]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S597]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S598]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L899:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kheat]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L897
    mov eax, 1
    jmp .L898
.L897:
    xor eax, eax
.L898:
    test rax, rax
    jz .L900
    lea rax, [rbp-264]
    mov rax, [rax]
    lea rax, [rbp-264]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-280]
    mov rax, [rax]
    lea rax, [rbp-280]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L901
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S599]
    mov rsi, 11
    call dl_write
    mov rdi, 1076
    call dl_putd
    lea rdi, [rip+.S600]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S601]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S602]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S603]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L901:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L900:
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L902
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S604]
    mov rsi, 11
    call dl_write
    mov rdi, 1077
    call dl_putd
    lea rdi, [rip+.S605]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S606]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S607]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S608]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L902:
    sub rax, rcx
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L903
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L905
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S609]
    mov rsi, 11
    call dl_write
    mov rdi, 1077
    call dl_putd
    lea rdi, [rip+.S610]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S611]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S612]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S613]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L905:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L903
    mov eax, 1
    jmp .L904
.L903:
    xor eax, eax
.L904:
    test rax, rax
    jz .L906
    lea rax, [rbp-272]
    mov rax, [rax]
    lea rax, [rbp-272]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L907
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S614]
    mov rsi, 11
    call dl_write
    mov rdi, 1077
    call dl_putd
    lea rdi, [rip+.S615]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S616]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S617]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S618]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L907:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-280]
    mov rax, [rax]
    lea rax, [rbp-280]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L908
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S619]
    mov rsi, 11
    call dl_write
    mov rdi, 1077
    call dl_putd
    lea rdi, [rip+.S620]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S621]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S622]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S623]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L908:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L906:
    lea rax, [rip+.S624]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-264]
    mov rax, [rax]
    test rax, rax
    jz .L909
    lea rax, [rip+.S625]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
.L909:
    lea rax, [rbp-272]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L910
    lea rax, [rip+.S626]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-280]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-272]
    mov rax, [rax]
    push rax
    lea rax, [rbp-272]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
.L910:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L891
.L892:
    jmp .L911
.L887:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfrom]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_findtok
    mov rcx, rbp
    sub rcx, 288
    mov qword ptr [rcx], rax
    lea rax, [rbp-288]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jnz .L912
    lea rax, [rbp-288]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L912
    xor eax, eax
    jmp .L913
.L912:
    mov eax, 1
.L913:
    test rax, rax
    jz .L914
    lea rax, [rip+.S627]
    push rax
    pop rdi
    call f_fail
.L914:
    lea rax, [rip+.S628]
    push rax
    pop rdi
    call f_synid
    mov rax, 40
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-288]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_synthing
    mov rax, 44
    push rax
    pop rdi
    call f_synop
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-288]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syncopy
    mov rax, 41
    push rax
    pop rdi
    call f_synop
    mov rax, 59
    push rax
    pop rdi
    call f_synop
.L911:
.L886:
.L871:
.L867:
.L862:
.L860:
.L842:
.L807:
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L915
    lea rax, [rip+.S629]
    push rax
    pop rdi
    call f_fail
.L915:
    mov rax, 6
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_syn
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rbp
    sub rcx, 296
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    mov rax, 278469
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L916:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L917
    call f_statement
    jmp .L916
.L917:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-296]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_flowwords:
    mov rsp, rbp
    pop rbp
    ret
f_vesselstmt:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L918:
    mov rax, 1
    test rax, rax
    jz .L919
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_name
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findlocal
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L920
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rip+g_lt]
    lea rax, [rip+g_lt]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S630]
    push rax
    lea rax, [rip+g_lo]
    lea rax, [rip+g_lo]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S631]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    jmp .L921
.L920:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L922
    lea rax, [rip+.S632]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S633]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L922:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rip+g_gt]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S634]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    lea rax, [rip+.S635]
    push rax
    pop rdi
    call f_es
.L921:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L923
    lea rax, [rip+.S636]
    push rax
    pop rdi
    call f_fail
.L923:
    lea rax, [rip+g_tyb]
    lea rax, [rip+g_tyb]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L924
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S637]
    mov rsi, 11
    call dl_write
    mov rdi, 1106
    call dl_putd
    lea rdi, [rip+.S638]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S639]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S640]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S641]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L924:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rdi, [rbp-48]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L925:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L927
    lea rax, [rip+g_fdowner]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L928
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktilde]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L928
    mov eax, 1
    jmp .L929
.L928:
    xor eax, eax
.L929:
    test rax, rax
    jz .L930
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L930
    mov eax, 1
    jmp .L931
.L930:
    xor eax, eax
.L931:
    test rax, rax
    jz .L932
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S642]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S643]
    mov rsi, 48
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S644]
    mov rsi, 12
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L932:
.L926:
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L925
.L927:
    lea rax, [rip+.S645]
    push rax
    pop rdi
    call f_ins
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_textlen
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_strlab
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rip+.S646]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S647]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lea_str
    lea rax, [rip+.S648]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L933
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S649]
    mov rsi, 11
    call dl_write
    mov rdi, 1112
    call dl_putd
    lea rdi, [rip+.S650]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S651]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L933:
    cqo
    idiv rcx
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+.S652]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    lea rax, [rip+g_ncall]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_cnm]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S653]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cline]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 44
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L934
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L918
.L934:
    jmp .L919
    jmp .L918
.L919:
    mov rax, 59
    push rax
    lea rax, [rip+.S654]
    push rax
    pop rsi
    pop rdi
    call f_need
    xor eax, eax
.Lret_vesselstmt:
    mov rsp, rbp
    pop rbp
    ret
f_fitsstmt:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L935:
    mov rax, 1
    test rax, rax
    jz .L936
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_haslast]
    mov rax, [rax]
    lea rax, [rip+g_haslast]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_lvalue
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L937
    lea rax, [rip+.S655]
    push rax
    pop rdi
    call f_fail
.L937:
    lea rax, [rip+.S656]
    push rax
    pop rdi
    call f_ins
    call f_expr
    lea rax, [rip+.S657]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S658]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S659]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    lea rax, [rip+g_ncall]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_cnm]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S660]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cline]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_line]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 44
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L938
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L935
.L938:
    jmp .L936
    jmp .L935
.L936:
    mov rax, 59
    push rax
    lea rax, [rip+.S661]
    push rax
    pop rsi
    pop rdi
    call f_need
    xor eax, eax
.Lret_fitsstmt:
    mov rsp, rbp
    pop rbp
    ret
f_bracelist:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L939:
    mov rax, 125
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L940
    mov rax, 123
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L941
    call f_bracelist
    jmp .L942
.L941:
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L943:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L945
    mov rax, 44
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L947
    mov rax, 125
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L947
    mov eax, 1
    jmp .L948
.L947:
    xor eax, eax
.L948:
    test rax, rax
    jnz .L945
    xor eax, eax
    jmp .L946
.L945:
    mov eax, 1
.L946:
    test rax, rax
    jz .L944
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L949
    mov rax, 123
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L949
    xor eax, eax
    jmp .L950
.L949:
    mov eax, 1
.L950:
    test rax, rax
    jz .L951
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L951:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L952
    mov rax, 125
    push rax
    pop rdi
    call f_at
    test rax, rax
    jnz .L952
    xor eax, eax
    jmp .L953
.L952:
    mov eax, 1
.L953:
    test rax, rax
    jz .L954
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L955
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S662]
    mov rsi, 11
    call dl_write
    mov rdi, 1149
    call dl_putd
    lea rdi, [rip+.S663]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S664]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S665]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S666]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L955:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L954:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L943
.L944:
    lea rax, [rip+g_nival]
    mov rax, [rax]
    lea rax, [rip+g_nival]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_ivals]
    lea rax, [rip+g_ivals]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_ivals]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L956
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L956
    mov eax, 1
    jmp .L957
.L956:
    xor eax, eax
.L957:
    test rax, rax
    jz .L958
    lea rax, [rip+g_inum]
    lea rax, [rip+g_inum]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_inum]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L959
.L958:
    lea rax, [rip+g_inum]
    lea rax, [rip+g_inum]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_inum]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L959:
.L942:
    mov rax, 44
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L960
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L960:
    jmp .L939
.L940:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    xor eax, eax
.Lret_bracelist:
    mov rsp, rbp
    pop rbp
    ret
f_putval:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    lea rax, [rip+g_inum]
    lea rax, [rip+g_inum]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    test rax, rax
    jz .L961
    lea rax, [rip+.S667]
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_ivals]
    lea rax, [rip+g_ivals]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    jmp .L962
.L961:
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rip+g_ivals]
    lea rax, [rip+g_ivals]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_expr
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L962:
    xor eax, eax
.Lret_putval:
    mov rsp, rbp
    pop rbp
    ret
f_zero:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+.S668]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S669]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    lea rax, [rip+.S670]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+.S671]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S672]
    push rax
    pop rdi
    call f_ins
    xor eax, eax
.Lret_zero:
    mov rsp, rbp
    pop rbp
    ret
f_declaration:
    push rbp
    mov rbp, rsp
    sub rsp, 192         
    call f_basetype
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
.L963:
    mov rax, 1
    test rax, rax
    jz .L964
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L965:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L966
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L965
.L966:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_name
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rdi, [rbp-64]
    mov rcx, 32
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L967:
    mov rax, 91
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L968
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 93
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L969
    lea rax, [rbp-72]
    mov rax, [rax]
    lea rax, [rbp-72]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L970
.L969:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L971
    lea rax, [rip+.S673]
    push rax
    pop rdi
    call f_fail
.L971:
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L970:
    mov rax, 93
    push rax
    lea rax, [rip+.S674]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .L967
.L968:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 80
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 88
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 96
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    lea rax, [rip+g_nival]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 61
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L972
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 123
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L973
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    mov rax, 2
    pop rcx
    mov qword ptr [rcx], rax
    call f_bracelist
    jmp .L974
.L973:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L975
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L975
    mov eax, 1
    jmp .L976
.L975:
    xor eax, eax
.L976:
    test rax, rax
    jz .L977
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    mov rax, 3
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-88]
    mov rax, [rax]
    lea rax, [rbp-88]
    push rax
    lea rax, [rbp-96]
    push rax
    pop rdi
    call f_joinstr
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L978
.L977:
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L978:
.L974:
.L972:
    lea rax, [rbp-72]
    mov rax, [rax]
    test rax, rax
    jz .L979
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L980
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L981
.L980:
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L981:
.L979:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    mov rcx, rbp
    sub rcx, 104
    mov qword ptr [rcx], rax
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L982
    call f_expr
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_local
    mov rcx, rbp
    sub rcx, 112
    mov qword ptr [rcx], rax
    lea rax, [rip+.S675]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S676]
    push rax
    lea rax, [rbp-112]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rdi
    call f_storercx
    jmp .L983
.L982:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_local
    mov rcx, rbp
    sub rcx, 120
    mov qword ptr [rcx], rax
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L984
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L985
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S677]
    mov rsi, 11
    call dl_write
    mov rdi, 1200
    call dl_putd
    lea rdi, [rip+.S678]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S679]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L985:
    cqo
    idiv rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_zero
    jmp .L986
.L984:
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L987
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L988
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S680]
    mov rsi, 11
    call dl_write
    mov rdi, 1202
    call dl_putd
    lea rdi, [rip+.S681]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S682]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L988:
    cqo
    idiv rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_zero
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L989
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S683]
    mov rsi, 11
    call dl_write
    mov rdi, 1203
    call dl_putd
    lea rdi, [rip+.S684]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S685]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S686]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S687]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L989:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 128
    mov qword ptr [rcx], rax
    lea rdi, [rbp-136]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    mov rax, 1
    mov rcx, rbp
    sub rcx, 144
    mov qword ptr [rcx], rax
    lea rax, [rbp-136]
    mov rax, [rax]
    lea rax, [rbp-136]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L990:
    lea rax, [rbp-136]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L992
    lea rax, [rip+g_fdowner]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-128]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L993
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ktilde]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L993
    mov eax, 1
    jmp .L994
.L993:
    xor eax, eax
.L994:
    test rax, rax
    jz .L995
    lea rax, [rbp-144]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nival]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L996
    lea rax, [rbp-144]
    mov rax, [rax]
    push rax
    pop rdi
    call f_putval
    lea rax, [rip+.S688]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S689]
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_fdoff]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L997
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S690]
    mov rsi, 11
    call dl_write
    mov rdi, 1205
    call dl_putd
    lea rdi, [rip+.S691]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S692]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S693]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S694]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L997:
    sub rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_insn
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rbp-136]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_storercx
.L996:
    lea rax, [rbp-144]
    mov rax, [rax]
    lea rax, [rbp-144]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L995:
.L991:
    lea rax, [rbp-136]
    mov rax, [rax]
    lea rax, [rbp-136]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L990
.L992:
    lea rax, [rip+g_nival]
    mov rax, [rax]
    push rax
    lea rax, [rbp-144]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L998
    lea rax, [rip+.S695]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S696]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L998:
    jmp .L999
.L987:
    mov rax, 8
    mov rcx, rbp
    sub rcx, 152
    mov qword ptr [rcx], rax
    mov rax, 1
    mov rcx, rbp
    sub rcx, 160
    mov qword ptr [rcx], rax
    lea rdi, [rbp-168]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1000
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1000
    mov eax, 1
    jmp .L1001
.L1000:
    xor eax, eax
.L1001:
    test rax, rax
    jz .L1002
    lea rax, [rbp-152]
    mov rax, [rax]
    lea rax, [rbp-152]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1002:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1003
    lea rax, [rbp-160]
    mov rax, [rax]
    lea rax, [rbp-160]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L1003:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1004
    lea rax, [rbp-160]
    mov rax, [rax]
    lea rax, [rbp-160]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L1004:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1005
    lea rax, [rbp-160]
    mov rax, [rax]
    lea rax, [rbp-160]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L1005:
    lea rax, [rip+g_nival]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 176
    mov qword ptr [rcx], rax
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1006
    lea rax, [rbp-176]
    mov rax, [rax]
    lea rax, [rbp-176]
    push rax
    lea rax, [rbp-96]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1006:
    lea rax, [rbp-176]
    mov rax, [rax]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L1007
    lea rax, [rip+.S697]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S698]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L1007:
    lea rax, [rbp-168]
    mov rax, [rax]
    lea rax, [rbp-168]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1008:
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    lea rax, [rbp-160]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1010
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1011
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S699]
    mov rsi, 11
    call dl_write
    mov rdi, 1217
    call dl_putd
    lea rdi, [rip+.S700]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S701]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S702]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S703]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1011:
    sub rax, rcx
    push rax
    lea rax, [rbp-152]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1012
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S704]
    mov rsi, 11
    call dl_write
    mov rdi, 1217
    call dl_putd
    lea rdi, [rip+.S705]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S706]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S707]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S708]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1012:
    sub rax, rcx
    mov rcx, rbp
    sub rcx, 184
    mov qword ptr [rcx], rax
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    lea rax, [rbp-176]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L1013
    lea rax, [rbp-152]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1014
    lea rax, [rip+.S709]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S710]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    jmp .L1015
.L1014:
    lea rax, [rip+.S711]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S712]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
.L1015:
    jmp .L1016
.L1013:
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1017
    lea rax, [rip+.S713]
    push rax
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1018
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S714]
    mov rsi, 11
    call dl_write
    mov rdi, 1220
    call dl_putd
    lea rdi, [rip+.S715]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S716]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S717]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S718]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1018:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    pop rsi
    pop rdi
    call f_insn
    jmp .L1019
.L1017:
    lea rax, [rbp-168]
    mov rax, [rax]
    push rax
    pop rdi
    call f_putval
.L1019:
    lea rax, [rbp-152]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1020
    lea rax, [rip+.S719]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S720]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
    jmp .L1021
.L1020:
    lea rax, [rip+.S721]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S722]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_insr
.L1021:
.L1016:
.L1009:
    lea rax, [rbp-168]
    mov rax, [rax]
    lea rax, [rbp-168]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1008
.L1010:
.L999:
.L986:
.L983:
    mov rax, 44
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1022
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L963
.L1022:
    jmp .L964
    jmp .L963
.L964:
    xor eax, eax
.Lret_declaration:
    mov rsp, rbp
    pop rbp
    ret
f_block:
    push rbp
    mov rbp, rsp
    sub rsp, 0           
    mov rax, 123
    push rax
    lea rax, [rip+.S723]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    lea rax, [rip+g_nsc]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_sc]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1023:
    mov rax, 125
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1024
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1025
    lea rax, [rip+.S724]
    push rax
    pop rdi
    call f_failat
.L1025:
    call f_statement
    jmp .L1023
.L1024:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    lea rax, [rip+g_nloc]
    push rax
    lea rax, [rip+g_sc]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    lea rax, [rip+g_nsc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1026
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S725]
    mov rsi, 11
    call dl_write
    mov rdi, 1237
    call dl_putd
    lea rdi, [rip+.S726]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S727]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S728]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S729]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1026:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_block:
    mov rsp, rbp
    pop rbp
    ret
f_statement:
    push rbp
    mov rbp, rsp
    sub rsp, 112         
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 123
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1027
    call f_block
    jmp .Lret_statement
.L1027:
    mov rax, 59
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1028
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .Lret_statement
.L1028:
    call f_istype
    test rax, rax
    jz .L1029
    call f_declaration
    mov rax, 59
    push rax
    lea rax, [rip+.S730]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .Lret_statement
.L1029:
    lea rax, [rip+g_kif]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1030
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 40
    push rax
    lea rax, [rip+.S731]
    push rax
    pop rsi
    pop rdi
    call f_need
    call f_expr
    call f_newlab
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rip+.S732]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S733]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    mov rax, 41
    push rax
    lea rax, [rip+.S734]
    push rax
    pop rsi
    pop rdi
    call f_need
    call f_statement
    lea rax, [rip+g_kelse]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1031
    call f_newlab
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+.S735]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    call f_statement
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    jmp .L1032
.L1031:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
.L1032:
    jmp .Lret_statement
.L1030:
    lea rax, [rip+g_kwhile]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1033
    call f_newlab
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 40
    push rax
    lea rax, [rip+.S736]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    call f_expr
    lea rax, [rip+.S737]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S738]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    mov rax, 41
    push rax
    lea rax, [rip+.S739]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    lea rax, [rip+g_nloop]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_brk]
    lea rax, [rip+g_brk]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_brk]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cont]
    lea rax, [rip+g_cont]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cont]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_statement
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    lea rax, [rip+g_nloop]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1034
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S740]
    mov rsi, 11
    call dl_write
    mov rdi, 1257
    call dl_putd
    lea rdi, [rip+.S741]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S742]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S743]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S744]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1034:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S745]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    jmp .Lret_statement
.L1033:
    lea rax, [rip+g_kfor]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1035
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 40
    push rax
    lea rax, [rip+.S746]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    lea rax, [rip+g_nsc]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_sc]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_istype
    test rax, rax
    jz .L1036
    call f_declaration
    jmp .L1037
.L1036:
    mov rax, 59
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1038
    call f_expr
.L1038:
.L1037:
    mov rax, 59
    push rax
    lea rax, [rip+.S747]
    push rax
    pop rsi
    pop rdi
    call f_need
    call f_newlab
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
    call f_newlab
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    mov rax, 59
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1039
    call f_expr
    lea rax, [rip+.S748]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S749]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
.L1039:
    mov rax, 59
    push rax
    lea rax, [rip+.S750]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 64
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
.L1040:
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L1042
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jnz .L1042
    xor eax, eax
    jmp .L1043
.L1042:
    mov eax, 1
.L1043:
    test rax, rax
    jz .L1041
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1044
    lea rax, [rbp-72]
    mov rax, [rax]
    lea rax, [rbp-72]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L1044:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1045
    lea rax, [rbp-72]
    mov rax, [rax]
    lea rax, [rbp-72]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1046
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S751]
    mov rsi, 11
    call dl_write
    mov rdi, 1271
    call dl_putd
    lea rdi, [rip+.S752]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S753]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S754]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S755]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1046:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L1045:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1047
    lea rax, [rip+.S756]
    push rax
    pop rdi
    call f_failat
.L1047:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1040
.L1041:
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 80
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    lea rax, [rip+g_nloop]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_brk]
    lea rax, [rip+g_brk]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_brk]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_cont]
    lea rax, [rip+g_cont]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_cont]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_statement
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    lea rax, [rip+g_nloop]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1048
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S757]
    mov rsi, 11
    call dl_write
    mov rdi, 1276
    call dl_putd
    lea rdi, [rip+.S758]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S759]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S760]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S761]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1048:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rbp-80]
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L1049
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 88
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_expr
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-88]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1049:
    lea rax, [rip+.S762]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    lea rax, [rbp-56]
    mov rax, [rax]
    push rax
    pop rdi
    call f_lab
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    lea rax, [rip+g_nloc]
    push rax
    lea rax, [rip+g_sc]
    lea rax, [rip+g_sc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    lea rax, [rip+g_nsc]
    push rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1050
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S763]
    mov rsi, 11
    call dl_write
    mov rdi, 1280
    call dl_putd
    lea rdi, [rip+.S764]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S765]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S766]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S767]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1050:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .Lret_statement
.L1035:
    lea rax, [rip+g_kreturn]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1051
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 59
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1052
    call f_expr
.L1052:
    mov rax, 59
    push rax
    lea rax, [rip+.S768]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+.S769]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_curfn]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_curown]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_label
    mov rax, 10
    push rax
    pop rdi
    call f_ec
    jmp .Lret_statement
.L1051:
    lea rax, [rip+g_kbreak]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L1053
    lea rax, [rip+g_kcontinue]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jnz .L1053
    xor eax, eax
    jmp .L1054
.L1053:
    mov eax, 1
.L1054:
    test rax, rax
    jz .L1055
    lea rax, [rip+g_kbreak]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    mov rcx, rbp
    sub rcx, 96
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1056
    lea rax, [rbp-96]
    mov rax, [rax]
    test rax, rax
    jz .L1057
    lea rax, [rip+.S770]
    push rax
    pop rdi
    call f_fail
    jmp .L1058
.L1057:
    lea rax, [rip+.S771]
    push rax
    pop rdi
    call f_fail
.L1058:
.L1056:
    lea rax, [rbp-96]
    mov rax, [rax]
    test rax, rax
    jz .L1059
    lea rax, [rip+.S772]
    push rax
    lea rax, [rip+g_brk]
    lea rax, [rip+g_brk]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
    jmp .L1060
.L1059:
    lea rax, [rip+.S773]
    push rax
    lea rax, [rip+g_cont]
    lea rax, [rip+g_cont]
    push rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_jmp
.L1060:
    mov rax, 59
    push rax
    lea rax, [rip+.S774]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .Lret_statement
.L1055:
    lea rax, [rip+g_kvessel]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1061
    call f_vesselstmt
    jmp .Lret_statement
.L1061:
    lea rax, [rip+g_kfits]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1062
    call f_fitsstmt
    jmp .Lret_statement
.L1062:
    lea rax, [rip+g_kmove]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1063
    call f_moves
    call f_vcheck
    jmp .Lret_statement
.L1063:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1064
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_isflowword
    test rax, rax
    jz .L1064
    mov eax, 1
    jmp .L1065
.L1064:
    xor eax, eax
.L1065:
    test rax, rax
    jz .L1066
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 40
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1066
    mov eax, 1
    jmp .L1067
.L1066:
    xor eax, eax
.L1067:
    test rax, rax
    jz .L1068
    call f_flowwords
    jmp .Lret_statement
.L1068:
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 104
    mov qword ptr [rcx], rax
.L1069:
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    mov rax, 59
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1071
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1071
    mov eax, 1
    jmp .L1072
.L1071:
    xor eax, eax
.L1072:
    test rax, rax
    jz .L1073
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-104]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1073
    mov eax, 1
    jmp .L1074
.L1073:
    xor eax, eax
.L1074:
    test rax, rax
    jz .L1070
    lea rax, [rbp-104]
    mov rax, [rax]
    push rax
    mov rax, 68
    push rax
    mov rax, 62
    push rax
    pop rsi
    pop rdi
    call f_op2
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L1075
    call f_decompose
    call f_vcheck
    jmp .Lret_statement
.L1075:
    lea rax, [rbp-104]
    mov rax, [rax]
    lea rax, [rbp-104]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1069
.L1070:
    call f_expr
    mov rax, 59
    push rax
    lea rax, [rip+.S775]
    push rax
    pop rsi
    pop rdi
    call f_need
    call f_vcheck
    xor eax, eax
.Lret_statement:
    mov rsp, rbp
    pop rbp
    ret
f_function:
    push rbp
    mov rbp, rsp
    sub rsp, 272         
    mov [rbp-8], rdi
    call f_basetype
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L1076:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1077
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1076
.L1077:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_name
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    mov rax, 40
    push rax
    lea rax, [rip+.S776]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rdi, [rbp-104]
    mov rcx, 72
    mov eax, LOW
    rep stosb
    lea rdi, [rbp-176]
    mov rcx, 72
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 184
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1078
    lea rax, [rbp-184]
    mov rax, [rax]
    lea rax, [rbp-184]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-104]
    lea rax, [rbp-104]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-104]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_kself]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-176]
    lea rax, [rbp-176]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-176]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    mov rax, 3
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    pop rcx
    mov qword ptr [rcx], rax
.L1078:
.L1079:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1080
    lea rax, [rip+g_kvoid]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1081
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 41
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L1081
    mov eax, 1
    jmp .L1082
.L1081:
    xor eax, eax
.L1082:
    test rax, rax
    jz .L1083
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1080
.L1083:
    call f_basetype
    mov rcx, rbp
    sub rcx, 192
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 200
    mov qword ptr [rcx], rax
.L1084:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1085
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-200]
    mov rax, [rax]
    lea rax, [rbp-200]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1084
.L1085:
    call f_name
    mov rcx, rbp
    sub rcx, 208
    mov qword ptr [rcx], rax
.L1086:
    mov rax, 91
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1087
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L1088:
    mov rax, 93
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1089
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1088
.L1089:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-200]
    mov rax, [rax]
    lea rax, [rbp-200]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1086
.L1087:
    lea rax, [rbp-184]
    mov rax, [rax]
    lea rax, [rbp-184]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-104]
    lea rax, [rbp-104]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-104]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-208]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-176]
    lea rax, [rbp-176]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-176]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    lea rax, [rbp-200]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-176]
    lea rax, [rbp-176]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L1090
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S777]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S778]
    mov rsi, 35
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-192]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1091
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S779]
    mov rsi, 11
    call dl_write
    mov rdi, 1328
    call dl_putd
    lea rdi, [rip+.S780]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S781]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S782]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S783]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1091:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S784]
    mov rsi, 2
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-208]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S785]
    mov rsi, 1
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L1090:
    mov rax, 41
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1092
    mov rax, 44
    push rax
    lea rax, [rip+.S786]
    push rax
    pop rsi
    pop rdi
    call f_need
.L1092:
    jmp .L1079
.L1080:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    mov rcx, rbp
    sub rcx, 216
    mov qword ptr [rcx], rax
    lea rax, [rbp-216]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L1093
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S787]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S788]
    mov rsi, 40
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1094
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S789]
    mov rsi, 11
    call dl_write
    mov rdi, 1333
    call dl_putd
    lea rdi, [rip+.S790]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S791]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S792]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S793]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1094:
    sub rax, rcx
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S794]
    mov rsi, 4
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L1093:
    lea rax, [rbp-184]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L1095
    lea rax, [rip+.S795]
    push rax
    pop rdi
    call f_fail
.L1095:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    mov rcx, rbp
    sub rcx, 224
    mov qword ptr [rcx], rax
    lea rax, [rbp-224]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1096
    lea rax, [rip+g_nf]
    mov rax, [rax]
    lea rax, [rip+g_nf]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-224]
    mov rax, [rax]
    lea rax, [rbp-224]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fnm]
    lea rax, [rip+g_fnm]
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fnm]
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fown]
    lea rax, [rip+g_fown]
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fown]
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1096:
    lea rax, [rip+g_frt]
    lea rax, [rip+g_frt]
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_frt]
    push rax
    lea rax, [rbp-224]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-216]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 59
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1097
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .Lret_function
.L1097:
    lea rax, [rip+g_curfn]
    mov rax, [rax]
    lea rax, [rip+g_curfn]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_curown]
    mov rax, [rax]
    lea rax, [rip+g_curown]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_frame]
    mov rax, [rax]
    lea rax, [rip+g_frame]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nloc]
    mov rax, [rax]
    lea rax, [rip+g_nloc]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nsc]
    mov rax, [rax]
    lea rax, [rip+g_nsc]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nloop]
    mov rax, [rax]
    lea rax, [rip+g_nloop]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_curdl]
    mov rax, [rax]
    lea rax, [rip+g_curdl]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1098
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1098
    mov eax, 1
    jmp .L1099
.L1098:
    xor eax, eax
.L1099:
    test rax, rax
    jz .L1100
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 108
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1100
    mov eax, 1
    jmp .L1101
.L1100:
    xor eax, eax
.L1101:
    test rax, rax
    jz .L1102
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 95
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1102
    mov eax, 1
    jmp .L1103
.L1102:
    xor eax, eax
.L1103:
    test rax, rax
    jz .L1104
    lea rax, [rip+g_curdl]
    mov rax, [rax]
    lea rax, [rip+g_curdl]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1104:
    lea rax, [rip+.S796]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_label
    lea rax, [rip+.S797]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+.S798]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S799]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S800]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_outn]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 232
    mov qword ptr [rcx], rax
    lea rax, [rip+.S801]
    push rax
    pop rdi
    call f_es
    lea rdi, [rbp-240]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-240]
    mov rax, [rax]
    lea rax, [rbp-240]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1105:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    lea rax, [rbp-184]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1107
    lea rax, [rbp-104]
    lea rax, [rbp-104]
    push rax
    lea rax, [rbp-240]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-176]
    lea rax, [rbp-176]
    push rax
    lea rax, [rbp-240]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_local
    mov rcx, rbp
    sub rcx, 248
    mov qword ptr [rcx], rax
    lea rax, [rip+.S802]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-248]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    lea rax, [rip+.S803]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1108
    lea rax, [rip+.S804]
    push rax
    pop rdi
    call f_es
.L1108:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1109
    lea rax, [rip+.S805]
    push rax
    pop rdi
    call f_es
.L1109:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1110
    lea rax, [rip+.S806]
    push rax
    pop rdi
    call f_es
.L1110:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1111
    lea rax, [rip+.S807]
    push rax
    pop rdi
    call f_es
.L1111:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1112
    lea rax, [rip+.S808]
    push rax
    pop rdi
    call f_es
.L1112:
    lea rax, [rbp-240]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1113
    lea rax, [rip+.S809]
    push rax
    pop rdi
    call f_es
.L1113:
    mov rax, 10
    push rax
    pop rdi
    call f_ec
.L1106:
    lea rax, [rbp-240]
    mov rax, [rax]
    lea rax, [rbp-240]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1105
.L1107:
    call f_block
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kmain]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1114
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1114
    mov eax, 1
    jmp .L1115
.L1114:
    xor eax, eax
.L1115:
    test rax, rax
    jz .L1116
    lea rax, [rip+.S810]
    push rax
    pop rdi
    call f_ins
    jmp .L1117
.L1116:
    lea rax, [rip+.S811]
    push rax
    pop rdi
    call f_ins
.L1117:
    lea rax, [rip+.S812]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_label
    lea rax, [rip+.S813]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+.S814]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S815]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+.S816]
    push rax
    pop rdi
    call f_ins
    lea rax, [rip+g_frame]
    mov rax, [rax]
    push rax
    mov rax, 15
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L1118
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S817]
    mov rsi, 11
    call dl_write
    mov rdi, 1358
    call dl_putd
    lea rdi, [rip+.S818]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S819]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1118:
    cqo
    idiv rcx
    push rax
    mov rax, 16
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rbp
    sub rcx, 256
    mov qword ptr [rcx], rax
    lea rax, [rip+g_outn]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 264
    mov qword ptr [rcx], rax
    lea rax, [rip+g_outn]
    mov rax, [rax]
    lea rax, [rip+g_outn]
    push rax
    lea rax, [rbp-232]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-256]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    lea rax, [rip+g_outn]
    mov rax, [rax]
    lea rax, [rip+g_outn]
    push rax
    lea rax, [rbp-264]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_curown]
    mov rax, [rax]
    lea rax, [rip+g_curown]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_function:
    mov rsp, rbp
    pop rbp
    ret
f_thingdef:
    push rbp
    mov rbp, rsp
    sub rsp, 13312       
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_name
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findthing
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1119
    lea rax, [rip+.S820]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S821]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L1119:
    lea rax, [rip+g_nth]
    mov rax, [rax]
    lea rax, [rip+g_nth]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_nth]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+g_thn]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_thn]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 123
    push rax
    lea rax, [rip+.S822]
    push rax
    pop rsi
    pop rdi
    call f_need
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rdi, [rbp-13200]
    mov rcx, 13176
    mov eax, LOW
    rep stosb
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 13208
    mov qword ptr [rcx], rax
.L1120:
    mov rax, 125
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1121
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 13216
    mov qword ptr [rcx], rax
    call f_basetype
    mov rcx, rbp
    sub rcx, 13224
    mov qword ptr [rcx], rax
.L1122:
    mov rax, 1
    test rax, rax
    jz .L1123
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 13232
    mov qword ptr [rcx], rax
.L1124:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1125
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-13232]
    mov rax, [rax]
    lea rax, [rbp-13232]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1124
.L1125:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_name
    mov rcx, rbp
    sub rcx, 13240
    mov qword ptr [rcx], rax
    mov rax, 40
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1126
    lea rax, [rbp-13208]
    mov rax, [rax]
    lea rax, [rbp-13208]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-13200]
    lea rax, [rbp-13200]
    push rax
    lea rax, [rbp-13208]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-13200]
    push rax
    lea rax, [rbp-13208]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-13216]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    lea rax, [rip+g_nf]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_fnm]
    lea rax, [rip+g_fnm]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fnm]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-13240]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fown]
    lea rax, [rip+g_fown]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fown]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_frt]
    lea rax, [rip+g_frt]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_frt]
    push rax
    lea rax, [rip+g_nf]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-13224]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13232]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    pop rcx
    mov qword ptr [rcx], rax
.L1127:
    mov rax, 123
    push rax
    pop rdi
    call f_at
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1128
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1127
.L1128:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 13248
    mov qword ptr [rcx], rax
.L1129:
    mov rax, 1
    test rax, rax
    jz .L1130
    mov rax, 123
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1131
    lea rax, [rbp-13248]
    mov rax, [rax]
    lea rax, [rbp-13248]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L1131:
    mov rax, 125
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1132
    lea rax, [rbp-13248]
    mov rax, [rax]
    lea rax, [rbp-13248]
    push rax
    lea rax, [rbp-13248]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1133
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S823]
    mov rsi, 11
    call dl_write
    mov rdi, 1387
    call dl_putd
    lea rdi, [rip+.S824]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S825]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S826]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S827]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1133:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L1132:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-13248]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1134
    jmp .L1130
.L1134:
    jmp .L1129
.L1130:
    jmp .L1123
.L1126:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 13256
    mov qword ptr [rcx], rax
    lea rdi, [rbp-13288]
    mov rcx, 32
    mov eax, LOW
    rep stosb
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-13288]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-13288]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-13288]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1135:
    mov rax, 91
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1136
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-13256]
    mov rax, [rax]
    lea rax, [rbp-13256]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1137
    lea rax, [rip+.S828]
    push rax
    pop rdi
    call f_fail
.L1137:
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    lea rax, [rbp-13256]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-13288]
    push rax
    lea rax, [rbp-13256]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 93
    push rax
    lea rax, [rip+.S829]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .L1135
.L1136:
    lea rax, [rbp-13224]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13232]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13256]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-13288]
    lea rax, [rbp-13288]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    mov rcx, rbp
    sub rcx, 13296
    mov qword ptr [rcx], rax
    lea rax, [rbp-13296]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isthing
    test rax, rax
    jz .L1138
    lea rax, [rbp-13224]
    mov rax, [rax]
    push rax
    mov rax, 3
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1140
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S830]
    mov rsi, 11
    call dl_write
    mov rdi, 1394
    call dl_putd
    lea rdi, [rip+.S831]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S832]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S833]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S834]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1140:
    sub rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1138
    mov eax, 1
    jmp .L1139
.L1138:
    xor eax, eax
.L1139:
    test rax, rax
    jz .L1141
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S835]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S836]
    mov rsi, 50
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S837]
    mov rsi, 4
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L1141:
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13240]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfield
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1142
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S838]
    mov rsi, 11
    call dl_write
    lea rax, [rip+g_line]
    mov rax, [rax]
    mov rdi, rax
    call dl_putd
    lea rdi, [rip+.S839]
    mov rsi, 3
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-13240]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S840]
    mov rsi, 23
    call dl_write
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S841]
    mov rsi, 1
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L1142:
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    lea rax, [rip+g_nfd]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_fdowner]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-13240]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-13296]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdoff]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13296]
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L1143
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S842]
    mov rsi, 11
    call dl_write
    mov rdi, 1397
    call dl_putd
    lea rdi, [rip+.S843]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S844]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1143:
    cqo
    idiv rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 44
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1144
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1122
.L1144:
    mov rax, 59
    push rax
    lea rax, [rip+.S845]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .L1123
    jmp .L1122
.L1123:
    jmp .L1120
.L1121:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 59
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1145
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L1145:
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    lea rax, [rip+g_nfd]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_fdowner]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdowner]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdname]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdname]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_ktilde]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdtype]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdtype]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_fdoff]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_fdoff]
    push rax
    lea rax, [rip+g_nfd]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_thtilde]
    lea rax, [rip+g_thtilde]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_thtilde]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_thsize]
    lea rax, [rip+g_thsize]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_thsize]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 13304
    mov qword ptr [rcx], rax
    lea rdi, [rbp-13312]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-13312]
    mov rax, [rax]
    lea rax, [rbp-13312]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1146:
    lea rax, [rbp-13312]
    mov rax, [rax]
    push rax
    lea rax, [rbp-13208]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1148
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-13200]
    lea rax, [rbp-13200]
    push rax
    lea rax, [rbp-13312]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rdi
    call f_function
.L1147:
    lea rax, [rbp-13312]
    mov rax, [rax]
    lea rax, [rbp-13312]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1146
.L1148:
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    lea rax, [rbp-13304]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_thingdef:
    mov rsp, rbp
    pop rbp
    ret
f_globaldecl:
    push rbp
    mov rbp, rsp
    sub rsp, 64          
    call f_basetype
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
.L1149:
    mov rax, 1
    test rax, rax
    jz .L1150
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
.L1151:
    mov rax, 42
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1152
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1151
.L1152:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    call f_name
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rdi, [rbp-64]
    mov rcx, 32
    mov eax, LOW
    rep stosb
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1153:
    mov rax, 91
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1154
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1155
    lea rax, [rip+.S846]
    push rax
    pop rdi
    call f_fail
.L1155:
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    mov rax, 93
    push rax
    lea rax, [rip+.S847]
    push rax
    pop rsi
    pop rdi
    call f_need
    jmp .L1153
.L1154:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_findglobal
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1156
    lea rax, [rip+.S848]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S849]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L1156:
    lea rax, [rip+g_ng]
    mov rax, [rax]
    lea rax, [rip+g_ng]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_gn]
    lea rax, [rip+g_gn]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_gn]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_gt]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    lea rax, [rbp-64]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ghas]
    lea rax, [rip+g_ghas]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_ghas]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 61
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1157
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jnz .L1158
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jnz .L1158
    xor eax, eax
    jmp .L1159
.L1158:
    mov eax, 1
.L1159:
    test rax, rax
    jz .L1160
    lea rax, [rip+.S850]
    push rax
    pop rdi
    call f_fail
.L1160:
    lea rax, [rip+g_gi]
    lea rax, [rip+g_gi]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_gi]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ghas]
    lea rax, [rip+g_ghas]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rip+g_ghas]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L1157:
    mov rax, 44
    push rax
    pop rdi
    call f_at
    test rax, rax
    jz .L1161
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1149
.L1161:
    jmp .L1150
    jmp .L1149
.L1150:
    mov rax, 59
    push rax
    lea rax, [rip+.S851]
    push rax
    pop rsi
    pop rdi
    call f_need
    xor eax, eax
.Lret_globaldecl:
    mov rsp, rbp
    pop rbp
    ret
f_program:
    push rbp
    mov rbp, rsp
    sub rsp, 16          
    lea rax, [rip+g_P]
    mov rax, [rax]
    lea rax, [rip+g_P]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1162:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rip+g_P]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1163
    lea rax, [rip+g_kthing]
    mov rax, [rax]
    push rax
    pop rdi
    call f_atk
    test rax, rax
    jz .L1164
    lea rax, [rip+g_P]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 123
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L1164
    mov eax, 1
    jmp .L1165
.L1164:
    xor eax, eax
.L1165:
    test rax, rax
    jz .L1166
    call f_thingdef
    jmp .L1162
.L1166:
    lea rax, [rip+g_P]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 8
    mov qword ptr [rcx], rax
.L1167:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 40
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1169
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 59
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1169
    mov eax, 1
    jmp .L1170
.L1169:
    xor eax, eax
.L1170:
    test rax, rax
    jz .L1171
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 61
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1171
    mov eax, 1
    jmp .L1172
.L1171:
    xor eax, eax
.L1172:
    test rax, rax
    jz .L1173
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 91
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1173
    mov eax, 1
    jmp .L1174
.L1173:
    xor eax, eax
.L1174:
    test rax, rax
    jz .L1175
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 44
    push rax
    pop rsi
    pop rdi
    call f_atop
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1175
    mov eax, 1
    jmp .L1176
.L1175:
    xor eax, eax
.L1176:
    test rax, rax
    jz .L1177
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1177
    mov eax, 1
    jmp .L1178
.L1177:
    xor eax, eax
.L1178:
    test rax, rax
    jz .L1168
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1167
.L1168:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 40
    push rax
    pop rsi
    pop rdi
    call f_atop
    test rax, rax
    jz .L1179
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rdi
    call f_function
    jmp .L1180
.L1179:
    call f_globaldecl
.L1180:
    jmp .L1162
.L1163:
    lea rax, [rip+g_kmain]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1181
    lea rax, [rip+.S852]
    push rax
    pop rdi
    call f_fail
.L1181:
    xor eax, eax
.Lret_program:
    mov rsp, rbp
    pop rbp
    ret
f_readfile:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, 2
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1182
    lea rax, [rip+g_low]
    mov rax, [rax]
    jmp .Lret_readfile
.L1182:
    mov rax, 1
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    mov rax, 1
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
.L1183:
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1185
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1185
    mov eax, 1
    jmp .L1186
.L1185:
    xor eax, eax
.L1186:
    test rax, rax
    jz .L1184
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1187
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S853]
    mov rsi, 11
    call dl_write
    mov rdi, 1457
    call dl_putd
    lea rdi, [rip+.S854]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S855]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S856]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S857]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1187:
    sub rax, rcx
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1188
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
.L1188:
    jmp .L1183
.L1184:
    mov rax, 3
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_linux
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1189
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S858]
    mov rsi, 11
    call dl_write
    mov rdi, 1459
    call dl_putd
    lea rdi, [rip+.S859]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S860]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S861]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S862]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1189:
    sub rax, rcx
    jmp .Lret_readfile
    xor eax, eax
.Lret_readfile:
    mov rsp, rbp
    pop rbp
    ret
f_writeall:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, 1
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
.L1190:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1191
    mov rax, 1
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1192
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S863]
    mov rsi, 11
    call dl_write
    mov rdi, 1464
    call dl_putd
    lea rdi, [rip+.S864]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S865]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S866]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S867]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1192:
    sub rax, rcx
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1193
    lea rax, [rip+.S868]
    push rax
    pop rdi
    call f_fail
.L1193:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L1190
.L1191:
    xor eax, eax
.Lret_writeall:
    mov rsp, rbp
    pop rbp
    ret
f_wstr:
    push rbp
    mov rbp, rsp
    sub rsp, 32          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
.L1194:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1195
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1194
.L1195:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1196
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S869]
    mov rsi, 11
    call dl_write
    mov rdi, 1466
    call dl_putd
    lea rdi, [rip+.S870]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S871]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S872]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S873]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1196:
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_writeall
    xor eax, eax
.Lret_wstr:
    mov rsp, rbp
    pop rbp
    ret
f_finish:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S874]
    push rax
    pop rsi
    pop rdi
    call f_wstr
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_rt]
    push rax
    lea rax, [rip+g_rtn]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_writeall
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S875]
    push rax
    pop rsi
    pop rdi
    call f_wstr
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_out]
    push rax
    lea rax, [rip+g_outn]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1197
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S876]
    mov rsi, 11
    call dl_write
    mov rdi, 1473
    call dl_putd
    lea rdi, [rip+.S877]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S878]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S879]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S880]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1197:
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_writeall
    lea rax, [rip+g_outn]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 16
    mov qword ptr [rcx], rax
    lea rax, [rip+.S881]
    push rax
    pop rdi
    call f_es
    lea rdi, [rbp-24]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rdi, [rbp-32]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1198:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1200
    lea rax, [rip+g_ghas]
    lea rax, [rip+g_ghas]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    test rax, rax
    jz .L1201
    lea rax, [rip+.S882]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_gn]
    lea rax, [rip+g_gn]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    lea rax, [rip+.S883]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_gi]
    lea rax, [rip+g_gi]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    mov rax, 10
    push rax
    pop rdi
    call f_ec
.L1201:
.L1199:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1198
.L1200:
    lea rax, [rip+.S884]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1202:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ng]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1204
    lea rax, [rip+g_ghas]
    lea rax, [rip+g_ghas]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1205
    lea rax, [rip+.S885]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_gn]
    lea rax, [rip+g_gn]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_en
    lea rax, [rip+.S886]
    push rax
    pop rdi
    call f_es
    lea rax, [rip+g_gt]
    lea rax, [rip+g_gt]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    pop rdi
    call f_size
    push rax
    mov rax, 7
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L1206
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S887]
    mov rsi, 11
    call dl_write
    mov rdi, 1479
    call dl_putd
    lea rdi, [rip+.S888]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S889]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1206:
    cqo
    idiv rcx
    push rax
    mov rax, 8
    mov rcx, rax
    pop rax
    imul rax, rcx
    push rax
    pop rdi
    call f_ed
    mov rax, 10
    push rax
    pop rdi
    call f_ec
.L1205:
.L1203:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1202
.L1204:
    lea rax, [rip+.S890]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1207:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_nstr]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1209
    lea rax, [rip+.S891]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
    lea rax, [rip+.S892]
    push rax
    pop rdi
    call f_es
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1210:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_sl]
    lea rax, [rip+g_sl]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1212
    lea rax, [rip+g_pool]
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rip+g_sp]
    lea rax, [rip+g_sp]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1213
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S893]
    mov rsi, 11
    call dl_write
    mov rdi, 1484
    call dl_putd
    lea rdi, [rip+.S894]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S895]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S896]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S897]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1213:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1214
    lea rax, [rip+.S898]
    push rax
    pop rdi
    call f_es
    jmp .L1215
.L1214:
    lea rax, [rbp-40]
    mov rax, [rax]
    push rax
    pop rdi
    call f_ed
.L1215:
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_sl]
    lea rax, [rip+g_sl]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1216
    lea rax, [rip+.S899]
    push rax
    pop rdi
    call f_es
.L1216:
.L1211:
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1210
.L1212:
    lea rax, [rip+g_sl]
    lea rax, [rip+g_sl]
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1217
    lea rax, [rip+.S900]
    push rax
    pop rdi
    call f_es
.L1217:
    mov rax, 10
    push rax
    pop rdi
    call f_ec
.L1208:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1207
.L1209:
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_out]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_outn]
    mov rax, [rax]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1218
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S901]
    mov rsi, 11
    call dl_write
    mov rdi, 1491
    call dl_putd
    lea rdi, [rip+.S902]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S903]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S904]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S905]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1218:
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_writeall
    xor eax, eax
.Lret_finish:
    mov rsp, rbp
    pop rbp
    ret
f_run:
    push rbp
    mov rbp, rsp
    sub rsp, 128         
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    lea rdi, [rbp-112]
    mov rcx, 64
    mov eax, LOW
    rep stosb
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 4
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 4
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 5
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 5
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 6
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 6
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-112]
    lea rax, [rbp-112]
    push rax
    mov rax, 7
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-112]
    push rax
    mov rax, 7
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 57
    push rax
    pop rdi
    call f_linux
    mov rcx, rbp
    sub rcx, 120
    mov qword ptr [rcx], rax
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1219
    mov rax, 59
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-112]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
    mov rax, 3
    push rax
    pop rdi
    call f_stop
.L1219:
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 128
    mov qword ptr [rcx], rax
    mov rax, 61
    push rax
    lea rax, [rbp-120]
    mov rax, [rax]
    push rax
    lea rax, [rbp-128]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
    lea rax, [rbp-128]
    mov rax, [rax]
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L1220
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S906]
    mov rsi, 11
    call dl_write
    mov rdi, 1502
    call dl_putd
    lea rdi, [rip+.S907]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S908]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1220:
    cqo
    idiv rcx
    push rax
    mov rax, 256
    mov rcx, rax
    pop rax
    test rcx, rcx
    jnz .L1221
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S909]
    mov rsi, 11
    call dl_write
    mov rdi, 1502
    call dl_putd
    lea rdi, [rip+.S910]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S911]
    mov rsi, 60
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1221:
    cqo
    idiv rcx
    mov rax, rdx
    jmp .Lret_run
    xor eax, eax
.Lret_run:
    mov rsp, rbp
    pop rbp
    ret
f_join:
    push rbp
    mov rbp, rsp
    sub rsp, 48          
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, 1
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    mov rax, 1
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
.L1222:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1223
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1222
.L1223:
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1224:
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1225
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-24]
    mov rax, [rax]
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rbp-32]
    mov rax, [rax]
    lea rax, [rbp-32]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1224
.L1225:
    lea rax, [rbp-8]
    mov rax, [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    xor eax, eax
.Lret_join:
    mov rsp, rbp
    pop rbp
    ret
f_lexlib:
    push rbp
    mov rbp, rsp
    sub rsp, 1680        
    mov [rbp-8], rdi
    lea rdi, [rbp-1656]
    mov rcx, 1648
    mov eax, LOW
    rep stosb
    lea rax, [rbp-1656]
    push rax
    lea rax, [rip+g_here]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    add rax, rcx
    mov rcx, rbp
    sub rcx, 1664
    mov qword ptr [rcx], rax
    lea rax, [rbp-1656]
    push rax
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    mov rax, 3620105
    push rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1226
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S912]
    mov rsi, 11
    call dl_write
    mov rdi, 1513
    call dl_putd
    lea rdi, [rip+.S913]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S914]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S915]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S916]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1226:
    sub rax, rcx
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_readfile
    mov rcx, rbp
    sub rcx, 1672
    mov qword ptr [rcx], rax
    lea rax, [rbp-1672]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1227
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S917]
    mov rsi, 16
    call dl_write
    lea rax, [rbp-1656]
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S918]
    mov rsi, 1
    call dl_write
    mov rax, 2
    push rax
    pop rdi
    call f_stop
.L1227:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    push rax
    lea rax, [rbp-1672]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    push rax
    lea rax, [rbp-1672]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    push rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    push rax
    lea rax, [rbp-1672]
    mov rax, [rax]
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1228
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S919]
    mov rsi, 11
    call dl_write
    mov rdi, 1517
    call dl_putd
    lea rdi, [rip+.S920]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S921]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S922]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S923]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1228:
    sub rax, rcx
    mov rcx, rax
    pop rax
    add rax, rcx
    push rax
    pop rsi
    pop rdi
    call f_lexrange
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    lea rax, [rip+g_srcn]
    push rax
    lea rax, [rbp-1664]
    mov rax, [rax]
    push rax
    lea rax, [rbp-1672]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    add rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    xor eax, eax
.Lret_lexlib:
    mov rsp, rbp
    pop rbp
    ret
f_main:
    push rbp
    mov rbp, rsp
    sub rsp, 19904       
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rip+g_low]
    mov rax, [rax]
    lea rax, [rip+g_low]
    push rax
    mov rax, 1
    push rax
    mov rax, 1
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1229
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S924]
    mov rsi, 11
    call dl_write
    mov rdi, 1523
    call dl_putd
    lea rdi, [rip+.S925]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S926]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S927]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S928]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1229:
    sub rax, rcx
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_digs]
    mov rax, [rax]
    lea rax, [rip+g_digs]
    push rax
    lea rax, [rip+.S929]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kint]
    mov rax, [rax]
    lea rax, [rip+g_kint]
    push rax
    lea rax, [rip+.S930]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kchar]
    mov rax, [rax]
    lea rax, [rip+g_kchar]
    push rax
    lea rax, [rip+.S931]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_klong]
    mov rax, [rax]
    lea rax, [rip+g_klong]
    push rax
    lea rax, [rip+.S932]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kvoid]
    mov rax, [rax]
    lea rax, [rip+g_kvoid]
    push rax
    lea rax, [rip+.S933]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kunsigned]
    mov rax, [rax]
    lea rax, [rip+g_kunsigned]
    push rax
    lea rax, [rip+.S934]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ksigned]
    mov rax, [rax]
    lea rax, [rip+g_ksigned]
    push rax
    lea rax, [rip+.S935]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kconst]
    mov rax, [rax]
    lea rax, [rip+g_kconst]
    push rax
    lea rax, [rip+.S936]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kstatic]
    mov rax, [rax]
    lea rax, [rip+g_kstatic]
    push rax
    lea rax, [rip+.S937]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kif]
    mov rax, [rax]
    lea rax, [rip+g_kif]
    push rax
    lea rax, [rip+.S938]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kelse]
    mov rax, [rax]
    lea rax, [rip+g_kelse]
    push rax
    lea rax, [rip+.S939]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kwhile]
    mov rax, [rax]
    lea rax, [rip+g_kwhile]
    push rax
    lea rax, [rip+.S940]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kfor]
    mov rax, [rax]
    lea rax, [rip+g_kfor]
    push rax
    lea rax, [rip+.S941]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kreturn]
    mov rax, [rax]
    lea rax, [rip+g_kreturn]
    push rax
    lea rax, [rip+.S942]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kbreak]
    mov rax, [rax]
    lea rax, [rip+g_kbreak]
    push rax
    lea rax, [rip+.S943]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kcontinue]
    mov rax, [rax]
    lea rax, [rip+g_kcontinue]
    push rax
    lea rax, [rip+.S944]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kmove]
    mov rax, [rax]
    lea rax, [rip+g_kmove]
    push rax
    lea rax, [rip+.S945]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kfrom]
    mov rax, [rax]
    lea rax, [rip+g_kfrom]
    push rax
    lea rax, [rip+.S946]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kto]
    mov rax, [rax]
    lea rax, [rip+g_kto]
    push rax
    lea rax, [rip+.S947]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kand]
    mov rax, [rax]
    lea rax, [rip+g_kand]
    push rax
    lea rax, [rip+.S948]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ksay]
    mov rax, [rax]
    lea rax, [rip+g_ksay]
    push rax
    lea rax, [rip+.S949]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kless]
    mov rax, [rax]
    lea rax, [rip+g_kless]
    push rax
    lea rax, [rip+.S950]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kapart]
    mov rax, [rax]
    lea rax, [rip+g_kapart]
    push rax
    lea rax, [rip+.S951]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_klower]
    mov rax, [rax]
    lea rax, [rip+g_klower]
    push rax
    lea rax, [rip+.S952]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_khigher]
    mov rax, [rax]
    lea rax, [rip+g_khigher]
    push rax
    lea rax, [rip+.S953]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ktowards]
    mov rax, [rax]
    lea rax, [rip+g_ktowards]
    push rax
    lea rax, [rip+.S954]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kcopy]
    mov rax, [rax]
    lea rax, [rip+g_kcopy]
    push rax
    lea rax, [rip+.S955]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kmain]
    mov rax, [rax]
    lea rax, [rip+g_kmain]
    push rax
    lea rax, [rip+.S956]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kdefine]
    mov rax, [rax]
    lea rax, [rip+g_kdefine]
    push rax
    lea rax, [rip+.S957]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kinclude]
    mov rax, [rax]
    lea rax, [rip+g_kinclude]
    push rax
    lea rax, [rip+.S958]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kthing]
    mov rax, [rax]
    lea rax, [rip+g_kthing]
    push rax
    lea rax, [rip+.S959]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kvessel]
    mov rax, [rax]
    lea rax, [rip+g_kvessel]
    push rax
    lea rax, [rip+.S960]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_klinux]
    mov rax, [rax]
    lea rax, [rip+g_klinux]
    push rax
    lea rax, [rip+.S961]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kwait]
    mov rax, [rax]
    lea rax, [rip+g_kwait]
    push rax
    lea rax, [rip+.S962]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kstop]
    mov rax, [rax]
    lea rax, [rip+g_kstop]
    push rax
    lea rax, [rip+.S963]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kwide]
    mov rax, [rax]
    lea rax, [rip+g_kwide]
    push rax
    lea rax, [rip+.S964]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_khigh]
    mov rax, [rax]
    lea rax, [rip+g_khigh]
    push rax
    lea rax, [rip+.S965]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kfits]
    mov rax, [rax]
    lea rax, [rip+g_kfits]
    push rax
    lea rax, [rip+.S966]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kshrug]
    mov rax, [rax]
    lea rax, [rip+g_kshrug]
    push rax
    lea rax, [rip+.S967]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kself]
    mov rax, [rax]
    lea rax, [rip+g_kself]
    push rax
    lea rax, [rip+.S968]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ktilde]
    mov rax, [rax]
    lea rax, [rip+g_ktilde]
    push rax
    lea rax, [rip+.S969]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kstore]
    mov rax, [rax]
    lea rax, [rip+g_kstore]
    push rax
    lea rax, [rip+.S970]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kconduct]
    mov rax, [rax]
    lea rax, [rip+g_kconduct]
    push rax
    lea rax, [rip+.S971]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kneighbours]
    mov rax, [rax]
    lea rax, [rip+g_kneighbours]
    push rax
    lea rax, [rip+.S972]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kspend]
    mov rax, [rax]
    lea rax, [rip+g_kspend]
    push rax
    lea rax, [rip+.S973]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_ktick]
    mov rax, [rax]
    lea rax, [rip+g_ktick]
    push rax
    lea rax, [rip+.S974]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kwear]
    mov rax, [rax]
    lea rax, [rip+g_kwear]
    push rax
    lea rax, [rip+.S975]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kmix]
    mov rax, [rax]
    lea rax, [rip+g_kmix]
    push rax
    lea rax, [rip+.S976]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kquiet]
    mov rax, [rax]
    lea rax, [rip+g_kquiet]
    push rax
    lea rax, [rip+.S977]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kleak]
    mov rax, [rax]
    lea rax, [rip+g_kleak]
    push rax
    lea rax, [rip+.S978]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kloss]
    mov rax, [rax]
    lea rax, [rip+g_kloss]
    push rax
    lea rax, [rip+.S979]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kper]
    mov rax, [rax]
    lea rax, [rip+g_kper]
    push rax
    lea rax, [rip+.S980]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kby]
    mov rax, [rax]
    lea rax, [rip+g_kby]
    push rax
    lea rax, [rip+.S981]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_kheat]
    mov rax, [rax]
    lea rax, [rip+g_kheat]
    push rax
    lea rax, [rip+.S982]
    push rax
    pop rdi
    call f_word
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_INT]
    mov rax, [rax]
    lea rax, [rip+g_INT]
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_CHARP]
    mov rax, [rax]
    lea rax, [rip+g_CHARP]
    push rax
    mov rax, 2
    push rax
    mov rax, 1
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_mkty
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 3
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1230
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S983]
    mov rsi, 112
    call dl_write
    mov rax, 2
    jmp .Lret_main
.L1230:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 2
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 24
    mov qword ptr [rcx], rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 3
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 32
    mov qword ptr [rcx], rax
    mov rax, 1
    mov rcx, rbp
    sub rcx, 40
    mov qword ptr [rcx], rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 48
    mov qword ptr [rcx], rax
.L1231:
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1232
    lea rax, [rip+g_here]
    lea rax, [rip+g_here]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_here]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 47
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1233
    lea rax, [rbp-48]
    mov rax, [rax]
    lea rax, [rbp-48]
    push rax
    lea rax, [rbp-40]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1233:
    lea rax, [rbp-40]
    mov rax, [rax]
    lea rax, [rbp-40]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1231
.L1232:
    lea rax, [rip+g_here]
    lea rax, [rip+g_here]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_here]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1234
    lea rax, [rip+g_here]
    push rax
    lea rax, [rip+.S984]
    push rax
    lea rax, [rip+.S985]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
.L1234:
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    lea rax, [rip+g_srcn]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_src]
    push rax
    mov rax, 3620105
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_readfile
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1235
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S986]
    mov rsi, 16
    call dl_write
    lea rax, [rbp-32]
    mov rax, [rax]
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S987]
    mov rsi, 1
    call dl_write
    mov rax, 2
    jmp .Lret_main
.L1235:
    lea rax, [rip+g_src]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_src]
    push rax
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    add rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
    mov rax, 1
    push rax
    lea rax, [rip+g_srcn]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_lexrange
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 56
    mov qword ptr [rcx], rax
    lea rdi, [rbp-64]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1236:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    lea rax, [rbp-56]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1238
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1239
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 72
    mov qword ptr [rcx], rax
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isflowword
    test rax, rax
    jz .L1240
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    lea rax, [rip+g_usesflow]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1240:
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kvessel]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1241
    lea rax, [rip+g_usesvessel]
    mov rax, [rax]
    lea rax, [rip+g_usesvessel]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1241:
    lea rax, [rbp-72]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfits]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1242
    lea rax, [rip+g_usesroom]
    mov rax, [rax]
    lea rax, [rip+g_usesroom]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1242:
    lea rax, [rip+g_pool]
    push rax
    lea rax, [rbp-72]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+.S988]
    push rax
    pop rsi
    pop rdi
    call f_starts
    test rax, rax
    jz .L1243
    lea rax, [rip+g_useswindow]
    mov rax, [rax]
    lea rax, [rip+g_useswindow]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1243:
.L1239:
.L1237:
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1236
.L1238:
    lea rax, [rip+g_usesvessel]
    mov rax, [rax]
    test rax, rax
    jnz .L1244
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    test rax, rax
    jnz .L1244
    xor eax, eax
    jmp .L1245
.L1244:
    mov eax, 1
.L1245:
    test rax, rax
    jz .L1246
    lea rax, [rip+g_usesroom]
    mov rax, [rax]
    lea rax, [rip+g_usesroom]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1246:
    lea rax, [rip+g_usesroom]
    mov rax, [rax]
    test rax, rax
    jz .L1247
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    lea rax, [rip+g_usesflow]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1247:
    lea rax, [rip+g_useswindow]
    mov rax, [rax]
    test rax, rax
    jz .L1248
    lea rax, [rip+.S989]
    push rax
    pop rdi
    call f_lexlib
.L1248:
    lea rax, [rip+g_usesroom]
    mov rax, [rax]
    test rax, rax
    jz .L1249
    lea rax, [rip+.S990]
    push rax
    pop rdi
    call f_lexlib
.L1249:
    lea rax, [rip+g_usesflow]
    mov rax, [rax]
    test rax, rax
    jz .L1250
    lea rax, [rip+.S991]
    push rax
    pop rdi
    call f_lexlib
.L1250:
    lea rax, [rip+g_usesvessel]
    mov rax, [rax]
    test rax, rax
    jz .L1251
    lea rax, [rip+.S992]
    push rax
    pop rdi
    call f_lexlib
.L1251:
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_tl]
    lea rax, [rip+g_tl]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 5
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_addtok
    lea rax, [rip+g_low]
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 80
    mov qword ptr [rcx], rax
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1252:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ntok]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1254
    lea rax, [rip+g_tv]
    lea rax, [rip+g_tv]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 88
    mov qword ptr [rcx], rax
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1255
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    pop rdi
    call f_isflowword
    test rax, rax
    jnz .L1257
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kvessel]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L1257
    xor eax, eax
    jmp .L1258
.L1257:
    mov eax, 1
.L1258:
    test rax, rax
    jnz .L1259
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kfits]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jnz .L1259
    xor eax, eax
    jmp .L1260
.L1259:
    mov eax, 1
.L1260:
    test rax, rax
    jz .L1255
    mov eax, 1
    jmp .L1256
.L1255:
    xor eax, eax
.L1256:
    test rax, rax
    jz .L1261
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L1262
.L1261:
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 4
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1263
    lea rax, [rbp-88]
    mov rax, [rax]
    push rax
    mov rax, 59
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1263
    mov eax, 1
    jmp .L1264
.L1263:
    xor eax, eax
.L1264:
    test rax, rax
    jz .L1265
    lea rax, [rbp-80]
    mov rax, [rax]
    lea rax, [rbp-80]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L1266
.L1265:
    lea rax, [rbp-80]
    mov rax, [rax]
    test rax, rax
    jz .L1267
    lea rax, [rip+g_tk]
    lea rax, [rip+g_tk]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    mov rax, 2
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1267
    mov eax, 1
    jmp .L1268
.L1267:
    xor eax, eax
.L1268:
    test rax, rax
    jz .L1269
    lea rax, [rip+g_flowname]
    lea rax, [rip+g_flowname]
    push rax
    lea rax, [rbp-88]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rip+g_flowname]
    push rax
    lea rax, [rbp-88]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    push rax
    mov rax, 1
    pop rcx
    mov byte ptr [rcx], al
.L1269:
.L1266:
.L1262:
.L1253:
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1252
.L1254:
    call f_program
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    push rax
    mov rax, 1
    pop rcx
    mov qword ptr [rcx], rax
.L1270:
    lea rax, [rbp-64]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_ncall]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1272
    lea rax, [rip+g_cnm]
    lea rax, [rip+g_cnm]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    mov rcx, rbp
    sub rcx, 96
    mov qword ptr [rcx], rax
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_findfn
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1273
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_klinux]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1273
    mov eax, 1
    jmp .L1274
.L1273:
    xor eax, eax
.L1274:
    test rax, rax
    jz .L1275
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kwait]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1275
    mov eax, 1
    jmp .L1276
.L1275:
    xor eax, eax
.L1276:
    test rax, rax
    jz .L1277
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kstop]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1277
    mov eax, 1
    jmp .L1278
.L1277:
    xor eax, eax
.L1278:
    test rax, rax
    jz .L1279
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_kwide]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1279
    mov eax, 1
    jmp .L1280
.L1279:
    xor eax, eax
.L1280:
    test rax, rax
    jz .L1281
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+g_khigh]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setne al
    movzx eax, al
    test rax, rax
    jz .L1281
    mov eax, 1
    jmp .L1282
.L1281:
    xor eax, eax
.L1282:
    test rax, rax
    jz .L1283
    lea rax, [rip+g_line]
    mov rax, [rax]
    lea rax, [rip+g_line]
    push rax
    lea rax, [rip+g_cline]
    lea rax, [rip+g_cline]
    push rax
    lea rax, [rbp-64]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+.S993]
    push rax
    lea rax, [rbp-96]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S994]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_failname
.L1283:
.L1271:
    lea rax, [rbp-64]
    mov rax, [rax]
    lea rax, [rbp-64]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1270
.L1272:
    lea rdi, [rbp-1744]
    mov rcx, 1648
    mov eax, LOW
    rep stosb
    lea rax, [rbp-1744]
    push rax
    lea rax, [rip+g_here]
    push rax
    lea rax, [rip+.S995]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
    lea rax, [rip+g_rtn]
    mov rax, [rax]
    lea rax, [rip+g_rtn]
    push rax
    lea rax, [rbp-1744]
    push rax
    lea rax, [rip+g_rt]
    push rax
    mov rax, 3620105
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_readfile
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rip+g_rtn]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1284
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S996]
    mov rsi, 28
    call dl_write
    lea rax, [rbp-1744]
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S997]
    mov rsi, 1
    call dl_write
    mov rax, 2
    jmp .Lret_main
.L1284:
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S998]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jz .L1285
    mov rax, 1
    push rax
    pop rdi
    call f_finish
    mov rax, 1
    jmp .Lret_main
.L1285:
    lea rdi, [rbp-3392]
    mov rcx, 1648
    mov eax, LOW
    rep stosb
    lea rdi, [rbp-5040]
    mov rcx, 1648
    mov eax, LOW
    rep stosb
    lea rdi, [rbp-6688]
    mov rcx, 1648
    mov eax, LOW
    rep stosb
    mov rax, 4
    mov rcx, rbp
    sub rcx, 6696
    mov qword ptr [rcx], rax
    lea rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 5
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1286
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 4
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S999]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jz .L1286
    mov eax, 1
    jmp .L1287
.L1286:
    xor eax, eax
.L1287:
    test rax, rax
    jz .L1288
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 5
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    push rax
    lea rax, [rip+.S1000]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
    lea rax, [rbp-6696]
    mov rax, [rax]
    lea rax, [rbp-6696]
    push rax
    mov rax, 6
    pop rcx
    mov qword ptr [rcx], rax
    jmp .L1289
.L1288:
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-32]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S1001]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
    mov rax, 1
    mov rcx, rbp
    sub rcx, 6704
    mov qword ptr [rcx], rax
.L1290:
    lea rax, [rbp-3392]
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-6704]
    mov rax, [rax]
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1291
    lea rax, [rbp-6704]
    mov rax, [rax]
    lea rax, [rbp-6704]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1290
.L1291:
    lea rax, [rbp-6704]
    mov rax, [rax]
    push rax
    mov rax, 6
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setg al
    movzx eax, al
    test rax, rax
    jz .L1292
    lea rax, [rbp-3392]
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-6704]
    mov rax, [rax]
    push rax
    mov rax, 6
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1294
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S1002]
    mov rsi, 11
    call dl_write
    mov rdi, 1597
    call dl_putd
    lea rdi, [rip+.S1003]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S1004]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1005]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1006]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1294:
    sub rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 46
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1292
    mov eax, 1
    jmp .L1293
.L1292:
    xor eax, eax
.L1293:
    test rax, rax
    jz .L1295
    lea rax, [rbp-3392]
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-6704]
    mov rax, [rax]
    push rax
    mov rax, 5
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1297
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S1007]
    mov rsi, 11
    call dl_write
    mov rdi, 1597
    call dl_putd
    lea rdi, [rip+.S1008]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S1009]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1010]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1011]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1297:
    sub rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    push rax
    mov rax, 100
    mov rcx, rax
    pop rax
    cmp rax, rcx
    sete al
    movzx eax, al
    test rax, rax
    jz .L1295
    mov eax, 1
    jmp .L1296
.L1295:
    xor eax, eax
.L1296:
    test rax, rax
    jz .L1298
    lea rax, [rbp-3392]
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-6704]
    mov rax, [rax]
    push rax
    mov rax, 6
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1299
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S1012]
    mov rsi, 11
    call dl_write
    mov rdi, 1597
    call dl_putd
    lea rdi, [rip+.S1013]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S1014]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1015]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1016]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1299:
    sub rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    movzx eax, byte ptr [rax]
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-6704]
    mov rax, [rax]
    push rax
    mov rax, 6
    push rax
    pop rcx
    pop rax
    cmp rcx, rax
    jle .L1300
    push rax
    push rcx
    mov qword ptr [rip+dl_fd], 2
    lea rdi, [rip+.S1017]
    mov rsi, 11
    call dl_write
    mov rdi, 1597
    call dl_putd
    lea rdi, [rip+.S1018]
    mov rsi, 2
    call dl_write
    lea rdi, [rip+.S1019]
    mov rsi, 12
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1020]
    mov rsi, 26
    call dl_write
    pop rdi
    call dl_putd
    lea rdi, [rip+.S1021]
    mov rsi, 1
    call dl_write
    mov edi, 2
    jmp dl_exit
.L1300:
    sub rax, rcx
    dec rax
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov byte ptr [rcx], al
.L1298:
.L1289:
    lea rax, [rbp-5040]
    push rax
    lea rax, [rbp-3392]
    push rax
    lea rax, [rip+.S1022]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
    lea rax, [rbp-6688]
    push rax
    lea rax, [rbp-3392]
    push rax
    lea rax, [rip+.S1023]
    push rax
    pop rdx
    pop rsi
    pop rdi
    call f_join
    mov rax, 2
    push rax
    lea rax, [rbp-5040]
    push rax
    mov rax, 577
    push rax
    mov rax, 420
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
    mov rcx, rbp
    sub rcx, 6712
    mov qword ptr [rcx], rax
    lea rax, [rbp-6712]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setl al
    movzx eax, al
    test rax, rax
    jz .L1301
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S1024]
    mov rsi, 17
    call dl_write
    lea rax, [rbp-5040]
    mov rdi, rax
    call dl_puts
    lea rdi, [rip+.S1025]
    mov rsi, 1
    call dl_write
    mov rax, 2
    jmp .Lret_main
.L1301:
    lea rax, [rbp-6712]
    mov rax, [rax]
    push rax
    pop rdi
    call f_finish
    mov rax, 3
    push rax
    lea rax, [rbp-6712]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdi
    call f_linux
    lea rax, [rip+.S1026]
    push rax
    lea rax, [rip+.S1027]
    push rax
    lea rax, [rbp-5040]
    push rax
    lea rax, [rip+.S1028]
    push rax
    lea rax, [rbp-6688]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_run
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1302
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S1029]
    mov rsi, 47
    call dl_write
    mov rax, 3
    jmp .Lret_main
.L1302:
    lea rax, [rip+.S1030]
    push rax
    lea rax, [rip+.S1031]
    push rax
    lea rax, [rip+.S1032]
    push rax
    lea rax, [rbp-6688]
    push rax
    lea rax, [rip+.S1033]
    push rax
    lea rax, [rbp-3392]
    push rax
    pop r9
    pop r8
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_run
    push rax
    mov rax, 1
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setge al
    movzx eax, al
    test rax, rax
    jz .L1303
    mov qword ptr [rip+dl_fd], 1
    lea rdi, [rip+.S1034]
    mov rsi, 42
    call dl_write
    mov rax, 3
    jmp .Lret_main
.L1303:
    mov rax, 87
    push rax
    lea rax, [rbp-5040]
    push rax
    pop rsi
    pop rdi
    call f_linux
    mov rax, 87
    push rax
    lea rax, [rbp-6688]
    push rax
    pop rsi
    pop rdi
    call f_linux
    lea rax, [rbp-24]
    mov rax, [rax]
    push rax
    lea rax, [rip+.S1035]
    push rax
    pop rsi
    pop rdi
    call f_same
    test rax, rax
    jz .L1304
    lea rdi, [rbp-19888]
    mov rcx, 13176
    mov eax, LOW
    rep stosb
    lea rax, [rbp-19888]
    lea rax, [rbp-19888]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-19888]
    push rax
    mov rax, 1
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-3392]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 2
    mov rcx, rbp
    sub rcx, 19896
    mov qword ptr [rcx], rax
    lea rdi, [rbp-19904]
    mov rcx, 8
    mov eax, LOW
    rep stosb
    lea rax, [rbp-19904]
    mov rax, [rax]
    lea rax, [rbp-19904]
    push rax
    lea rax, [rbp-6696]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
.L1305:
    lea rax, [rbp-19904]
    mov rax, [rax]
    push rax
    lea rax, [rbp-8]
    mov rax, [rax]
    mov rcx, rax
    pop rax
    cmp rax, rcx
    setle al
    movzx eax, al
    test rax, rax
    jz .L1307
    lea rax, [rbp-19888]
    lea rax, [rbp-19888]
    push rax
    lea rax, [rbp-19896]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-19888]
    push rax
    lea rax, [rbp-19896]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rbp-16]
    mov rax, [rax]
    lea rax, [rbp-16]
    mov rax, [rax]
    push rax
    lea rax, [rbp-19904]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    lea rax, [rbp-19896]
    mov rax, [rax]
    lea rax, [rbp-19896]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
.L1306:
    lea rax, [rbp-19904]
    mov rax, [rax]
    lea rax, [rbp-19904]
    mov rcx, rax
    mov rax, [rcx]
    inc qword ptr [rcx]
    jmp .L1305
.L1307:
    lea rax, [rbp-19888]
    lea rax, [rbp-19888]
    push rax
    lea rax, [rbp-19896]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    mov rax, [rax]
    lea rax, [rbp-19888]
    push rax
    lea rax, [rbp-19896]
    mov rax, [rax]
    dec rax
    imul rax, 8
    pop rcx
    add rax, rcx
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    pop rcx
    mov qword ptr [rcx], rax
    mov rax, 59
    push rax
    lea rax, [rbp-3392]
    push rax
    lea rax, [rbp-19888]
    push rax
    lea rax, [rip+g_low]
    mov rax, [rax]
    push rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    call f_linux
.L1304:
    mov rax, 1
    jmp .Lret_main
    mov eax, 1
.Lret_main:
    mov rsp, rbp
    pop rbp
    ret

.data
g_pooln: .quad 1
g_outn: .quad 1
g_line: .quad 1
g_labn: .quad 1
.bss
g_src: .skip 3620112
g_srcn: .skip 8
g_pool: .skip 3620112
g_hh: .skip 32776
g_hnext: .skip 2227752
g_hname: .skip 2227752
g_nnames: .skip 8
g_tk: .skip 5198096
g_tv: .skip 5198096
g_tl: .skip 5198096
g_tn: .skip 5198096
g_ntok: .skip 8
g_nsyn: .skip 8
g_out: .skip 47061392
g_low: .skip 8
g_digs: .skip 8
g_defname: .skip 171360
g_defs: .skip 171360
g_defe: .skip 171360
g_ndef: .skip 8
g_tyb: .skip 171360
g_tys: .skip 171360
g_tynd: .skip 171360
g_tyd1: .skip 171360
g_tyd2: .skip 171360
g_tyd3: .skip 171360
g_nty: .skip 8
g_INT: .skip 8
g_CHARP: .skip 8
g_thn: .skip 13176
g_thsize: .skip 13176
g_thtilde: .skip 13176
g_nth: .skip 8
g_fdowner: .skip 171360
g_fdname: .skip 171360
g_fdtype: .skip 171360
g_fdoff: .skip 171360
g_nfd: .skip 8
g_gn: .skip 2227752
g_gt: .skip 2227752
g_gi: .skip 2227752
g_ghas: .skip 2227752
g_ng: .skip 8
g_fnm: .skip 2227752
g_fown: .skip 2227752
g_frt: .skip 2227752
g_nf: .skip 8
g_ln: .skip 2227752
g_lt: .skip 2227752
g_lo: .skip 2227752
g_nloc: .skip 8
g_sc: .skip 171360
g_nsc: .skip 8
g_cnm: .skip 2227752
g_cline: .skip 2227752
g_ncall: .skip 8
g_sp: .skip 2227752
g_sl: .skip 2227752
g_nstr: .skip 8
g_brk: .skip 171360
g_cont: .skip 171360
g_nloop: .skip 8
g_P: .skip 8
g_curfn: .skip 8
g_curown: .skip 8
g_curdl: .skip 8
g_frame: .skip 8
g_lastfoff: .skip 8
g_lasttoff: .skip 8
g_haslast: .skip 8
g_usesflow: .skip 8
g_usesvessel: .skip 8
g_usesroom: .skip 8
g_useswindow: .skip 8
g_flowname: .skip 3620112
g_kint: .skip 8
g_kchar: .skip 8
g_klong: .skip 8
g_kvoid: .skip 8
g_kunsigned: .skip 8
g_ksigned: .skip 8
g_kconst: .skip 8
g_kstatic: .skip 8
g_kif: .skip 8
g_kelse: .skip 8
g_kwhile: .skip 8
g_kfor: .skip 8
g_kreturn: .skip 8
g_kbreak: .skip 8
g_kcontinue: .skip 8
g_kmove: .skip 8
g_kfrom: .skip 8
g_kto: .skip 8
g_kand: .skip 8
g_ksay: .skip 8
g_kless: .skip 8
g_kapart: .skip 8
g_klower: .skip 8
g_khigher: .skip 8
g_ktowards: .skip 8
g_kcopy: .skip 8
g_kmain: .skip 8
g_kdefine: .skip 8
g_kinclude: .skip 8
g_kthing: .skip 8
g_kvessel: .skip 8
g_klinux: .skip 8
g_kwait: .skip 8
g_kstop: .skip 8
g_kwide: .skip 8
g_khigh: .skip 8
g_kfits: .skip 8
g_kshrug: .skip 8
g_kself: .skip 8
g_ktilde: .skip 8
g_kstore: .skip 8
g_kconduct: .skip 8
g_kneighbours: .skip 8
g_kspend: .skip 8
g_ktick: .skip 8
g_kwear: .skip 8
g_kmix: .skip 8
g_kquiet: .skip 8
g_kleak: .skip 8
g_kloss: .skip 8
g_kper: .skip 8
g_kby: .skip 8
g_kheat: .skip 8
g_ivals: .skip 2227752
g_inum: .skip 2227752
g_nival: .skip 8
g_rt: .skip 3620112
g_rtn: .skip 8
g_here: .skip 1648

.section .rodata
.S1: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S2: .byte 58, 32
.S3: .byte 10
.S4: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S5: .byte 58, 32
.S6: .byte 10
.S7: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S8: .byte 58, 32
.S9: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S10: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S11: .byte 58, 32
.S12: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S13: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S14: .byte 10
.S15: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S16: .byte 58, 32
.S17: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S18: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S19: .byte 10
.S20: .byte 116, 104, 97, 116, 32, 105, 115, 32, 116, 104, 101, 32, 122, 101, 114, 111, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114, 32, 111, 114, 32, 110, 111, 116, 32, 107, 110, 111, 119, 110, LOW
.S21: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S22: .byte 58, 32
.S23: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S24: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S25: .byte 10
.S26: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S27: .byte 58, 32
.S28: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S29: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S30: .byte 10
.S31: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S32: .byte 58, 32
.S33: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S34: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S35: .byte 10
.S36: .byte 116, 104, 97, 116, 32, 35, 32, 119, 111, 114, 100, 32, 105, 115, 32, 110, 111, 116, 32, 107, 110, 111, 119, 110, LOW
.S37: .byte 119, 111, 114, 100, 115, 32, 105, 110, 32, 113, 117, 111, 116, 101, 115, 32, 110, 101, 101, 100, 32, 116, 104, 101, 105, 114, 32, 99, 108, 111, 115, 105, 110, 103, 32, 113, 117, 111, 116, 101, LOW
.S38: .byte 116, 104, 97, 116, 32, 105, 115, 32, 110, 111, 116, 32, 111, 110, 101, 32, 99, 104, 97, 114, 97, 99, 116, 101, 114, LOW
.S39: .byte 122, 101, 114, 111, 32, 97, 112, 112, 108, 101, 115, 63, 32, 84, 104, 101, 114, 101, 32, 97, 114, 101, 32, 110, 101, 118, 101, 114, 32, 122, 101, 114, 111, 32, 97, 112, 112, 108, 101, 115, 46, 32, 84, 104, 101, 32, 115, 101, 101, 100, 115, 44, 32, 119, 97, 116, 101, 114, 44, 32, 115, 117, 110, 108, 105, 103, 104, 116, 32, 97, 110, 100, 32, 116, 104, 101, 32, 110, 105, 116, 114, 111, 103, 101, 110, 32, 116, 104, 101, 32, 102, 117, 110, 103, 105, 32, 105, 110, 32, 116, 104, 101, 32, 115, 111, 105, 108, 32, 116, 97, 107, 101, 32, 117, 112, 32, 109, 97, 107, 101, 32, 116, 104, 101, 32, 116, 114, 101, 101, 32, 116, 104, 97, 116, 32, 103, 105, 118, 101, 115, 32, 116, 104, 101, 32, 97, 112, 112, 108, 101, 115, 46, 32, 83, 97, 121, 32, 119, 104, 97, 116, 32, 105, 115, 32, 116, 104, 101, 114, 101, 58, 32, 68, 32, 110, 117, 109, 101, 114, 97, 108, 115, 32, 117, 115, 101, 32, 116, 104, 101, 32, 100, 105, 103, 105, 116, 115, 32, 49, 45, 57, 32, 65, 45, 68, 32, 40, 116, 101, 110, 32, 105, 115, 32, 36, 65, 44, 32, 116, 104, 105, 114, 116, 101, 101, 110, 32, 36, 68, 44, 32, 102, 111, 117, 114, 116, 101, 101, 110, 32, 49, 49, 41, LOW
.S40: .byte 68, 32, 110, 117, 109, 101, 114, 97, 108, 115, 32, 117, 115, 101, 32, 116, 104, 101, 32, 100, 105, 103, 105, 116, 115, 32, 49, 45, 57, 32, 65, 45, 68, 32, 40, 116, 101, 110, 32, 105, 115, 32, 36, 65, 44, 32, 116, 104, 105, 114, 116, 101, 101, 110, 32, 36, 68, 44, 32, 102, 111, 117, 114, 116, 101, 101, 110, 32, 49, 49, 41, LOW
.S41: .byte 102, 114, 97, 99, 116, 105, 111, 110, 115, 32, 97, 114, 101, 32, 110, 111, 116, 32, 105, 110, 32, 68, 101, 108, 116, 97, 32, 121, 101, 116, LOW
.S42: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S43: .byte 58, 32
.S44: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S45: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S46: .byte 10
.S47: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S48: .byte 58, 32
.S49: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S50: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S51: .byte 10
.S52: .byte 116, 104, 97, 116, 32, 105, 115, 32, 110, 111, 116, 32, 97, 32, 68, 32, 110, 117, 109, 101, 114, 97, 108, 32, 40, 100, 105, 103, 105, 116, 115, 32, 49, 45, 57, 32, 65, 45, 68, 41, LOW
.S53: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S54: .byte 58, 32
.S55: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S56: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S57: .byte 10
.S58: .byte 105, 110, 32, 68, 32, 101, 118, 101, 114, 121, 32, 110, 97, 109, 101, 32, 97, 110, 100, 32, 110, 117, 109, 98, 101, 114, 32, 105, 115, 32, 97, 108, 119, 97, 121, 115, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 40, 110, 111, 32, 48, 32, 105, 110, 32, 105, 116, 41, LOW
.S59: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S60: .byte 58, 32
.S61: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S62: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S63: .byte 10
.S64: .byte 78, 85, 76, 76, LOW
.S65: .byte 110, 117, 108, 108, 112, 116, 114, LOW
.S66: .byte 78, 85, 76, 76, 32, 105, 115, 32, 97, 32, 109, 97, 107, 101, 45, 98, 101, 108, 105, 101, 118, 101, 32, 122, 101, 114, 111, 58, 32, 97, 32, 112, 111, 105, 110, 116, 101, 114, 32, 97, 108, 119, 97, 121, 115, 32, 112, 111, 105, 110, 116, 115, 32, 97, 116, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, LOW
.S67: .byte 102, 97, 108, 115, 101, LOW
.S68: .byte 102, 97, 108, 115, 101, 32, 105, 115, 32, 97, 32, 109, 97, 107, 101, 45, 98, 101, 108, 105, 101, 118, 101, 32, 122, 101, 114, 111, 58, 32, 115, 97, 121, 32, 119, 104, 97, 116, 32, 105, 115, 32, 116, 114, 117, 101, 32, 105, 110, 115, 116, 101, 97, 100, LOW
.S69: .byte 69, 88, 73, 84, 95, 83, 85, 67, 67, 69, 83, 83, LOW
.S70: .byte 69, 88, 73, 84, 95, 83, 85, 67, 67, 69, 83, 83, 32, 105, 115, 32, 97, 32, 109, 97, 107, 101, 45, 98, 101, 108, 105, 101, 118, 101, 32, 122, 101, 114, 111, 58, 32, 109, 97, 105, 110, 32, 101, 110, 100, 115, 32, 119, 105, 116, 104, 32, 114, 101, 116, 117, 114, 110, 32, 49, 32, 40, 97, 108, 108, 32, 103, 111, 111, 100, 41, LOW
.S71: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S72: .byte 58, 32
.S73: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S74: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S75: .byte 10
.S76: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S77: .byte 58, 32
.S78: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S79: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S80: .byte 10
.S81: .byte 105, 110, 32, 68, 32, 116, 104, 105, 110, 103, 115, 32, 97, 114, 101, 32, 109, 111, 118, 101, 100, 32, 40, 109, 111, 118, 101, 32, 78, 32, 102, 114, 111, 109, 32, 97, 32, 116, 111, 32, 98, 59, 41, 32, 111, 114, 32, 98, 114, 111, 107, 101, 110, 32, 105, 110, 116, 111, 32, 112, 97, 114, 116, 115, 44, 32, 110, 101, 118, 101, 114, 32, 116, 97, 107, 101, 110, 32, 98, 101, 108, 111, 119, 32, 119, 104, 97, 116, 32, 105, 115, 32, 116, 104, 101, 114, 101, 46, 32, 84, 104, 101, 114, 101, 32, 97, 114, 101, 32, 110, 111, 32, 110, 101, 103, 97, 116, 105, 118, 101, 32, 110, 117, 109, 98, 101, 114, 115, 58, 32, 105, 116, 32, 105, 115, 32, 105, 109, 112, 111, 115, 115, 105, 98, 108, 101, 46, 32, 69, 118, 101, 110, 32, 116, 104, 101, 32, 108, 111, 119, 101, 115, 116, 32, 116, 101, 109, 112, 101, 114, 97, 116, 117, 114, 101, 32, 105, 115, 32, 110, 111, 116, 32, 98, 101, 108, 111, 119, 32, 97, 110, 121, 116, 104, 105, 110, 103, 58, 32, 105, 116, 32, 105, 115, 32, 101, 110, 101, 114, 103, 121, 32, 115, 111, 32, 108, 111, 119, 32, 119, 101, 32, 99, 97, 110, 32, 110, 111, 32, 108, 111, 110, 103, 101, 114, 32, 109, 101, 97, 115, 117, 114, 101, 32, 105, 116, 44, 32, 126, 32, 40, 99, 111, 117, 110, 116, 32, 116, 101, 109, 112, 101, 114, 97, 116, 117, 114, 101, 32, 117, 112, 32, 102, 114, 111, 109, 32, 116, 104, 101, 114, 101, 44, 32, 110, 101, 118, 101, 114, 32, 98, 101, 108, 111, 119, 41, LOW
.S82: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S83: .byte 58, 32
.S84: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S85: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S86: .byte 58, 32
.S87: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S88: .byte 32, 32, 32, 32, LOW
.S89: .byte 32, 32, 32, 32, LOW
.S90: .byte 32, 32, 32, 32, LOW
.S91: .byte 46, 76, LOW
.S92: .byte 58, 10, LOW
.S93: .byte 32, 32, 32, 32, LOW
.S94: .byte 32, 46, 76, LOW
.S95: .byte 32, 32, 32, 32, 108, 101, 97, 32, LOW
.S96: .byte 44, 32, 91, 114, 105, 112, 43, 46, 83, LOW
.S97: .byte 93, 10, LOW
.S98: .byte 114, 100, 105, LOW
.S99: .byte 109, 111, 118, 32, 114, 115, 105, 44, 32, LOW
.S100: .byte 99, 97, 108, 108, 32, 100, 108, 95, 119, 114, 105, 116, 101, LOW
.S101: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S102: .byte 58, 32
.S103: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S104: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S105: .byte 10
.S106: .byte 109, 111, 118, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 105, 112, 43, 100, 108, 95, 102, 100, 93, 44, 32, 50, LOW
.S107: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32, LOW
.S108: .byte 109, 111, 118, 32, 114, 100, 105, 44, 32, LOW
.S109: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 100, LOW
.S110: .byte 58, 32, LOW
.S111: .byte 109, 111, 118, 32, 101, 100, 105, 44, 32, 50, LOW
.S112: .byte 106, 109, 112, 32, 100, 108, 95, 101, 120, 105, 116, LOW
.S113: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S114: .byte 58, 32
.S115: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S116: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S117: .byte 10
.S118: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S119: .byte 58, 32
.S120: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S121: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S122: .byte 10
.S123: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S124: .byte 58, 32
.S125: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S126: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S127: .byte 10
.S128: .byte 111, 110, 108, 121, 32, 114, 111, 119, 115, 32, 97, 110, 100, 32, 112, 111, 105, 110, 116, 101, 114, 115, 32, 104, 97, 118, 101, 32, 112, 108, 97, 99, 101, 115, 32, 116, 111, 32, 99, 111, 117, 110, 116, LOW
.S129: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 97, 32, 110, 97, 109, 101, LOW
.S130: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S131: .byte 58, 32
.S132: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S133: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S134: .byte 10
.S135: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S136: .byte 58, 32
.S137: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S138: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S139: .byte 10
.S140: .byte 116, 104, 105, 110, 103, 32, LOW
.S141: .byte 32, 105, 115, 32, 110, 111, 116, 32, 109, 97, 100, 101, 32, 40, 121, 101, 116, 41, LOW
.S142: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 97, 32, 116, 121, 112, 101, LOW
.S143: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S144: .byte 58, 32
.S145: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S146: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S147: .byte 10
.S148: .byte 109, 111, 118, 122, 120, 32, 101, 97, 120, 44, 32, 98, 121, 116, 101, 32, 112, 116, 114, 32, 91, 114, 97, 120, 93, LOW
.S149: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 97, 120, 93, LOW
.S150: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S151: .byte 109, 111, 118, 122, 120, 32, 101, 97, 120, 44, 32, 98, 121, 116, 101, 32, 112, 116, 114, 32, 91, 114, 99, 120, 93, LOW
.S152: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 99, 120, 93, LOW
.S153: .byte 97, 32, 119, 104, 111, 108, 101, 32, 114, 111, 119, 32, 99, 97, 110, 110, 111, 116, 32, 98, 101, 32, 115, 101, 116, 32, 97, 116, 32, 111, 110, 99, 101, LOW
.S154: .byte 109, 111, 118, 32, 114, 115, 105, 44, 32, 114, 97, 120, LOW
.S155: .byte 109, 111, 118, 32, 114, 100, 105, 44, 32, 114, 99, 120, LOW
.S156: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, LOW
.S157: .byte 114, 101, 112, 32, 109, 111, 118, 115, 98, LOW
.S158: .byte 109, 111, 118, 32, 98, 121, 116, 101, 32, 112, 116, 114, 32, 91, 114, 99, 120, 93, 44, 32, 97, 108, LOW
.S159: .byte 109, 111, 118, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 99, 120, 93, 44, 32, 114, 97, 120, LOW
.S160: .byte 39, LOW
.S161: .byte 39, 32, 105, 115, 32, 97, 108, 114, 101, 97, 100, 121, 32, 104, 101, 114, 101, LOW
.S162: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S163: .byte 58, 32
.S164: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S165: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S166: .byte 58, 32
.S167: .byte 32, 104, 97, 115, 32, 110, 111, 32, 112, 97, 114, 116, 32, 39
.S168: .byte 39, 10
.S169: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, LOW
.S170: .byte 108, 101, 97, 32, 114, 97, 120, 44, 32, 91, 114, 98, 112, 45, LOW
.S171: .byte 93, LOW
.S172: .byte 32, 32, 32, 32, 108, 101, 97, 32, 114, 97, 120, 44, 32, 91, 114, 105, 112, 43, 103, 95, LOW
.S173: .byte 93, 10, LOW
.S174: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 98, 112, 45, LOW
.S175: .byte 93, LOW
.S176: .byte 39, LOW
.S177: .byte 39, 32, 105, 115, 32, 110, 111, 116, 32, 107, 110, 111, 119, 110, 32, 104, 101, 114, 101, LOW
.S178: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S179: .byte 58, 32
.S180: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S181: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S182: .byte 10
.S183: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S184: .byte 58, 32
.S185: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S186: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S187: .byte 10
.S188: .byte 115, 97, 121, 32, 110, 101, 101, 100, 115, 32, 105, 116, 115, 32, 119, 111, 114, 100, 115, 32, 105, 110, 32, 113, 117, 111, 116, 101, 115, 32, 102, 105, 114, 115, 116, LOW
.S189: .byte 100, 108, 95, 114, 101, 112, 111, 114, 116, LOW
.S190: .byte 100, 108, 95, 113, 117, 105, 101, 116, LOW
.S191: .byte 99, 109, 112, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 105, 112, 43, 103, 95, 100, 108, 95, 113, 117, 105, 101, 116, 93, 44, 32, 49, LOW
.S192: .byte 106, 103, 101, LOW
.S193: .byte 109, 111, 118, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 105, 112, 43, 100, 108, 95, 102, 100, 93, 44, 32, 49, LOW
.S194: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S195: .byte 58, 32
.S196: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S197: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S198: .byte 10
.S199: .byte 115, 97, 121, 32, 107, 110, 111, 119, 115, 32, 37, 100, 32, 37, 115, 32, 37, 99, LOW
.S200: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 44, 39, LOW
.S201: .byte 109, 111, 118, 32, 114, 100, 105, 44, 32, 114, 97, 120, LOW
.S202: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 100, LOW
.S203: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 115, LOW
.S204: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 99, LOW
.S205: .byte 115, 97, 121, 32, 104, 97, 115, 32, 109, 111, 114, 101, 32, 118, 97, 108, 117, 101, 115, 32, 116, 104, 97, 110, 32, 37, 100, 32, 37, 115, 32, 37, 99, 32, 112, 108, 97, 99, 101, 115, LOW
.S206: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 44, 39, LOW
.S207: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S208: .byte 116, 104, 97, 116, 32, 116, 97, 107, 101, 115, 32, 97, 32, 100, 105, 102, 102, 101, 114, 101, 110, 116, 32, 110, 117, 109, 98, 101, 114, 32, 111, 102, 32, 118, 97, 108, 117, 101, 115, LOW
.S209: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S210: .byte 112, 111, 112, 32, 114, 115, 105, LOW
.S211: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S212: .byte 114, 101, 112, 32, 109, 111, 118, 115, 98, LOW
.S213: .byte 109, 111, 118, 32, 101, 97, 120, 44, 32, 49, LOW
.S214: .byte 112, 111, 112, 32, 114, 56, LOW
.S215: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S216: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S217: .byte 112, 111, 112, 32, 114, 97, 120, LOW
.S218: .byte 116, 101, 115, 116, 32, 114, 56, 44, 32, 114, 56, LOW
.S219: .byte 106, 110, 122, LOW
.S220: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10, LOW
.S221: .byte 109, 111, 118, 32, 114, 115, 105, 44, 32, 114, 97, 120, LOW
.S222: .byte 115, 117, 98, 32, 114, 99, 120, 44, 32, 114, 97, 120, LOW
.S223: .byte 105, 109, 117, 108, 32, 114, 99, 120, 44, 32, 114, 100, 105, LOW
.S224: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S225: .byte 99, 113, 111, LOW
.S226: .byte 105, 100, 105, 118, 32, 114, 56, LOW
.S227: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, 114, 115, 105, LOW
.S228: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S229: .byte 112, 111, 112, 32, 114, 97, 120, LOW
.S230: .byte 99, 109, 112, 32, 114, 99, 120, 44, 32, 114, 97, 120, LOW
.S231: .byte 106, 108, 101, LOW
.S232: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S233: .byte 112, 117, 115, 104, 32, 114, 99, 120, LOW
.S234: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32, LOW
.S235: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S236: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 100, LOW
.S237: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32, LOW
.S238: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S239: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 100, LOW
.S240: .byte 10, LOW
.S241: .byte 115, 117, 98, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S242: .byte 115, 117, 98, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S243: .byte 106, 103, 101, LOW
.S244: .byte 110, 101, 103, 32, 114, 97, 120, LOW
.S245: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S246: .byte 99, 109, 111, 118, 103, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S247: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S248: .byte 99, 109, 111, 118, 108, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S249: .byte 95, 95, LOW
.S250: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S251: .byte 58, 32
.S252: .byte 32, 104, 97, 115, 32, 110, 111, 32, 102, 117, 110, 99, 116, 105, 111, 110, 32, 39
.S253: .byte 39, 10
.S254: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S255: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S256: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 44, 39, LOW
.S257: .byte 109, 111, 114, 101, 32, 116, 104, 97, 110, 32, 53, 32, 105, 110, 112, 117, 116, 115, 32, 116, 111, 32, 97, 32, 116, 104, 105, 110, 103, 39, 115, 32, 102, 117, 110, 99, 116, 105, 111, 110, 32, 105, 115, 32, 110, 111, 116, 32, 105, 110, 32, 68, 101, 108, 116, 97, 32, 121, 101, 116, LOW
.S258: .byte 112, 111, 112, 32, 114, 57, LOW
.S259: .byte 112, 111, 112, 32, 114, 56, LOW
.S260: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S261: .byte 112, 111, 112, 32, 114, 100, 120, LOW
.S262: .byte 112, 111, 112, 32, 114, 115, 105, LOW
.S263: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S264: .byte 32, 32, 32, 32, 99, 97, 108, 108, 32, 102, 95, LOW
.S265: .byte 100, 108, 95, 115, 104, 114, 117, 103, 114, 101, 97, 100, LOW
.S266: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 98, 112, 45, LOW
.S267: .byte 93, LOW
.S268: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S269: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 44, 39, LOW
.S270: .byte 109, 111, 114, 101, 32, 116, 104, 97, 110, 32, 54, 32, 105, 110, 112, 117, 116, 115, 32, 105, 115, 32, 110, 111, 116, 32, 105, 110, 32, 68, 101, 108, 116, 97, 32, 121, 101, 116, LOW
.S271: .byte 112, 111, 112, 32, 114, 57, LOW
.S272: .byte 112, 111, 112, 32, 114, 56, LOW
.S273: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S274: .byte 112, 111, 112, 32, 114, 100, 120, LOW
.S275: .byte 112, 111, 112, 32, 114, 115, 105, LOW
.S276: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S277: .byte 32, 32, 32, 32, 99, 97, 108, 108, 32, 102, 95, LOW
.S278: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, LOW
.S279: .byte 114, 97, 120, LOW
.S280: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 41, 39, LOW
.S281: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 105, 112, 43, 100, 108, 95, 117, 110, 107, 110, 111, 119, 110, 93, LOW
.S282: .byte 100, 105, 100, 32, 110, 111, 116, 32, 101, 120, 112, 101, 99, 116, 32, 116, 104, 97, 116, 32, 104, 101, 114, 101, LOW
.S283: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 41, 39, LOW
.S284: .byte 108, 101, 97, 32, 114, 97, 120, 44, 32, 91, 114, 105, 112, 43, 100, 108, 95, 117, 110, 107, 110, 111, 119, 110, 93, LOW
.S285: .byte 111, 110, 108, 121, 32, 97, 32, 116, 104, 105, 110, 103, 32, 104, 97, 115, 32, 112, 97, 114, 116, 115, LOW
.S286: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S287: .byte 58, 32
.S288: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S289: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S290: .byte 10
.S291: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 97, 120, 93, LOW
.S292: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 97, 120, 93, LOW
.S293: .byte 111, 110, 108, 121, 32, 114, 111, 119, 115, 32, 97, 110, 100, 32, 112, 111, 105, 110, 116, 101, 114, 115, 32, 104, 97, 118, 101, 32, 112, 108, 97, 99, 101, 115, 32, 116, 111, 32, 99, 111, 117, 110, 116, LOW
.S294: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S295: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 93, 39, LOW
.S296: .byte 100, 101, 99, 32, 114, 97, 120, LOW
.S297: .byte 105, 109, 117, 108, 32, 114, 97, 120, 44, 32, LOW
.S298: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S299: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S300: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 97, 120, 93, LOW
.S301: .byte 111, 110, 108, 121, 32, 97, 32, 116, 104, 105, 110, 103, 32, 104, 97, 115, 32, 105, 116, 115, 32, 111, 119, 110, 32, 102, 117, 110, 99, 116, 105, 111, 110, 115, LOW
.S302: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 40, 39, LOW
.S303: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S304: .byte 58, 32
.S305: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S306: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S307: .byte 10
.S308: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 114, 97, 120, LOW
.S309: .byte 105, 110, 99, 32, 98, 121, 116, 101, 32, 112, 116, 114, 32, 91, 114, 99, 120, 93, LOW
.S310: .byte 105, 110, 99, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 99, 120, 93, LOW
.S311: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S312: .byte 115, 101, 116, 101, 32, 97, 108, LOW
.S313: .byte 109, 111, 118, 122, 120, 32, 101, 97, 120, 44, 32, 97, 108, LOW
.S314: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 41, 39, LOW
.S315: .byte 109, 111, 118, 122, 120, 32, 101, 97, 120, 44, 32, 97, 108, LOW
.S316: .byte 105, 110, 99, 32, 98, 121, 116, 101, 32, 112, 116, 114, 32, 91, 114, 97, 120, 93, LOW
.S317: .byte 105, 110, 99, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 97, 120, 93, LOW
.S318: .byte 116, 101, 115, 116, 32, 114, 99, 120, 44, 32, 114, 99, 120, LOW
.S319: .byte 106, 110, 122, LOW
.S320: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10, LOW
.S321: .byte 99, 113, 111, LOW
.S322: .byte 105, 100, 105, 118, 32, 114, 99, 120, LOW
.S323: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 114, 100, 120, LOW
.S324: .byte 105, 109, 117, 108, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S325: .byte 105, 109, 117, 108, 32, 114, 99, 120, 44, 32, LOW
.S326: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S327: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S328: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S329: .byte 115, 101, 116, 108, 32, 97, 108, LOW
.S330: .byte 115, 101, 116, 103, 32, 97, 108, LOW
.S331: .byte 115, 101, 116, 108, 101, 32, 97, 108, LOW
.S332: .byte 115, 101, 116, 103, 101, 32, 97, 108, LOW
.S333: .byte 115, 101, 116, 101, 32, 97, 108, LOW
.S334: .byte 115, 101, 116, 110, 101, 32, 97, 108, LOW
.S335: .byte 109, 111, 118, 122, 120, 32, 101, 97, 120, 44, 32, 97, 108, LOW
.S336: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S337: .byte 58, 32
.S338: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S339: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S340: .byte 10
.S341: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S342: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S343: .byte 58, 32
.S344: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S345: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S346: .byte 10
.S347: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 114, 97, 120, LOW
.S348: .byte 112, 111, 112, 32, 114, 97, 120, LOW
.S349: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S350: .byte 106, 122, LOW
.S351: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S352: .byte 106, 122, LOW
.S353: .byte 109, 111, 118, 32, 101, 97, 120, 44, 32, 49, LOW
.S354: .byte 106, 109, 112, LOW
.S355: .byte 120, 111, 114, 32, 101, 97, 120, 44, 32, 101, 97, 120, LOW
.S356: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S357: .byte 106, 110, 122, LOW
.S358: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S359: .byte 106, 110, 122, LOW
.S360: .byte 120, 111, 114, 32, 101, 97, 120, 44, 32, 101, 97, 120, LOW
.S361: .byte 106, 109, 112, LOW
.S362: .byte 109, 111, 118, 32, 101, 97, 120, 44, 32, 49, LOW
.S363: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S364: .byte 106, 122, LOW
.S365: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 58, 39, LOW
.S366: .byte 106, 109, 112, LOW
.S367: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S368: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S369: .byte 109, 111, 118, 32, 114, 100, 120, 44, 32, 114, 97, 120, LOW
.S370: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, 114, 100, 120, LOW
.S371: .byte 105, 109, 117, 108, 32, 114, 97, 120, 44, 32, 114, 100, 120, LOW
.S372: .byte 112, 117, 115, 104, 32, 114, 99, 120, LOW
.S373: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 114, 100, 120, LOW
.S374: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S375: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S376: .byte 112, 117, 115, 104, 32, 114, 99, 120, LOW
.S377: .byte 109, 111, 118, 32, 114, 100, 105, 44, 32, 114, 99, 120, LOW
.S378: .byte 109, 111, 118, 32, 114, 115, 105, 44, 32, 114, 97, 120, LOW
.S379: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 108, 111, 119, 101, 114, LOW
.S380: .byte 112, 111, 112, 32, 114, 99, 120, LOW
.S381: .byte 112, 111, 112, 32, 114, 97, 120, LOW
.S382: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 118, 99, 104, 101, 99, 107, LOW
.S383: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S384: .byte 58, 32
.S385: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S386: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S387: .byte 58, 32
.S388: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S389: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S390: .byte 58, 32
.S391: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S392: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S393: .byte 10
.S394: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S395: .byte 58, 32
.S396: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S397: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S398: .byte 58, 32
.S399: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S400: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S401: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 102, 114, 111, 109, 39, LOW
.S402: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S403: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S404: .byte 58, 32
.S405: .byte 32, 104, 97, 115, 32, 110, 111, 32, 110, 101, 105, 103, 104, 98, 111, 117, 114, 115, 58, 32, 115, 97, 121, 32, 119, 104, 101, 114, 101, 32, 105, 116, 32, 103, 111, 101, 115, 32, 40, 109, 111, 118, 101, 32, 78, 32, 102, 114, 111, 109, 32
.S406: .byte 32, 116, 111, 32, 121, 59, 41, 10
.S407: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S408: .byte 112, 111, 112, 32, 114, 115, 105, LOW
.S409: .byte 114, 100, 120, LOW
.S410: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 109, 111, 118, 101, 111, 117, 116, LOW
.S411: .byte 100, 108, 95, 109, 111, 118, 101, 111, 117, 116, LOW
.S412: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S413: .byte 112, 111, 112, 32, 114, 57, LOW
.S414: .byte 112, 111, 112, 32, 114, 56, LOW
.S415: .byte 112, 111, 112, 32, 114, 97, 120, LOW
.S416: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 49, LOW
.S417: .byte 106, 108, LOW
.S418: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 91, 114, 56, 93, LOW
.S419: .byte 106, 103, LOW
.S420: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S421: .byte 112, 117, 115, 104, 32, 114, 56, LOW
.S422: .byte 112, 117, 115, 104, 32, 114, 57, LOW
.S423: .byte 109, 111, 118, 32, 114, 100, 105, 44, 32, 114, 57, LOW
.S424: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 114, 111, 111, 109, LOW
.S425: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 114, 97, 120, LOW
.S426: .byte 112, 111, 112, 32, 114, 57, LOW
.S427: .byte 112, 111, 112, 32, 114, 56, LOW
.S428: .byte 112, 111, 112, 32, 114, 97, 120, LOW
.S429: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 114, 99, 120, LOW
.S430: .byte 106, 103, LOW
.S431: .byte 115, 117, 98, 32, 91, 114, 56, 93, 44, 32, 114, 97, 120, LOW
.S432: .byte 97, 100, 100, 32, 91, 114, 57, 93, 44, 32, 114, 97, 120, LOW
.S433: .byte 106, 109, 112, LOW
.S434: .byte 115, 117, 98, 32, 91, 114, 56, 93, 44, 32, 114, 97, 120, LOW
.S435: .byte 97, 100, 100, 32, 91, 114, 57, 93, 44, 32, 114, 97, 120, LOW
.S436: .byte LOW
.S437: .byte 109, 111, 118, 32, 114, 100, 105, 44, 32, 114, 57, LOW
.S438: .byte 114, 115, 105, LOW
.S439: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 111, 118, 101, 114, 102, 108, 111, 119, LOW
.S440: .byte 100, 108, 95, 111, 118, 101, 114, 102, 108, 111, 119, LOW
.S441: .byte 106, 109, 112, LOW
.S442: .byte 109, 111, 118, 101, 32, 110, 101, 101, 100, 115, 32, 49, 32, 111, 114, 32, 109, 111, 114, 101, 10, LOW
.S443: .byte 112, 117, 115, 104, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 56, 93, LOW
.S444: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S445: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32, LOW
.S446: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S447: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 100, LOW
.S448: .byte 32, 102, 114, 111, 109, 32, LOW
.S449: .byte 44, 32, 105, 116, 32, 104, 111, 108, 100, 115, 32, LOW
.S450: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S451: .byte 99, 97, 108, 108, 32, 100, 108, 95, 112, 117, 116, 100, LOW
.S452: .byte 10, LOW
.S453: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S454: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S455: .byte 58, 32, 39
.S456: .byte 39, 32, 109, 117, 115, 116, 32, 104, 111, 108, 100, 32, 97, 32, 119, 104, 111, 108, 101, 32, 110, 117, 109, 98, 101, 114, 32, 116, 111, 32, 98, 114, 101, 97, 107, 32, 100, 111, 119, 110, 32, 111, 114, 32, 116, 97, 107, 101, 32, 112, 97, 114, 116, 115, 10
.S457: .byte 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S458: .byte 93, 44, 32, 114, 97, 120, LOW
.S459: .byte 97, 100, 100, 32, 114, 97, 120, 44, 32, LOW
.S460: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S461: .byte 58, 32
.S462: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S463: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S464: .byte 10
.S465: .byte 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S466: .byte 93, 44, 32, 114, 97, 120, LOW
.S467: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 68, 62, LOW
.S468: .byte 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S469: .byte 93, 44, 32, 114, 97, 120, LOW
.S470: .byte 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S471: .byte 93, 44, 32, 114, 97, 120, LOW
.S472: .byte 103, 105, 118, 101, 32, 101, 118, 101, 114, 121, 32, 107, 110, 111, 119, 110, 32, 112, 97, 114, 116, 32, 97, 110, 32, 97, 109, 111, 117, 110, 116, 44, 32, 111, 114, 32, 110, 111, 110, 101, 32, 40, 116, 104, 101, 110, 32, 116, 104, 101, 121, 32, 115, 104, 97, 114, 101, 32, 101, 118, 101, 110, 108, 121, 41, LOW
.S473: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S474: .byte 58, 32, 101, 118, 101, 114, 121, 32, 98, 114, 101, 97, 107, 100, 111, 119, 110, 32, 101, 110, 100, 115, 32, 119, 105, 116, 104, 32, 126, 58, 32, 116, 104, 101, 32, 117, 110, 107, 110, 111, 119, 110, 32, 101, 110, 101, 114, 103, 121, 32, 108, 101, 102, 116, 32, 105, 110, 32
.S475: .byte 10
.S476: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S477: .byte 58, 32, 126, 32, 105, 115, 32, 116, 104, 101, 32, 117, 110, 107, 110, 111, 119, 110, 32, 101, 110, 101, 114, 103, 121, 32, 108, 101, 102, 116, 32, 105, 110, 32
.S478: .byte 58, 32, 105, 116, 32, 104, 97, 115, 32, 110, 111, 32, 110, 97, 109, 101, 46, 32, 65, 32, 110, 97, 109, 101, 100, 32, 112, 97, 114, 116, 32, 105, 115, 32, 97, 32, 107, 110, 111, 119, 110, 32, 112, 97, 114, 116, 32, 40, 119, 114, 105, 116, 101, 32, 105, 116, 32, 98, 101, 102, 111, 114, 101, 32, 126, 41, 10
.S479: .byte 109, 111, 118, 32, 114, 56, 44, 32, 91, 114, 98, 112, 45, LOW
.S480: .byte 93, LOW
.S481: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, 91, 114, 56, 93, LOW
.S482: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 49, LOW
.S483: .byte 106, 108, LOW
.S484: .byte 109, 111, 118, 32, 114, 100, 120, 44, 32, 114, 97, 120, LOW
.S485: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 91, 114, 98, 112, 45, LOW
.S486: .byte 93, LOW
.S487: .byte 99, 109, 112, 32, 114, 99, 120, 44, 32, 49, LOW
.S488: .byte 106, 108, LOW
.S489: .byte 99, 109, 112, 32, 114, 99, 120, 44, 32, 114, 100, 120, LOW
.S490: .byte 106, 103, LOW
.S491: .byte 115, 117, 98, 32, 114, 100, 120, 44, 32, 114, 99, 120, LOW
.S492: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 91, 114, 98, 112, 45, LOW
.S493: .byte 93, LOW
.S494: .byte 109, 111, 118, 32, 114, 57, 44, 32, 91, 114, 98, 112, 45, LOW
.S495: .byte 93, LOW
.S496: .byte 97, 100, 100, 32, 91, 114, 57, 93, 44, 32, 114, 99, 120, LOW
.S497: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, LOW
.S498: .byte 99, 113, 111, LOW
.S499: .byte 105, 100, 105, 118, 32, 114, 99, 120, LOW
.S500: .byte 99, 109, 112, 32, 114, 97, 120, 44, 32, 49, LOW
.S501: .byte 106, 108, LOW
.S502: .byte 109, 111, 118, 32, 114, 57, 44, 32, 91, 114, 98, 112, 45, LOW
.S503: .byte 93, LOW
.S504: .byte 97, 100, 100, 32, 91, 114, 57, 93, 44, 32, 114, 97, 120, LOW
.S505: .byte 97, 100, 100, 32, 91, 114, 105, 112, 43, 100, 108, 95, 117, 110, 107, 110, 111, 119, 110, 93, 44, 32, 114, 100, 120, LOW
.S506: .byte 109, 111, 118, 32, 114, 57, 44, 32, 91, 114, 98, 112, 45, LOW
.S507: .byte 93, LOW
.S508: .byte 97, 100, 100, 32, 91, 114, 57, 93, 44, 32, 114, 100, 120, LOW
.S509: .byte 109, 111, 118, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 56, 93, 44, 32, 76, 79, 87, LOW
.S510: .byte 106, 109, 112, LOW
.S511: .byte 32, 105, 115, 32, 97, 116, 32, 105, 116, 115, 32, 108, 111, 119, 101, 115, 116, 32, 112, 111, 105, 110, 116, 58, 32, 111, 110, 108, 121, 32, 126, 32, 40, 117, 110, 107, 110, 111, 119, 110, 32, 101, 110, 101, 114, 103, 121, 41, 32, 105, 115, 32, 108, 101, 102, 116, 32, 105, 110, 32, 105, 116, 10, LOW
.S512: .byte 32, 105, 115, 32, 116, 111, 111, 32, 108, 105, 116, 116, 108, 101, 32, 102, 111, 114, 32, 116, 104, 111, 115, 101, 32, 112, 97, 114, 116, 115, 10, LOW
.S513: .byte 102, 108, 111, 119, 32, 119, 111, 114, 100, 115, 32, 116, 97, 107, 101, 32, 110, 97, 109, 101, 115, 32, 40, 111, 114, 32, 112, 97, 114, 116, 115, 58, 32, 112, 46, 115, 117, 103, 97, 114, 41, LOW
.S514: .byte 100, 108, 95, 116, 104, 105, 110, 103, LOW
.S515: .byte 100, 108, 95, 116, 104, 105, 110, 103, LOW
.S516: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S517: .byte 58, 32
.S518: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S519: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S520: .byte 10
.S521: .byte 97, 32, 102, 108, 111, 119, 32, 119, 111, 114, 100, 32, 110, 101, 101, 100, 115, 32, 97, 32, 59, 32, 97, 116, 32, 105, 116, 115, 32, 101, 110, 100, LOW
.S522: .byte 115, 116, 111, 114, 101, 32, 120, 32, 108, 101, 97, 107, 32, 78, 59, LOW
.S523: .byte 100, 108, 95, 115, 101, 116, 108, 101, 97, 107, LOW
.S524: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S525: .byte 58, 32
.S526: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S527: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S528: .byte 10
.S529: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S530: .byte 58, 32
.S531: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S532: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S533: .byte 10
.S534: .byte 109, 105, 120, 32, 97, 44, 32, 98, 59, LOW
.S535: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S536: .byte 58, 32
.S537: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S538: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S539: .byte 10
.S540: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S541: .byte 58, 32
.S542: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S543: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S544: .byte 10
.S545: .byte 100, 108, 95, 115, 101, 116, 108, 101, 97, 107, LOW
.S546: .byte 100, 108, 95, 115, 101, 116, 108, 101, 97, 107, LOW
.S547: .byte 100, 108, 95, 108, 105, 110, 107, 50, LOW
.S548: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S549: .byte 58, 32
.S550: .byte 32, 97, 110, 100, 32
.S551: .byte 32, 104, 97, 118, 101, 32, 110, 111, 32, 112, 97, 114, 116, 115, 32, 105, 110, 32, 99, 111, 109, 109, 111, 110, 32, 116, 111, 32, 109, 105, 120, 10
.S552: .byte 100, 108, 95, 115, 101, 116, 108, 101, 97, 107, LOW
.S553: .byte 100, 108, 95, 115, 101, 116, 108, 101, 97, 107, LOW
.S554: .byte 100, 108, 95, 108, 105, 110, 107, 50, LOW
.S555: .byte 109, 105, 120, 32, 116, 119, 111, 32, 116, 104, 105, 110, 103, 115, 32, 40, 116, 104, 101, 105, 114, 32, 115, 104, 97, 114, 101, 100, 32, 112, 97, 114, 116, 115, 32, 109, 105, 120, 41, 32, 111, 114, 32, 116, 119, 111, 32, 119, 104, 111, 108, 101, 32, 110, 117, 109, 98, 101, 114, 115, LOW
.S556: .byte 119, 101, 97, 114, 32, 120, 32, 98, 121, 32, 121, 32, 112, 101, 114, 32, 78, 32, 68, 62, 32, 97, 32, 43, 32, 98, 32, 126, 59, LOW
.S557: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S558: .byte 58, 32
.S559: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S560: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S561: .byte 10
.S562: .byte 101, 118, 101, 114, 121, 32, 119, 101, 97, 114, 32, 101, 110, 100, 115, 32, 119, 105, 116, 104, 32, 126, 58, 32, 116, 104, 101, 32, 117, 110, 107, 110, 111, 119, 110, 32, 101, 110, 101, 114, 103, 121, 32, 105, 116, 32, 108, 101, 97, 118, 101, 115, LOW
.S563: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S564: .byte 58, 32
.S565: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S566: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S567: .byte 10
.S568: .byte 119, 101, 97, 114, 32, 110, 101, 101, 100, 115, 32, 97, 116, 32, 108, 101, 97, 115, 116, 32, 111, 110, 101, 32, 107, 110, 111, 119, 110, 32, 112, 97, 114, 116, 32, 98, 101, 102, 111, 114, 101, 32, 126, LOW
.S569: .byte 119, 101, 97, 114, 32, 110, 101, 101, 100, 115, 32, 119, 104, 97, 116, 32, 119, 101, 97, 114, 115, 32, 105, 116, 44, 32, 97, 32, 110, 101, 105, 103, 104, 98, 111, 117, 114, 58, 32, 119, 101, 97, 114, 32, 114, 117, 98, 98, 101, 114, 32, 98, 121, 32, 115, 117, 110, 32, 68, 62, 32, 100, 117, 115, 116, 32, 126, 59, LOW
.S570: .byte 119, 101, 97, 114, 32, 120, 32, 98, 121, 32, 121, 32, 112, 101, 114, 32, 78, 32, 68, 62, 32, 97, 32, 43, 32, 98, 32, 126, 59, LOW
.S571: .byte 100, 108, 95, 119, 101, 97, 114, LOW
.S572: .byte 100, 108, 95, 119, 101, 97, 114, 95, 112, 97, 114, 116, LOW
.S573: .byte 100, 108, 95, 113, 117, 105, 101, 116, 115, 101, 116, LOW
.S574: .byte 115, 104, 114, 117, 103, 32, 78, 32, 102, 114, 111, 109, 32, 120, 59, LOW
.S575: .byte 100, 108, 95, 115, 104, 114, 117, 103, 111, 102, 102, LOW
.S576: .byte 100, 108, 95, 116, LOW
.S577: .byte 102, 111, 114, LOW
.S578: .byte 105, 110, 116, LOW
.S579: .byte 100, 108, 95, 116, 105, 99, 107, 49, LOW
.S580: .byte 99, 111, 110, 100, 117, 99, 116, 32, 119, 105, 114, 101, 32, 108, 111, 115, 115, 32, 78, 59, 32, 32, 111, 114, 32, 32, 99, 111, 110, 100, 117, 99, 116, 32, 119, 105, 114, 101, 32, 108, 111, 115, 115, 32, 78, 32, 112, 101, 114, 32, 77, 59, LOW
.S581: .byte 99, 111, 110, 100, 117, 99, 116, 32, 119, 105, 114, 101, 32, 108, 111, 115, 115, 32, 78, 32, 112, 101, 114, 32, 77, 59, LOW
.S582: .byte 100, 108, 95, 115, 101, 116, 112, 101, 114, LOW
.S583: .byte 110, 101, 105, 103, 104, 98, 111, 117, 114, 115, 32, 120, 58, 32, 97, 44, 32, 98, 44, 32, 99, 59, LOW
.S584: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S585: .byte 58, 32
.S586: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S587: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S588: .byte 10
.S589: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S590: .byte 58, 32
.S591: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S592: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S593: .byte 10
.S594: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S595: .byte 58, 32
.S596: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S597: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S598: .byte 10
.S599: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S600: .byte 58, 32
.S601: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S602: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S603: .byte 10
.S604: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S605: .byte 58, 32
.S606: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S607: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S608: .byte 10
.S609: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S610: .byte 58, 32
.S611: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S612: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S613: .byte 10
.S614: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S615: .byte 58, 32
.S616: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S617: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S618: .byte 10
.S619: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S620: .byte 58, 32
.S621: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S622: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S623: .byte 10
.S624: .byte 100, 108, 95, 108, 105, 110, 107, 50, LOW
.S625: .byte 100, 108, 95, 115, 101, 116, 104, 101, 97, 116, 111, 110, 108, 121, LOW
.S626: .byte 100, 108, 95, 119, 101, 105, 103, 104, 116, LOW
.S627: .byte 115, 112, 101, 110, 100, 32, 78, 32, 102, 114, 111, 109, 32, 120, 59, LOW
.S628: .byte 100, 108, 95, 115, 112, 101, 110, 100, LOW
.S629: .byte 102, 108, 111, 119, 32, 105, 115, 32, 110, 111, 116, 32, 108, 111, 97, 100, 101, 100, LOW
.S630: .byte 108, 101, 97, 32, 114, 97, 120, 44, 32, 91, 114, 98, 112, 45, LOW
.S631: .byte 93, LOW
.S632: .byte 39, LOW
.S633: .byte 39, 32, 105, 115, 32, 110, 111, 116, 32, 107, 110, 111, 119, 110, 32, 104, 101, 114, 101, LOW
.S634: .byte 32, 32, 32, 32, 108, 101, 97, 32, 114, 97, 120, 44, 32, 91, 114, 105, 112, 43, 103, 95, LOW
.S635: .byte 93, 10, LOW
.S636: .byte 97, 32, 118, 101, 115, 115, 101, 108, 32, 105, 115, 32, 97, 32, 116, 104, 105, 110, 103, 32, 119, 105, 116, 104, 32, 112, 97, 114, 116, 115, 32, 40, 116, 104, 105, 110, 103, 32, 116, 97, 110, 107, 32, 116, 59, 32, 118, 101, 115, 115, 101, 108, 32, 116, 59, 41, LOW
.S637: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S638: .byte 58, 32
.S639: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S640: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S641: .byte 10
.S642: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S643: .byte 58, 32, 101, 118, 101, 114, 121, 32, 112, 97, 114, 116, 32, 111, 102, 32, 97, 32, 118, 101, 115, 115, 101, 108, 32, 104, 111, 108, 100, 115, 32, 97, 32, 119, 104, 111, 108, 101, 32, 110, 117, 109, 98, 101, 114, 32, 40, 39
.S644: .byte 39, 32, 100, 111, 101, 115, 32, 110, 111, 116, 41, 10
.S645: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S646: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S647: .byte 114, 115, 105, LOW
.S648: .byte 109, 111, 118, 32, 114, 100, 120, 44, 32, LOW
.S649: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S650: .byte 58, 32
.S651: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S652: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 118, 101, 115, 115, 101, 108, LOW
.S653: .byte 100, 108, 95, 118, 101, 115, 115, 101, 108, LOW
.S654: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S655: .byte 102, 105, 116, 115, 32, 105, 115, 32, 102, 111, 114, 32, 97, 32, 119, 104, 111, 108, 101, 32, 110, 117, 109, 98, 101, 114, 32, 111, 114, 32, 97, 32, 112, 97, 114, 116, 32, 116, 104, 97, 116, 32, 104, 111, 108, 100, 115, 32, 111, 110, 101, LOW
.S656: .byte 112, 117, 115, 104, 32, 114, 97, 120, LOW
.S657: .byte 109, 111, 118, 32, 114, 115, 105, 44, 32, 114, 97, 120, LOW
.S658: .byte 112, 111, 112, 32, 114, 100, 105, LOW
.S659: .byte 99, 97, 108, 108, 32, 102, 95, 100, 108, 95, 102, 105, 116, 115, LOW
.S660: .byte 100, 108, 95, 102, 105, 116, 115, LOW
.S661: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S662: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S663: .byte 58, 32
.S664: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S665: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S666: .byte 10
.S667: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, LOW
.S668: .byte 108, 101, 97, 32, 114, 100, 105, 44, 32, 91, 114, 98, 112, 45, LOW
.S669: .byte 93, LOW
.S670: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, LOW
.S671: .byte 109, 111, 118, 32, 101, 97, 120, 44, 32, 76, 79, 87, LOW
.S672: .byte 114, 101, 112, 32, 115, 116, 111, 115, 98, LOW
.S673: .byte 97, 32, 114, 111, 119, 32, 115, 105, 122, 101, 32, 109, 117, 115, 116, 32, 98, 101, 32, 97, 32, 110, 117, 109, 98, 101, 114, LOW
.S674: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 93, 39, LOW
.S675: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 114, 98, 112, LOW
.S676: .byte 115, 117, 98, 32, 114, 99, 120, 44, 32, LOW
.S677: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S678: .byte 58, 32
.S679: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S680: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S681: .byte 58, 32
.S682: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S683: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S684: .byte 58, 32
.S685: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S686: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S687: .byte 10
.S688: .byte 109, 111, 118, 32, 114, 99, 120, 44, 32, 114, 98, 112, LOW
.S689: .byte 115, 117, 98, 32, 114, 99, 120, 44, 32, LOW
.S690: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S691: .byte 58, 32
.S692: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S693: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S694: .byte 10
.S695: .byte 109, 111, 114, 101, 32, 118, 97, 108, 117, 101, 115, 32, 116, 104, 97, 110, 32, 112, 97, 114, 116, 115, 32, 105, 110, 32, LOW
.S696: .byte LOW
.S697: .byte 109, 111, 114, 101, 32, 118, 97, 108, 117, 101, 115, 32, 116, 104, 97, 110, 32, 112, 108, 97, 99, 101, 115, 32, 105, 110, 32, LOW
.S698: .byte LOW
.S699: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S700: .byte 58, 32
.S701: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S702: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S703: .byte 10
.S704: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S705: .byte 58, 32
.S706: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S707: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S708: .byte 10
.S709: .byte 109, 111, 118, 32, 98, 121, 116, 101, 32, 112, 116, 114, 32, 91, 114, 98, 112, 45, LOW
.S710: .byte 93, 44, 32, 76, 79, 87, LOW
.S711: .byte 109, 111, 118, 32, 113, 119, 111, 114, 100, 32, 112, 116, 114, 32, 91, 114, 98, 112, 45, LOW
.S712: .byte 93, 44, 32, 76, 79, 87, LOW
.S713: .byte 109, 111, 118, 32, 114, 97, 120, 44, 32, LOW
.S714: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S715: .byte 58, 32
.S716: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S717: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S718: .byte 10
.S719: .byte 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S720: .byte 93, 44, 32, 97, 108, LOW
.S721: .byte 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S722: .byte 93, 44, 32, 114, 97, 120, LOW
.S723: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 123, 39, LOW
.S724: .byte 97, 32, 123, 32, 110, 101, 101, 100, 115, 32, 105, 116, 115, 32, 125, LOW
.S725: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S726: .byte 58, 32
.S727: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S728: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S729: .byte 10
.S730: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S731: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 40, 39, LOW
.S732: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S733: .byte 106, 122, LOW
.S734: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 41, 39, LOW
.S735: .byte 106, 109, 112, LOW
.S736: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 40, 39, LOW
.S737: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S738: .byte 106, 122, LOW
.S739: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 41, 39, LOW
.S740: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S741: .byte 58, 32
.S742: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S743: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S744: .byte 10
.S745: .byte 106, 109, 112, LOW
.S746: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 40, 39, LOW
.S747: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S748: .byte 116, 101, 115, 116, 32, 114, 97, 120, 44, 32, 114, 97, 120, LOW
.S749: .byte 106, 122, LOW
.S750: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S751: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S752: .byte 58, 32
.S753: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S754: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S755: .byte 10
.S756: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 41, 39, LOW
.S757: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S758: .byte 58, 32
.S759: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S760: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S761: .byte 10
.S762: .byte 106, 109, 112, LOW
.S763: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S764: .byte 58, 32
.S765: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S766: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S767: .byte 10
.S768: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S769: .byte 32, 32, 32, 32, 106, 109, 112, 32, 46, 76, 114, 101, 116, 95, LOW
.S770: .byte 98, 114, 101, 97, 107, 32, 111, 117, 116, 115, 105, 100, 101, 32, 97, 32, 108, 111, 111, 112, LOW
.S771: .byte 99, 111, 110, 116, 105, 110, 117, 101, 32, 111, 117, 116, 115, 105, 100, 101, 32, 97, 32, 108, 111, 111, 112, LOW
.S772: .byte 106, 109, 112, LOW
.S773: .byte 106, 109, 112, LOW
.S774: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S775: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S776: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 40, 39, LOW
.S777: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S778: .byte 58, 32, 103, 105, 118, 101, 32, 97, 32, 116, 104, 105, 110, 103, 32, 98, 121, 32, 105, 116, 115, 32, 112, 108, 97, 99, 101, 58, 32, 116, 104, 105, 110, 103, 32
.S779: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S780: .byte 58, 32
.S781: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S782: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S783: .byte 10
.S784: .byte 32, 42
.S785: .byte 10
.S786: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 44, 39, LOW
.S787: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S788: .byte 58, 32, 103, 105, 118, 101, 32, 98, 97, 99, 107, 32, 97, 32, 116, 104, 105, 110, 103, 32, 98, 121, 32, 105, 116, 115, 32, 112, 108, 97, 99, 101, 32, 40, 116, 104, 105, 110, 103, 32
.S789: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S790: .byte 58, 32
.S791: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S792: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S793: .byte 10
.S794: .byte 32, 42, 41, 10
.S795: .byte 109, 111, 114, 101, 32, 116, 104, 97, 110, 32, 54, 32, 105, 110, 112, 117, 116, 115, 32, 105, 115, 32, 110, 111, 116, 32, 105, 110, 32, 68, 101, 108, 116, 97, 32, 121, 101, 116, LOW
.S796: .byte 102, 95, LOW
.S797: .byte 58, 10, LOW
.S798: .byte 112, 117, 115, 104, 32, 114, 98, 112, LOW
.S799: .byte 109, 111, 118, 32, 114, 98, 112, 44, 32, 114, 115, 112, LOW
.S800: .byte 32, 32, 32, 32, 115, 117, 98, 32, 114, 115, 112, 44, 32, LOW
.S801: .byte 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 10, LOW
.S802: .byte 32, 32, 32, 32, 109, 111, 118, 32, 91, 114, 98, 112, 45, LOW
.S803: .byte 93, 44, 32, LOW
.S804: .byte 114, 100, 105, LOW
.S805: .byte 114, 115, 105, LOW
.S806: .byte 114, 100, 120, LOW
.S807: .byte 114, 99, 120, LOW
.S808: .byte 114, 56, LOW
.S809: .byte 114, 57, LOW
.S810: .byte 109, 111, 118, 32, 101, 97, 120, 44, 32, 49, LOW
.S811: .byte 120, 111, 114, 32, 101, 97, 120, 44, 32, 101, 97, 120, LOW
.S812: .byte 46, 76, 114, 101, 116, 95, LOW
.S813: .byte 58, 10, LOW
.S814: .byte 109, 111, 118, 32, 114, 115, 112, 44, 32, 114, 98, 112, LOW
.S815: .byte 112, 111, 112, 32, 114, 98, 112, LOW
.S816: .byte 114, 101, 116, LOW
.S817: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S818: .byte 58, 32
.S819: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S820: .byte 116, 104, 105, 110, 103, 32, LOW
.S821: .byte 32, 105, 115, 32, 97, 108, 114, 101, 97, 100, 121, 32, 109, 97, 100, 101, LOW
.S822: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 123, 39, LOW
.S823: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S824: .byte 58, 32
.S825: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S826: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S827: .byte 10
.S828: .byte 97, 32, 114, 111, 119, 32, 115, 105, 122, 101, 32, 109, 117, 115, 116, 32, 98, 101, 32, 97, 32, 110, 117, 109, 98, 101, 114, LOW
.S829: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 93, 39, LOW
.S830: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S831: .byte 58, 32
.S832: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S833: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S834: .byte 10
.S835: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S836: .byte 58, 32, 97, 32, 116, 104, 105, 110, 103, 32, 99, 97, 110, 110, 111, 116, 32, 104, 111, 108, 100, 32, 105, 116, 115, 101, 108, 102, 32, 40, 104, 111, 108, 100, 32, 97, 32, 112, 108, 97, 99, 101, 58, 32, 116, 104, 105, 110, 103, 32
.S837: .byte 32, 42, 41, 10
.S838: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S839: .byte 58, 32, 39
.S840: .byte 39, 32, 105, 115, 32, 97, 108, 114, 101, 97, 100, 121, 32, 97, 32, 112, 97, 114, 116, 32, 111, 102, 32
.S841: .byte 10
.S842: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S843: .byte 58, 32
.S844: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S845: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S846: .byte 97, 32, 114, 111, 119, 32, 115, 105, 122, 101, 32, 109, 117, 115, 116, 32, 98, 101, 32, 97, 32, 110, 117, 109, 98, 101, 114, LOW
.S847: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 93, 39, LOW
.S848: .byte 39, LOW
.S849: .byte 39, 32, 105, 115, 32, 97, 108, 114, 101, 97, 100, 121, 32, 104, 101, 114, 101, LOW
.S850: .byte 97, 32, 107, 101, 112, 116, 45, 102, 111, 114, 45, 116, 104, 101, 45, 114, 117, 110, 32, 118, 97, 108, 117, 101, 32, 115, 116, 97, 114, 116, 115, 32, 97, 115, 32, 97, 32, 112, 108, 97, 105, 110, 32, 110, 117, 109, 98, 101, 114, LOW
.S851: .byte 101, 120, 112, 101, 99, 116, 101, 100, 32, 39, 59, 39, LOW
.S852: .byte 110, 111, 32, 109, 97, 105, 110, LOW
.S853: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S854: .byte 58, 32
.S855: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S856: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S857: .byte 10
.S858: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S859: .byte 58, 32
.S860: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S861: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S862: .byte 10
.S863: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S864: .byte 58, 32
.S865: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S866: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S867: .byte 10
.S868: .byte 99, 111, 117, 108, 100, 32, 110, 111, 116, 32, 119, 114, 105, 116, 101, LOW
.S869: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S870: .byte 58, 32
.S871: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S872: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S873: .byte 10
.S874: .byte 46, 105, 110, 116, 101, 108, 95, 115, 121, 110, 116, 97, 120, 32, 110, 111, 112, 114, 101, 102, 105, 120, 10, LOW
.S875: .byte 10, 46, 116, 101, 120, 116, 10, LOW
.S876: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S877: .byte 58, 32
.S878: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S879: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S880: .byte 10
.S881: .byte 10, 46, 100, 97, 116, 97, 10, LOW
.S882: .byte 103, 95, LOW
.S883: .byte 58, 32, 46, 113, 117, 97, 100, 32, LOW
.S884: .byte 46, 98, 115, 115, 10, LOW
.S885: .byte 103, 95, LOW
.S886: .byte 58, 32, 46, 115, 107, 105, 112, 32, LOW
.S887: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S888: .byte 58, 32
.S889: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S890: .byte 10, 46, 115, 101, 99, 116, 105, 111, 110, 32, 46, 114, 111, 100, 97, 116, 97, 10, LOW
.S891: .byte 46, 83, LOW
.S892: .byte 58, 32, 46, 98, 121, 116, 101, 32, LOW
.S893: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S894: .byte 58, 32
.S895: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S896: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S897: .byte 10
.S898: .byte 76, 79, 87, LOW
.S899: .byte 44, 32, LOW
.S900: .byte 76, 79, 87, LOW
.S901: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S902: .byte 58, 32
.S903: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S904: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S905: .byte 10
.S906: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S907: .byte 58, 32
.S908: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S909: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S910: .byte 58, 32
.S911: .byte 115, 104, 97, 114, 101, 100, 32, 97, 109, 111, 110, 103, 32, 108, 101, 115, 115, 32, 116, 104, 97, 110, 32, 49, 58, 32, 116, 104, 101, 114, 101, 32, 105, 115, 32, 110, 111, 116, 104, 105, 110, 103, 32, 116, 111, 32, 115, 104, 97, 114, 101, 32, 105, 116, 32, 119, 105, 116, 104, 10
.S912: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S913: .byte 58, 32
.S914: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S915: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S916: .byte 10
.S917: .byte 100, 99, 58, 32, 99, 97, 110, 110, 111, 116, 32, 114, 101, 97, 100, 32
.S918: .byte 10
.S919: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S920: .byte 58, 32
.S921: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S922: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S923: .byte 10
.S924: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S925: .byte 58, 32
.S926: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S927: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S928: .byte 10
.S929: .byte 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, LOW
.S930: .byte 105, 110, 116, LOW
.S931: .byte 99, 104, 97, 114, LOW
.S932: .byte 108, 111, 110, 103, LOW
.S933: .byte 118, 111, 105, 100, LOW
.S934: .byte 117, 110, 115, 105, 103, 110, 101, 100, LOW
.S935: .byte 115, 105, 103, 110, 101, 100, LOW
.S936: .byte 99, 111, 110, 115, 116, LOW
.S937: .byte 115, 116, 97, 116, 105, 99, LOW
.S938: .byte 105, 102, LOW
.S939: .byte 101, 108, 115, 101, LOW
.S940: .byte 119, 104, 105, 108, 101, LOW
.S941: .byte 102, 111, 114, LOW
.S942: .byte 114, 101, 116, 117, 114, 110, LOW
.S943: .byte 98, 114, 101, 97, 107, LOW
.S944: .byte 99, 111, 110, 116, 105, 110, 117, 101, LOW
.S945: .byte 109, 111, 118, 101, LOW
.S946: .byte 102, 114, 111, 109, LOW
.S947: .byte 116, 111, LOW
.S948: .byte 97, 110, 100, LOW
.S949: .byte 115, 97, 121, LOW
.S950: .byte 108, 101, 115, 115, LOW
.S951: .byte 97, 112, 97, 114, 116, LOW
.S952: .byte 108, 111, 119, 101, 114, LOW
.S953: .byte 104, 105, 103, 104, 101, 114, LOW
.S954: .byte 116, 111, 119, 97, 114, 100, 115, LOW
.S955: .byte 99, 111, 112, 121, LOW
.S956: .byte 109, 97, 105, 110, LOW
.S957: .byte 100, 101, 102, 105, 110, 101, LOW
.S958: .byte 105, 110, 99, 108, 117, 100, 101, LOW
.S959: .byte 116, 104, 105, 110, 103, LOW
.S960: .byte 118, 101, 115, 115, 101, 108, LOW
.S961: .byte 108, 105, 110, 117, 120, LOW
.S962: .byte 119, 97, 105, 116, LOW
.S963: .byte 115, 116, 111, 112, LOW
.S964: .byte 115, 99, 114, 101, 101, 110, 119, 105, 100, 101, LOW
.S965: .byte 115, 99, 114, 101, 101, 110, 104, 105, 103, 104, LOW
.S966: .byte 102, 105, 116, 115, LOW
.S967: .byte 115, 104, 114, 117, 103, LOW
.S968: .byte 115, 101, 108, 102, LOW
.S969: .byte 126, LOW
.S970: .byte 115, 116, 111, 114, 101, LOW
.S971: .byte 99, 111, 110, 100, 117, 99, 116, LOW
.S972: .byte 110, 101, 105, 103, 104, 98, 111, 117, 114, 115, LOW
.S973: .byte 115, 112, 101, 110, 100, LOW
.S974: .byte 116, 105, 99, 107, LOW
.S975: .byte 119, 101, 97, 114, LOW
.S976: .byte 109, 105, 120, LOW
.S977: .byte 113, 117, 105, 101, 116, LOW
.S978: .byte 108, 101, 97, 107, LOW
.S979: .byte 108, 111, 115, 115, LOW
.S980: .byte 112, 101, 114, LOW
.S981: .byte 98, 121, LOW
.S982: .byte 104, 101, 97, 116, LOW
.S983: .byte 100, 99, 58, 32, 116, 104, 101, 32, 68, 101, 108, 116, 97, 32, 99, 111, 109, 112, 105, 108, 101, 114, 32, 105, 110, 32, 68, 101, 108, 116, 97, 10, 32, 32, 100, 99, 32, 98, 117, 105, 108, 100, 32, 102, 105, 108, 101, 46, 100, 101, 108, 116, 97, 32, 91, 45, 111, 32, 111, 117, 116, 93, 10, 32, 32, 100, 99, 32, 114, 117, 110, 32, 102, 105, 108, 101, 46, 100, 101, 108, 116, 97, 32, 91, 45, 111, 32, 111, 117, 116, 93, 10, 32, 32, 100, 99, 32, 97, 115, 109, 32, 102, 105, 108, 101, 46, 100, 101, 108, 116, 97, 10
.S984: .byte 46, 47, LOW
.S985: .byte LOW
.S986: .byte 100, 99, 58, 32, 99, 97, 110, 110, 111, 116, 32, 114, 101, 97, 100, 32
.S987: .byte 10
.S988: .byte 119, 105, 110, 100, 111, 119, 95, LOW
.S989: .byte 119, 105, 110, 100, 111, 119, 46, 100, 101, 108, 116, 97, LOW
.S990: .byte 114, 111, 111, 109, 46, 100, 101, 108, 116, 97, LOW
.S991: .byte 102, 108, 111, 119, 46, 100, 101, 108, 116, 97, LOW
.S992: .byte 118, 101, 115, 115, 101, 108, 46, 100, 101, 108, 116, 97, LOW
.S993: .byte 39, LOW
.S994: .byte 39, 32, 105, 115, 32, 110, 111, 116, 32, 109, 97, 100, 101, 32, 97, 110, 121, 119, 104, 101, 114, 101, LOW
.S995: .byte 114, 117, 110, 116, 105, 109, 101, 46, 115, LOW
.S996: .byte 100, 99, 58, 32, 99, 97, 110, 110, 111, 116, 32, 114, 101, 97, 100, 32, 116, 104, 101, 32, 114, 117, 110, 116, 105, 109, 101, 32
.S997: .byte 10
.S998: .byte 97, 115, 109, LOW
.S999: .byte 45, 111, LOW
.S1000: .byte LOW
.S1001: .byte LOW
.S1002: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S1003: .byte 58, 32
.S1004: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S1005: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S1006: .byte 10
.S1007: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S1008: .byte 58, 32
.S1009: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S1010: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S1011: .byte 10
.S1012: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S1013: .byte 58, 32
.S1014: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S1015: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S1016: .byte 10
.S1017: .byte 68, 101, 108, 116, 97, 32, 108, 105, 110, 101, 32
.S1018: .byte 58, 32
.S1019: .byte 99, 97, 110, 110, 111, 116, 32, 109, 111, 118, 101, 32
.S1020: .byte 32, 111, 117, 116, 32, 111, 102, 32, 115, 111, 109, 101, 116, 104, 105, 110, 103, 32, 104, 111, 108, 100, 105, 110, 103, 32
.S1021: .byte 10
.S1022: .byte 46, 115, LOW
.S1023: .byte 46, 111, LOW
.S1024: .byte 100, 99, 58, 32, 99, 97, 110, 110, 111, 116, 32, 119, 114, 105, 116, 101, 32
.S1025: .byte 10
.S1026: .byte 47, 117, 115, 114, 47, 98, 105, 110, 47, 97, 115, LOW
.S1027: .byte 45, 45, 54, 52, LOW
.S1028: .byte 45, 111, LOW
.S1029: .byte 100, 99, 58, 32, 116, 104, 101, 32, 97, 115, 115, 101, 109, 98, 108, 121, 32, 100, 105, 100, 32, 110, 111, 116, 32, 103, 111, 32, 116, 104, 114, 111, 117, 103, 104, 32, 40, 97, 32, 100, 99, 32, 98, 117, 103, 41, 10
.S1030: .byte 47, 117, 115, 114, 47, 98, 105, 110, 47, 108, 100, LOW
.S1031: .byte 45, 45, 110, 111, 45, 119, 97, 114, 110, 45, 114, 119, 120, 45, 115, 101, 103, 109, 101, 110, 116, 115, LOW
.S1032: .byte 45, 110, LOW
.S1033: .byte 45, 111, LOW
.S1034: .byte 100, 99, 58, 32, 116, 104, 101, 32, 112, 114, 111, 103, 114, 97, 109, 32, 99, 111, 117, 108, 100, 32, 110, 111, 116, 32, 98, 101, 32, 112, 117, 116, 32, 116, 111, 103, 101, 116, 104, 101, 114, 10
.S1035: .byte 114, 117, 110, LOW
