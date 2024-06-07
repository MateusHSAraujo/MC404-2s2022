#define _FILE_OFFSET_BITS 64
#define _LARGEFILE_SOURCE
#define _LARGE_FILES

#include <fcntl.h>
#include <unistd.h>

struct section_header{
   unsigned char sh_name[4];
   unsigned char sh_type[4];
   unsigned char sh_flags[4];
   unsigned char sh_addr[4];
   unsigned char sh_offset[4];
   unsigned char sh_size[4];
   unsigned char sh_link[4];
   unsigned char sh_info[4];
   unsigned char sh_addralign[4];
   unsigned char sh_entsize[4];

};
typedef struct section_header section_header;

struct file_header{
   unsigned int e_shoff; //índice do começo do header da tabela de seções
   unsigned int e_shnum; //Número de entradas na tabela de seções
   unsigned int e_shstrndx; //indice do header que contém o nome das seções
};
typedef struct file_header file_header;

struct string_table{
   unsigned int size;
   unsigned int offset;
};
typedef struct string_table string_table;

struct symble_table{
   unsigned int size;
   unsigned int offset;
   unsigned int entries;
};
typedef struct symble_table symble_table;

//Essa lê uma certa quantidade de bits a partir de um certo off set em um arquivo
void readNBitsAt(int n, unsigned char* buffer, char* file_name, int off_set){
   int fd = open(file_name, O_RDONLY | O_BINARY);
   unsigned char dump[off_set];
   read(fd,dump,off_set);
   read(fd,buffer,n);
   close(fd);
   return;
}

void readNBitsAtSC(int n, char* buffer, char* file_name, int off_set){
   int fd = open(file_name, O_RDONLY | O_BINARY);
   unsigned char dump[off_set];
   read(fd,dump,off_set);
   read(fd,buffer,n);
   close(fd);
   return;
}


unsigned long int pwr(int base, int exp){
    unsigned long int pot=1;
    for(int i=0;i<exp;i++){
        pot*=base;
    }
    return pot;
}


//Essa função converte uma string contendo um determinado número de bits em litle endian para sua representação em inteiros  
long long int calcIntLltE(unsigned char* lltE, int tam){
   //lltE é o vetor com os bytes em litle endian
   //tam é a quantidade de bytes
   long long int res=0;
   for(int i=0,j=0;i<tam;i++,j+=2){
      res+=lltE[i]*pwr(16,j);
   }
   return res;
}

void getFileHeader(file_header* fileHeader, char* file){

   unsigned char lltEe_shoff[4] ,lltEe_shnum[2],lltEe_shstrndx[2];
   
   readNBitsAt(4,lltEe_shoff,file,0x20);
   readNBitsAt(2,lltEe_shnum,file,0x30);
   readNBitsAt(2,lltEe_shstrndx,file,0x32);

   fileHeader->e_shoff=calcIntLltE(lltEe_shoff,4);
   fileHeader->e_shnum=calcIntLltE(lltEe_shnum,2);
   fileHeader->e_shstrndx=calcIntLltE(lltEe_shstrndx,2);
   return;

}


void getSectionsList(section_header* sectionHeaders, file_header fileHeader, char* file){

   int numberOfsections=fileHeader.e_shnum;
   int offset=fileHeader.e_shoff;   
   int fd = open(file,O_RDONLY | O_BINARY);
   unsigned char dump[offset];
   read(fd,dump,offset);
   for(int i=0;i<numberOfsections;i++){
      read(fd,(sectionHeaders+i)->sh_name,4);
      read(fd,(sectionHeaders+i)->sh_type,4);
      read(fd,(sectionHeaders+i)->sh_flags,4);
      read(fd,(sectionHeaders+i)->sh_addr,4);
      read(fd,(sectionHeaders+i)->sh_offset,4);
      read(fd,(sectionHeaders+i)->sh_size,4);
      read(fd,(sectionHeaders+i)->sh_link,4);
      read(fd,(sectionHeaders+i)->sh_info,4);
      read(fd,(sectionHeaders+i)->sh_addralign,4);
      read(fd,(sectionHeaders+i)->sh_entsize,4);
      
   }
   
   return;
}


unsigned int getNameLenInStrTab(string_table strTab,char* file, unsigned int nameIndex){
   unsigned char itr;
   unsigned int len=1;
   for(int i=0;i<strTab.size;i++){
         readNBitsAt(1,&itr,file,nameIndex+i);
         if(itr=='\0'){
            //Achou o fim da string
            break;
         } else {
            len++;
         }
      }
      return len;
}

void concatenaStr(char* strs[],unsigned int lens[],unsigned int numStr ,char* buffer){
   unsigned int tLen=0;
   for(int i=0;i<numStr;i++){
      tLen+=lens[i]-1;
   }
   for(int i=0;i<numStr;i++){
      unsigned int indexToStart=0;
      for (int k=0; k<i;k++){
         indexToStart+=lens[k]-1;
      }
      if(i==(numStr-1)){
         for(int j=0;j<lens[i];j++){
            buffer[indexToStart+j]=strs[i][j];
         }
      } else {
         for(int j=0;j<lens[i]-1;j++){
            buffer[indexToStart+j]=strs[i][j];
         }
      }
   }

}

unsigned char mapToHexD(unsigned char decD){
   unsigned char ans;
   if(decD<10){
      ans=decD+'0';
   } else{
      ans=decD+87;
   }
   return ans;
}

void convertToHex(unsigned char* dec,char* buffer, int sizeDec){
   for(int i=0;i<=sizeDec-1;i++){
      char msb=mapToHexD(dec[i]/16);
      char lsb=mapToHexD(dec[i]%16);
      buffer[2*i]=msb;
      buffer[(2*i)+1]=lsb;
   }
   buffer[(sizeDec*2)]='\0';
}

void printSectionsTable(section_header* sectionHeaders, string_table shstrtab, unsigned int numberOfSections, char* file, unsigned int lenFileName){
   char eol[]="\n";
   char msg[]=":\tfile format elf32-littleriscv\n\nSections:\nIdx Name          Size     VMA      Type\n";
   char* aux[]={eol,file,msg};
   unsigned int lens[]={sizeof(eol),lenFileName,sizeof(msg)};
   char info[sizeof(eol)+lenFileName+sizeof(msg)-2];
   concatenaStr(aux,lens,3,info);
   write(1,info,sizeof(info));


   //Iteraremos sobre a lista de headers para printar suas informações
   for(int i=0;i<numberOfSections;i++){
      
      section_header itrSecHeader=sectionHeaders[i];
      char index[]={'0'+i,'\0'};
      char tab[]="\t";
      char spc[]=" ";
      char eol[]="\n";
      unsigned int nameIndex=shstrtab.offset+calcIntLltE(itrSecHeader.sh_name,4);
      
      //Identificando o tamanho do nome da secao
      unsigned int len=getNameLenInStrTab(shstrtab,file,nameIndex);      

      //Lendo o nome da secao:
      char secName[len];
      readNBitsAtSC(len,secName,file,nameIndex);
      
      //Invertendo a edianess de size e vma:
      unsigned char size[4];
      unsigned char vma[4];
      for(int i=0;i<4;i++){
         size[i]=itrSecHeader.sh_size[3-i];
         vma[i]=itrSecHeader.sh_addr[3-i];
      }

      char strSize[9];
      char strVma[9];
      convertToHex(size,strSize,4);
      convertToHex(vma,strVma,4);

      //Juntando tudo em uma string
      char* cct[]={spc,spc,index,spc,secName,spc,strSize,spc,strVma,eol};
      unsigned int lens[]={sizeof(spc),sizeof(spc),sizeof(index),sizeof(spc),sizeof(secName),sizeof(spc),sizeof(strSize),sizeof(tab),sizeof(strVma),sizeof(eol)};
      unsigned int lenBuff=0;
      for(int i=0;i<(sizeof(lens)/4);i++){
         lenBuff+=lens[i]-1;
      }
      char line[lenBuff+1];
      concatenaStr(cct,lens,10,line);
      write(1,line,sizeof(line));

   }

}

int compareStr(char* str1, unsigned int len1, char* str2, unsigned int len2 ){
   int ret=0;
   if (len1==len2){
      ret=1;
      for(int i=0;i<len1;i++){
         if(str1[i]!=str2[i]){
            ret=0;
         }
      }
   }
   return ret;
}

unsigned int getIndex(char* srcName,unsigned int lenSecName,section_header* sectionHeaders,string_table shstrtab,unsigned int numberOfSections, char* file){
   unsigned int ans=0;
   for(int i=0;i<numberOfSections;i++){
      section_header itrSecHeader=sectionHeaders[i];
      unsigned int nameIndex=shstrtab.offset+calcIntLltE(itrSecHeader.sh_name,4);
      unsigned int len=getNameLenInStrTab(shstrtab,file,nameIndex); 
      char secName[len];
      readNBitsAtSC(len,secName,file,nameIndex);
      if(compareStr(secName,sizeof(secName),srcName,lenSecName)){
         ans=i;
         break;
      }
   }
   return ans;
}

struct symTabEntry {
   unsigned char st_name[4];
   unsigned char st_value[4];
   unsigned char st_size[4];
   unsigned char st_info;
   unsigned char st_other;
   unsigned char st_shndx[2];

};
typedef struct symTabEntry symTabEntry;

void buildSymTabVct(symTabEntry* symtabVct, symble_table symtab, char* file){
   int numberOfEntries=symtab.entries;
   int offset=symtab.offset;   
   int fd = open(file,O_RDONLY | O_BINARY);
   unsigned char dump[offset];
   read(fd,dump,offset);
   for(int i=0;i<numberOfEntries;i++){
      read(fd,(symtabVct+i)->st_name,4);
      read(fd,(symtabVct+i)->st_value,4);
      read(fd,(symtabVct+i)->st_size,4);
      read(fd,&((symtabVct+i)->st_info),1);
      read(fd,&((symtabVct+i)->st_other),1);
      read(fd,(symtabVct+i)->st_shndx,2);
   }
}

void mapBind(unsigned char bind, char* buffer){
   if(bind==0){
      //STB_Local
      buffer[0]='l';
   } else if(bind==1){
      //STB_Global
      buffer[0]='g';
   } else if(bind==2){
      //STB_Weak
   } else if(bind==10){
      //STB_LOOS
   } else if(bind==12){
      //STB_HIOS
   } else if(bind==13){
      //STB_LOPROC
   } else if(bind==15){
      //STB_HIPROC
   }
   buffer[1]='\0';
   return;
}

void printSymbleTable(symble_table symtab, string_table strtab, string_table shstrtab,section_header* sectionHeaders, char* file, unsigned int fileNameLen){
   char eol[]="\n";
   char tab[]="\t";
   char spc[]=" ";
   char msg[]=":\tfile format elf32-littleriscv\n\nSYMBOL TABLE:\n";
   char* aux[]={eol,file,msg};
   unsigned int lens[]={sizeof(eol),fileNameLen,sizeof(msg)};
   char info[sizeof(eol)+fileNameLen+sizeof(msg)-2];
   concatenaStr(aux,lens,3,info);
   write(1,info,sizeof(info));
   symTabEntry symTabVct[symtab.entries];
   buildSymTabVct(symTabVct,symtab,file);
   
   for(int i=1;i<symtab.entries;i++){
      symTabEntry itrSymTab=symTabVct[i];
      
      //Obtendo o valor associado ao simbolo:
      unsigned char value[4];
      char strValue[9];
      for(int i=0;i<4;i++){
         value[i]=itrSymTab.st_value[3-i];
      }
      convertToHex(value,strValue,4);

      //Obtem o bind do simbolo:
      unsigned char bind = ((itrSymTab.st_info)>>4);
      char strBind[2];
      mapBind(bind,strBind);


      //Obtendo o nome da seção a qual o símbolo pertence:
      /*ESTOU SUPONDE QUE ISSO FUNCIONARIA MESMO SE O CAMPO st_shndx CONTIVER O VALOR SHN_XINDEX
      Não sei o que como agir se este é o valor, não consegui entender das especificações o que é para ser feito
      */

      section_header inSec = sectionHeaders[calcIntLltE(itrSymTab.st_shndx,2)];
      unsigned int secNameIndex=shstrtab.offset+calcIntLltE(inSec.sh_name,4);
      unsigned int len=getNameLenInStrTab(shstrtab,file,secNameIndex);
      if(calcIntLltE(itrSymTab.st_shndx,2)==0 || calcIntLltE(itrSymTab.st_shndx,2)==65521){
         //Se st_shndx=0 , temos a condição SHN_UNDEF e o print da seção é *UND*. Se st_shndx=fff1=65521 , temos a condição
         // SNH_ABS e o print da seção é *ABS*
         len=6;
      }     
      char secName[len];
      if(calcIntLltE(itrSymTab.st_shndx,2)==0){
         secName[0]='*';
         secName[1]='U';
         secName[2]='N';
         secName[3]='D';
         secName[4]='*';
         secName[5]='\0';
      } else if (calcIntLltE(itrSymTab.st_shndx,2)==65521){
         secName[0]='*';
         secName[1]='A';
         secName[2]='B';
         secName[3]='S';
         secName[4]='*';
         secName[5]='\0';
      } else {
         readNBitsAtSC(len,secName,file,secNameIndex);
      }
      
      
      
      //Obtem o tipo do simbolo:
      //Não sei pra que serve isso
      //unsigned char info = ((itrSymTab.st_info)&0xf);
      
      unsigned char size[4];
      char strSize[9];
      for(int i=0;i<4;i++){
         size[i]=itrSymTab.st_size[3-i];
      }
      convertToHex(size,strSize,4);

      //Obtendo o nome do símbolo:
      unsigned int symNameIdx=strtab.offset+calcIntLltE(itrSymTab.st_name,4);
      unsigned int snlen=getNameLenInStrTab(strtab,file,symNameIdx);
      char symName[snlen];
      readNBitsAtSC(snlen,symName,file,symNameIdx);

      //Juntando tudo em uma string
      char* cct[]={strValue,spc,strBind,spc,spc,spc,spc,spc,spc,spc,secName,tab,strSize,spc,symName,eol};
      unsigned int lens[]={sizeof(strValue),2,sizeof(strBind),2,2,2,2,2,2,2,sizeof(secName),sizeof(tab),sizeof(strSize),sizeof(tab),sizeof(symName),sizeof(eol)};
      unsigned int lenBuff=0;
      for(int i=0;i<(sizeof(lens)/4);i++){
         lenBuff+=lens[i]-1;
      }
      char line[lenBuff+1];
      concatenaStr(cct,lens,sizeof(lens)/4,line);
      write(1,line,sizeof(line));
   }
}

struct rotText {
   unsigned char addrsLltE[4];
   unsigned char addrsBigE[4];
   unsigned int addrsInt;
   unsigned int nameOffset;
   unsigned int nameLen;
};
typedef struct rotText rotText;

void cpyStr2inStr1(unsigned char* str1,unsigned char* str2, unsigned int len){
   for(int i=0;i<len;i++){
      str1[i]=str2[i];
   }
}

void cpyStr2inStr1SC(char* str1, char* str2, unsigned int len){
   for(int i=0;i<len;i++){
      str1[i]=str2[i];
   }
}

char mapToHexI(unsigned int intD){
   char ans;
   if(intD<10){
      ans=intD+'0';
   } else{
      ans=intD+87;
   }
   return ans;
}

void convertIntToHex(unsigned int num,char* buff,unsigned int blen){
   for(int i=0;i<blen;i++){
      buff[i]='0';
   }
   int div=num;
   int rest;
   int i=0;
   while (div!=0){
      rest=div%16;
      buff[blen-2-i]=mapToHexI(rest);
      div=div/16;
      i++;
   }
   buff[blen-1]='\0';
}

void cvtIntToBinLltE(unsigned int num,unsigned int buff[32]){
   for(int i=0;i<32;i++){
      buff[i]=0;
   }
   unsigned int div=num;
   int rest;
   int i=0;
   while (div!=0){
      rest=div%2;
      buff[i]=rest;
      div=div/2;
      i++;
   }
}


void cpmlLlte(unsigned int* buff, unsigned int len){
   for(int i=0;i<len;i++){
        buff[i]=!(buff[i]);
   }
   for(int i=0;i<len;i++){
      if(buff[i]==0){
         buff[i]=1;
         break;
      } else{
         buff[i]=0;
      }
   }
   return;
}


long long int cvtBinLlteToInt(unsigned int buff[],unsigned int stridx,unsigned int stpidx){
      long long int ans=0;
      for(int i=0,j=stridx;j<=stpidx;i++,j++){
         ans+=buff[j]*pwr(2,i);
      }
      return ans;
}

