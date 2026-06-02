#include <iostream>
#include <cstdint>
#include <iomanip>
#include <string>
using namespace std;

const uint8_t DIR_KEYPAD = 0xEE;
const uint8_t DIR_VRAM   = 0xF0;

void mostrarPantalla(uint8_t vram[8]) {
    cout << "\nResultado en pantalla 8x8\n\n";
    cout << "      0 1 2 3 4 5 6 7\n";

    for (int fila = 0; fila < 8; fila++) {
        cout << "Fila " << fila << ": ";

        for (int col = 0; col < 8; col++) {
            int bit = 7 - col;
            bool encendido = (vram[fila] >> bit) & 1;
            cout << (encendido ? "* " : ". ");
        }

        cout << "  VRAM[0x"
             << hex << uppercase << setw(2) << setfill('0')
             << (int)(DIR_VRAM + fila)
             << "] = 0x"
             << setw(2) << (int)vram[fila]
             << dec << setfill(' ')
             << endl;
    }
}

int leerNumero() {
    string entrada;
    cin >> entrada;

    if (entrada.size() > 2 && entrada[0] == '0' &&
        (entrada[1] == 'x' || entrada[1] == 'X')) {
        return stoi(entrada, nullptr, 16);
    }

    return stoi(entrada);
}

int main() {
    uint8_t vram[8];

    cout << "=== CALCULADORA VISUAL PDUA ===\n";
    cout << "Keypad MMIO: 0x" << hex << uppercase << (int)DIR_KEYPAD << endl;
    cout << "VRAM MMIO  : 0x" << hex << uppercase << (int)DIR_VRAM
         << " a 0x" << (int)(DIR_VRAM + 7) << dec << endl;

    while (true) {
        for (int i = 0; i < 8; i++) {
            vram[i] = 0x00;
        }

        cout << "\nIngrese el estado del keypad ";
        cout << "(decimal 0-255 o hexadecimal tipo 0x0A, -1 para salir): ";

        int valor = leerNumero();

        if (valor == -1) {
            break;
        }

        if (valor < 0 || valor > 255) {
            cout << "Valor invalido. Debe estar entre 0 y 255.\n";
            continue;
        }

        uint8_t keypad = static_cast<uint8_t>(valor);

        int boton0 = (keypad >> 0) & 1;
        int boton1 = (keypad >> 1) & 1;
        int boton2 = (keypad >> 2) & 1;
        int boton3 = (keypad >> 3) & 1;
        int boton4 = (keypad >> 4) & 1;
        int boton5 = (keypad >> 5) & 1;
        int boton6 = (keypad >> 6) & 1;
        int boton7 = (keypad >> 7) & 1;

        int orientacion = boton0;

        int n = 0;
        if (boton1 == 1) n++;
        if (boton3 == 1) n++;
        if (boton5 == 1) n++;
        if (boton7 == 1) n++;

        int p = 0;
        if (boton2 == 1) p++;
        if (boton4 == 1) p++;
        if (boton6 == 1) p++;

        int S;
        int spacing;

        if (p > 0) {
            S = 9 * p;
            spacing = n;
        } else {
            S = 4 * n;
            spacing = 0;
        }

        for (int k = 0; k < S; k++) {
            int indice = k * (spacing + 1);

            if (indice >= 64) {
                break;
            }

            int fila;
            int columna;

            if (orientacion == 1) {
                columna = indice / 8;
                fila = indice % 8;
            } else {
                fila = indice / 8;
                columna = indice % 8;
            }

            int bit = 7 - columna;
            vram[fila] = vram[fila] | (1 << bit);
        }

        cout << "\nKeypad leido: ";
        cout << "0x" << hex << uppercase << setw(2) << setfill('0')
             << (int)keypad << dec << setfill(' ') << endl;

        cout << "n impares  = " << n << endl;
        cout << "p pares    = " << p << endl;
        cout << "S LEDs     = " << S << endl;
        cout << "spacing    = " << spacing << endl;
        cout << "orientacion = " << (orientacion ? "vertical" : "horizontal") << endl;

        mostrarPantalla(vram);
    }

    cout << "\nPrograma finalizado.\n";
    return 0;
}
