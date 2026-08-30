global xeravend_start
extern xkmain

section .text
bits 32
xeravend_start:
    ; print 'OK'
    ;mov dword [0xb8000], 0x2f4b2f4f
    mov esp, stack_top
    call xkmain
    hlt

section .bss
stack_bottom:
    resb 4096 * 4
stack_top:
