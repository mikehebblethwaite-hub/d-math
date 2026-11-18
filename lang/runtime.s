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
