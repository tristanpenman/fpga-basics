#include <math.h>
#include <stdio.h>

#define SHORT_TO_BINARY(value)  \
  (value & 0x8000 ? '1' : '0'), \
  (value & 0x4000 ? '1' : '0'), \
  (value & 0x2000 ? '1' : '0'), \
  (value & 0x1000 ? '1' : '0'), \
  (value & 0x0800 ? '1' : '0'), \
  (value & 0x0400 ? '1' : '0'), \
  (value & 0x0200 ? '1' : '0'), \
  (value & 0x0100 ? '1' : '0'), \
  (value & 0x0080 ? '1' : '0'), \
  (value & 0x0040 ? '1' : '0'), \
  (value & 0x0020 ? '1' : '0'), \
  (value & 0x0010 ? '1' : '0'), \
  (value & 0x0008 ? '1' : '0'), \
  (value & 0x0004 ? '1' : '0'), \
  (value & 0x0002 ? '1' : '0'), \
  (value & 0x0001 ? '1' : '0')

int main(int argc, char **argv) {
  printf("memory_initialization_radix=2;\n");
  printf("memory_initialization_vector=\n");
  for (int i = 0; i < 1024; i++) {
    const unsigned short f = (unsigned short)((sinf((float)i * 2.0f * M_PI / 1024.0f) + 1.0f) * 32544.0f) + 448;
    fprintf(stderr, "%u\n", f);
    fprintf(stdout, "%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n", SHORT_TO_BINARY(f), i == 1023 ? ';' : ',');
  }

  return 0;
}
