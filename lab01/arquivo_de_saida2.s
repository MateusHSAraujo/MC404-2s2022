	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0_d2p0"
	.file	"arquivo2.c"
	.globl	write
	.p2align	2
	.type	write,@function
write:
.Lfunc_begin0:
	.file	1 "/home/mateus/lab1" "arquivo2.c"
	.loc	1 1 0
	.cfi_sections .debug_frame
	.cfi_startproc
	addi	sp, sp, -32
	.cfi_def_cfa_offset 32
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	.cfi_offset ra, -4
	.cfi_offset s0, -8
	addi	s0, sp, 32
	.cfi_def_cfa s0, 0
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
.Ltmp0:
	.loc	1 9 6 prologue_end
	lw	a3, -12(s0)
	.loc	1 9 17 is_stmt 0
	lw	a4, -16(s0)
	.loc	1 9 29
	lw	a5, -20(s0)
	.loc	1 2 1 is_stmt 1
	#APP
	mv	a0, a3	# file descriptor
	mv	a1, a4	# buffer 
	mv	a2, a5	# size 
	addi	a7, zero, 64	# syscall write (64) 
	ecall	

	#NO_APP
	.loc	1 12 1
	lw	s0, 24(sp)
	lw	ra, 28(sp)
	addi	sp, sp, 32
	ret
.Ltmp1:
.Lfunc_end0:
	.size	write, .Lfunc_end0-write
	.cfi_endproc

	.section	.debug_abbrev,"",@progbits
	.byte	1
	.byte	17
	.byte	1
	.byte	37
	.byte	14
	.byte	19
	.byte	5
	.byte	3
	.byte	14
	.byte	16
	.byte	23
	.byte	27
	.byte	14
	.byte	17
	.byte	1
	.byte	18
	.byte	6
	.byte	0
	.byte	0
	.byte	2
	.byte	46
	.byte	1
	.byte	17
	.byte	1
	.byte	18
	.byte	6
	.byte	64
	.byte	24
	.byte	3
	.byte	14
	.byte	58
	.byte	11
	.byte	59
	.byte	11
	.byte	39
	.byte	25
	.byte	63
	.byte	25
	.byte	0
	.byte	0
	.byte	3
	.byte	5
	.byte	0
	.byte	2
	.byte	24
	.byte	3
	.byte	14
	.byte	58
	.byte	11
	.byte	59
	.byte	11
	.byte	73
	.byte	19
	.byte	0
	.byte	0
	.byte	4
	.byte	36
	.byte	0
	.byte	3
	.byte	14
	.byte	62
	.byte	11
	.byte	11
	.byte	11
	.byte	0
	.byte	0
	.byte	5
	.byte	15
	.byte	0
	.byte	73
	.byte	19
	.byte	0
	.byte	0
	.byte	6
	.byte	38
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.word	.Ldebug_info_end0-.Ldebug_info_start0
.Ldebug_info_start0:
	.half	4
	.word	.debug_abbrev
	.byte	4
	.byte	1
	.word	.Linfo_string0
	.half	12
	.word	.Linfo_string1
	.word	.Lline_table_start0
	.word	.Linfo_string2
	.word	.Lfunc_begin0
	.word	.Lfunc_end0-.Lfunc_begin0
	.byte	2
	.word	.Lfunc_begin0
	.word	.Lfunc_end0-.Lfunc_begin0
	.byte	1
	.byte	88
	.word	.Linfo_string3
	.byte	1
	.byte	1


	.byte	3
	.byte	2
	.byte	145
	.byte	116
	.word	.Linfo_string4
	.byte	1
	.byte	1
	.word	98
	.byte	3
	.byte	2
	.byte	145
	.byte	112
	.word	.Linfo_string6
	.byte	1
	.byte	1
	.word	105
	.byte	3
	.byte	2
	.byte	145
	.byte	108
	.word	.Linfo_string7
	.byte	1
	.byte	1
	.word	98
	.byte	0
	.byte	4
	.word	.Linfo_string5
	.byte	5
	.byte	4
	.byte	5
	.word	110
	.byte	6
	.byte	0
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"Ubuntu clang version 12.0.0-3ubuntu1~20.04.5"
.Linfo_string1:
	.asciz	"arquivo2.c"
.Linfo_string2:
	.asciz	"/home/mateus/lab1"
.Linfo_string3:
	.asciz	"write"
.Linfo_string4:
	.asciz	"__fd"
.Linfo_string5:
	.asciz	"int"
.Linfo_string6:
	.asciz	"__buf"
.Linfo_string7:
	.asciz	"__n"
	.ident	"Ubuntu clang version 12.0.0-3ubuntu1~20.04.5"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.section	.debug_line,"",@progbits
.Lline_table_start0:
