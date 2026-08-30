global xeravend_start
extern xkmain

section .text
bits 32
xeravend_start:
    mov esp, stack_top

    ; Multiboot2 guarantees eax = magic, ebx = boot info pointer at entry.
    ; Stash them somewhere safe before any call clobbers them - you'll
    ; want ebx (the boot info pointer) once you get to memory management.
    mov edi, eax        ; edi = multiboot magic
    mov esi, ebx        ; esi = multiboot info pointer

    call check_cpuid
    call check_long_mode

    call set_up_page_tables
    call enable_paging

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start

; ---------------------------------------------------------------------
; check_cpuid: verifies the CPUID instruction itself is available by
; attempting to flip the ID bit (bit 21) of EFLAGS. If the CPU is too
; old to support CPUID, the bit won't stick.
; ---------------------------------------------------------------------
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .no_cpuid
    ret
.no_cpuid:
    mov esi, msg_no_cpuid
    jmp error

; ---------------------------------------------------------------------
; check_long_mode: uses CPUID to check (a) extended functions are
; available at all, then (b) the long-mode-supported bit (bit 29 of
; EDX from extended function 0x80000001).
; ---------------------------------------------------------------------
check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode
    ret
.no_long_mode:
    mov esi, msg_no_long_mode
    jmp error

; ---------------------------------------------------------------------
; set_up_page_tables: identity-maps the first 1GiB of memory using
; 2MiB pages: one PML4 entry -> one PDPT entry -> 512 PD entries.
; Long mode requires paging to be active before the switch.
; ---------------------------------------------------------------------
set_up_page_tables:
    mov eax, p3_table
    or eax, 0b11            ; present + writable
    mov [p4_table], eax

    mov eax, p2_table
    or eax, 0b11
    mov [p3_table], eax

    mov ecx, 0
.map_p2_table:
    mov eax, 0x200000       ; 2MiB
    mul ecx
    or eax, 0b10000011      ; present + writable + huge page
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ret

; ---------------------------------------------------------------------
; enable_paging: points CR3 at the page tables, enables PAE, sets the
; long-mode-enable bit in the EFER MSR, then flips CR0.PG.
; ---------------------------------------------------------------------
enable_paging:
    mov eax, p4_table
    mov cr3, eax

    mov eax, cr4
    or eax, 1 << 5           ; PAE
    mov cr4, eax

    mov ecx, 0xC0000080      ; EFER MSR
    rdmsr
    or eax, 1 << 8           ; LME
    wrmsr

    mov eax, cr0
    or eax, 1 << 31          ; PG
    mov cr0, eax

    ret

; ---------------------------------------------------------------------
; VGA text mode is memory-mapped at 0xb8000: 80x25 cells, 2 bytes per
; cell (ASCII byte, then attribute byte). No driver needed to write
; here in protected mode - it's just ordinary memory at that address.
; ---------------------------------------------------------------------
VGA_TEXT_BUFFER equ 0xb8000
VGA_COLS        equ 80
VGA_ROWS        equ 25
ERR_ATTR        equ 0x4f        ; white text on red background

; ---------------------------------------------------------------------
; print_string: clears the screen, then prints a null-terminated
; string starting at the top-left corner. Input: esi = string pointer.
; Clobbers eax, ecx, edi.
; ---------------------------------------------------------------------
print_string:
    mov edi, VGA_TEXT_BUFFER
    mov ecx, VGA_COLS * VGA_ROWS
    mov ax, (ERR_ATTR << 8) | ' '
.clear:
    mov [edi], ax
    add edi, 2
    loop .clear

    mov edi, VGA_TEXT_BUFFER
.print_char:
    mov al, [esi]
    cmp al, 0
    je .done
    mov ah, ERR_ATTR
    mov [edi], ax
    add edi, 2
    inc esi
    jmp .print_char
.done:
    ret

; ---------------------------------------------------------------------
; halt_forever: disables interrupts, then halts in a loop. A single
; hlt can technically be woken by an NMI and fall through to the next
; instruction, so this loops back into hlt rather than trusting one
; call to stop the CPU for good.
; ---------------------------------------------------------------------
halt_forever:
    cli
.hang:
    hlt
    jmp .hang

; ---------------------------------------------------------------------
; error: esi must point at a null-terminated message before jumping
; here. Prints it full-screen in white-on-red, then halts for good.
; Used for conditions we can't recover from before we have any real
; drivers or panic handling in the 64-bit kernel.
; ---------------------------------------------------------------------
error:
    call print_string
    jmp halt_forever

section .bss
align 16
stack_bottom:
    resb 4096 * 4
stack_top:

align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

section .rodata
msg_no_cpuid:
    db "FATAL ERROR: CPUID instruction is not supported on this CPU.", 0
msg_no_long_mode:
    db "FATAL ERROR: This CPU does not support 64-bit (long mode). Xeravend requires an x86-64 CPU.", 0

gdt64:
    dq 0                                        ; null descriptor
.code_segment: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53)    ; executable, code, present, 64-bit
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

section .text
bits 64
long_mode_start:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call xkmain
    hlt