long long int cvtSBinLlteToInt(unsigned int buff[],unsigned int stridx,unsigned int stpidx){
      long long int ans=0;
      if(buff[stpidx]==0){   
         for(int i=0,j=stridx;j<=stpidx;i++,j++){
            ans+=buff[j]*pwr(2,i);
         }
      } else {
         int len=stpidx-stridx+1;
         int aux=1;

         for(int j=stridx;j<=stpidx-1;j++){
            if(buff[j]==1){
               aux=0;
            }
         }

         if(aux==0){
            unsigned int nBuff[len];
            for(int i=0,j=stridx;i<len;i++,j++){
               nBuff[i]=buff[j];
            }
            cpmlLlte(nBuff,len);
            ans=(-1)*cvtBinLlteToInt(nBuff,0,len-1);

         } else {
            for(int i=0,j=stridx;j<=stpidx;i++,j++){
               ans+=buff[j]*pwr(2,i);
            }
            ans*=-1;
         }
         
      }
      return ans;
}

/*
long long int cvtSBinLlteToInt(unsigned int buff[32],unsigned int stridx,unsigned int stpidx){
      long long int ans;
      if(buff[31]==0){
         for(int i=0,j=stridx;j<=stpidx;i++,j++){
            ans+=buff[j]*pwr(2,i);
         }

      } else {
         unsigned int len=stpidx-stridx+1;
         unsigned int vct[len];
         for(int i=0,j=stridx;j<=stpidx;i++,j++){
            vct[i]=buff[j];
         }
         cpmlLlte(vct,len);
         for(int i=0,j=stridx;i<len;i++,j++){
            ans+=buff[j]*pwr(2,i);
         }
         ans*=(-1);
      }
      return ans;
}
*/

int idtfOp(unsigned int sum06,unsigned int sum1214, unsigned int sum2531, unsigned int sum2031){
   int ans=-1;
   switch (sum06)
   {
   case 0b0110111:
      write(1,"lui\t",5);
      ans=0;
      break;

   case 0b0010111:
      write(1,"auipc\t",7);
      ans=1;
      break;

   case 0b1101111:
      write(1,"jal\t",5);
      ans=2;
      break;

   case 0b1100111:
      write(1,"jalr\t",6);
      ans=3;
      break;

   case 0b1100011:
      switch (sum1214)
      {
      case 0b000:
         write(1,"beq\t",5);
         ans=4;
         break;
      case 0b001:
         write(1,"bne\t",5);
         ans=5;
         break;
      case 0b100:
         write(1,"blt\t",5);
         ans=6;
         break;
      case 0b101:
         write(1,"bge\t",5);
         ans=7;
         break;
      case 0b110:
         write(1,"bltu\t",6);
         ans=8;
         break;
      case 0b111:
         write(1,"bgeu\t",6);
         ans=9;
         break;
      default:
         break;
      }
      break;

   case 0b0000011:
      switch (sum1214)
      {
      case 0b000:
         write(1,"lb\t",4);
         ans=10;
         break;
      case 0b001:
         write(1,"lh\t",4);
         ans=11;
         break;
      case 0b010:
         write(1,"lw\t",4);
         ans=12;
         break;
      case 0b100:
         write(1,"lbu\t",5);
         ans=13;
         break;
      case 0b101:
         write(1,"lhu\t",5);
         ans=14;
         break;
      default:
         break;
      }
      break; 

   case 0b0100011:
      switch (sum1214)
      {
      case 0b000:
         write(1,"sb\t",4);
         ans=15;
         break;
      case 0b001:
         write(1,"sh\t",4);
         ans=16;
         break;
      case 0b010:
         write(1,"sw\t",4);
         ans=17;
         break;
      default:
         break;
      }
      break;

   case 0b0010011:
      switch (sum1214)
      {
      case 0b000:
         write(1,"addi\t",6);
         ans=18;
         break;
      case 0b010:
         write(1,"slti\t",6);
         ans=19;
         break;
      case 0b011:
         write(1,"sltiu\t",7);
         ans=20;
         break;
      case 0b100:
         write(1,"xori\t",6);
         ans=21;
         break;
      case 0b110:
         write(1,"ori\t",5);
         ans=22;
         break;
      case 0b111:
         write(1,"andi\t",6);
         ans=23;
         break;
      case 0b001:
         write(1,"slli\t",6);
         ans=24;
         break;
      case 0b101:
         switch (sum2531)
         {
         case 0:
            write(1,"srli\t",6);
            ans=25;
            break;
         case 0b0100000:
            write(1,"srai\t",6);
            ans=26;
            break; 
         default:
            break;
         } 
         break;
      default:
         break;
      }
      break;
   case 0b110011:
      switch (sum1214)
      {
      case 0b000:
         switch (sum2531)
         {
         case 0:
            write(1,"add\t",5);
            ans=27;
            break;
         case 0b0100000:
            write(1,"sub\t",5);
            ans=28;
            break;         
         default:
            break;
         }
         break;
      case 0b001:
         write(1,"sll\t",5);
         ans=29;
         break;
      case 0b010:
         write(1,"slt\t",5);
         ans=30;
         break;
      case 0b011:
         write(1,"sltu\t",6);
         ans=31;
         break;
      case 0b100:
         write(1,"xor\t",5);
         ans=32;
         break;
      case 0b101:
         switch (sum2531)
         {
         case 0:
            write(1,"srl\t",5);
            ans=33;
            break;
         case 0b0100000:
            write(1,"sra\t",5);
            ans=34;
            break;
         default:
            break;
         }
         break;
      case 0b110:
         write(1,"or\t",4);
         ans=35;
         break;
      case 0b111:
         write(1,"and\t",5);
         ans=36;
         break;   
      default:
         break;
      }
      break;
   case 0b0001111:
      switch (sum1214)
      {
      case 0:
         write(1,"fence\t",7);
         ans=37;
         break;
      case 1:
         write(1,"fence.i\t",8);
         ans=38;
         break;
      default:
         break;
      }
      break;
   case 0b1110011:
      switch (sum1214)
      {
      case 0:
         switch (sum2031)
         {
         case 0:
            write(1,"ecall\t",7);
            ans=39;
            break;
         case 1:
            write(1,"ebreak\t",8);
            ans=40;
            break;         
         default:
            break;
         }
         break;
      case 0b001:
         write(1,"csrrw\t",7);
         ans=41;
         break;
      case 0b010:
         write(1,"csrrs\t",7);
         ans=42;
         break;
      case 0b011:
         write(1,"csrrc\t",7);
         ans=43;
         break;
      case 0b101:
         write(1,"csrrwi\t",8);
         ans=44;
         break;
      case 0b110:
         write(1,"csrrsi\t",8);
         ans=45;
         break;
      case 0b111:
         write(1,"cssrci\t",8);
         ans=46;
         break;
      default:
         break;
      }
      break;
   default:
      break;
   }
   if(ans<0){
      write(1,"<unknown>\n",sizeof("<unknown>\n"));
   }
   return ans;
}

