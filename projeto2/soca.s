.bss
.align 4
isr_stack:      # Final da pilha das ISRs
.skip 1024      # Aloca 1024 bytes para a pilha
isr_stack_end:  # Base da pilha das ISRs

.align 2
.text

###### Definição das macros para facilitação da implementação em MMIO: ######
# Macros do GPT:
.set GPT_TRIGGER, 0xffff0100            # Ativador do GPT (byte)
.set GPT_TIME_READ, 0xffff0104          # Leitura do tempo do sistema do GPT (word)
.set GPT_INTERRUPTION_SET, 0xffff0108   # Tempo de ativação de interrupção do GPT (word)

# Macros do Self-Driving Car:
.set CAR_GPS_TRIGGER, 0xffff0300            # Ativador do GPS (byte)
.set CAR_LINE_CAMERA_TRIGGER, 0xffff0301    # Ativador da câmera de linha (byte)
.set CAR_USS_TRIGGER, 0xffff0302            # Ativador do sensor ultrasônico (byte)      
.set CAR_GPS_EANGLE_X, 0xffff0304           # Ângulo de Euler em X da última leitura de GPS (word)  
.set CAR_GPS_EANGLE_Y, 0xffff0308           # Ângulo de Euler em Y da última leitura de GPS (word)
.set CAR_GPS_EANGLE_Z, 0xffff030c           # Ângulo de Euler em Z da última leitura de GPS (word)
.set CAR_GPS_X, 0xffff0310                  # Posição X da última leitura de GPS (word)
.set CAR_GPS_Y, 0xffff0314                  # Posição Y da última leitura de GPS (word)
.set CAR_GPS_Z, 0xffff0318                  # Posição Z da última leitura de GPS (word)
.set CAR_USS_READING, 0xffff031c            # Valor da leitura de distância feita pelo sensor ultrasônico (word)
.set CAR_STEERING_WELL, 0xffff0320          # Registrador de controle do volante do carro (byte)
.set CAR_ENGINE, 0xffff0321                 # Registrador de controle do sentido do carro (byte)
.set CAR_BREAK, 0xffff0322                  # Registrador do freio de mão do carro (byte)
.set CAR_LINE_CAMERA_READING, 0xffff0324    # Registrador que guarda a leitura da câmera de linha (256 unsigned bytes)

# Macros da Serial IO:
.set SIO_WRITE_TRIGGER, 0xffff0500          # Ativador de escrita da porta serial (byte)
.set SIO_WRITE_BUFFER, 0xffff0501           # Registrador que guarda o que será escrito na porta serial (byte)
.set SIO_READ_TRIGGER, 0xffff0502           # Ativador de leitura da porta serial (byte)
.set SIO_READ_BUFFER, 0xffff0503            # Registrador que guarda o que foi lido na porta serial (byte)

# Macros do Canvas:
.set CANVAS_WRITE_TRIGGER, 0xffff0700       # Ativador da escrita no canvas (byte)
.set CANVAS_ARRAY_SIZE, 0xffff0702          # Registrador que guarda o tamanho do vetor de bytes a ser escrito (half)
.set CANVAS_INITIAL_POSITION, 0xffff0704    # Registrador que gurada o ponto inicial de escrita do vetor de bytes (word)
.set CANVAS_PIXEL_ARRAY, 0xffff0708         # Vetor de bytes a ser escrito (126 words)

###### Inicializador do sistema: ######

.globl _start
_start:
    # 1°) Registrar a ISR (em direct mode, nesse caso):
    la t0, int_handler      # Carrega em t0 o endereço da rotina principal de ISR (direct mode)
    csrw mtvec, t0          # Escreve no registrador mtvec a rotina de tratamento de exceções
    
    # 2°) Configurar a pilha especial das ISR:
    la t0, isr_stack_end    # Carrega em t0 o início da pilha especial das ISR
    csrw mscratch, t0       # Coloca esse endereço em mscratch

    # 3°) Configurar a pilha do programa:
    li sp, 0x07fffffc       # Carrega o endereço da pilha do programa em sp (O ENUNCIADO FALA QUE BASTA APONTAR PARA 0X07FFFFFC. ISSO ESTÁ CERTO?)


    # 4°) Configurar os dispositivos antes de habilitar as interrupções:
    # Nessa implementação, o GPT não precisa ser inicializado antes

    # 5°) Habilitar as interrupções:
    # Habilita interrupções externas (mie.MEIE<=1):
    csrr t0, mie            # Lê o registrador mie e coloca em t0
    li t2, 0x800            # Seta o campo MEIE (bit 11)
    or t1, t1, t2           #
    csrw mie, t1            # Atualiza o registrador mie

    # Habilita interropções globais (mstatus.MIE <= 1)
    csrr t0, mstatus        # Lê o registrador mstatus e coloca a t0
    ori t0, t0, 0x8         # Seta o campo MIE (bit 3)
    csrw mstatus, t0        # Atualiza o registrador mstatus

    # 6°) Configurar o registrador mstatus para alterar para modo de usuário assim que a instrução mret for executada:
    csrr t1, mstatus        # Atualiza o campo mstatus.MPP
    li t2, ~0x1800          # (bits 11 and 12)
    and t1, t1, t2          # Com o valor 00 (modo usuário)
    csrw mstatus, t1

    # 7°) Carregar a rotina do usuário no csr mepc para que ela seja executada após a instrução mret:
    la t0, main             # Carrega a instrução de entrada do usuário
    csrw mepc, t0           # Coloca ela em mepc

mret

###### Tratador de interrupções: ######
int_handler:
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -48 # Aloca espaço na pilha da ISR
    sw fp, 0(sp) 
    sw ra, 4(sp) 
    sw t0, 8(sp) 
    sw t1, 12(sp) 
    sw t2, 16(sp) 
    sw t3, 20(sp) 
    sw t4, 24(sp) 
    sw t5, 28(sp) 
    sw t6, 32(sp) 
    addi fp,sp, 48
    #
    /*
    # Verificando se trata-se de uma interrupção ou exceção (syscall):
    
    csrr t0, mcause # Lê a causa da interrupção. Sê mcause>=0 , trata-se de uma exceção, caso contrário , é uma interrupção
    bge t0, zero, 1f 
    jal gpt_isr     # Se t0>=0, é uma interrupção. Como só o GPT gera interrupções, pula pra sua função.
    j 2f
    
    1:*/
    # Tratamento das syscalls (código da syscall em a7):
    li t1, 10
    li t2, 11
    li t3, 12
    li t4, 13
    li t5, 15
    li t6, 16
    li t0, 17
    bne a7, t1, 1f                      # Se a7 != t1 ==10 , salta para 1f
    jal syscall_set_motor               # Se a7==t1==t0 , chama a syscall_set_motor
    1:
    bne a7, t2, 1f                      # Se a7 != t2 ==11 , salta para 1f
    jal syscall_set_handbreak           # Se a7==t2==11 , chama a syscall_set_handbreak
    1:
    bne a7, t3, 1f                      # Se a7 != t3 ==12 , salta para 1f
    jal syscall_read_sensors            # Se a7==t3==12 , chama a syscall_read_sensors
    1:
    bne a7, t4, 1f                      # Se a7 != t4 ==13 , salta para 1f
    jal syscall_read_sensor_distance    # Se a7==t4==13 , chama a syscall_read_sensor_distance 
    1:
    bne a7, t5, 1f                      # Se a7 != t5 ==15 , salta para 1f
    jal syscall_get_position            # Se a7==t5==15 , chama a syscall_get_position
    1:
    bne a7, t6, 1f                      # Se a7 != t6 ==16 , salta para 1f
    jal syscall_get_rotation            # Se a7==t6==16 , chama a syscall_get_rotation
    1:
    bne a7, t0, 1f                      # Se a7 != t0 ==17 , salta para 1f
    jal syscall_read                    # Se a7==t0==17 , chama a syscall_read
    1:

    li t0, 18
    li t1, 19
    li t2, 20

    bne a7, t0, 1f                      # Se a7 != t0 ==18 , salta para 1f
    jal syscall_write                   # Se a7==t0==18 , chama a syscall_write
    1:
    bne a7, t1, 1f                      # Se a7 != t1 ==19 , salta para 1f
    jal syscall_draw_line               # Se a7==t1==19 , chama a syscall_draw_line
    1:
    bne a7, t2, 1f                      # Se a7 != t2 ==20 , salta para 1f
    jal syscall_get_systime             # Se a7==t2==20 , chama a syscall_get_systime
    1:
    csrr t0, mepc                       # carrega endereço de retorno (endereço da instrução que invocou a syscall)
    addi t0, t0, 4                      # soma 4 no endereço de retorno (para retornar após a ecall) 
    csrw mepc, t0                       # armazena endereço de retorno de volta no mepc
    
    2:
    # Recupera o contexto
    lw fp, 0(sp)
    lw ra, 4(sp)
    lw t0, 8(sp) 
    lw t1, 12(sp) 
    lw t2, 16(sp) 
    lw t3, 20(sp)
    lw t4, 24(sp) 
    lw t5, 28(sp) 
    lw t6, 32(sp)  
    addi sp, sp, 48 # Desaloca espaço da pilha da ISR
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente

mret           # Recuperar o restante do contexto (pc <- mepc)

###### Chamadas de sistema: ######

# int syscall_set_motor(int desloc, int angle):
# - Código 10
# - Deve acionar os motores (para frente se a0=1 e para trás se a0=-1) e girar o volante no valor dado
# - Retorna 0 em caso de sucesso e -1 em caso de falha (parâmetros inválidos)
syscall_set_motor:
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
    li t0, 1
    bne a0, t0, 1f
    li t0, CAR_BREAK
    sb a0, 0(t0)
    1:
ret

# void syscall_read_sensors(char* buffer[256]):
# - Código 12
# - Deve ler os valores do sensor de luminosidade
syscall_read_sensors:
    # Ativando a leitura do sensor de luminosidade
    li t0, CAR_LINE_CAMERA_TRIGGER  # Carrega o inteiro que identifica a posição de memória do ativador da camera de linha
    li t1, 1                        # t1=1 : carrega 1 em t1
    sb t1, 0(t0)                    # MEM[t0]<=t1 == MEM[t0]<=1 : armazena 1 na posição de memória do ativador (provocando a atualização da câmera de linha)
    
    1:# While MEM[t0]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
    # Leitura da câmera de linha disponível
    mv t6, a0
    li t0, 256 # t0=256 (Comparador do loop)
    li t1, 0   # t1=0 (Indexador do loop (i))
    li t2, CAR_LINE_CAMERA_READING # Carrega em t2 o inteiro que identifica a posição de memória do começo do array gerado na leitura
    1:# While t1 < t0: 
        beq t1, t0, 1f      # Sai do loop se t1>=t0 , isto é, o loop se mantém enquanto t1 varia de 0 a 255
        lbu t3, 0(t2)       # t3<=MEM[t2] == t3<=MEM[t2+i] : Lê o elemento (um unsigned byte) da iteração no array da câmera  
        sb t3, 0(a0)         # MEM[a0]<=t3 == MEM[a0+i]<=t3 : Escreve o elemento lido na posição de memória da iteração
        addi t2, t2, 1      # t2+=1 : Desloca a posição de leitura no array da câmera de linha
        addi a0, a0, 1      # a0+=1 : Desloca a posição de escrita no buffer passado
        addi t1, t1 ,1      # t1+=1 == i+=1 : Incrementa o indexador
        j 1b
    1:
    mv a0, t6
ret

