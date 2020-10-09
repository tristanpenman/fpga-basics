#include <math.h>
#include <stdio.h>

int main(int argc, char **argv) {
  printf("memory_initialization_radix=2;\n");
  printf("memory_initialization_vector=\n");
  int c = 1;
  for (int i = 0; i < 64; i++) {
    for (int j = 0; j < 64; j++) {
    fprintf(stdout, "%c", (c || i > j)  ? '1' : '0');
      c = !c;
    }
    c = !c;
    fprintf(stdout, "%c\n", i == 63 ? ';' : ',');
  }

  return 0;
}