unsigned int sizePrintableInt(int num){
   int i=1;
   int div;
   if(num<0){
      div=num*(-1);
   } else{
      div=num;
   }

   while(div!=0){
      div=div/10;
      i++;
   }
   if(num<=0){
      i++;
   }
   return i;
}

void convertToPrintableInt(int num, char* str, unsigned int len){
   int i=0;
   int div;
   if(num<0){
      div=num*(-1);
   } else{
      div=num;
   }
   while(div!=0){
      str[len-i-2]=(div%10)+'0';
      div=div/10;
      i++;
   }
   str[len-1]='\0';
   if(num<0){
      str[0]='-';
   } else if(num==0){
      str[0]='0';
   }
   return ;
}

void compactHexStr(char* hex, unsigned int lenHex, char* buffer, unsigned int lenBuffer, unsigned int zerosToCut){
   buffer[0]='0';
   buffer[1]='x';
   for(int i=0;(i+zerosToCut)<lenHex;i++){
      buffer[2+i]=hex[i+zerosToCut];
   }
}

void printOffSetRot(unsigned int offset, rotText* rots, unsigned int nRoots, char* file){
   int idxRotJump=-1;
   int i=0;
   while(i<nRoots){
      if(rots[i].addrsInt==offset){
         idxRotJump=i;
         break;
      } else {
         i++;
      }
   }
   
   if(idxRotJump>=0){
      char strHexOS[9];
      convertIntToHex(offset,strHexOS,9);
      int zerosToCut=0;
      for(int i=0;i<9;i++){
         if(strHexOS[i] =='0'){
            zerosToCut++;
         } else {
            break;
         }
      }
      char cpcHstr[9-zerosToCut+2];
      compactHexStr(strHexOS,9,cpcHstr,sizeof(cpcHstr),zerosToCut);
      write(1,cpcHstr,sizeof(cpcHstr));
      write(1," <",sizeof(" <"));
      char rotName[rots[idxRotJump].nameLen];
      readNBitsAtSC(rots[idxRotJump].nameLen,rotName,file,rots[idxRotJump].nameOffset);
      write(1,rotName,sizeof(rotName));
      write(1,">\n",sizeof(">\n"));


   }else {
      i=0;
      int idxFstRotBefore=-1;
      int fistOffsetBefore=-1;
      while(i<nRoots){
         if(i==0 && rots[i].addrsInt<offset){
            idxFstRotBefore=i;
            fistOffsetBefore=rots[i].addrsInt;
            i++;
         } else if (i!=0 && rots[i].addrsInt<fistOffsetBefore){
            idxFstRotBefore=i;
            fistOffsetBefore=rots[i].addrsInt;
            i++;
         }
         i++;
      }

      if(idxFstRotBefore>=0 && fistOffsetBefore>=0){
         char strHexOS[9];
         convertIntToHex(offset,strHexOS,9);
         int zerosToCut=0;
         for(int i=0;i<9;i++){
            if(strHexOS[i]=='0'){
               zerosToCut++;
            } else {
               break;
            }
         }
         char cpcHstr[9-zerosToCut+2];
         compactHexStr(strHexOS,9,cpcHstr,sizeof(cpcHstr),zerosToCut);
         write(1,cpcHstr,sizeof(cpcHstr));
         write(1," <",sizeof(" <"));
         char rotName[rots[idxFstRotBefore].nameLen];
         readNBitsAtSC(rots[idxFstRotBefore].nameLen,rotName,file,rots[idxFstRotBefore].nameOffset);
         unsigned int diff = offset-fistOffsetBefore;

         char strHexOSDIFF[9];
         convertIntToHex(diff,strHexOSDIFF,9);
         zerosToCut=0;
         for(int i=0;i<9;i++){
            if(strHexOSDIFF[i]=='0'){
               zerosToCut++;
            } else {
               break;
            }
         }
         char cpcHstrDIFF[9-zerosToCut+2];
         compactHexStr(strHexOSDIFF,9,cpcHstrDIFF,sizeof(cpcHstrDIFF),zerosToCut);
         write(1,"+",2);
         write(1,cpcHstrDIFF,sizeof(cpcHstrDIFF));
         write(1,">\n",sizeof(">\n"));


      } else {
         char strHexOS[9];
         convertIntToHex(offset,strHexOS,9);
         int zerosToCut=0;
         for(int i=0;i<9;i++){
            if(strHexOS[i]=='0'){
               zerosToCut++;
            } else {
               break;
            }
         }
         char cpcHstr[9-zerosToCut+2];
         compactHexStr(strHexOS,9,cpcHstr,sizeof(cpcHstr),zerosToCut);
         write(1,cpcHstr,sizeof(cpcHstr));
         write(1," <.text",sizeof(" <.text"));
         unsigned int diff = offset-fistOffsetBefore;
         char strHexOSDIFF[9];
         convertIntToHex(diff,strHexOSDIFF,9);
         zerosToCut=0;
         for(int i=0;i<9;i++){
            if(strHexOSDIFF[i]=='0'){
               zerosToCut++;
            } else {
               break;
            }
         }
         char cpcHstrDIFF[9-zerosToCut+2];
         compactHexStr(strHexOSDIFF,9,cpcHstrDIFF,sizeof(cpcHstrDIFF),zerosToCut);
         write(1,"+",2);
         write(1,cpcHstrDIFF,sizeof(cpcHstrDIFF));
         write(1,">\n",sizeof(">\n"));
      }
   }
   

}

