#include "api_car.h"
int main(){
    unsigned char img[256];
    char filter[]={3,4,0};
    for(int i=0,j=1; i<256; i++, j++){
        if(j>=5){
            j=1;
        }
        img[i]=j;
    }

    

    filter_1d_image(img,filter);

    for(int i=0; i<256; i++){
        char buffer[10];
        itoa(img[i],buffer,10);
        puts(buffer);
    }
}