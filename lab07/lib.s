.text
# void read(int file_descp, char* str, int bytes):
read: # Argumentos: a0 = file_descriptor , a1 = endereço do buffer no qual a string será posicionada ,a2 = quantidade de bytes a serem lidos
    li a7, 63               #syscall read (63)
    ecall
ret

# void write(int file_descp, char* str, int bytes)
write:  # Argumentos: a0 = file_descriptor , a1 = endereço do buffer no qual a string será posicionada ,a2 = quantidade de bytes a serem lidos
    li a7, 64           # syscall write (64)
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

.globl puts
# int puts(char* str):
puts: # Argumentos: a0 = endereço da string terminada em '\0'; Retorno = 1 ; Deve printar a string passada em stdout
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 5(sp)        
    sw fp, 1(sp)
    li t0, 10           # Variável local
    sb t0, 0(sp)        # caracter '\n' colocado em um buffer para ser impresso em seguida da string
    
    add fp,sp, 16
    #

    mv a1, a0           # a1 = a0 , i.e, a1 = endereço de str
    jal ra, lenStr      # lenStr(a0) -> a0 = quantidade de bytes a serem escritos
    mv a2, a0           # a2= a0 , i.e, a2 = quantidade de bytes a serem escritos
    li a0, 1            # file descriptor = 1 é o file descriptor de stdout
    jal ra, write       # write(a0,a1,a2) -> escreve em stdout a string str

    li a0, 1
    mv a1, sp           # a1 = sp , i.e, a1 = endereço do caracter '\n'
    li a2, 1            # a2 = 1 , pois '\n' tem só um caracter
    jal ra, write       # write(a0,a1,a2) -> escreve '\n' em stdout

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


    1: # Do ... While t1 != t2 , i.e, t2!= '\n':
        li a0, 0            # a0 = 0 , i.e, a0 = file descriptor de stdin
        mv a1, s2           # a1 = s2 , i.e, a1= 12+sp , i.e, a1 = endereço do buffer de comparação
        li a2, 1            # a2 = 1 , pois vamos executar a leitura de um byte de cada vez e armazená-lo no buffer de comparação (0(sp))
        jal read            # read(0,0(sp),1) -> coloca em 0(sp) um byte lido de stdin
        lbu t2, 0(s2)       # Carrega o byte lido em t2
        beq t2, s3, 1f      # Se t2 == s3 == '\n' , quebra o while. Se não...
        sb t2, 0(s1)        # Salva o byte lido no endereço guardado em s7, que começa como o início da string e aumenta a cada execução
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

    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    addi sp, sp, 16
    #

ret

.globl time
# int time():
time: # Sem argumentos; Retorno = inteiro que representa  o tempo do sistema em ms
    # Alocando quadro de pilha:
    addi sp, sp, -32
    sw ra, 24(sp)        
    sw fp, 20(sp)
    sw zero, 8(sp)            # Buffer para timeval (Por que time val tem 12 bytes? Há mais de um inteiro nesse buffer?)

    add fp,sp, 32
    #

    lw a0, 8(sp)            # Colocando em a0 o endereço do buffer timeval

    li a7, 169              # Syscall gettimeofday
    ecall   
    lw a0, 8(sp)            # Colocando novamente o endereço do buffer timeval em a0
    lw t1, 0(a0)            # tempo em segundos
    lw t2, 8(a0)            # fração do tempo em microssegundos
    li t3, 1000
    mul t1, t1, t3          # Convertendo segundos em milisegundos
    div t2, t2, t3          # Convertendo microsegundos em milisegundos
    add a0, t2, t1          # Somando os resultados


    # Desalocando quadro de pilha:
    lw fp, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 32
    #
ret

.globl sleep
#void sleep(int ms):
sleep: # Argumentos: a0 = tempo em ms que o programa deve parar
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 0(sp)        
    sw fp, 4(sp)
    sw s1, 8(sp)        # Variável para guardar o valor de tempo de pausa
    sw s2, 12(sp)       # Variável para guardar o valor de tempo inicial
    add fp,sp, 16
    #

    mv s1, a0           # s1 = tempo de pausa
    jal time            # time() retorna em a0 o tempo em ms
    mv s2, a0           # s2 = tempo inicial 
    
    1: # While True:
        jal time            # time() retorna em a0 o tempo em ms 
        sub t0, a0, s2      # t0 -= a0 , i.e, t0 = Delta t
        bge t0, s1, 1f      # Quebra o laço se o tempo de execução (t0) for maior ou igual ao tempo de pausa desejado (t1) 
        j 1b
    1:

    # Desalocando quadro de pilha:
    lw ra, 0(sp)        
    lw fp, 4(sp)
    lw s1, 8(sp)        # Variável para guardar o valor de tempo de pausa
    lw s2, 12(sp)
    addi sp, sp, 16
    #
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

.globl imageFilter
# void imageFilter(char * img, int width, int height, char filter[3][3]);
imageFilter: # Argumentos: a0 = endereço para o primeiro byte da imagem, a1 = inteiro que identifica o comprimento (colunas), a2 = inteiro que idenficia a altura (linhas), a3 = endereço do primeiro valor da matriz do filtro ; Deve aplicar o filtro dado na imagem
    # Alocando quadro de pilha:
    addi sp, sp, -32
    sw fp, 0(sp)        
    sw ra, 4(sp)        
    sw s7, 8(sp)        #
    sw s1, 12(sp)       #
    sw s2, 16(sp)       #
    sw s3, 20(sp)       # Salvando registradores callee-saved
    sw s4, 24(sp)       #
    sw s5, 28(sp)       #
    add fp,sp, 32
    #
    
    mv s7, a1     # variável para guardar a1 (número de colunas da imagem)
    mv s1, a2     # variável para guardar a2 (número de linhas da imagem)
    mv s2, a0     # variável para guardar a0 (endereço do início da imagem)
    mv s3, a3     # variável para guardar a3 (endereço do filtro)

    li s4, 0                        # Variável indexadora para as linhas (i)
    1: # While s4 < a2 , i.e, i < número de linhas:
        bge s4, s1, 1f
        li s5, 0                    # Variável indexadora para as colunas (j)

        2: # While s5 < a1 , i.e, j < número de linhas:
            bge s5, s7, 2f
            
            mv a0, s5               # Argumento a0 = coluna do pixel (j == s5)
            mv a1, s4               # Argumento a1 = linha do pixel (i == s4)
            mv a2, s2               # Argumento a2 = endereço de início da imagem no array == s2
            mv a3, s7               # Argumento a3 = número de colunas (max_x) == s7
            mv a4, s1               # Argumento a4 = número de linhas (max_y) == s1
            mv a5, s3               # Argumento a5 = endereço da matriz de filtro == s3
            
            jal getFiltPixel        # Com os argumentos acima, a função getPixel deve ler o pixel na posição x e y fornecidas e retornar, em a2, sua cor concatenada
            jal setPixel            # Com os argumentos acima (lembrando que a2 será mudado por setPixel), setPixel deve imprimir o pixel no canvas
            
            addi s5,s5,1            # s5++
            j 2b
        2:

        addi s4, s4, 1             # s4++
        j 1b
    1:


    # Desalocando quadro de pilha:
    lw fp, 0(sp)        
    lw ra, 4(sp)        
    lw s7, 8(sp)        
    lw s1, 12(sp)       
    lw s2, 16(sp)
    lw s3, 20(sp)        
    lw s4, 24(sp)        
    lw s5, 28(sp)  
    addi sp, sp, 32
    #

ret

#int getFiltPixel(int x, int y, char* img, int max_x, int max_y, char* filt):
getFiltPixel:  # Argumentos: a0 = coluna do pixel (i==x) , a1 = linha do pixel (j==y) , a2 = endereço de início da imagem no array, a3 = número de colunas, a4 = número de linhas, a5 = endereço do primeiro valor da matriz de filtro; Retorno: a2 = cor do pixel
    # Alocando quadro de pilha:
    addi sp, sp, -48
    sw fp, 0(sp)
    sw ra, 4(sp)        
    li t0, 0
    sw s7, 8(sp)       #    
    sw s1, 12(sp)      #
    sw s2, 16(sp)      #
    sw s3, 20(sp)      # Salvando registradores callee-saved
    sw s4, 24(sp)      #
    sw s5, 28(sp)      #
    sw s6, 32(sp)      #
    add fp,sp, 48
    # 
    mv t0, a3                    # Carrega, em t0, o inteiro que identifica a largura / número de colunas : t0=jmax
    mv t1, a4                    # Carrega, em t0, o inteiro que identifica a altura / número de linhas : t0=imax
    addi t0, t0, -1              # t0-- : t0 = índice da última coluna
    addi t1, t1, -1              # t1-- : t1 = índice da última linha

    beq a0, zero, 1f                # Se a0 == 0  
    beq a0, t0, 1f                  # ou a0 == t0
    beq a1, zero, 1f                # ou a1 == 0 
    beq a1, t1, 1f                  # ou a1 == t1 , salta 1
    j 2f                            # Se não, salta para 2
    
    1:                              # Nesse caso, o pixel está na borda, por isso deve ter cor preta
    li a2, 255                      # A cor do pixel será 0
    ret                             # Retorna da função

    2:                              # Nesse caso, o pixel não está na borda e sua cor deve ser obtida aplicando o filtro
    
    mv s7, a0                       # Salvando em s7 o argumento a0 da chamada (coluna do pixel)
    mv s1, a1                       # Salvando em s1 o argumento a1 da chamada (linha do pixel)
    mv s2, a2                       # Salvando em s2 o argumento a2 da chamada

    li s3, 0                        # s3 será meu acumulador
    li s4, -1                       # s4 será o offset da linha
    li s5, 2                        # s5 será meu comparador

    1: # while s4 < s5 == s4 < 2 (s4 = -1, 0 ,1) :
        bge s4, s5, 1f              # Sai do while externo se s4 == 2
        li s6, -1                   # s6 será o offset da coluna

        2: # while s6 < s5 == s6 < 2 (s6 = -1, 0 ,1) :
            bge s6, s5 , 2f         # Sai do while interno se s6 == 2
            mv a2, s2               # Reseta o valor de a2 para o endereço de memória que começa o array da imagem
            mv a0, s7               # Reseta o valor de a0 para a coluna do pixel
            mv a1, s1               # Reseta o valor de a1 para a linha do pixel
            add a0, a0, s6          # a0 += s6 : a0 = j+s6
            add a1, a1, s4          # a1 += s5 : a1 = i+s5
            jal getPixel            # getPixel(j+s6, i+s5) -> a2 = p[i+t1,j+t2]

            # Multiplicação entre os valores da matriz
            addi t5, s4, 1          # t5 = s4 + 1 = (0,1,2) (linha da matriz filtro)
            addi t6, s6, 1          # t6 = s6 + 1 = (0,1,2) (coluna da matriz filtro)
            li t4, 3                # t4 = 3 , i.e, t4 = número de colunas da matriz filtro
            mul t4, t4, t5          # t4 = 3*t5 , i.e, t4 = 3*i
            add t4, t4, t6          # t4 += t6 , i.e, t4 = 3*i+j
            add t4, t4, a5          # t4 = str_filt + 3*i + j , i.e, t4 = elemento do filtro compátivel com o elemento iterado
            lw t4, 0(t4)            # Carrega da memória o valor da matriz de filtro
            mul t4, a2, t4          # Multiplica o valor da matriz pelo valor do pixel e guarda em t4
            add s3, s3, t4          # Soma no acumulador

            addi s6, s6, 1          # t1++
            j 2b
        2:

        addi s4, s4, 1              # t1++
        j 1b
    1:

    mv t0, s3                       # Passa para t0 o acumulador
    li t1, 0                        # Comparador
    bge t0, t1 ,1f                  # Se t0>=0, pula
    li t0, 0                        # Se t0<0 , então t0=0
    1:
    li t1, 255                      # Comparador
    blt t0, t1, 1f                  # Se t0<255, pula
    li t0, 255                      # Se t0>=255, então t0=255
    1:
    # Esse tratamento é feito considerando que o valor do pixel está em t0:
    li a2, 255                      # Definindo alpha do pixel (sempre igual a 255 == 11111111) 
    slli t1, t0, 8                  # Desloca o valor do pixel em 8 casas, pois red fica entre os índices 8 e 15
    add a2, a2, t1                  # Definindo blue do pixel
    slli t1, t0, 16                 # Desloca o valor do pixel em 16 casas, pois green fica entre os índices 23 e 16   
    add a2, a2, t1                  # Definindo green do pixel
    slli t1, t0, 24                 # Desloca o valor do pixel em 24 casas, pois red fica entre os índices 31 e 24
    add a2, a2, t1                  # Definindo red do pixel

    mv a0,s7                        # Restabelecendo o argumento a0 da chamada
    mv a1,s1                        # Restabelecendo o argumento a1 da chamada

    # Desalocando quadro de pilha:
    lw fp, 0(sp)
    lw ra, 4(sp)
    lw s7, 8(sp)       #    
    lw s1, 12(sp)      #
    lw s2, 16(sp)      #
    lw s3, 20(sp)      # Restaurando registradores callee-saved
    lw s4, 24(sp)      #
    lw s5, 28(sp)      #
    sw s6, 32(sp)      #
    addi sp, sp, 48
    #  
ret 

# getPixel deve encontrar o pixel na matriz e salvar o byte que ele representa em a2
getPixel: # Argumentos: a0 = coluna do pixel (j==x) , a1 = linha do pixel (i==y) , a2 = endereço de início da imagem no array, a3 = número máximo de colunas

    mul a3, a1, a3                  # a3*=a1 : t0 = i*(jmax)
    add a3, a3, a0                  # a3+=a0 : t0 = i*(jmax) + j
    add a3, a3, a2                  # a3+=a2 : t0 = start_img_i + i*(jmax) + j : a3 = Endereço na memória do pixel no array da imagem
    lbu a2, 0(a3)                   # Carrega o byte que representa o pixel de endereço desejado em a2 (unsigned pois o valor vai de 0 a 255)

ret


# void setPixel(int x, int y, int rgb)
setPixel: # Argumentos: a0 = coordenada x do pixel , a1=coordenada y do pixel , a2 = cor do pixel
    #Mantém o a2 da chamada de setPixel
    li a7, 2200 # syscall setGSPixel (2200)
    ecall
ret

.globl exit
# void exit(int code):
exit:
    li a7, 93
    ecall
ret