# int syscall_read_sensor_disance():
# - Código 13
# - Deve ler os valores do sensor de luminosidade
# - Retorna o valor obtido na leitura do sensor
/*    PORÉM HÁ TRÊS SENSORES. ESSA LEITURA DEVE SER FEITA SÓ PARA O FRONTAL? VOU IMPLEMENTAR IMAGINANDO QUE A LEITURA É DO FRONTAL     */
syscall_read_sensor_distance:
    # Ativando a leitura do sensor ultrasônico
    li t0, CAR_USS_TRIGGER          # Carrega o inteiro que identifica a posição de memória do ativador dO sensor ultrasônico
    li t1, 2                        # t1=2 : carrega 2 em t1
    sb t1, 0(t0)                    # MEM[t0]<=t1 == MEM[t0]<=2 : armazena 2 na posição de memória do ativador (provocando a atualização do sensor do meio)
    
    1:# While MEM[t0]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
    # Leitura do sensor disponível
    li t0, CAR_USS_READING          # Carrega o inteiro que identifica a posição de memória da leitura dO sensor ultrasônico
    lw t1, 0(t0)                    # t1<=MEM[t0] == t1<=MEM[CAR_USS_READING] : Coloca em t1 a leitura do sensor
    li t2, -100                     
    beq t1, t2, 1f                  # Salta para 1f se t1==t2==-100
    li t2, -1 
    beq t1, t2, 1f                  # Salta para 1f se t1==t2==-1
    mv a0, t1                       # Se t1!= -1 e t1!= -100, então copia t1 para a0, pois a leitura encontrou um objeto próximo
    j 2f
    1:
    li a0, -1                       # Se t1==-1 ou t1==-100, a leitura não encontrou objetos, portanto o retorno é -1
    2:
ret

# void syscall_get_position(int* x, int* y, int* z):
# - Código 15
# - Lê a posição aproximada do carro usando o dispositivo de GPS
syscall_get_position:
    # Fazendo a leitura do GPS
    li t0, CAR_GPS_TRIGGER    # Carrega o inteiro que identifica a posição de memória do ativador do gps
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

# void syscall_get_rotation(int* x, int* y, int* z):
# - Código 16
# - Lê a rotação global do giroscópio
syscall_get_rotation:
    # Fazendo a leitura do giroscópio
    li t0, CAR_GPS_TRIGGER    # Carrega o inteiro que identifica a posição de memória do ativador do gps
    li t1, 1                    # t1=1 : carrega 1 em t1
    sb t1, 0(t0)                # MEM[t0]<=t1 == MEM[t0]<=1 : armazena 1 na posição de memória do ativador (provocando a atualização do GPS e do giroscópio)
    
    1:# While MEM[t0]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
    # Leitura do GPS concluída

    # Atualizando das variáveis
    li t1, CAR_GPS_EANGLE_X     # Carrega em t1 o endereço do registrador externo que guarda o valor do ângulo de Euler em X do carro
    li t2, CAR_GPS_EANGLE_Y     # Carrega em t2 o endereço do registrador externo que guarda o valor do ângulo de Euler em Y do carro
    li t3, CAR_GPS_EANGLE_Z     # Carrega em t3 o endereço do registrador externo que guarda o valor do ângulo de Euler em Z do carro
    lw t1, 0(t1)                # t1<=MEM[CAR_GPS_X] : Carrega em t1 o valor do registrador externo que guarda o valor do ângulo de Euler em X do carro
    lw t2, 0(t2)                # t2<=MEM[CAR_GPS_Y] : Carrega em t2 o valor do registrador externo que guarda o valor do ângulo de Euler em Y do carro
    lw t3, 0(t3)                # t3<=MEM[CAR_GPS_Z] : Carrega em t3 o valor do registrador externo que guarda o valor do ângulo de Euler em Z do carro
    sw t1, 0(a0)                # MEM[a0]<=t1 : Salva em a0 (endereço da variável x) o valor de t1
    sw t2, 0(a1)                # MEM[a1]<=t2 : Salva em a1 (endereço da variável y) o valor de t2
    sw t3, 0(a2)                # MEM[a2]<=t3 : Salva em a2 (endereço da variável z) o valor de t3

ret

# int syscall_read(int fd, char* buffer, int size):
# - Código 17
# - Lê size bytes de stdin e guarda eles no buffer passado como parâmetro
# - Retorna a quantidade de bytes lidos
syscall_read:
    beq a0, zero, 1f            # Devemos considerar apenas o caso em que fd=0. Caso contrário, a função retornará
    li a0, 0
    ret
    1:

    li t0, 0                    # t0=0 : Variável indexadora (i)
    li t1, 1                    # t1=1 : Ativador da leitura    
    li t2, SIO_READ_TRIGGER     # Carrega o inteiro que identifica a posição de memória do ativador de leitura de stdin
    li t3, SIO_READ_BUFFER      # Carrega o inteiro que identifica a posição de memória do resultado da leitura de stdin
    mv t6, a1
    1: #While t0<a2 == i<size:
        bge t0, a2, 1f          # Sai do loop se t0>=a2
        sb t1, 0(t2)             # MEM[t2]<=t1 == MEM[SIO_READ_TRIGGER]<=1 : Ativa a leitura de stdin

        2:# While MEM[t2]!=0:
            lb t4, 0(t2)
            beq t4, zero, 2f
            j 2b
        2:
        # Leitura de stdin pronta
        
        lbu t4, 0(t3)           # t4<=MEM[t3] == t4<=MEM[SIO_READ_BUFFER] : Carrega em t4 o caracter lido de stdin
        beq t4, zero, 1f        # Quebra o laço se t4 == 0 == NULL, pois isso indica que stdin está vazia
        sb t4, 0(a1)            # MEM[a1]<=t4 == MEM[a1]<=MEM[SIO_READ_BUFFER] : Salva no buffer o caracter lido de stdin
        addi a1, a1, 1          # a1+=1 : Desloca para o próximo elemento do buffer
        addi t0, t0, 1          # t0+=1 : Incrementa o indexador
        j 1b                    # Volta
    1:
    mv a1, t6
    mv a0, t0                   # a0=t0 : Coloca em a0 a quantidade de bytes lidos

ret

# int syscall_write(int fd, char* buffer, int size):
# - Código 18
# - Escreve size bytes do buffer passado como parâmetro em stdout
syscall_write:
    li t0, 1
    beq a0, t0, 1f              # Devemos considerar apenas o caso em que fd=1. Caso contrário, a função retornará
    ret
    1:

    li t0, 0                    # t0=0 : Variável indexadora (i)
    li t1, 1                    # t1=1 : Ativador da escrita
    li t2, SIO_WRITE_TRIGGER    # Carrega o inteiro que identifica a posição de memória do ativador de escrita de stdout
    li t3, SIO_WRITE_BUFFER     # Carrega o inteiro que identifica a posição de memória do buffer de escrita de stdout
    mv t6, a1
    1: #While t0<a2 == i<size:
        bge t0, a2, 1f          # Sai do loop se t0>=a2
        
        lbu t4, 0(a1)           # t4<=MEM[a1] : Carrega em t4 o caracter a ser escrito em stdout
        sb t4, 0(t3)            # MEM[t3]<=t4 == MEM[SIO_WRITE_BUFFER]<=MEM[a1] : Salva no buffer o caracter a ser escrito em stdout
        sb t1, 0(t2)            # MEM[t2]<=t1 == MEM[SIO_WRITE_TRIGGER]<=1 : Ativa a escrita em stdout

        2:# While MEM[t2]!=0:
            lb t4, 0(t2)
            beq t4, zero, 2f
            j 2b
        2:
        # Escrita em stdou terminada
        
        addi a1, a1, 1          # a1+=1 : Desloca para o próximo elemento do buffer
        addi t0, t0, 1          # t0+=1 : Incrementa o indexador
        j 1b                    # Volta
    1:
    mv a1, t6
ret

# void syscall_draw_line(char* buffer):
# - Código 19
# - Desenha a câmera de linha no canvas (o buffer dado apresenta o valor dos bytes a serem convertidos em palavras RGBA e impressas) 
# - Preciso escrever primeiro R, depois B, depois G, e então A na memória. Portanto, se eu usar um registrador para compor o pixel
# e então salvar seu valor na memória, devo colocar no registrador AGBR
syscall_draw_line:
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw ra, 0(sp)        
    sw fp, 4(sp)
    sw a0, 8(sp)        # Salva a0 para restaurar no fim da syscall
    add fp,sp, 16
    #

    li t0, 504
    li t1, CANVAS_ARRAY_SIZE
    sh t0, 0(t1)
    li t2, CANVAS_INITIAL_POSITION
    sw zero, 0(t2)
    li t0, CANVAS_PIXEL_ARRAY # Carrega em t0 o inteiro que identifica a posição de memória do array de pixel do canvas
    li t1, 0 # t1=0 : Variável indexadora (i)
    li t2, 256 # t2=256 : Variável comparadora 
    1:# While t1<t2 == i<256: 
        bge t1, t2, 1f      # Se t1>=t2 == t1>=256, sai do laço
        li t6, 255          # t6=255 : Valor de alpha
        slli t6, t6, 24     # t6 = t6<<24 : Desloca t6 24 casas para a esquerda (salvando assim nos índices 24 a 31 do registrador)       

        lbu t3, 0(a0)       # t3<=MEM[a0] : Carrega em t3 o byte que representa o pixel. Esse byte representa o vlaro de R=G=B do pixel
        slli t4, t3, 8      # t4=t3<<8 : Desloca t3 em 8 casas para a esquerda (para ocupar os índices 8 a 15 do registrador ,i.e, definir B)
        slli t5, t3, 16     # t5=t3<<16 : Desloca t3 em 16 casas para a esquerda (para ocupar os índices 16 a 23 do registrador, i.e, definir G)

        add t4, t4, t3      # t4+=t3
        add t6, t6, t5      # t6+=t5
        add t6, t6, t4      # t6+=t4 == t6=t6+t5+t4+t3 : Preenche t6 com os valores de cada parte do pixel

        sw t6, 0(t0)         # MEM[t0]<=t6 : Salva o valor do pixel na memória
        addi t0, t0, 4      # t0+=4 : Desloca a posição de memória para o próximo pixel do canvas
        addi a0, a0, 1      # a0++ : Desloca para o próximo elemento do buffer
        addi t1, t1, 1      # t1+=1 == i++ : Incrementa o índice
        j 1b
    1:
    # Preenchimento do buffer concluído
    li t1, 1
    li t0, CANVAS_WRITE_TRIGGER  # Carrega em t0 o inteiro que identifica a posição de memória que guarda o ativador do canvas
    sb t1, 0(t0)    # MEM[t0]<=t1 == MEM[CANVAS_WRITE_TRIGGER]<=1 : Ativa a escrita no canvas
    
    1:# While MEM[t0]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
    # Escrita concluída

    # Desalocando quadro de pilha:
    lw ra, 0(sp)
    lw fp, 4(sp)
    lw a0, 8(sp)
    addi sp, sp, 16
    #
ret

# int syscall_get_systime():
# - Código 20
# - Retorna o tempo do sistema desde que foi ligado em segundos
syscall_get_systime:
    li t0, GPT_TRIGGER              # Coloca o endereço do registrador de intervalo de interrupção do GPT em t0
    li t1, 1                        # t1=1
    sw t1,(t0)                      # [GPT_TRIGGER]<=t1 : Ativa a contagem do gpt
    1:# While MEM[GPT_TRIGGER]!=0:
        lb t1, 0(t0)
        beq t1, zero, 1f
        j 1b
    1:
    li a0, GPT_TIME_READ 
    lw a0, 0(a0)
ret
