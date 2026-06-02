START:
    ; Leer keypad desde el puerto 0xEE
    MOV ACC, 0xEE
    MOV DPTR, ACC
    MOV ACC, [DPTR]
    MOV A, ACC

    ; Caso 1: botones 1 y 3 = 0x0A
    ; Se compara sumando el complemento a 2: 0xF6 + 0x0A = 0
    MOV ACC, 0xF6
    ADD ACC, A
    JZ CASE1

    ; Caso 2: botones 0 y 2 = 0x05
    MOV ACC, 0xFB
    ADD ACC, A
    JZ CASE2

    ; Caso 3: botones 0, 1, 2 y 3 = 0x0F
    MOV ACC, 0xF1
    ADD ACC, A
    JZ CASE3

    ; Caso 5: todos los botones = 0xFF
    MOV ACC, 0x01
    ADD ACC, A
    JZ CASE5

BLANK:
    ; Caso 4 o cualquier otro valor: matriz apagada
    MOV ACC, 0x00
    MOV A, ACC

    MOV ACC, 0xF0
    CALL WRITE_A
    MOV ACC, 0xF1
    CALL WRITE_A
    MOV ACC, 0xF2
    CALL WRITE_A
    MOV ACC, 0xF3
    CALL WRITE_A
    MOV ACC, 0xF4
    CALL WRITE_A
    MOV ACC, 0xF5
    CALL WRITE_A
    MOV ACC, 0xF6
    CALL WRITE_A
    MOV ACC, 0xF7
    CALL WRITE_A

    JMP START

CASE1:
    ; Solo impares: n = 2, p = 0, horizontal, S = 8
    ; Fila 0 completa encendida
    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0xFF
    MOV [DPTR], ACC

    MOV ACC, 0x00
    MOV A, ACC

    MOV ACC, 0xF1
    CALL WRITE_A
    MOV ACC, 0xF2
    CALL WRITE_A
    MOV ACC, 0xF3
    CALL WRITE_A
    MOV ACC, 0xF4
    CALL WRITE_A
    MOV ACC, 0xF5
    CALL WRITE_A
    MOV ACC, 0xF6
    CALL WRITE_A
    MOV ACC, 0xF7
    CALL WRITE_A

    JMP START

CASE2:
    ; Par sin impares: n = 0, p = 1, vertical, S = 9
    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0xC0
    MOV [DPTR], ACC

    MOV ACC, 0x80
    MOV A, ACC

    MOV ACC, 0xF1
    CALL WRITE_A
    MOV ACC, 0xF2
    CALL WRITE_A
    MOV ACC, 0xF3
    CALL WRITE_A
    MOV ACC, 0xF4
    CALL WRITE_A
    MOV ACC, 0xF5
    CALL WRITE_A
    MOV ACC, 0xF6
    CALL WRITE_A
    MOV ACC, 0xF7
    CALL WRITE_A

    JMP START

CASE3:
    ; Par e impares: n = 2, p = 1, vertical, S = 9
    ; Indices activos: 0, 3, 6, 9, 12, 15, 18, 21, 24
    MOV ACC, 0xF0
    MOV DPTR, ACC
    MOV ACC, 0x90
    MOV [DPTR], ACC

    MOV ACC, 0x40
    MOV A, ACC

    MOV ACC, 0xF1
    CALL WRITE_A
    MOV ACC, 0xF4
    CALL WRITE_A
    MOV ACC, 0xF7
    CALL WRITE_A

    MOV ACC, 0x20
    MOV A, ACC

    MOV ACC, 0xF2
    CALL WRITE_A
    MOV ACC, 0xF5
    CALL WRITE_A

    MOV ACC, 0x80
    MOV A, ACC

    MOV ACC, 0xF3
    CALL WRITE_A
    MOV ACC, 0xF6
    CALL WRITE_A

    JMP START

CASE5:
    ; Todos oprimidos: n = 4, p = 3, vertical, S = 27
    ; Solo 13 LEDs quedan dentro de la matriz 8x8
    MOV ACC, 0x84
    MOV A, ACC

    MOV ACC, 0xF0
    CALL WRITE_A
    MOV ACC, 0xF5
    CALL WRITE_A

    MOV ACC, 0x10
    MOV A, ACC

    MOV ACC, 0xF1
    CALL WRITE_A
    MOV ACC, 0xF6
    CALL WRITE_A

    MOV ACC, 0x42
    MOV A, ACC

    MOV ACC, 0xF2
    CALL WRITE_A
    MOV ACC, 0xF7
    CALL WRITE_A

    MOV ACC, 0xF3
    MOV DPTR, ACC
    MOV ACC, 0x08
    MOV [DPTR], ACC

    MOV ACC, 0xF4
    MOV DPTR, ACC
    MOV ACC, 0x21
    MOV [DPTR], ACC

    JMP START

WRITE_A:
    ; Subrutina: escribe el valor de A en la direccion que viene en ACC
    MOV DPTR, ACC
    MOV ACC, A
    MOV [DPTR], ACC
    RET
