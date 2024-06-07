#include <stdio.h>

int pwr(int base, int exp){
    int pot=1;
    for(int i=0;i<exp;i++){
        pot*=base;
    }
    return pot;
}
int cvtBinLlteToInt(int buff[32],unsigned int stridx,unsigned int stpidx){
      int ans=0;
      for(int i=0,j=stridx;j<=stpidx;i++,j++){
         ans+=buff[j]*pwr(2,i);
      }
      return ans;
}

int main(int argc, char *argv[]) {
   printf("0 -%s\n",argv[0]);
   printf("1--%c\n",argv[1][1]);
   printf("2--%s\n",argv[2]);
   printf("3--%s\n",argv[3]);

}