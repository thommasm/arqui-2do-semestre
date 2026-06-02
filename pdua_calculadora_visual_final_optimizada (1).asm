
MAIN:
    ; Leer Keypad desde direccion 0xEE
    MOV ACC, 0xEE
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    MOV A, ACC

    ; Caso 1: botones 1 y 3 -> 0x0A
    MOV ACC, 0x0A
    SUB ACC, A
    JZ C1

    ; Caso 2: botones 0 y 2 -> 0x05
    MOV ACC, 0x05
    SUB ACC, A
    JZ C2

    ; Caso 3: botones 0, 1, 2 y 3 -> 0x0F
    MOV ACC, 0x0F
    SUB ACC, A
    JZ C3

    ; Caso 5: todos los botones -> 0xFF
    MOV ACC, 0xFF
    SUB ACC, A
    JZ C5

    ; Caso 4 o cualquier combinacion no contemplada: limpiar pantalla
    CALL CLEAR
    JMP MAIN

; =============================================================
; C1: Solo impares
; n = 2, p = 0, orientacion horizontal
; S = 4n = 8 LEDs continuos
; Resultado: fila 0 completa encendida = 0xFF
; =============================================================
C1:
    CALL CLEAR
    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0xFF
    MOV [DPTR], ACC
    JMP MAIN

; =============================================================
; C2: Par sin impares
; n = 0, p = 1, orientacion vertical
; S = 9 LEDs continuos
; Resultado: columna 0 completa y un LED en columna 1, fila 0
; =============================================================
C2:
    CALL CLEAR

    ; 0xE9 guarda direccion actual de VRAM, inicia en 0xF0
    MOV ACC, 0xE9
    MOV DPTR, ACC
    MOV ACC, 0xF0
    MOV [DPTR], ACC

    ; 0xEA guarda contador de filas, inicia en 8
    MOV ACC, 0xEA
    MOV DPTR, ACC
    MOV ACC, 0x08
    MOV [DPTR], ACC

L2:
    ; Escribir 0x80 en la fila actual: prende columna izquierda
    MOV ACC, 0xE9
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    MOV DPTR, ACC
    MOV ACC, 0x80
    MOV [DPTR], ACC

    ; Incrementar direccion de VRAM guardada en 0xE9
    MOV ACC, 0xE9
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    INC ACC
    MOV [DPTR], ACC

    ; Decrementar contador 0xEA usando resta de 1
    MOV ACC, 0x01
    MOV A, ACC
    MOV ACC, 0xEA
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    SUB ACC, A
    MOV [DPTR], ACC

    ; Cuando contador llega a cero, terminar columna
    JZ R2
    JMP L2

R2:
    ; Ajustar fila 0 a 0xC0 para prender columna 0 y columna 1
    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0xC0
    MOV [DPTR], ACC
    JMP MAIN

; =============================================================
; C3: Par e impares
; n = 2, p = 1, orientacion vertical
; S = 9 intercalado con step = 3
; Patrones por fila ya calculados para ahorrar memoria
; =============================================================
C3:
    CALL CLEAR

    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0x90
    MOV [DPTR], ACC

    MOV ACC, 0xF1
    MOV DPTR, ACC
    MOV ACC, 0x40
    MOV [DPTR], ACC

    MOV ACC, 0xF2
    MOV DPTR, ACC
    MOV ACC, 0x20
    MOV [DPTR], ACC

    MOV ACC, 0xF3
    MOV DPTR, ACC
    MOV ACC, 0x80
    MOV [DPTR], ACC

    MOV ACC, 0xF4
    MOV DPTR, ACC
    MOV ACC, 0x40
    MOV [DPTR], ACC

    MOV ACC, 0xF5
    MOV DPTR, ACC
    MOV ACC, 0x20
    MOV [DPTR], ACC

    MOV ACC, 0xF6
    MOV DPTR, ACC
    MOV ACC, 0x80
    MOV [DPTR], ACC

    MOV ACC, 0xF7
    MOV DPTR, ACC
    MOV ACC, 0x40
    MOV [DPTR], ACC
    JMP MAIN

; =============================================================
; C5: Todos los botones oprimidos
; n = 4, p = 3, orientacion vertical
; S = 27, step = 5, 13 LEDs visibles
; Patrones por fila ya calculados para ahorrar memoria
; =============================================================
C5:
    CALL CLEAR

    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0x84
    MOV [DPTR], ACC

    MOV ACC, 0xF1
    MOV DPTR, ACC
    MOV ACC, 0x10
    MOV [DPTR], ACC

    MOV ACC, 0xF2
    MOV DPTR, ACC
    MOV ACC, 0x42
    MOV [DPTR], ACC

    MOV ACC, 0xF3
    MOV DPTR, ACC
    MOV ACC, 0x08
    MOV [DPTR], ACC

    MOV ACC, 0xF4
    MOV DPTR, ACC
    MOV ACC, 0x21
    MOV [DPTR], ACC

    MOV ACC, 0xF5
    MOV DPTR, ACC
    MOV ACC, 0x84
    MOV [DPTR], ACC

    MOV ACC, 0xF6
    MOV DPTR, ACC
    MOV ACC, 0x10
    MOV [DPTR], ACC

    MOV ACC, 0xF7
    MOV DPTR, ACC
    MOV ACC, 0x42
    MOV [DPTR], ACC
    JMP MAIN

; =============================================================
; CLEAR: limpia VRAM desde 0xF0 hasta 0xF7
; Usa:
;   0xE9 = direccion actual de VRAM
;   0xEA = contador de 8 filas
; =============================================================
CLEAR:
    ; direccion inicial = 0xF0
    MOV ACC, 0xE9
    MOV DPTR, ACC
    MOV ACC, 0xF0
    MOV [DPTR], ACC

    ; contador = 8
    MOV ACC, 0xEA
    MOV DPTR, ACC
    MOV ACC, 0x08
    MOV [DPTR], ACC

LC:
    ; RAM[ RAM[0xE9] ] = 0x00
    MOV ACC, 0xE9
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    MOV DPTR, ACC
    MOV ACC, 0x00
    MOV [DPTR], ACC

    ; RAM[0xE9] = RAM[0xE9] + 1
    MOV ACC, 0xE9
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    INC ACC
    MOV [DPTR], ACC

    ; RAM[0xEA] = RAM[0xEA] - 1
    MOV ACC, 0x01
    MOV A, ACC
    MOV ACC, 0xEA
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    SUB ACC, A
    MOV [DPTR], ACC

    ; Si contador llega a cero, salir de CLEAR
    JZ EC
    JMP LC

EC:
    RET
