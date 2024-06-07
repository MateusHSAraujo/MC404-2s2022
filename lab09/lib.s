.bss
_system_time: .word 0

.align 4
isr_stack:      # Final da pilha das ISRs
.skip 1024      # Aloca 1024 bytes para a pilha
isr_stack_end:  # Base da pilha das ISRs

.align 4
program_stack:  # Final da pilha do programa
.skip 1024      # Aloca 1024 bytes para a pilha do programa
program_stack_end: # Base da pilha do programa


.text
.set GPT_ACTIVATOR, 0xffff0100          # Word
.set GPT_TIME_READ, 0xffff0104          # Word
.set GPT_INTERRUPTION_SET, 0xffff0108   # Word
.set MIDI_CH, 0xffff0300                # Byte
.set MIDI_INST, 0xffff0302              # Short
.set MIDI_NOTE, 0xffff0304              # Byte
.set MIDI_VEL,  0xffff0305              # Byte
.set MIDI_DUR, 0xffff0306               # Short
.align 2


_start:
    # 1°) Registrar a ISR (em direct mode, nesse caso):
    la t0, main_isr                # Carrega em t0 o endereço da rotina principal de ISR (direct mode)
    csrw mtvec, t0                 # Escreve no registrador mtvec a rotina de tratamento de exceções
    
    # 2°) Configurar a pilha especial das ISR:
    la t0, isr_stack_end           # Carrega em t0 o início da pilha especial das ISR
    csrw mscratch, t0              # Coloca esse endereço em mscratch

    # 3°) Configurar a pilha do programa:
    la sp, program_stack_end       # Carrega o endereço da pilha do programa em sp

    # 4°) Configurar os dispositivos antes de habilitar as interrupções:
    li t0, GPT_INTERRUPTION_SET     # Coloca o endereço do registrador de intervalo de interrupção do GPT em t0
    li t1, 100                      # t1=100
    sw t1,(t0)                      # [GPT_INTERRUPTION_SET]<=t1

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

jal main


main_isr:
    # Salvar o contexto
    csrrw sp, mscratch, sp # Troca sp com mscratch
    addi sp, sp, -16 # Aloca espaço na pilha da ISR
    sw fp, 0(sp) 
    sw ra, 4(sp) 
    addi fp,sp, 16

    # Trata a interrupção
    jal gpt_isr

    # Recupera o contexto
    lw fp, 0(sp)
    lw ra, 4(sp) 
    addi sp, sp, 16 # Desaloca espaço da pilha da ISR
    csrrw sp, mscratch, sp # Troca sp com mscratch novamente
mret # Retorna da interrupção


# ISR do GPT
gpt_isr:
    # Alocando quadro de pilha:
    addi sp, sp, -16
    sw fp, 0(sp)
    sw ra, 4(sp)
    sw t0, 8(sp)
    sw t1, 12(sp)     
    add fp,sp, 16
    #

    la t0, _system_time             # Coloca o endereço da variável global _system_time em t0
    lw t1, 0(t0)                    # t1<=[_system_time]
    addi t1, t1, 100                # t1+=100
    sw t1, 0(t0)                    # [_system_time]<=t1

    li t0, GPT_INTERRUPTION_SET     # Coloca o endereço do registrador de intervalo de interrupção do GPT em t0
    li t1, 100                      # t1=100
    sw t1,(t0)                      # [GPT_INTERRUPTION_SET]<=t1
    

    # Desalocando quadro de pilha:
    lw fp, 0(sp)        
    lw ra, 4(sp)
    lw t0, 8(sp)
    lw t1, 12(sp)        
    addi sp, sp, 16
    #
ret



# void paly_note(int ch, int inst, int note, int vel, int dur): a0=ch,a1=inst,a2=note,a3=vel,a4=dur
play_note:
    li t0, MIDI_CH             
    li t1, MIDI_INST
    li t2, MIDI_NOTE
    li t3, MIDI_VEL
    li t4, MIDI_DUR
    sh a1, 0(t1)            # [MIDI_INST]<=a1
    sb a2, 0(t2)            # [MIDI_NOTE]<=a2
    sb a3, 0(t3)            # [MIDI_VEL]<=a3
    sh a4, 0(t4)            # [MIDI_DUR]<=a4
    sb a0, 0(t0)            # [MIDI_CH]<=a0 (feito por último pois dará início a reprodução)
ret

.globl _start
.globl play_note
.globl _system_time