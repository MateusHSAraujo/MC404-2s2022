	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0_d2p0"
	.file	"arquivo1.c"
	.globl	main
	.p2align	2
	.type	main,@function
main:
.Lfunc_begin0:
	.file	1 "/home/mateus/lab1" "arquivo1.c"
	.loc	1 2 0
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
	mv	a0, zero
	sw	a0, -32(s0)
	sw	a0, -12(s0)
	addi	a0, zero, 10
.Ltmp0:
	.loc	1 3 12 prologue_end
	sh	a0, -16(s0)
	lui	a0, 136775
	addi	a0, a0, -910
	sw	a0, -20(s0)
	lui	a0, 456050
	addi	a0, a0, 111
	sw	a0, -24(s0)
	lui	a0, 444102
	addi	a0, a0, 1352
	sw	a0, -28(s0)
	addi	a0, zero, 1
	addi	a1, s0, -28
	addi	a2, zero, 13
	.loc	1 4 1
	call	write
	lw	a0, -32(s0)
	.loc	1 5 1
	lw	s0, 24(sp)
	lw	ra, 28(sp)
	addi	sp, sp, 32
	ret
.Ltmp1:
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc

	.globl	_start
	.p2align	2
	.type	_start,@function
_start:
.Lfunc_begin1:
	.loc	1 7 0
	.cfi_startproc
	addi	sp, sp, -16
	.cfi_def_cfa_offset 16
.Ltmp2:
	.loc	1 8 1 prologue_end
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	.cfi_offset ra, -4
	.cfi_offset s0, -8
	addi	s0, sp, 16
	.cfi_def_cfa s0, 0
	call	main
	.loc	1 9 1
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Ltmp3:
.Lfunc_end1:
	.size	_start, .Lfunc_end1-_start
	.cfi_endproc

	.type	.L__const.main.str,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__const.main.str:
	.asciz	"Hello World!\n"
	.size	.L__const.main.str, 14

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
	.byte	73
	.byte	19
	.byte	63
	.byte	25
	.byte	0
	.byte	0
	.byte	3
	.byte	52
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
	.byte	46
	.byte	0
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
	.byte	63
	.byte	25
	.byte	0
	.byte	0
	.byte	5
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
	.byte	6
	.byte	1
	.byte	1
	.byte	73
	.byte	19
	.byte	0
	.byte	0
	.byte	7
	.byte	33
	.byte	0
	.byte	73
	.byte	19
	.byte	55
	.byte	11
	.byte	0
	.byte	0
	.byte	8
	.byte	38
	.byte	0
	.byte	73
	.byte	19
	.byte	0
	.byte	0
	.byte	9
	.byte	36
	.byte	0
	.byte	3
	.byte	14
	.byte	11
	.byte	11
	.byte	62
	.byte	11
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
	.word	.Lfunc_end1-.Lfunc_begin0
	.byte	2
	.word	.Lfunc_begin0
	.word	.Lfunc_end0-.Lfunc_begin0
	.byte	1
	.byte	88
	.word	.Linfo_string3
	.byte	1
	.byte	2

	.word	91

	.byte	3
	.byte	2
	.byte	145
	.byte	100
	.word	.Linfo_string6
	.byte	1
	.byte	3
	.word	98
	.byte	0
	.byte	4
	.word	.Lfunc_begin1
	.word	.Lfunc_end1-.Lfunc_begin1
	.byte	1
	.byte	88
	.word	.Linfo_string5
	.byte	1
	.byte	7

	.byte	5
	.word	.Linfo_string4
	.byte	5
	.byte	4
	.byte	6
	.word	110
	.byte	7
	.word	122
	.byte	14
	.byte	0
	.byte	8
	.word	115
	.byte	5
	.word	.Linfo_string7
	.byte	8
	.byte	1
	.byte	9
	.word	.Linfo_string8
	.byte	8
	.byte	7
	.byte	0
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"Ubuntu clang version 12.0.0-3ubuntu1~20.04.5"
.Linfo_string1:
	.asciz	"arquivo1.c"
.Linfo_string2:
	.asciz	"/home/mateus/lab1"
.Linfo_string3:
	.asciz	"main"
.Linfo_string4:
	.asciz	"int"
.Linfo_string5:
	.asciz	"_start"
.Linfo_string6:
	.asciz	"str"
.Linfo_string7:
	.asciz	"char"
.Linfo_string8:
	.asciz	"__ARRAY_SIZE_TYPE__"
	.ident	"Ubuntu clang version 12.0.0-3ubuntu1~20.04.5"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym main
	.addrsig_sym write
	.section	.debug_line,"",@progbits
.Lline_table_start0:
