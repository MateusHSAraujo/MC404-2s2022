.data
input_file: .asciz "imagem.pgm"


.bss
input_adress: .skip 262159  # buffer que conterá a imagem
width: .skip 4  # largura / número de colunas
height: .skip 4 # altura / número de linhas
image_array_start_index: .skip 4 # posição do array no qual se inicia a matriz da imagem

.text
setCanvasSize:
    la a0, width
    lw a0, 0(a0)
    la a1, height
    lw a1, 0(a1)
    li a7, 2201
    ecall
ret    


open:
    la a0, input_file    # endereço do caminho para o arquivo
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # modo
    li a7, 1024          # syscall open 
    ecall
ret

read: # Argumentos: a0 = file_descriptor , a1=endereço do buffer no qual a string será posicionada ,a2 = quantidade de bits a serem lidos
    #Mantém o a0 da chamada de read 
    #Mantém o a1 da chamada de read 
    #Mantém o a2 da chamada de read
    li a7, 63               #syscall read (63)
    ecall
ret

contaDigitos:
    la t0, input_adress
    addi t0, t0, 3
    li a1, 0 # a1 será o acumulador para width
    li a2, 0 # a2 será o acumulador para height

    1: # While t1 != ' ':
        lb t1, 0(t0)        # t1 recebe o byte da string que fica no endereço t0
        li t2, 32           # comparador
        addi t0, t0, 1
        beq t1, t2, 1f   # Se t1=t2=' ' para a contagem
        addi a1, a1, 1
        j 1b
    1:

    1: # While t1 != '\n':
        lb t1, 0(t0)        # t1 recebe o byte da string que fica no endereço t0
        li t2, 10           # comparador
        beq t1, t2, 1f      # Se t1=t2='\n' para a contagem
        addi t0, t0, 1
        addi a2, a2, 1
        j 1b
    1:

    # Gravando o endereço do início do array da imagem em uma variável pra poder usá-la depois
    addi t0, t0 ,5
    la t1, image_array_start_index
    sw t0, 0(t1)

ret

defineWH: # Argumentos: a1 = número de dígitos de width , a2 = número de dígitos de height

    la t0, input_adress
    addi t0, t0, 3 #t0 agora é o endereço do primeiro caracter de width
    addi a1, a1, -1
    li t5, 0    #acumulador
        
    1: # While a1 != 0 :
        lb t1, 0(t0)
        li t2, 1
        mv t4 , a1
        
        2: # While t4 !=0 :
            beq t4, zero, 2f    #Sai do while interno se t4 == 0
            li t3 , 10
            mul t2, t2, t3      #t2*=10
            addi t4, t4, -1
            j 2b
        2:
        
        addi t1, t1, -48        #t1-=48
        mul t1, t1, t2          #t1*=t2
        add t5, t1, t5          #t5+=t1
        addi t0, t0, 1
        beq a1, zero, 1f # Sai do while externo se a1 == 0
        addi a1, a1, -1
        j 1b
    1:

    la t1,width
    sw t5, 0(t1)
    addi t0, t0, 1
    addi a2, a2, -1
    li t5, 0

    1: # While a2 != 0:
        lb t1, 0(t0)
        li t2, 1
        mv t4 , a2
        
        2: # While t4 != 0:
            beq t4, zero, 2f # Sai do while se t4 == 0
            li t3 , 10
            mul t2, t2, t3
            addi t4, t4, -1
            j 2b
        2:
        
        addi t1, t1, -48
        mul t1, t1, t2
        add t5, t1, t5
        beq a2, zero, 1f # Sai do while externo se a2 == 0
        addi a2, a2, -1
        addi t0, t0, 1
        j 1b
    1:

    la t1, height
    sw t5, 0(t1)

ret