void change0forSpc(char* fstC,int len){
   for(int i=0;i<len;i++){
      if(fstC[i]=='0'){
         fstC[i]=' ';
      } else{
         break;
      }
   }
}

void printM1 (char* r1, int len1 ,char* r2, int len2, int immd);
void printM2 (char* r1, int len1 ,char* r2, int len2, int immd);
void printM3(char* r0, int len0, char* r1, int len1, char* r2, int len2);


void printText(symble_table symtab, string_table strtab, unsigned char textIdx,section_header* sectionHeaders ,char* file, unsigned int fileNameLen){
   section_header headerText = sectionHeaders[textIdx];
   char eol[]="\n";
   char msg[]=":\tfile format elf32-littleriscv\n\nDisassembly of section .tex:\n\n";
   char* aux[]={eol,file,msg};
   unsigned int lens[]={sizeof(eol),fileNameLen,sizeof(msg)};
   char info[sizeof(eol)+fileNameLen+sizeof(msg)-2];
   concatenaStr(aux,lens,3,info);
   write(1,info,sizeof(info));

   symTabEntry symTabVct[symtab.entries];
   buildSymTabVct(symTabVct,symtab,file);

   //Contando quantos rótulos/símbolos a seção text tem:
   unsigned int nRots=0;
   for(int i=0;i<symtab.entries;i++){
      if(calcIntLltE(symTabVct[i].st_shndx,2)==textIdx){
         nRots++;
      }
   }

   rotText rots[nRots];

   //Obtendo os rótulos/símbolos pertencentes a função text:
   for(int i=0,j=0;i<symtab.entries;i++){
      if(calcIntLltE(symTabVct[i].st_shndx,2)==textIdx){
         cpyStr2inStr1(rots[j].addrsLltE,symTabVct[i].st_value,4);
         for(int k=0;k<4;k++){
            rots[j].addrsBigE[k]=rots[j].addrsLltE[3-k];
         }
         rots[j].nameOffset=strtab.offset+calcIntLltE(symTabVct[i].st_name,4);
         rots[j].nameLen=getNameLenInStrTab(strtab,file,rots[j].nameOffset);
         rots[j].addrsInt=calcIntLltE(rots[j].addrsLltE,4);
         j++;
      }
   }


   unsigned int textSize = calcIntLltE(headerText.sh_size,4);
   unsigned char textVMA[4];
   cpyStr2inStr1(textVMA,headerText.sh_addr,4);
   unsigned int virtualOffSet=calcIntLltE(textVMA,4);
   unsigned int textStrOffSet= calcIntLltE(headerText.sh_offset,4);

   for(int i=0;i<textSize;i+=4){
      unsigned int nowVOS=virtualOffSet+i;
      unsigned int nowROS=textStrOffSet+i;
      int noEntryRot=1;
      for(int j=0;j<nRots;j++){
         if(nowVOS==rots[j].addrsInt){
            if(i!=0){
               write(1,"\n",2);
            }
            char strRotAddrs[9];
            convertToHex(rots[j].addrsBigE,strRotAddrs,4);
            char rotName[rots[j].nameLen];
            readNBitsAtSC(rots[j].nameLen,rotName,file,rots[j].nameOffset);
            char* cct[]={strRotAddrs," ","<",rotName,">:\n"};
            unsigned int lens[]={sizeof(strRotAddrs),2,2,sizeof(rotName),4};
            unsigned int len=5;
            unsigned int lenBuff=0;
            for(int i=0;i<(sizeof(lens)/4);i++){
               lenBuff+=lens[i]-1;
            }
            char title[lenBuff+1];
            concatenaStr(cct,lens,len,title);
            write(1,title,sizeof(title));
            noEntryRot=0;
            break;
         }
      }
      if(noEntryRot && i==0){
         char strNowVA[9];
         convertIntToHex(nowVOS,strNowVA,9);
         write(1,strNowVA,9);
         write(1," <.text>:\n",sizeof(" <.text>:\n"));
      }

      char fstC[9];
      convertIntToHex(virtualOffSet+i,fstC,9);
      change0forSpc(fstC,9);

      unsigned char b0,b1,b2,b3;
      readNBitsAt(1,&b0,file,nowROS);
      readNBitsAt(1,&b1,file,nowROS+1);
      readNBitsAt(1,&b2,file,nowROS+2);
      readNBitsAt(1,&b3,file,nowROS+3);
      
      char stb0[3],stb1[3],stb2[3],stb3[3];
      convertIntToHex(b0,stb0,3);
      convertIntToHex(b1,stb1,3);
      convertIntToHex(b2,stb2,3);
      convertIntToHex(b3,stb3,3);
      

      unsigned char inst[4]={b0,b1,b2,b3};
      unsigned int binVct[32];
      cvtIntToBinLltE(calcIntLltE(inst,4),binVct);

      char* cct1[]={fstC,": ",stb0," ",stb1," ",stb2,"  ",stb3,"\t"};
      unsigned int lens[]={sizeof(fstC),3,3,2,3,2,3,2,3,2};
      unsigned int lenBuff=0;
      for(int i=0;i<(sizeof(lens)/4);i++){
         lenBuff+=lens[i]-1;
      }
      char fstPart[lenBuff+1];
      concatenaStr(cct1,lens,10,fstPart);
      write(1,fstPart,sizeof(fstPart));

      int op = idtfOp(cvtBinLlteToInt(binVct,0,6),cvtBinLlteToInt(binVct,12,14),cvtBinLlteToInt(binVct,25,31),cvtBinLlteToInt(binVct,20,31));

      char* flags[]={"ustatus","fflags","frm","fcrs","uie","utvec","6","7","vstarta","vxsat","vxrm"};
      char*  regNames[]={"zero","ra","sp","gp","tp","t0","t1","t2","s0","s1","a0","a1","a2","a3","a4","a5","a6","a7","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","t3","t4","t6"};
      int regNLens[]={5,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3};

      if(op==0 || op==1){ //lui e auipc
         unsigned int regValue = cvtBinLlteToInt(binVct,7,11);
         long long int immediate = cvtSBinLlteToInt(binVct,12,31);
         write(1,regNames[regValue],regNLens[regValue]);
         write(1,", ",3);
         int sizeStrInt=sizePrintableInt(immediate);
         char printableInt[sizeStrInt];
         convertToPrintableInt(immediate,printableInt,sizeof(printableInt));
         write(1,printableInt,sizeof(printableInt));
         write(1,"\n",2);

      } else if(op==2){ //Jall
         unsigned int regValue = cvtBinLlteToInt(binVct,7,11);
         unsigned int offsetVect[21];

         offsetVect[0]=0;
         for(int i=12;i<=19;i++){
            offsetVect[i]=binVct[i];
         }
         offsetVect[11]=binVct[20];
         for(int i=1;i<=10;i++){
            offsetVect[i]=binVct[i+20];
         }
         offsetVect[20]=binVct[31];



         int offset=cvtSBinLlteToInt(offsetVect,0,12);
         write(1,regNames[regValue],regNLens[regValue]);
         write(1,", ",3);
         printOffSetRot(nowVOS+offset, rots,nRots,file);

      } else if(op>=4 && op<=9) { //bne até bgeu
         unsigned int rs1V =cvtBinLlteToInt(binVct,15,19);
         unsigned int rs2V =cvtBinLlteToInt(binVct,20,24);
         
         write(1,regNames[rs1V],regNLens[rs1V]);
         write(1,", ",3);
         write(1,regNames[rs2V],regNLens[rs2V]);
         write(1,", ",3);
         
         unsigned int offsetVect[13];

         offsetVect[12]=binVct[31];
         offsetVect[11]=binVct[7];
         for(int i=1;i<5;i++){
            offsetVect[i]=binVct[i+8-1];
         }
         for(int i=5;i<11;i++){
            offsetVect[i]=binVct[i+25-5];
         }
         offsetVect[0]=0;
         int offset=cvtSBinLlteToInt(offsetVect,0,12);

         printOffSetRot(nowVOS+offset, rots,nRots,file);

      }
      else if(op==3 || (op>=10 && op<=14)){ //Jalr e lb até lhu
         unsigned int rdV =cvtBinLlteToInt(binVct,7,11);
         unsigned int rs1V = cvtBinLlteToInt(binVct,15,19);
         int immediate = cvtSBinLlteToInt(binVct,20,31); 
         printM2(regNames[rdV],regNLens[rdV],regNames[rs1V],regNLens[rs1V],immediate);

      
      } else if(op>=15 && op<=17 ){ //sb,sh,sw
         unsigned int rs1V =cvtBinLlteToInt(binVct,15,19);
         unsigned int rs2V = cvtBinLlteToInt(binVct,20,24);
         unsigned int offsetVect[12];

         for(int i=0;i<=4;i++){
            offsetVect[i]=binVct[i+7];
         }
         for(int i=5;i<=11;i++){
            offsetVect[i]=binVct[i+25-5];
         }

         int offset=cvtSBinLlteToInt(offsetVect,0,11);
         
         printM2(regNames[rs2V],regNLens[rs2V],regNames[rs1V],regNLens[rs1V],offset);
      
      
      } else if(op>=18 && op<=23){ //de addi até andi
         unsigned int rdV =cvtBinLlteToInt(binVct,7,11);
         unsigned int rs1V = cvtBinLlteToInt(binVct,15,19);
         int immediate = cvtSBinLlteToInt(binVct,20,31); //O imediato pode ser negativo
         printM1(regNames[rdV],regNLens[rdV],regNames[rs1V],regNLens[rs1V],immediate);

      } else if(op>=24 && op<=26){ //de slli até srai
         unsigned int rdV =cvtBinLlteToInt(binVct,7,11);
         unsigned int rs1V = cvtBinLlteToInt(binVct,15,19);
         int shamt = cvtSBinLlteToInt(binVct,20,24); //O imediato pode ser negativo
         printM1(regNames[rdV],regNLens[rdV],regNames[rs1V],regNLens[rs1V],shamt);

      } else if(op>=25 && op<=36){ //add até and
         unsigned int rdV =cvtBinLlteToInt(binVct,7,11);
         unsigned int rs1V =cvtBinLlteToInt(binVct,15,19);
         unsigned int rs2V =cvtBinLlteToInt(binVct,20,24);
         printM3(regNames[rdV],regNLens[rdV],regNames[rs1V],regNLens[rs1V],regNames[rs2V],regNLens[rs2V]);

      } else if(op==37){ // fence
         char iorw1[5];
         char iorw2[5];
         iorw1[1]=(binVct[24]==1)? 'w':'\0';
         iorw1[2]=(binVct[25]==1)? 'r':'\0';
         iorw1[3]=(binVct[26]==1)? 'o':'\0';
         iorw1[4]=(binVct[27]==1)? 'i':'\0';
         iorw2[1]=(binVct[20]==1)? 'w':'\0';
         iorw2[2]=(binVct[21]==1)? 'r':'\0';
         iorw2[3]=(binVct[22]==1)? 'o':'\0';
         iorw2[4]=(binVct[23]==1)? 'i':'\0';
         iorw1[0]='\0';
         iorw2[0]='\0';
         write(1,iorw1,5);
         write(1,", ",3);
         write(1,iorw2,5);
         write(1,"\n",2);

      } else if(op>=38 && op<=40){//fence.i, ecall, ebreak 
         write(1,"\n",2);

      } else if(op>=41 && op<=43){
         unsigned int rdV =cvtBinLlteToInt(binVct,7,11);
         unsigned int rs1V =cvtBinLlteToInt(binVct,15,19);
         write(1,regNames[rdV],regNLens[rdV]);
         
         int csr = cvtBinLlteToInt(binVct,20,31);
         if (csr<=10){
            write(1,flags[csr],sizeof(flags[csr])); //Corrigir
         } else {
            char strCsr[sizePrintableInt(csr)];
            convertToPrintableInt(csr,strCsr,sizeof(strCsr));
            write(1,strCsr,sizeof(strCsr));
         }
         write(1,", ",3);
         write(1,regNames[rs1V],regNLens[rs1V]);
         write(1,"\n",2);

      } else if (op>=44 && op<=46){
         unsigned int rdV =cvtBinLlteToInt(binVct,7,11);
         write(1,regNames[rdV],regNLens[rdV]);

         int csr = cvtBinLlteToInt(binVct,20,31);
         if (csr<=10){
            write(1,flags[csr],sizeof(flags[csr])); //Corrigir
         } else {
            char strCsr[sizePrintableInt(csr)];
            convertToPrintableInt(csr,strCsr,sizeof(strCsr));
            write(1,strCsr,sizeof(strCsr));
         }
         write(1,", ",3);

         int zimm = cvtSBinLlteToInt(binVct,20,31);
         char strZimm[sizePrintableInt(csr)];
         convertToPrintableInt(zimm,strZimm,sizeof(strZimm));
         write(1,"\n",2);
      }
   }
}

