.bss
desloc_x: .skip 4
desloc_y: .skip 4
dist_x: .skip 4
dist_y: .skip 4

.data
car_x: .word 165
car_y: .word -113
target_x: .word 73
target_y: .word -19

.align 2
.text
.set CAR_GPS_ACTIVATOR, 0xffff0100
.set CAR_GPS_X, 0xffff0110
.set CAR_GPS_Y, 0xffff0114
.set CAR_GPS_Z, 0xffff0118
.set CAR_STEERING_WELL, 0xffff0120
.set CAR_ENGINE, 0xffff0121
.set CAR_BREAK, 0xffff0122

.globl _start
# void scanGPS():
scanGPS:
    li t0, CAR_GPS_ACTIVATOR        # Carrega o inteiro que identifica a posição de memória do ativador do gps
    li t1, 1                        # t1=1 : carrega 1 em t1
    sb t1, 0(t0)                    # MEM[t0]<=t1 == MEM[t0]<=1 : armazena 1 na posição de memória do ativador (provocando a atualização do GPS)
    
    1:# While MEM[t0]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
ret

# void setCarXY(): 
updateCarXY:
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 0(sp)        
    sw fp, 4(sp)
    
    add fp,sp, 16
    #

    jal scanGPS                    # Chama a função scanGPS para atualizar o valor das posições de GPS 

    la t0, car_x                   # Carrega o endereço da variável globar car_x em t0
    li t1, CAR_GPS_X               # Carrega o inteiro que identifica a posição de memória do ativador do gps
    lw t1, 0(t1)                   # t1<=MEM[t1] == t1<=MEM[CAR_GPS_X] : Carrega em t1 o valor da posição x do carro
    lw t2, 0(t0)                   # t2<=MEM[t0] : Carrega em t2 a posição x anterior do carro 
    sub t2, t1, t2                 # t2=t1-t2 : Calcula o deslocamento x do carro ( x_atual - x_anterior ) e armazena em t2
    la t3, desloc_x                # Carrega em t3 o endereço da variável global desloc_x
    sw t2, 0(t3)                   # MEM[t3]<=t2 : Salva na variável desloc_x o deslocamento calculado
    sw t1, 0(t0)                   # MEM[t0]<=t1 == MEM[car_x]<=t1 : Salva t1 na variável car_x

    la t0, car_y                   # Carrega o endereço da variável globar car_y em t0
    li t1, CAR_GPS_Z               # Carrega o inteiro que identifica a posição de memória do ativador do gps
    lw t1, 0(t1)                   # t1<=MEM[t1] == t1<=MEM[CAR_GPS_Z] : Carrega em t1 o valor da posição y do carro
    lw t2, 0(t0)                   # t2<=MEM[t0] : Carrega em t2 a posição y anterior do carro 
    sub t2, t1, t2                 # t2=t1-t2 : Calcula o deslocamento y do carro ( y_atual - y_anterior ) e armazena em t2
    la t3, desloc_y                # Carrega em t3 o endereço da variável global desloc_y
    sw t2, 0(t3)                   # MEM[t3]<=t2 : Salva na variável desloc_y o deslocamento calculado
    sw t1, 0(t0)                   # MEM[t0]<=t1 == MEM[car_Y]<=t1 : Salva t1 na variável car_Y

    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    addi sp, sp, 16
    #
ret

# int clcInnerProduct(): deve retornar o valor do produto interno de desloc com o vetor perpendicular a dist em a0
clcInnerProduct:
    la t0, desloc_x
    lw t0, 0(t0)
    la t1, dist_y
    lw t1, 0(t1)
    mul a0, t0, t1

    la t0, desloc_y
    lw t0, 0(t0)
    la t1, dist_x
    lw t1, 0(t1)
    li t2, -1
    mul t1, t1, t2
    mul t0, t0, t1

    add a0, a0, t0
ret

# void setEngine(int vel): deve definir a velocidade do carro mediante o inteiro passado em a0
setEngine:
    li t0, CAR_ENGINE
    sb a0, 0(t0)
ret

# void setWheelToRight(): deve girar o volante para a direita
setWheelToRight:
    li t0, CAR_STEERING_WELL
    li t1, 127
    sb t1, 0(t0)
ret

# void setWheelToLeft(): deve girar o volante para a direita
setWheelToLeft:
    li t0, CAR_STEERING_WELL
    li t1, -127
    sb t1, 0(t0)
ret

# void setWheelToMiddle(): deve zerar o volante
setWheelToMiddle:
    li t0, CAR_STEERING_WELL
    li t1, 0
    sb t1, 0(t0)
ret

# void clcDistanceVct():
clcDistanceVct:
    la t0, target_x                # Carrega em t0 o endereço da variável global target_x
    la t1, car_x                   # Carrega em t1 o endereço da variável global car_x
    lw t0, 0(t0)                   # t0<=MEM[t0] : Carrega em t0 o valor da variável global target_x
    lw t1, 0(t1)                   # t1<=MEM[t1] : Carrega em t0 o valor da variável global car_x
    sub t0, t0, t1                 # t0 = t0 - t1 : t0 passa a ser o componente x do vetor de distância entre o carro e o alvo
    la t1, dist_x                  # Carrega em t1 o endereço da variável global dist_x
    sw t0, 0(t1)                   # MEM[t1]<=t0 : Salva to no endereço da variável global dist_x

    la t0, target_y                # Carrega em t0 o endereço da variável global target_y
    la t1, car_y                   # Carrega em t1 o endereço da variável global car_y
    lw t0, 0(t0)                   # t0<=MEM[t0] : Carrega em t0 o valor da variável global t0
    lw t1, 0(t1)                   # t1<=MEM[t1] : Carrega em t0 o valor da variável global t1
    sub t0, t0, t1                 # t0 = t0 - t1 : t0 passa a ser o componente y do vetor de distância entre o carro e o alvo
    la t1, dist_y                  # Carrega em t1 o endereço da variável global dist_y
    sw t0, 0(t1)                   # MEM[t1]<=t0 : Salva t0 no endereço da variável global dist_y

ret

# void exit(int code):
exit:
    li a7, 93
    ecall
ret

#void sleep(int ms):
sleep: # Argumentos: a0 = tempo em ms que o programa deve parar
    1:
        beq a0, zero, 1f
        addi a0, a0, -1
        j 1b
    1:
ret

#int approx_mod_dist():
approx_mod_dist: # Retorno: a0 = módulo da distância aproximado
    
    la t0, dist_x
    lw t0, 0(t0)
    la t1, dist_y
    lw t1, 0(t1)
    mul t0, t0, t0
    mul t1, t1, t1
    add a0, t0, t1

    mv t0, a0           # t0 = a0
    li t1, 2            # t1 = 2
    div a0, a0, t1      # a0 = a0/t1 == a0/2 , i.e, a0 é o guess inicial (k)
    li a1, 20

    1: # While a1 != 0
        beq a1, zero, 1f
        div t2, t0, a0      # t2 = t0/a0 = y/k
        add a0, a0, t2      # a0 = a0 + t2 = k+(y/k)
        div a0, a0, t1      # a0 = a0/t1 = a0/2 = (k+(y/k))/2 == k'
        addi a1, a1, -1
        j 1b
    1:

ret

breakEngine:
    li t0, CAR_BREAK
    li t1, 1
    sb t1, 0(t0)
ret


_start:
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 0(sp)        
    sw fp, 4(sp)
    
    add fp,sp, 16
    #

    li a0, 1
    jal setEngine
    li a0, 1000
    jal sleep

    li s1, 15
    1: #While TRUE 
        
        li a0, 3
        #jal sleep

        jal updateCarXY                # Atualiza a posição (x,y) e o deslocamento do carro
        jal clcDistanceVct             # Atualiza o vetor distância
        jal approx_mod_dist            # Calcula o módulo da distância aproximado
        
        bge a0, s1, continue           # Pula a próxima instrução se a0 == 15
        li a0, 0 
        jal breakEngine
        li a0, 5
        #jal sleep
        li a0, 1
        jal exit
        continue:

        jal clcInnerProduct            # Atualiza o valor do produto interno

        bge a0, zero, 2f               # Se a0>0 pula pra 2f  
        beq a0, zero, 3f               # se a0==0 pula pra 3f
        jal setWheelToRight            # Se não (a0<0) vira o volante pra direita
        j 1b                           # Reinicia o loop
        2:
        jal setWheelToLeft             # Vira o volante para a esquerda
        j 1b                           # Reinicia o loop
        3:
        jal setWheelToMiddle           # Zera o volante
        j 1b                           # Reinicia o loop

    1:

    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    addi sp, sp, 16
    #