# getPixel deve encontrar o pixel na matriz, converter seu valor para o inteiro correspondente e definir sua cor
getPixel: # Argumentos: a0 = coluna do pixel (i==x) , a1 = linha do pixel (j==y) , a2 = endereço de início da imagem no array
# Lembrar que, a cada linha, há um caracter de quebra de linha. Portanto, a cada linha temos um offset mais um byte no array da imagem.
    la t0, width                    # Carrega, em t0, o endereço do inteiro que identifica a largura
    lw t0, 0(t0)                    # Carrega, em t0, o inteiro que identifica a largura / número de linhas : t0=jmax
    mul t0, t0, a0                  # t0*=a0 : t0 = i*(jmax)
    add t0, t0, a1                  # t0+=a1 : t0 = i*(jmax) + j
    add t0, t0, a2                  # t0+=a2 : t0 = start_img_i + i*(jmax) + j : t0 = Endereço na memória do pixel no array da imagem

    lbu t0, 0(t0)                   # Carrega o byte que representa o pixel de endereço desejado em t0 (unsigned pois o valor vai de 0 a 255)

    li a2, 255                      # Definindo alpha do pixel (sempre igual a 255 == 11111111) 
    slli t1, t0, 8                  # Desloca o valor do pixel em 8 casas, pois red fica entre os índices 8 e 15
    add a2, a2, t1                  # Definindo blue do pixel
    slli t1, t0, 16                 # Desloca o valor do pixel em 16 casas, pois green fica entre os índices 23 e 16   
    add a2, a2, t1                  # Definindo green do pixel
    slli t1, t0, 24                 # Desloca o valor do pixel em 24 casas, pois red fica entre os índices 31 e 24
    add a2, a2, t1                  # Definindo red do pixel

jalr zero, s11, 0

setPixel: # Argumentos: a0 = coordenada x do pixel , a1=coordenada y do pixel ,a2 = cor do pixel
    #Mantém o a0 da chamada de setPixel 
    #Mantém o a1 da chamada de setPixel
    #Mantém o a2 da chamada de setPixel
    li a7, 2200 # syscall setGSPixel (2200)
    ecall
jalr zero, s11, 0

generateImage:
    la s0, image_array_start_index  # Carrega, em s0, o endereço do inteiro que identifica o endereço da memória do início do array da imagem
    lw s0, 0(s0)                    # Carrega, em s0, o inteiro que identidica o início do array da imagem 
    
    la t0, height                   # Carrega, em t0, o endereço do inteiro que identifica a largura
    lw t2, 0(t0)                    # Carrega, em t2, o inteiro que identifica a largura / número de linhas

    la t0, width                    # Carrega, em t0, o endereço do inteiro que identifica a altura
    lw t3, 0(t0)                    # Carrega, em t3, o intieiro que identifica a altura/ número de colunas

    li t4, 0                        # Variável indexadora para linhas (i)
    
    1: # While i!= t2 , ou seja, i!= height-1 :
        bge t4, t2, 1f              # Quebra o while se t4 >= t2
        li t5, 0                    # Variável indexadora para colunas (j)

        2: # While j!= t5 , ou seja, j!= width-1 :
            bge t5, t3, 2f          # Quebra o while se t5 >= t3 == j < número de colunas

            mv a2, s0               # Argumento a2 = endereço de início da imagem no array
            mv a0, t5               # Argumento a0 = coluna do pixel (posição x)
            mv a1, t4               # Argumento a1 = linha do pixel (posição y)
            jal s11, getPixel       # Com os argumentos acima, a função getPixel deve ler o pixel na posição x e y fornecidas e retornar, em a2, sua cor concatenada
            jal s11, setPixel       # Com os argumentos acima (lembrando que a2 será mudado por setPixel), setPixel deve imprimir o pixel no canvas

            addi t5, t5, 1          # t5++ == j++
            j 2b                    # Volta pro começo do while interno
        2:

        addi t4, t4, 1              # t4++ == i++
        j 1b                        # Volta pro começo do while externo
    1:

ret


.globl _start
_start:
    call open           # Função open devolve o file descriptor do arquivo em a0
    li a2, 262159         
    la a1, input_adress
    call read           # Chamando read para ler toda a matriz e guardá-la no buffer input_adress
    call contaDigitos   # Chamando a função contaDigitos para contar quantos dígitos tem no número decimal de width e height, ela retorna em a1 o número de dígitos de width e em a2 o número de dígitos de height
    call defineWH       # Construindo os números que indicam a largura e a altura da matriz
    call setCanvasSize  # Acertando a altura e a largura do Canvas
    call generateImage  # Função que deve construir e imprimir a imagem no canvas



