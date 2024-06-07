#include "lib.h"


void _start(){
  char buffer[100];
  int t0, t1, number = 635;
  t0 = time();
  sleep(number);
  t1 = time();
  puts(itoa(t1-t0, buffer, 10));

}


/*
char buffer[100];
char img[40000];
int number = 635;

void run_operation(int op){
  int t0, t1, x, y, y_b, x_c, t_a, t_b, t_c, t_r, width, height, i, j; 
  char filter[3][3];
  switch (op){
  case 0:
    puts(buffer);
    break;

  case 1:
    gets(buffer);
    puts(buffer);
    break;

  case 2:
    puts(itoa(number, buffer, 10));
    break;

  case 3:
    puts(itoa(atoi(gets(buffer)), buffer, 16));
    break;

  case 4:
    t0 = time();
    sleep(number);
    t1 = time();
    puts(itoa(t1-t0, buffer, 10));
    break;

  case 5:
    puts(itoa(time(), buffer, 10));
    break;

  case 6:
    puts(itoa(approx_sqrt(number, 40), buffer, 10));
    break;

  case 7:
    t0 = time();
    approx_sqrt(number, 100);
    t1 = time();
    puts(itoa(t1-t0, buffer, 10));
    puts(itoa(number, buffer, 10));
    break;

  case 9:
    width = atoi(gets(buffer));
    height = atoi(gets(buffer));
    for (i = 0; i < 3; i++){
      for (j = 0; j < 3; j++){
        filter[i][j] = atoi(gets(buffer));
      } 
    }
    imageFilter(img, width, height, filter);
    for (i = 0; i < height; i++){      
      for (j = 0; j < width; j++){
        puts(itoa(img[i*width + j], buffer, 10));
      } 
    }
    break;

  case 10:
    gets(buffer);
    puts(buffer);
    gets(buffer);
    puts(buffer);
    break;
  
  default:
    break;
  }
}

void _start(){
  int operation = atoi(gets(buffer));
  run_operation(operation);
  exit(0);
}
*/

