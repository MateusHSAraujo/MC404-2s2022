
int read(int __fd, const void *__buf, int __n){
  int bytes;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read (63) \n"
    "ecall \n"
    "mv %0, a0"
    : "=r"(bytes)  // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return bytes;
}
 
void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void dectobin (int n, int bin[32]){
    
    int div=n;
    if(n<0){
        div=n*(-1);
    }
    int rest;
    int i=0;
    while (div!=0)
    {
        rest=div%2;
        bin[31-i]=rest;
        div=div/2;
        i++;
    }
    
    return ;
}


void cmpl2 (int bin[32]) {
    for(int i=0;i<32;i++){
        bin[i]=!(bin[i]);
    }
    for(int i=0;i<32;i++){
        if(bin[31-i]==0){
            bin[31-i]=1;
            break;
        } else{
            bin[31-i]=0;
        }
    }
    return;
}

char digitBinToHex(int d3, int d2, int d1, int d0){
    char rtn;
    if(d3==0){
        if(d2==0){
            if(d1==0){
                if(d0==0){
                    rtn='0';
                } else {
                    rtn='1';
                }
            } else{
                 if(d0==0){
                    rtn='2';
                } else{
                    rtn='3';
                }
            }
        } else{
            if(d1==0){
                if(d0==0){
                    rtn='4';
                } else{
                    rtn='5';
                }
            } else{
                 if(d0==0){
                    rtn='6';
                } else {
                    rtn='7';
                }
            }
        }
    }else {
        if(d2==0){
            if(d1==0){
                if(d0==0){
                    rtn='8';
                } else{
                    rtn='9';
                }
            } else{
                if(d0==0){
                    rtn='a';
                } else{
                    rtn='b';
                }
            }
        } else{
            if(d1==0){
                if(d0==0){
                    rtn='c';
                } else{
                    rtn='d';
                }
            } else{
                if(d0==0){
                    rtn='e';
                } else{
                    rtn='f';
                }
            }
        }
    }
    return rtn;
}

long long int powe(int base, int exp){
    long long int pot=1;
    for(int i=0;i<exp;i++){
        pot*=base;
    }
    return pot;
}

long long int swEd(int sbin[32]){
    int swbin[32];
    long long int cvrt=0;
    for(int i=0; i<32; i++){
        swbin[i]=0;
    }
    for(int i=0; i<32;i+=8){
        int j=0;
        while (j<=8){
            swbin[i+j]=sbin[32-i-(8-j)];
            j++;
        }
    }

    for(int i=0; i<32; i++){
        cvrt+=(swbin[i])*(powe(2,(31-i)));
    }
    return cvrt;
}

void sbinToHex(int sbin[32], char hex[8]){
    for(int i=0, j=0; i<32;i+=4, j++){
        hex[j]=digitBinToHex(sbin[i],sbin[i+1],sbin[i+2],sbin[i+3]);
    }
}


int hexDigitToInt(char d){
    int rtn;
    if (d=='a' || d=='b' || d=='c' || d=='d' || d=='e' || d=='f'){
        rtn = d-87;
    } else {
        rtn = d-48;
    }
    return rtn;
}

int hexVctToInt (int* vct, int tam){
    int sum=0;
    for(int i=0;i<tam;i++){
        sum +=(*(vct+i) )*powe(16,tam-1-i); 
    }
    return sum;
}


int decVctToInt (int* vct, int tam){
    int sum=0;
    for(int i=0;i<tam;i++){
        sum +=(*(vct+i) )*powe(10,tam-1-i); 
    }
    return sum;
}

int convertInput(char str[20], int n){
    int conversion=0;

    if (str[0]=='0' && str[1]=='x') { 
        int tam=n-3;
        int vct[n-3];
        for(int i=2, j=0; i<n-1; i++, j++){
            vct[j]=hexDigitToInt(str[i]);
        }
        conversion = hexVctToInt(vct,tam);

    } else if (str[0]!='-') {
        int tam=n-1;
        int vct[n-1];
        for(int i=0, j=0; i<n-1; i++, j++){
            vct[j]=str[i]-48;
        }
       conversion= decVctToInt(vct, tam);

    } else {
        int tam=n-2;
        int vct[tam];
        for(int i=1, j=0; i<n-1; i++, j++){
            vct[j]=str[i]-48;
        }
        conversion= (decVctToInt(vct, tam))*(-1);
    }
    
    return conversion;
}

void printBin(int bin[32]){
    int tamBin=32;
    int strIndex=0;
    for(int i=0;i<32;i++){
        if (bin[i]==1){
            strIndex=i;
            break;
        } else {
            tamBin--;
        }
    }

    char str[tamBin+4];
    str[0]='0';
    str[1]='b';
    for(int i=0, j=0; i<tamBin;i++, j++){
        str[2+j]=bin[strIndex+i]+'0';
    }
    str[tamBin+2]='\n';
    str[tamBin+3]='\0';
    write(1, str, tamBin+4);//aqui

}

void printDec(int dec){
    int tam=0;
    unsigned long int dive;
    if(dec<0){
        dive=dec*(-1);
    }else{
        dive=dec;
    }

    while (dive!=0)
    {
        dive=dive/10;
        tam++;
    }

    if(dec<0){
        char str[tam+3];
        str[0]='-';
        str[tam+1]='\n';
        str[tam+2]='\0';
        for(unsigned long int div=dec*(-1), i=0; div!=0;div=div/10, i++){
            int rest;
            rest=div%10;
            str[tam-i]=rest+'0';
        }
        write(1, str, tam+3); //aqui
    } else {
        char str[tam+2];
        str[tam]='\n';
        str[tam+1]='\0';
        for(unsigned long int div=dec, i=0; div!=0;div=div/10, i++){
            int rest;
            rest=div%10;
            str[tam-1-i]=rest+'0';
        }
        write(1, str, tam+2); //aqui
    }

}

void printDecLL(unsigned long int dec){
    int tam=0;
    unsigned long int dive = dec;
    if(dec<0){
        dive=dec*(-1);
    }
    
    while (dive!=0)
    {
        dive=dive/10;
        tam++;
    }

    if(dec<0){
        char str[tam+3];
        str[0]='-';
        str[tam+1]='\n';
        str[tam+2]='\0';
        int i = 0;
        for(unsigned long int div=dec*(-1); div!=0;div=div/10){
            int rest;
            rest=div%10;
            str[tam-i]=rest+'0';
            i++;
        }
        write(1, str, tam+3); //aqui
    } else {
        char str[tam+2];
        str[tam]='\n';
        str[tam+1]='\0';
        int i=0;
        for(unsigned long int div=dec; div!=0;div=div/10){
            int rest;
            rest=div%10;
            str[tam-1-i]=rest+'0';
            i++;
        }
        write(1, str, tam+2); //aqui
    }


}


void printHex(char hex[8]){
    int tamHex=8;
    int strIndex=0;
    for(int i=0;i<8;i++){
        if (hex[i]!='0'){
            strIndex=i;
            break;
        } else {
            tamHex--;
        }
    }

    char str[tamHex+4];
    str[0]='0';
    str[1]='x';
    for(int i=0, j=0; i<tamHex;i++, j++){
        str[2+j]=hex[strIndex+i];
    }
    str[tamHex+2]='\n';
    str[tamHex+3]='\0';
    
    write(1, str, tamHex+4); //aqui

}

int main()
{
    char str[20];
    int bin[32];
    char hex[8];

    int n = read(0, str, 20);

    int decimal= convertInput(str,n);
    for(int i=0; i<32;i++){
      hex[i]='0';
    }
    for(int i=0; i<32;i++){
      bin[i]=0;
    }

    dectobin(decimal, bin);
    if (decimal<0){
      cmpl2(bin);
    }
    sbinToHex(bin,hex);
    unsigned long int swpEdianess=swEd(bin);

    printBin(bin);
    printDec(decimal);
    printHex(hex);
    printDecLL(swpEdianess);

    return 0;
}
 
void _start(){
  main();
}