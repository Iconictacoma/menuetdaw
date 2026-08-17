; ==========      ========      ==                  ==
; ============   ==========     ==                  ==
; ==        ==   ==      ==     ==                  ==
; ==        ==   ==      ==     ==                  ==
; ==        ==   ==      ==     ==                  ==
; ==        ==   ==========     ==        ==        ==
; ==        ==   ==========     ==        ==        ==
; ==        ==   ==      ==     ==       ====       ==
; ==        ==   ==      ==     ==       ====       ==
; ==        ==   ==      ==     ==      ======      ==
; ==        ==   ==      ==     ==      ======      ==
; ==        ==   ==      ==     ==     ==    ==     ==
; ==        ==   ==      ==     ==     ==    ==     ==
; ==        ==   ==      ==     ==    ==      ==    ==
; ==        ==   ==      ==     ==    ==      ==    ==
; ============   ==      ==      ======        ======
; ==========     ==      ==      ======        ======
; ========       ==      ==       ====          ====                For MenuetOS

use64
org 0x0

    db 'MENUET64'
    dq 0x01
    dq START
    dq I_END
    dq MEM_END
    dq STACK_END
    dq 0x0
    dq 0x0

START:
    call draw_window

event_loop:
    mov rax, 23
    mov rbx, 1
    syscall

    cmp rax, 1
    je  do_redraw
    cmp rax, 2
    je  do_key
    cmp rax, 3
    je  do_button

    call update_audio

    jmp event_loop

do_redraw:
    call draw_window
    jmp  event_loop

do_key:
    mov rax, 2
    syscall
    jmp event_loop

do_button:
    mov rax, 17
    syscall
    shr rax, 8
    cmp rax, 1
    je  close_app

    cmp rax, 100
    je  play_c
    cmp rax, 101
    je  play_cs
    cmp rax, 102
    je  play_d
    cmp rax, 103
    je  play_ds
    cmp rax, 104
    je  play_e
    cmp rax, 105
    je  play_f
    cmp rax, 200
    je  toggle_play
    cmp rax, 201
    je  toggle_stop

    jmp event_loop

play_c:
    mov word [phase_increment], 512
    jmp event_loop

play_cs:
    mov word [phase_increment], 542
    jmp event_loop

play_d:
    mov word [phase_increment], 574
    jmp event_loop

play_ds:
    mov word [phase_increment], 608
    jmp event_loop

play_e:
    mov word [phase_increment], 645
    jmp event_loop

play_f:
    mov word [phase_increment], 683
    jmp event_loop

toggle_play:
    mov byte [is_playing], 1
    jmp event_loop

toggle_stop:
    mov byte [is_playing], 0
    mov word [phase_acc], 0
    jmp event_loop

close_app:
    mov rax, -1
    syscall

draw_window:
    mov rax, 12
    mov rbx, 1
    syscall

    mov rax, 0
    mov rbx, (100 shl 32) + 640
    mov rcx, (100 shl 32) + 420
    mov rdx, 0x00222222
    mov r8,  0x00FFFFFF
    mov r9,  0x00000000
    mov r10, window_title
    syscall

    mov rax, 13
    mov rbx, (20 shl 32) + 600
    mov rcx, (40 shl 32) + 30
    mov rdx, 0x001A1A1A
    syscall

    mov rax, 8
    mov rbx, (30 shl 32) + 60
    mov rcx, (45 shl 32) + 20
    mov rdx, 200
    mov r8,  0x002E7D32
    syscall

    mov rax, 4
    mov rbx, (43 shl 32) + 52
    mov rcx, 0x00FFFFFF
    mov rdx, lbl_play
    mov r8, 4
    syscall

    mov rax, 8
    mov rbx, (100 shl 32) + 60
    mov rcx, (45 shl 32) + 20
    mov rdx, 201
    mov r8,  0x00C62828
    syscall

    mov rax, 4
    mov rbx, (113 shl 32) + 52
    mov rcx, 0x00FFFFFF
    mov rdx, lbl_stop
    mov r8, 4
    syscall

    mov rax, 13
    mov rbx, (120 shl 32) + 500
    mov rcx, (90 shl 32) + 150
    mov rdx, 0x00141414
    syscall

    mov rax, 38
    mov rbx, (120 shl 32) + 620
    mov rcx, (140 shl 32) + 140
    mov rdx, 0x00333333
    syscall

    mov rax, 38
    mov rbx, (120 shl 32) + 620
    mov rcx, (190 shl 32) + 190
    mov rdx, 0x00333333
    syscall

    mov rax, 8
    mov rbx, (20 shl 32) + 28
    mov rcx, (260 shl 32) + 110
    mov rdx, 100
    mov r8,  0x00EEEEEE
    syscall

    mov rax, 8
    mov rbx, (50 shl 32) + 28
    mov rcx, (260 shl 32) + 110
    mov rdx, 102
    mov r8,  0x00EEEEEE
    syscall

    mov rax, 8
    mov rbx, (80 shl 32) + 28
    mov rcx, (260 shl 32) + 110
    mov rdx, 104
    mov r8,  0x00EEEEEE
    syscall

    mov rax, 8
    mov rbx, (110 shl 32) + 28
    mov rcx, (260 shl 32) + 110
    mov rdx, 105
    mov r8,  0x00EEEEEE
    syscall

    mov rax, 8
    mov rbx, (40 shl 32) + 16
    mov rcx, (260 shl 32) + 65
    mov rdx, 101
    mov r8,  0x00111111
    syscall

    mov rax, 8
    mov rbx, (70 shl 32) + 16
    mov rcx, (260 shl 32) + 65
    mov rdx, 103
    mov r8,  0x00111111
    syscall

    mov rax, 12
    mov rbx, 2
    syscall
    ret

update_audio:
    cmp byte [is_playing], 0
    je  .silent

    mov rdi, audio_buffer
    mov rcx, 512
    call render_audio_buffer

    mov rax, 55
    mov rbx, 0
    mov rcx, audio_buffer
    mov rdx, 2048
    syscall
    ret

.silent:
    ret

render_audio_buffer:
    push rax
    push rbx

.render_loop:
    mov ax, [phase_acc]
    add ax, [phase_increment]
    mov [phase_acc], ax

    mov [rdi], ax
    mov [rdi + 2], ax

    add rdi, 4
    dec rcx
    jnz .render_loop

    pop rbx
    pop rax
    ret

window_title:
    db 'MenuetOS Assembly DAW v0.2', 0

lbl_play:
    db 'PLAY', 0

lbl_stop:
    db 'STOP', 0

phase_acc:        dw 0
phase_increment:  dw 512
is_playing:       db 0

I_END:
    rb 4096
audio_buffer:
    rb 2048
STACK_END:
    rb 8192
MEM_END: