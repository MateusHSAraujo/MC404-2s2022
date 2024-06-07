.bss
desloc_x: .skip 4
desloc_y: .skip 4
desloc_z: .skip 4
dist_x: .skip 4
dist_y: .skip 4
dist_z: .skip 4

.align 4
isr_stack:      # Final da pilha das ISRs
.skip 1024      # Aloca 1024 bytes para a pilha
isr_stack_end:  # Base da pilha das ISRs

.align 4
program_stack:  # Final da pilha do programa
.skip 1024      # Aloca 1024 bytes para a pilha do programa
program_stack_end: # Base da pilha do programa


.data
car_x: .word 165
car_y: .word 0
car_z: .word -113
target_x: .word 73
target_z: .word -19

.align 2
.text
.set CAR_GPS_ACTIVATOR, 0xffff0100          
.set CAR_GPS_X, 0xffff0110
.set CAR_GPS_Y, 0xffff0114
.set CAR_GPS_Z, 0xffff0118
.set CAR_STEERING_WELL, 0xffff0120
.set CAR_ENGINE, 0xffff0121
.set CAR_BREAK, 0xffff0122

.align 4
###### Tratador de interrupções e syscalls ######
int_handler:
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -32 # Aloca espaço na pilha da ISR
    sw fp, 0(sp) 
    sw ra, 4(sp) 
    sw t0, 8(sp) 
    sw t1, 12(sp) 
    sw t2, 16(sp) 
    sw t3, 20(sp) 
    addi fp,sp, 32
    #

    # Tratamento das syscalls:
    # a7 contém o código da syscall:
    li t1, 10
    li t2, 11
    li t3, 15
    
    bne a7, t1, 1f                          # Se a7 != t1 ==10 , salta para 1f
    jal syscall_set_engine_and_steering     # Se a7==t1==t0 , chama a syscall set_engine_and_stearing
    1:
    bne a7, t2, 1f              # Se a7 != t2 ==11 , salta para 1f
    jal syscall_set_handbreak   # Se a7==t2==11 , chama a syscall set_handbreak
    1:
    bne a7, t3, 1f              # Se a7 != t3 ==15 , salta para 1f
    jal syscall_get_position    # Se a7==t5==15 , chama a syscall get_position
    1:


    csrr t0, mepc  # carrega endereço de retorno (endereço da instrução que invocou a syscall)
    addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
    csrw mepc, t0  # armazena endereço de retorno de volta no mepc

    # Recupera o contexto
    lw fp, 0(sp)
    lw ra, 4(sp)
    lw t0, 8(sp) 
    lw t1, 12(sp) 
    lw t2, 16(sp) 
    lw t3, 20(sp) 
    addi sp, sp, 32 # Desaloca espaço da pilha da ISR
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente

mret           # Recuperar o restante do contexto (pc <- mepc)
  
# int syscall_set_engine_and_steering(int desloc, int angle):
# - Código 10
# - Deve acionar os motores (para frente se a0=1 e para trás se a0=-1) e girar o volante no valor dado
# - Retorna 0 em caso de sucesso e -1 em caso de falha (parâmetros inválidos)
syscall_set_engine_and_steering:
    li t0, -1
    blt a0, t0, 1f
    li t0, 2
    bge a0, t0, 1f
    li t0, -127
    blt a1, t0, 1f
    li t0, 128
    bge a1, t0, 1f

    li t0, CAR_ENGINE
    sb a0, 0(t0)
    li t0, CAR_STEERING_WELL
    sb a1, 0(t0)

    # Retorna 0 em caso de sucesso:
    li a0, 0
    j 2f
    1: # Retorno -1 em caso de parâmetros inválidos
    li a0, -1
    2:
ret

# void syscall_set_handbreak(int set):
# - Código 11
# - Deve acionar o freio de mão se set=1
syscall_set_handbreak:
    li t0, CAR_BREAK
    sb a0, 0(t0)

ret

# void syscall_get_position(int* x, int* y, int* z):
# - Código 15
# - Lê a posição aproximada do carro usando o dispositivo de GPS
syscall_get_position:
    # Fazendo a leitura do GPS
    li t0, CAR_GPS_ACTIVATOR    # Carrega o inteiro que identifica a posição de memória do ativador do gps
    li t1, 1                    # t1=1 : carrega 1 em t1
    sb t1, 0(t0)                # MEM[t0]<=t1 == MEM[t0]<=1 : armazena 1 na posição de memória do ativador (provocando a atualização do GPS)
    
    1:# While MEM[t0]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
    # Leitura do GPS concluída

    # Atualizando das variáveis
    li t1, CAR_GPS_X    # Carrega em t1 o endereço do registrador externo que guarda o valor X do carro
    li t2, CAR_GPS_Y    # Carrega em t2 o endereço do registrador externo que guarda o valor Y do carro
    li t3, CAR_GPS_Z    # Carrega em t3 o endereço do registrador externo que guarda o valor Z do carro
    lw t1, 0(t1)        # t1<=MEM[CAR_GPS_X] : Carrega em t1 o valor do registrador externo que guarda o valor X do carro
    lw t2, 0(t2)        # t2<=MEM[CAR_GPS_Y] : Carrega em t2 o valor do registrador externo que guarda o valor Y do carro
    lw t3, 0(t3)        # t3<=MEM[CAR_GPS_Z] : Carrega em t3 o valor do registrador externo que guarda o valor Z do carro
    sw t1, 0(a0)        # MEM[a0]<=t1 : Salva em a0 (endereço da variável x) o valor de t1
    sw t2, 0(a1)        # MEM[a1]<=t2 : Salva em a1 (endereço da variável y) o valor de t2
    sw t3, 0(a2)        # MEM[a2]<=t3 : Salva em a2 (endereço da variável z) o valor de t3

ret

###### Inicializador do sistema ######
.globl _start
_start:
    # 1°) Registrar a ISR (em direct mode, nesse caso):
    la t0, int_handler                # Carrega em t0 o endereço da rotina principal de ISR (direct mode)
    csrw mtvec, t0                 # Escreve no registrador mtvec a rotina de tratamento de exceções
    
    # 2°) Configurar a pilha especial das ISR:
    la t0, isr_stack_end           # Carrega em t0 o início da pilha especial das ISR
    csrw mscratch, t0              # Coloca esse endereço em mscratch

    # 3°) Configurar a pilha do programa:
    la sp, program_stack_end       # Carrega o endereço da pilha do programa em sp

    # 4°) Configurar os dispositivos antes de habilitar as interrupções:
    # Os dispositivos do carro não precisão de configuração inicial

    # 5°) Habilitar as interrupções:
    # Habilita interrupções externas (mie.MEIE<=1):
    csrr t0, mie                    # Lê o registrador mie e coloca em t0
    li t2, 0x800                    # Seta o campo MEIE (bit 11)
    or t1, t1, t2                   #
    csrw mie, t1                    # Atualiza o registrador mie

    # Habilita interropções globais (mstatus.MIE <= 1)
    csrr t0, mstatus                # Lê o registrador mstatus e coloca a t0
    ori t0, t0, 0x8                 # Seta o campo MIE (bit 3)
    csrw mstatus, t0                # Atualiza o registrador mstatus

    # 6°) Configurar o registrador mstatus para alterar para modo de usuário assim que a instrução mret for executada:
    csrr t1, mstatus # Atualiza o campo mstatus.MPP
    li t2, ~0x1800 # (bits 11 and 12)
    and t1, t1, t2 # Com o valor 00 (modo usuário)
    csrw mstatus, t1

    # 7°) Carregar a rotina do usuário no csr mepc para que ela seja executada após a instrução mret:
    la t0, user_main # Loads the user software
    csrw mepc, t0 # entry point into mepc

mret



###### Lógica de controle implementada somente com as syscalls ######
.globl logica_controle
logica_controle:
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 0(sp)        
    sw fp, 4(sp)
    sw s1, 8(sp)
    add fp,sp, 16
    #

    li a0, 1                          
    li a1, 0
    li a7, 10                         # Liga o motor
    ecall

    li s1, 225
    1: #While TRUE 
        jal updateCarXYZ               # Atualiza a posição (x,y,z) e o deslocamento do carro
        jal clcDistanceVct             # Atualiza o vetor distância, colocando o módulo desse vetor em a0

        bge a0, s1, continue           # Pula as próximas instruções se a0 >= 225 (|distância|>=15)
        li a0, 1
        li a7, 11
        ecall                          # Invoca o sistema com o código 15 (syscall_set_handbreak)
        j 1f
        continue:

        jal clcInnerProduct            # Atualiza o valor do produto interno

        bge a0, zero, 2f               # Se a0>0 pula pra 2f  
        # Se não (a0<0) vira o volante pra direita
        li a0, 1
        li a1, 100
        li a7, 10
        ecall
        j 1b                           # Reinicia o loop
        
        2: # Se a0>0, vira o volante para a esquerda 
        beq a0, zero, 3f               # se a0==0 pula pra 3f
        li a0, 1
        li a1, -100
        li a7, 10
        ecall
        j 1b                           # Reinicia o loop
        
        3: # Se a0==0, zera o volante
        li a0, 1
        li a1, 0
        li a7, 10
        ecall
        j 1b                           # Reinicia o loop

    1:

    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    #

ret


# int clcDistanceVct(): Atualiza o vetor de distância e retorna seu módulo
clcDistanceVct:
    la t0, target_x                # Carrega em t0 o endereço da variável global target_x
    la t1, car_x                   # Carrega em t1 o endereço da variável global car_x
    lw t0, 0(t0)                   # t0<=MEM[t0] : Carrega em t0 o valor da variável global target_x
    lw t1, 0(t1)                   # t1<=MEM[t1] : Carrega em t0 o valor da variável global car_x
    sub t0, t0, t1                 # t0 = t0 - t1 : t0 passa a ser o componente x do vetor de distância entre o carro e o alvo
    la t1, dist_x                  # Carrega em t1 o endereço da variável global dist_x
    sw t0, 0(t1)                   # MEM[t1]<=t0 : Salva to no endereço da variável global dist_x

    la t2, target_z                # Carrega em t2 o endereço da variável global target_z
    la t3, car_z                   # Carrega em t3 o endereço da variável global car_z
    lw t2, 0(t2)                   # t2<=MEM[t2] : Carrega em t2 o valor da variável global target_z
    lw t3, 0(t3)                   # t3<=MEM[t3] : Carrega em t0 o valor da variável global car_z
    sub t2, t2, t3                 # t2 = t2 - t3 : t2 passa a ser o componente y do vetor de distância entre o carro e o alvo
    la t3, dist_z                  # Carrega em t3 o endereço da variável global dist_z
    sw t2, 0(t3)                   # MEM[t3]<=t2 : Salva t0 no endereço da variável global dist_z

    mul t0, t0 ,t0
    mul t3, t3 ,t3 
    add a0, t0, t3

ret

updateCarXYZ:
    # Alocando quadro de pilha:
    addi sp, sp, -32
    sw ra, 0(sp)        
    sw fp, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    
    add fp,sp, 32
    #

    la a0, car_x        # Carrega o endereço da variável globar car_x em a0
    la a1, car_y        # Carrega o endereço da variável globar car_y em a1
    la a2, car_z        # Carrega o endereço da variável globar car_z em a2

    lw s1, 0(a0)        # s1<=MEM[a0] : Carrega em s1 a posição x anterior do carro 
    lw s2, 0(a1)        # s2<=MEM[a1] : Carrega em s2 a posição y anterior do carro 
    lw s3, 0(a2)        # s3<=MEM[a2] : Carrega em s3 a posição z anterior do carro 

    li a7, 15
    ecall       # Invoca o sistema operacional com o código 15 (syscall_get_position)
    # A partir daqui, a nova posição do carro foi atualizada e está disponível nas variáveis globais 

    la t0, car_x                   # Carrega o endereço da variável globar car_x em t0
    lw t0, 0(t0)                   # t0<=MEM[car_x] : Carrega em t0 o valor da posição x do carro
    sub t0, t0, s1                 # t0=t0-s1 : Calcula o deslocamento x do carro ( x_atual - x_anterior ) e armazena em t0
    la t1, desloc_x                # Carrega em t1 o endereço da variável global desloc_x
    sw t0, 0(t1)                   # MEM[t1]<=t0 : Salva na variável desloc_x o deslocamento calculado
    
    la t2, car_z                   # Carrega o endereço da variável globar car_z em t0
    lw t2, 0(t2)                   # t2<=MEM[car_z] : Carrega em t1 o valor da posição Z do carro
    sub t2, t2, s3                 # t2=t2-s3 : Calcula o deslocamento z do carro ( z_atual - z_anterior ) e armazena em t2
    la t3, desloc_z                # Carrega em t3 o endereço da variável global desloc_z
    sw t2, 0(t3)                   # MEM[t3]<=t2 : Salva na variável desloc_z o deslocamento calculado

    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 32
    #
ret

# int clcInnerProduct(): deve retornar o valor do produto interno de desloc com o vetor perpendicular a dist em a0
clcInnerProduct:
    la t0, desloc_x
    lw t0, 0(t0)
    la t1, dist_z
    lw t1, 0(t1)
    mul a0, t0, t1

    la t0, desloc_z
    lw t0, 0(t0)
    la t1, dist_x
    lw t1, 0(t1)
    li t2, -1
    mul t1, t1, t2
    mul t0, t0, t1

    add a0, a0, t0
ret

