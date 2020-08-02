#include <math.h>
#include <stdio.h>

#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')

int main(int argc, char **argv) {
  printf("memory_initialization_radix=2;\n");
  printf("memory_initialization_vector=\n");
  for (int i = 0; i < 1024; i++) {
    const unsigned char f = (unsigned char)((sinf((float)i * 2.0f * M_PI / 1024.0f) + 1.0f) * 100.0f) + 28;
    fprintf(stderr, "%u\n", f);
    fprintf(stdout, "%c%c%c%c%c%c%c%c%c\n", BYTE_TO_BINARY(f), i == 1023 ? ';' : ',');
  }

  return 0;
}
