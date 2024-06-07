.align 2
.text
###### Implementação da API em linguagem de montagem: ######

# int set_motor(char vertical, char horizontal);
/*
  Define os valores para o deslocamento vertical e horizontal do carro.
  Paramêtros:
  * vertical:   um byte que define o deslocamento vertical, entre -1 e 1.
                Valor -1 faz o carro andar para trás e 1 para frente
  * horizontal: define o valor para o deslocamento horizontal, entre -127 e 127.
                Valores negativos gera deslocamento para a direita e positivos
                para a esquerda.
  Retorna:
  * 0 em caso de sucesso.
  * -1 caso algum parametro esteja fora de seu intervalo.
*/
.globl set_motor
set_motor:
    li a7, 10
    ecall
ret

# int set_handbreak(char valor)
/*
  Aciona o freio de mão do carro.
  Paramêtros:
  * valor:  um byte que define se o freio será acionado ou não.
            1 para acionar o freio e 0 para não acionar.
  Retorna:
  * 0 em caso de sucesso.
  * -1 caso algum parametro esteja fora de seu intervalo .
*/
.globl set_handbreak
set_handbreak:
    li a7, 11
    li t0, 2
    blt a0, zero, 1f # Salta para 1f se a0<0
    bge a0, t0, 1f # Salta para 1f se a0>=t0 == a0>=2
    ecall # Se a0==1 ou ao==0, chama a syscall
    li a0, 0 # Nesse caso, os parâmetros foram válidos, então o retorno é 0
    j 2f
    1:
    li a0, -1 # Se a0<0 e a0>1, então os parâmetros não são válidos. Portanto o retorno é -1
    2:
ret

# void read_camera(unsigned char* img);
/*
  Lê os valores da camera de linha.
  Paramêtros:
  * img:  endereço de um vetor de 256 elementos que armazenará os
          valores lidos da camera de linha.
  Retorna:
    Nada
*/
.globl read_camera
read_camera:
    li a7, 12
    ecall
ret

# int read_sensor_distance(void);
/*
  Lê a distancia do sensor ultrasônico
  Paramêtros:
    Nenhum
  Retorna:
    O inteiro com a distância do sensor, em centímetros.
*/
.globl read_sensor_distance
read_sensor_distance:
    li a7, 13
    ecall
ret

# void get_position(int* x, int* y, int* z);
/*
  Lê a posição aproximada do carro usano um dispositivo de GPS
  Parametros:
  * x:  endereço da variável que armazenará o valor da posição x
  * y:  endereço da variável que armazenará o valor da posição y
  * z:  endereço da variável que armazenará o valor da posição z
  Retorna:
    Nada
*/
.globl get_position
get_position:
    li a7, 15
    ecall
ret

# void get_rotation(int* x, int* y, int* z);
/*
  Lê a rotação global do dispositivo de giroscópio
  Parametros:
  * x:  endereço da variável que armazenará o valor do angulo de Euler em x
  * y:  endereço da variável que armazenará o valor do angulo de Euler em y
  * z:  endereço da variável que armazenará o valor do angulo de Euler em z
  Retorna:
    Nada
*/
.globl get_rotation
get_rotation:
    li a7, 16
    ecall
ret

# unsigned int get_time(void);
/*
  Lê o tempo do sistema
  Paramêtros:
    Nenhum
  Retorna:
    O tempo do sistema, em milisegundos.
*/
.globl get_time
get_time:
    li a7, 20   # Carrega em a7 o identificador da syscall get_systime
    ecall
ret


# void filter_1d_image(unsigned char * img, char * filter);
/*
  Filtra uma imagem unidimensional utilizando um filtro unidimensional (similar ao lab 6b, mas para apenas uma dimensão). 
  Paramêtros:
    img: array representando a imagem.
    filter: vetor de 3 posições representando o filtro 1D.
  Retorna:
    Nada
*/
.globl filter_1d_image
filter_1d_image:
    mv t5, a0   # Salva o valor de a0 em t5
    li t0, 0    # Variável que guarda o valor do pixel após o cálculo usando o filtro (deve ser aplicado após o cálculo da iteração seguinte)
    li t1, 1    # Variável indexadora 
    li t2, 255  # Variável comparadora


    1: # While t1<t2 == t1<255:
        bge t1, t2, 1f  # Sai do loop se t1>=t5 == t1>=255
        li t6, 0        # Variável acumuladora (resetada para 0 a cada iteração)
        # Como o array é unidmensional e não é dado uma posição para se guardar a imagem filtrada sem estragar o array original. 
        # É preciso implementar um algorítimo de troca, que atua a partir do índice i=1 até i=254 (pois i=0 e i=255 tem valor zero), 
        # trocando os valores dos pixels calculados na iteração passada somente após o registro do valor original na iteração atual.
        lbu t3, 0(a0)   # t3<=MEM[a0] : Obtém o valor do pixel anterior
        sb t0, 0(a0)    # MEM[a0]<=t0 : Coloca o valor do pixel calculado na iteração anterior
        lb t4, 0(a1)    # t4<=MEM[a1] : Obtém o valor do filtro para o pixel anterior
        mul t3, t3, t4  # t3*=t4 : Multiplica o valor do pixel anterior pelo valor do filtro para ele
        add t6, t6, t3  # t6+=t3 : Soma o resultado no acumulador
        
        lbu t3, 1(a0)   # t3<=MEM[a0+1] : Obtém o valor do pixel atual
        lb t4, 1(a1)    # t4<=MEM[a1+1] : Obtém o calor do filtro para o pixel atual
        mul t3, t3, t4  # t3*=t4 : Multiplica o valor do pixel atual pelo valor do filtro para ele
        add t6, t6, t3  # t6+=t3 : Soma o resultado no acumulador
        
        lbu t3, 2(a0)   # t3<=MEM[a0+2] : Obtém o valor do pixel posterior
        lb t4, 2(a1)    # t4<=MEM[a1+2] : Obtém o calor do filtro para o pixel posterior
        mul t3, t3, t4  # t3*=t4 : Multiplica o valor do pixel posterior pelo valor do filtro para ele
        add t6, t6, t3  # t6+=t3 : Soma o resultado no acumulador
        # Processo de cálculo do pixel filtrado completo, resultado em t6
        li t4, 256      #
        blt t6, t4, 2f  # Se t6<t4, pula pra 2f. Se não, então t6>=256. Por isso atualiza t6 para 255
        li t6, 255      #
        2:
        bge t6, zero, 2f#
        li t6, 0        # Se t6>=0, pula pra 2f. Se não, então t6<0. Por isso atualiza t6 para 0
        2:              #
        mv t0, t6       # t0=t6 : Copia t6 em t0 para ser guardado na possição atual de a0 na próxima iteração

        addi t1, t1, 1  # t1++ : Incrementa o índice
        addi a0, a0, 1  # a0++ : Desloca para o próximo elemento do vetor
        j 1b
    1:
    
    sb t0, 0(a0)        # No fim do laço, o pixel filtrado da posição 254 ainda não foi trocado
    li t6, 0            # O último pixel (255) está na borda, por isso seu valor é zero
    sb t6, 1(a0)     
    mv a0, t5           # Restaura o valor inicial de a0
ret

# void display_image(char * img);
/*
  Mostra uma imagem 1D (1x256) no canvas. 
  Paramêtros:
    img: array representando a imagem.
  Retorna:
    Nada
*/
.globl display_image
display_image:
    li a7, 19
    ecall
ret

##### Funções já implementadas no laboratório 7: ######

# void read(int file_descp, char* str, int bytes):
read: # Argumentos: a0 = file_descriptor , a1 = endereço do buffer no qual a string será posicionada ,a2 = quantidade de bytes a serem lidos
    li a7, 17               
    ecall
ret

# void write(int file_descp, char* str, int bytes)
write:  # Argumentos: a0 = file_descriptor , a1 = endereço do buffer no qual a string será posicionada ,a2 = quantidade de bytes a serem escritos
    li a7, 18           
    ecall

ret

# int lenStr(char* str):
lenStr: # Argumentos: a0 = endereço da string terminada em '\0' ; Retorno = tamanho da string (quantidade de bytes)
    li t1, 0 # Acumulador
    li t2, 0 # Comparador
    lbu t0, 0(a0) # Caracter iterado (i) 

    1: # While t0 != t2 , i.e, i!='\0' :
        beq t0, t2, 1f      # Se t0 == 2, quebra o while . Se não...
        addi t1, t1, 1     # t1++
        addi a0, a0, 1     # a0++
        lbu t0, 0(a0)       # t0 = str[a0]
        j 1b
    1:
    mv a0, t1

ret

# int puts(char* str):
.globl puts
puts: # Argumentos: a0 = endereço da string terminada em '\0'; Retorno = 1 ; Deve printar a string passada em stdout
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 5(sp)        
    sw fp, 1(sp)
    li t0, 10           # t0=10 == t0='\n' : Variável local
    sb t0, 0(sp)        # caracter '\n' colocado em um buffer para ser impresso em seguida da string
    
    add fp,sp, 16
    #

    mv a1, a0           # a1 = a0 , i.e, a1 = endereço de str
    jal lenStr          # lenStr(a0) -> a0 = quantidade de bytes a serem escritos
    mv a2, a0           # a2 = a0 , i.e, a2 = quantidade de bytes a serem escritos
    li a0, 1            # file descriptor = 1 é o file descriptor de stdout
    jal write           # write(a0,a1,a2) -> escreve em stdout a string str

    li a0, 1
    mv a1, sp           # a1 = sp , i.e, a1 = endereço do caracter '\n'
    li a2, 1            # a2 = 1 , pois '\n' tem só um caracter
    jal write           # write(a0,a1,a2) -> escreve '\n' em stdout

    li a0, 1

    # Desalocando quadro de pilha:
    lw fp, 1(sp)
    lw ra, 5(sp)
    addi sp, sp, 16
    #
ret

.globl gets
# char* gets(char* str):
gets:   # Argumentos: a0 = endereço da string terminada em '\0'; Retorno = endereço para a string lida ; Deve escrever todos os caracteres até a quebra de linha de stdin em str
    # Alocando quadro de pilha:
    addi sp, sp, -32
    sw ra, 0(sp)        
    sw fp, 4(sp)
    sw a0, 8(sp)
    sb zero, 12(sp)      # buffer para guardar o caracter lido mais recente 
    sw s1, 13(sp)
    sw s2, 17(sp)
    sw s3, 21(sp)
    add fp,sp, 32
    #

    mv s1, a0           # s1 = a0 , i.e, t0 = cópia do endereço do começo de str
    addi s2, sp, 12     # s2 = sp + 12 , i.e, s1 = endereço do buffer de comparação
    li s3, 10           # s3 = '\n' (comparador)


    1: # Do ... While t1 != t2 , i.e, t1 != '\n':
        li a0, 0            # a0 = 0 , i.e, a0 = file descriptor de stdin
        mv a1, s2           # a1 = s2 , i.e, a1= 12+sp , i.e, a1 = endereço do buffer de comparação
        li a2, 1            # a2 = 1 , pois vamos executar a leitura de um byte de cada vez e armazená-lo no buffer de comparação (12(sp))
        jal read            # read(0,12(sp),1) -> coloca em 12(sp) um byte lido de stdin
        lbu t2, 0(s2)       # Carrega o byte lido em t2
        beq t2, s3, 1f      # Se t2 == s3 == '\n' , quebra o while. Se não...
        sb t2, 0(s1)        # Salva o byte lido no endereço guardado em s1, que começa como o início da string e aumenta a cada execução
        addi s1, s1 ,1      # t0++ , i.e, passa pro próximo elemento da string
        j 1b
    1: 


    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    lw a0, 8(sp)
    lw s1, 13(sp)
    lw s2, 17(sp)
    lw s3, 21(sp)
    addi sp, sp, 32
    #
ret

.globl atoi
#int atoi(char* str):
atoi: # Argumentos: a0 = endereço do primeiro caracter de uma string terminada em '\0'; Retorno : a0 = número inteiro resultante da conversão ; Deve converter o inteiro representado pela string em um int de base 10
    # A função primeiro descarta todos os espaços em branco do começo até o primeiro caracter que não é um espaço em branco
    li t1, 32               # t1 = 32 == ' '
    li t2, 9                # t2 = 9 == '\t'
    li t3, 10               # t3 = 10 == '\n'
    li t4, 11               # t4 = 11 == '\b'
    li t5, 12               # t5 = 12 == '\f'
    li t6, 13               # t6 = 13 == '\r'
    1: # While t1 == ' ' or '\t' or '\n' or '\v' or '\f' or '\r':
        lbu t0, 0(a0)           # carrega em t0 o char no endereço de memória t0
        beq t0, t1, 2f          #
        beq t0, t2, 2f          #
        beq t0, t3, 2f          #   
        beq t0, t4, 2f          # Se t0 == ' ' ou '\t' ou '\n' ou '\v' ou '\f' ou '\r' , salta para 2f
        beq t0, t5, 2f          #
        beq t0, t6, 2f          #
        j 1f                    # Se não, quebra o while  

        2:  
        addi a0, a0, 1          # a0++ : a0 = endereço do próximo char de str
        j 1b                    # Reinicia o while
    1:

    # Depois da etapa acima, a0 agora possui o endereço do primeiro byte que não indica um espaço em branco
    # Primeiro devemos verificar se este caracter é um sinal. Se ele for um número, assumimos que o valor é positivo
    # A qualquer momento, se o caracter não for um número, a função deve encerrar e retornar o que foi convertido até antes do char não número
    li t1, 45           # t1 = 45 == '-'
    bne t0, t1, 1f      # Se t0 != t1 == '-' , salta para 1f
    li t1, -1           # Se não, então t0 == '-'. Carregamos em t1 o valor -1 para multiplicar pelo resultado da conversão no final
    addi a0, a0 ,1      # Avança para o próximo char
    j 2f
    
    1:  
    li t1, 43           # t1 = 43 == '+'
    bne t0, t1, 1f      # Se t0 != t1 == '+' , salta para 1f
    addi a0, a0 , 1     # Avança para o próximo char
    1:
    li t1, 1            # Será executada se t0 == '+' ou t0!= '-', guardando 1 em t1

    2: 
    li t2, 0            # t2 será o acumulador que, no fim, deverá conter o número de dígitos no número
    mv t5, a0           # Copiando o valor de a0 em t5 para poder reiniciar a iteração fazendo a conversão

    1: # Do ... While t0 >= 48 and t0 <= 57 ('0'<=t0<='9'):
        lbu t0, 0(a0)
        li t3, 48
        blt t0, t3, 1f  # Se t0 < t3 , quebra o laço saltando para 1f
        li t3, 58
        bge t0, t3, 1f  # Se t0 >= 58 , quebra o laço saltando para 1f 
        addi a0, a0, 1  # a0++
        addi t2, t2, 1  # t2++
        j 1b
    1:
    # A partir daqui, t2 contém a quantidade de dígitos do número, basta agora convertê-lo

    mv a0, t5           # Reestabelecendo o valor do começo do número
    addi t2, t2, -1     # A potência de 10 do da primeiro dígito é sempre uma unidade menor que o número de dígitos
    li t6, 0            # t6 será o acumulador do número convertido            
    
    1: # Do... While t2 != 0 :
        lbu t0, 0(a0)   # Carrega o char do endereço indicado por a0
        li t3, 1        # t3 = 1 (acumulador da potência de 10)
        mv t4 , t2      # Cópia da quantidade de dígitos para poder ser decrementada
        
        2: # While t4 !=0 :
            beq t4, zero, 2f    # Sai do while interno se t4 == 0
            li t5 , 10          # t5 = 10 
            mul t3, t3, t5      # t3*=10
            addi t4, t4, -1     # t4--
            j 2b
        2:
        
        addi t0, t0, -48        # t0-=48
        mul t0, t0, t3          # t0*=t3
        add t6, t0, t6          # t6+=t0
        addi a0, a0, 1          # a0++ (avança para o próximo char)
        beq t2, zero, 1f        # Sai do while externo se a1 == 0
        addi t2, t2, -1
        j 1b
    1:
    mul a0, t6, t1      # a0 = t6*t1, i.e, a0 = -t6 ou a0 = t6

ret

# char* cvt10(int value, char* str):
cvt10:  # Argumentos: a0 = inteiro identificando o valor a ser convertido, a1 = endereço da string para guardar o resultado da conversão; Retorno: a0 = endereço da string da conversão   
    mv t6, a1           # Salva o endereço inicial da string
    li t0, 0
    bge a0, t0, 1f       # Salta para 1f se a0 >= 0
    li t0, -1           # Se não, guarda -1 em t0, para adicionar o valor de menos na conversão
    mul a0, a0, t0      # a0*=t0 , i.e, a0*=-1
    li t0, 45           # t0 = 45 = '-'
    sb t0, 0(a1)        # Salva '-' no primeiro byte da string
    addi a1, a1, 1      # Avança para o próximo espaço da string
    1:

    mv t0, a0           # Copia o valor de a0 em t0
    li t1, 0            # t1 = 0 (comparador)
    li t2, 0            # t2 = 0 (acumulador)
    li t3, 10           # t3 = 10 (valor de divisão)
    1: # Do... While t0 != t1 == 0:
        divu t0, t0 ,t3         # t0 = t0/10
        addi t2, t2, 1
        beq t0, t1, 1f          # Quebra se t0 = 0
        j 1b 
    1:
    mv t0, a0           # Copia o valor de a0 em t0 (de novo), mantendo o comparador e o valor de divisão. Agora, t2 contém o número de dígitos do decimal
    
    li t4, 0           # t4 ='\0'
    mv t5, a1           # t5 = a1
    add t5, t5, t2          # t5 += t2 (endereço do último caracter da string)
    sb  t4, 0(t5)       # Salva '\0' no último caracter da string    
    addi t2, t2, -1     # t2 agora é o offset do digito em relação ao primeiro
    
    1: # While t0 != t1 == 0:
        remu t4, t0, t3         # t4 = t0 % 10
        divu t0, t0, t3         # t0 = t0/10
        addi t4, t4, 48         # t4 += 48 , i.e, t4 += '0' (converte dígito inteiro em caracter)
        mv t5, a1               # t5 = a1
        add t5, t5, t2          # t5 += t2
        sb t4, 0(t5)            # guarda t4 no endereço contido em t5
        beq t0, t1, 1f          # Quebra o laço se t0 = 0
        addi t2, t2, -1         # t2--
        j 1b
    1:

    mv a0, t6

ret

# char* cvt16(int value, char* str):
cvt16: # Argumentos: a0 = inteiro identificando o valor a ser convertido, a1 = endereço da string para guardar o resultado da conversão; Retorno: a0 = endereço da string da conversão
    mv t6, a1           # Salva o endereço inicial da string
    li t0, 0
    bge a0, t0, 1f       # Salta para 1f se a0 >= 0
    li t0, -1           # Se não, guarda -1 em t0, para adicionar o valor de menos na conversão
    mul a0, a0, t0      # a0*=t0 , i.e, a0*=-1
    li t0, 45           # t0 = 45 = '-'
    sb t0, 0(a1)        # Salva '-' no primeiro byte da string
    addi a1, a1, 1      # Avança para o próximo espaço da string
    1:

    mv t0, a0           # Copia o valor de a0 em t0
    li t1, 0            # t1 = 0 (comparador)
    li t2, 0            # t2 = 0 (acumulador)
    li t3, 16           # t3 = 16 (valor de divisão)
    1: # Do... While t0 != t1 == 0:
        divu t0, t0 ,t3         # t0 = t0/16
        addi t2, t2, 1
        beq t0, t1, 1f          # Quebra se t0 = 0
        j 1b 
    1:
    mv t0, a0           # Copia o valor de a0 em t0 (de novo), mantendo o comparador e o valor de divisão. Agora, t2 contém o número de dígitos do hexadecimal
    
    li t4, 0           # t4 ='\0'
    mv t5, a1           # t5 = a1
    add t5, t2, t5          # t5 += t2 (endereço do último caracter da string)
    sb  t4, 0(t5)       # Salva '\0' no último caracter da string    
    addi t2, t2, -1     # t2 agora é o offset do digito em relação ao primeiro
    
    1: # While t0 != t1 == 0:
        remu t4, t0, t3         # t4 = t0 % 16
        divu t0, t0, t3         # t0 = t0/16
        addi t4, t4, 48         # t4 += 48 , i.e, t4 += '0' (converte dígito inteiro em caracter)
        li t5, 58               
        blt t4 ,t5 ,2f          # Se t4 < t5 == 58 , então t4 é um dígito decimal, portanto pula a próxima instrução 
        addi t4, t4, 39         # Se não, t4 = 'a','b','c','d' ou 'f'. Por isso se soma 39 para mapear o resultado nos chars corretos
        2:
        mv t5, a1               # t5 = a1
        add t5, t5, t2          # t5 += t2
        sb t4, 0(t5)            # guarda t4 no endereço contido em t5
        beq t0, t1, 1f          # Quebra o laço se t0 = 0
        addi t2, t2, -1         # t2--
        j 1b
    1:

    mv a0, t6

ret

.globl itoa
#char* itoa(int value, char* str, int base):
itoa: # Argumentos: a0 = inteiro identificando o valor a ser convertido, a1 = endereço da string para guardar o resultado da conversão, a2 = inteiro identificando a base da conversão ; Retorno : a0 = endereço da string da conversão ; Deve converter o inteiro dado como argumento em uma string
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 0(sp)        
    sw fp, 4(sp)

    add fp,sp, 16
    #

    li t0, 10
    bne a2, t0, 1f
    jal cvt10
    j 2f
    1:
    jal cvt16
    2:
    mv a0, a1
    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    addi sp, sp, 16
    #

ret

.globl sleep
#void sleep(int ms);
sleep:
    mv t0, a0           # t0=a0 : Agora, t0 guarda o valor de milisegundos de pausa
    li a7, 20           # a7=20 : Carrega em a7 o identificador da syscall_get_systime
    ecall               # Chama o SO, colocando em a0 o tempo do sistema
    mv t1, a0           # t1=a0 : Copia esse valor para t1. Agora t1 guarda o valor de tempo do começo da rotina
    1: # Do ... While 
        li a7, 20       # a7=20 : Carrega em a7 o identificador da syscall_get_systime
        ecall           # Chama o SO, colocando em a0 o tempo do sistema
        sub t2, a0, t1  # t2=a0-t1 : Coloca em t2 a diferença do tempo atual para o tempo de início da rotina
        bge t2, t0, 1f  # Sai do laço se t2>=t0, i.e., se a diferença do tempo atual para o tempo de início é maior que o tempo de pausa em ms
        j 1b            # Reinicia o loop
    1:
    mv a0, t0           # Restaura a variável a0
ret

.globl approx_sqrt
#int approx_sqrt(int x, int iterations):
approx_sqrt: # Argumentos: a0 = inteiro para se calcular a raiz, a1 = número de iterações; Retorno: a0 = raiz aproximada de x com a aplicção de iterations iterações
    mv t0, a0           # t0 = a0
    li t1, 2            # t1 = 2
    div a0, a0, t1      # a0 = a0/t1 == a0/2 , i.e, a0 é o guess inicial (k)
    
    1: # While a1 != 0
        beq a1, zero, 1f
        div t2, t0, a0      # t2 = t0/a0 = y/k
        add a0, a0, t2      # a0 = a0 + t2 = k+(y/k)
        div a0, a0, t1      # a0 = a0/t1 = a0/2 = (k+(y/k))/2 == k'
        addi a1, a1, -1
        j 1b
    1:

ret