void printM1 (char* r1, int len1 ,char* r2, int len2, int immd){
   write(1,r1,len1);
   write(1,", ",3);
   write(1,r2,len2);
   write(1,", ",3);
   char printableInt[sizePrintableInt(immd)];
   convertToPrintableInt(immd,printableInt,sizeof(printableInt));
   write(1,printableInt,sizeof(printableInt));
   write(1,"\n",2);
}

void printM2 (char* r1, int len1 ,char* r2, int len2, int immd){
   write(1,r1,len1);
   write(1,", ",3);
   char printableInt[sizePrintableInt(immd)];
   convertToPrintableInt(immd,printableInt,sizeof(printableInt));
   write(1,printableInt,sizeof(printableInt));
   write(1,"(",2);
   write(1,r2,len2);
   write(1,")\n",3);
}

void printM3(char* r0, int len0, char* r1, int len1, char* r2, int len2){
   write(1,r0,len0);
   write(1,", ",3);
   write(1,r1,len1);
   write(1,", ",3);
   write(1,r2,len2);
   write(1,"\n",2);
}


int main (int argc, char *argv[]){

   /*
   char fileName[sizeof(argv[2])];
   cpyStr2inStr1SC(fileName,argv[2],sizeof(argv[2]));
   */
   //DEBUG 
   char fileName[]="test-00.o";
   //
   
   file_header fileHeader;
   getFileHeader(&fileHeader,fileName);
  

   section_header sectionHeaders[fileHeader.e_shnum];
   getSectionsList(sectionHeaders,fileHeader,fileName);
   
   section_header headerShstrtab = sectionHeaders[fileHeader.e_shstrndx];
   unsigned int size=calcIntLltE(headerShstrtab.sh_size,4), offset=calcIntLltE(headerShstrtab.sh_offset,4);

   
   string_table shstrtab, strtab;
   shstrtab.size=size;
   shstrtab.offset=offset;

   unsigned int indexStrtab=getIndex(".strtab",sizeof(".strtab"),sectionHeaders,shstrtab,fileHeader.e_shoff,fileName);
   unsigned int indexSymtab=getIndex(".symtab",sizeof(".symtab"),sectionHeaders,shstrtab,fileHeader.e_shoff,fileName);
   section_header headerStrtab = sectionHeaders[indexStrtab];
   section_header headerSymtab = sectionHeaders[indexSymtab];
   strtab.size=calcIntLltE(headerStrtab.sh_size,4);
   strtab.offset=calcIntLltE(headerStrtab.sh_offset,4);
   symble_table symtab;
   symtab.size=calcIntLltE(headerSymtab.sh_size,4);
   symtab.offset=calcIntLltE(headerSymtab.sh_offset,4);
   symtab.entries=symtab.size/16;

   unsigned int indexText=getIndex(".text",sizeof(".text"),sectionHeaders,shstrtab,fileHeader.e_shoff,fileName);

   /*
   char op=argv[1][1];
   switch (op)
   {
   case 'h':
      printSectionsTable(sectionHeaders,shstrtab,fileHeader.e_shnum,fileName,sizeof(fileName));
      break;

   case 't':
      printSymbleTable(symtab,strtab,shstrtab,sectionHeaders,fileName,sizeof(fileName));
      break;

   case 'd':
      printText(symtab,strtab,indexText,sectionHeaders,fileName,sizeof(fileName));
      break;
      
   default:
      break;
   }
  */

   
   //DEBUG
   printSectionsTable(sectionHeaders,shstrtab,fileHeader.e_shnum,fileName,sizeof(fileName));
   //printSymbleTable(symtab,strtab,shstrtab,sectionHeaders,fileName,sizeof(fileName));
   //printText(symtab,strtab,indexText,sectionHeaders,fileName,sizeof(fileName));
    
}