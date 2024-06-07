.globl _start
.bss
input: .skip 20     #buffer de leitura
output:  .skip 20   #buffer de escrita

.text
.align 2
read:
li a0, 0            # file descriptor = 0 (stdin)
la a1, input        # buffer
li a2, 20           # size (lendo 20 bytes)
li a7, 63           # syscall read (63)
ecall
ret

write:
li a0, 1            # file descriptor = 1 (stdout)
la a1, output       # buffer
li a2, 20           # size
li a7, 64           # syscall write (64)
ecall
ret

_start:
call read            #invoca read
li a0, 0             #contador
while:
call processaNum
li t0, 20           #comparador
beq t0, a0, skip    #if t0=a0=20 , então saí do loop
j while
skip:
call write          #invoca write
end:
ret #Fim do programa

##########Função processaNum#############
processaNum:        #Argumentos em a0 (posição do número a se avaliado), retorno em ra
la t0, input        #coloca o endereço da string em t0
add t0, t0, a0      #calcula o deslocamento incial da iteração

li t1, 0            #t1 será o registrador acumulador

lb t2, 0(t0)        # Lê o primeiro dígito do número (MSD)
li t3, 1000         # Carrega 1000 em t3 para depois multiplicar pelo dígito
addi t2, t2, -48    # transforma o primeiro caracter em um dígito decimal
mul t2, t2, t3      # Multiplica por 1000
add t1, t1, t2      # Soma no acumulador

lb t2, 1(t0)        # Lê o segundo dígito do número
li t3, 100          # Carrega 100 em t3 para depois multiplicar pelo dígito
addi t2, t2, -48    # transforma o primeiro caracter em um dígito decimal
mul t2, t2, t3      # Multiplica por 100
add t1, t1, t2      # Soma no acumulador

lb t2, 2(t0)        # Lê o terceiro dígito do número
li t3, 10           # Carrega 10 em t3 para depois multiplicar pelo dígito
addi t2, t2, -48    # transforma o primeiro caracter em um dígito decimal
mul t2, t2, t3      # Multiplica por 1000
add t1, t1, t2      # Soma no acumulador

lb t2, 3(t0)        # Lê o quarto dígito do número (LSD)
li t3, 1            # Carrega 1 em t3 para depois multiplicar pelo dígito
addi t2, t2, -48    # transforma o primeiro caracter em um dígito decimal
mul t2, t2, t3      # Multiplica por 1
add t1, t1, t2      # Soma no acumulador

#A partir daqui o número deve estar montado e pronto para operar
mv a1, t1           #Colocando o valor decimal em a1 para ser usado de argumento na função babylon
li t2, 2            #Carrega 2 em t2 para fazer a divisão abaixo
div a2, a1, t2      #Calcula o chute inicial e guarda em a2
jal s1, babylon
#A partir daqui a raiz foi calculada e sua aproximação está em a2, basta agora converter esse número para ascII

la t0, output       #coloca o endereço da string de saída em t0
add t0, t0, a0      #calcula o deslocamento incial da iteração
li t1, 1000

li t1, 1000         #carrega 1000 em t1
div t2, a2, t1      #divide o resultado da raiz por 1000
addi t2, t2, 48     #converte a divisão inteira para ascii
sb t2, 0(t0)        #armazena na primeira posição da string de saída
rem a2, a2, t1      #toma o resto da divisão da raiz por 1000 e guarda em a2

li t1, 100          #carrega 100 em t1
div t2, a2, t1      #divide o resto da divisão por 1000 por 100
addi t2, t2, 48     #converte a divisão inteira para ascii
sb t2, 1(t0)        #armazena na primeira posição da string de saída
rem a2, a2, t1      #toma o resto da divisão da raiz por 100 e guarda em a2

li t1, 10           #carrega 10 em t1
div t2, a2, t1      #divide o resto da divisão por 100 da raiz por 10
addi t2, t2, 48     #converte a divisão inteira para ascii
sb t2, 2(t0)        #armazena na primeira posição da string de saída
rem a2, a2, t1      #toma o resto da divisão da raiz por 10 e guarda em a2
addi t2, a2, 48     #o resto da divisão da raiz por 10 já é primeiro dígito, por isso convertemos ele pra ascii
sb t2, 3(t0)        #e o armazenamos na sting
li t1, 32           #código asc do espaço (" ")
sb t1, 4(t0)        #adiciona espaço logo após o número na sting
li t2, 15
bne a0, t2, 1f      #pula as próximas 2 instruções se a0 != t2 = 15 para só escrever \n no fim da string 
li t1, 10
sb t1, 4(t0)
1:
addi a0, a0, 5      #adiciona 5 em a0 para corrigir o deslocamento da próxima interação
ret                 #retorna 
############################################

#############Função Babylon#################
babylon:            #Argumentos em a1 (y=número decimal) e a2(k1=chute inicial ou k=chute anterior) , retorno em s1
li t0, 0            #Acumulador (deve ir até nove para serem executadas as 10 iterações) 
while1:
#Realizando a iteração do método babylon
div t1, a1, a2      # t1 = a1/a2 = y/k
add a2, a2, t1      # a2 = a2 + t1 = k+(y/k)
li t1, 2            # t1 = 2
div a2, a2, t1      # a2 = a2/t1 = a2/2 = (k+(y/k))/2
# A partir daqui, uma iteração foi completa. As próximas instruções configuram as condições do loop
li t1, 9
beq t0, t1, skip1   #Se t0=t1=9, sai do loop
addi t0, t0, 1          #Essas 2 intruções só são acessadoas se t0!=9. Nesse caso aumento t0 em 1 e volta pro início do loop
j while1
skip1:              #Essa parte só é acessada quando o loop é quebrado
jalr zero, s1       #Retorna para a função que a chamou
############################################