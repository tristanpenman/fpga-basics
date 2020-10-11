#include <math.h>
#include <stdio.h>

#define BYTE_TO_BINARY(byte)  \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')

int main(int argc, char **argv) {
  printf("memory_initialization_radix=2;\n");
  printf("memory_initialization_vector=\n");
  int n = 0;
  for (int i = 0; i < 64; i++) {
    for (int j = 0; j < 64; j++) {
      if (i > 0 && i % 16 == 0 && j == 0) {
        n = (n + 1) % 4;
      }
      int s = (i + j) % 16;
      switch (n) {
        case 0:
          fprintf(stdout, "%c%c%c%c00000000%c\n", BYTE_TO_BINARY(s), i == 63 && j == 63 ? ';' : ',');
          break;
        case 1:
          fprintf(stdout, "0000%c%c%c%c0000%c\n", BYTE_TO_BINARY(s), i == 63 && j == 63 ? ';' : ',');
          break;
        case 2:
          fprintf(stdout, "00000000%c%c%c%c%c\n", BYTE_TO_BINARY(s), i == 63 && j == 63 ? ';' : ',');
          break;
        case 3:
          fprintf(stdout, "%c%c%c%c%c%c%c%c0000%c\n", BYTE_TO_BINARY(s), BYTE_TO_BINARY(s), i == 63 && j == 63 ? ';' : ',');
          break;
      }
      if (s == 15) {
        n = (n + 1) % 4;
      }
    }
  }

  return 0;
}
