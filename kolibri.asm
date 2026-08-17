use32
org 0x0

    db 'MENUET01'
    dd 0x01
    dd START
    dd I_END
    dd MEM_END
    dd STACK_END
    dd 0x0
    dd 0x0

START:
    call draw_window

event_loop:
    mov eax, 23
    mov ebx, 1
    int 0x40

    cmp eax, 1
    je  do_redraw
    cmp eax, 2
    je  do_key
    cmp eax, 3
    je  do_button

    call update_audio

    jmp event_loop

do_redraw:
    call draw_window
    jmp  event_loop

do_key:
    mov eax, 2
    int 0x40
    jmp event_loop

do_button:
    mov eax, 17
    int 0x40
    shr eax, 8
    cmp eax, 1
    je  close_app

    cmp eax, 100
    je  play_c
    cmp eax, 101
    je  play_cs
    cmp eax, 102
    je  play_d
    cmp eax, 103
    je  play_ds
    cmp eax, 104
    je  play_e
    cmp eax, 105
    je  play_f
    cmp eax, 200
    je  toggle_play
    cmp eax, 201
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
    mov eax, -1
    int 0x40

draw_window:
    mov eax, 12
    mov ebx, 1
    int 0x40

    mov eax, 0
    mov ebx, (100 shl 16) + 640
    mov ecx, (100 shl 16) + 420
    mov edx, 0x34222222
    mov esi, 0x00FFFFFF
    mov edi, window_title
    int 0x40

    mov eax, 13
    mov ebx, (20 shl 16) + 600
    mov ecx, (40 shl 16) + 30
    mov edx, 0x001A1A1A
    int 0x40

    mov eax, 8
    mov ebx, (30 shl 16) + 60
    mov ecx, (45 shl 16) + 20
    mov edx, 200
    mov esi, 0x002E7D32
    int 0x40

    mov eax, 4
    mov ebx, (43 shl 16) + 52
    mov ecx, 0x00FFFFFF
    mov edx, lbl_play
    mov esi, 4
    int 0x40

    mov eax, 8
    mov ebx, (100 shl 16) + 60
    mov ecx, (45 shl 16) + 20
    mov edx, 201
    mov esi, 0x00C62828
    int 0x40

    mov eax, 4
    mov ebx, (113 shl 16) + 52
    mov ecx, 0x00FFFFFF
    mov edx, lbl_stop
    mov esi, 4
    int 0x40

    mov eax, 13
    mov ebx, (120 shl 16) + 500
    mov ecx, (90 shl 16) + 150
    mov edx, 0x00141414
    int 0x40

    mov eax, 38
    mov ebx, (120 shl 16) + 620
    mov ecx, (140 shl 16) + 140
    mov edx, 0x00333333
    int 0x40

    mov eax, 38
    mov ebx, (120 shl 16) + 620
    mov ecx, (190 shl 16) + 190
    mov edx, 0x00333333
    int 0x40

    mov eax, 8
    mov ebx, (20 shl 16) + 28
    mov ecx, (260 shl 16) + 110
    mov edx, 100
    mov esi, 0x00EEEEEE
    int 0x40

    mov eax, 8
    mov ebx, (50 shl 16) + 28
    mov ecx, (260 shl 16) + 110
    mov edx, 102
    mov esi, 0x00EEEEEE
    int 0x40

    mov eax, 8
    mov ebx, (80 shl 16) + 28
    mov ecx, (260 shl 16) + 110
    mov edx, 104
    mov esi, 0x00EEEEEE
    int 0x40

    mov eax, 8
    mov ebx, (110 shl 16) + 28
    mov ecx, (260 shl 16) + 110
    mov edx, 105
    mov esi, 0x00EEEEEE
    int 0x40

    mov eax, 8
    mov ebx, (40 shl 16) + 16
    mov ecx, (260 shl 16) + 65
    mov edx, 101
    mov esi, 0x00111111
    int 0x40

    mov eax, 8
    mov ebx, (70 shl 16) + 16
    mov ecx, (260 shl 16) + 65
    mov edx, 103
    mov esi, 0x00111111
    int 0x40

    mov eax, 12
    mov ebx, 2
    int 0x40
    ret

update_audio:
    cmp byte [is_playing], 0
    je  .silent

    mov edi, audio_buffer
    mov ecx, 512
    call render_audio_buffer

    mov eax, 55
    mov ebx, 0
    mov ecx, audio_buffer
    mov edx, 2048
    int 0x40
    ret

.silent:
    ret

render_audio_buffer:
    push eax
    push ebx

.render_loop:
    mov ax, [phase_acc]
    add ax, [phase_increment]
    mov [phase_acc], ax

    mov [edi], ax
    mov [edi + 2], ax

    add edi, 4
    dec ecx
    jnz .render_loop

    pop ebx
    pop eax
    ret

window_title:
    db 'Menuetdaw KOLIBRI VERSION', 0

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