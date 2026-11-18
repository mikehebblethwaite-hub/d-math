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
f_wait:                         # wait(ms): the firmware's Stall, in millionths of a second
    push rbp
    mov rbp, rsp
    imul rcx, rdi, 1000
    mov rax, [rip+dl_system]
    mov rax, [rax+96]           # boot services
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 32
    call qword ptr [rax+248]    # Stall
    mov rsp, rbp
    pop rbp
    mov eax, 1
    ret
f_memmap:                       # memmap(row, bytes): the firmware's memory map into the row; gives back its size
    push rbp
    mov rbp, rsp
    mov [rip+dl_mapsize], rsi
    mov rax, [rip+dl_system]
    mov rax, [rax+96]
    mov rdx, rdi
    lea rcx, [rip+dl_mapsize]
    lea r8, [rip+dl_mapkey]
    lea r9, [rip+dl_descsize]
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 48
    lea r10, [rip+dl_descver]
    mov [rsp+32], r10
    call qword ptr [rax+56]     # GetMemoryMap
    mov rsp, rbp
    pop rbp
    mov rax, [rip+dl_mapsize]
    ret
f_screen:                       # screen(): the firmware's graphics output; gives back where the screen's pixels are
    push rbp
    mov rbp, rsp
    mov rax, [rip+dl_system]
    mov rax, [rax+96]
    lea rcx, [rip+dl_gopguid]
    xor edx, edx
    lea r8, [rip+dl_gop]
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 32
    call qword ptr [rax+320]    # LocateProtocol
    mov rsp, rbp
    pop rbp
    mov rax, [rip+dl_gop]
    test rax, rax
    jz 1f
    mov rax, [rax+24]           # its mode
    mov rcx, [rax+24]           # where the pixels are
    mov [rip+dl_fb], rcx
    mov rax, [rax+8]            # its mode's shape
    mov ecx, dword ptr [rax+4]
    mov [rip+dl_gw], rcx
    mov ecx, dword ptr [rax+8]
    mov [rip+dl_gh], rcx
    mov ecx, dword ptr [rax+32]
    mov [rip+dl_gs], rcx
    mov rax, [rip+dl_fb]
1:  ret
f_screenx:
    mov rax, [rip+dl_gw]
    ret
f_screeny:
    mov rax, [rip+dl_gh]
    ret
f_screenrow:                    # pixels along a row of the screen's memory (can be more than it shows)
    mov rax, [rip+dl_gs]
    ret
f_key:                          # key(): the last key pressed (its letter), or LOW when none; keys with no letter
    push rbp                    # (arrows, Esc) give their scan code past a thousand
    mov rbp, rsp
    mov rax, [rip+dl_system]
    mov rcx, [rax+48]           # the keyboard (ConIn)
    lea rdx, [rip+dl_key]
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 32
    call qword ptr [rcx+8]      # ReadKeyStroke
    mov rsp, rbp
    pop rbp
    test rax, rax
    jnz 1f
    movzx eax, word ptr [rip+dl_key+2]
    test rax, rax
    jnz 2f
    movzx eax, word ptr [rip+dl_key]
    add rax, 1000
2:  ret
1:  mov eax, LOW
    ret
f_off:                          # off(): switch the machine off (the firmware's ResetSystem, shut down)
    mov rax, [rip+dl_system]
    mov rax, [rax+88]           # runtime services
    mov ecx, 2                  # shut down
    xor edx, edx
    xor r8, r8
    xor r9, r9
    .byte 72, 131, 228, 240     # and rsp, 16-even
    sub rsp, 32
    call qword ptr [rax+104]    # ResetSystem
    jmp dl_exit
f_memmapstep:                   # how many bytes each part of the map takes
    mov rax, [rip+dl_descsize]
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
dl_system: .quad LOW
dl_stack:  .quad LOW
dl_mapsize: .quad LOW
dl_mapkey: .quad LOW
dl_descsize: .quad LOW
dl_descver: .quad LOW
dl_key:    .quad LOW
dl_gop:    .quad LOW
dl_fb:     .quad LOW
dl_gw:     .quad LOW
dl_gh:     .quad LOW
dl_gs:     .quad LOW
dl_gopguid: .byte 0xDE, 0xA9, 0x42, 0x90, 0xDC, 0x23, 0x38, 0x4A, 0x96, 0xFB, 0x7A, 0xDE, 0xD0, 0x80, 0x51, 0x6A
dl_digits: .ascii "123456789ABCD"
dl_tilde:  .ascii "~"
.bss
dl_wbuf:   .skip 400000
