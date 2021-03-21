/* ���荞�݊֌W */

#include "bootpack.h"
#include <stdio.h>

// PIC�I�񑶊퐥8��
// IMR(interrupt mask register)���f�����񑶊�C�^�꘢�u?1�C?��IRQ�M������
// ICW(initial control word)���n���T�������CICW�L�l���CICW1�aICW4�^PIC��z?�����C���f�M��?��������?�C?�u?�Œ�?
// ICW3�L?�嘸?��?��C��O����IRQ2?�ژ�PIC
// ICW2�r��IRQ��?�ꍆ���f�ʒmCPU
// INT 0x00~0x0f�p�ȕۏ�?�p����?����n?�������C���ڐG??���f
// IRQ1��??�CIRQ12���l?
void init_pic(void)
/* PIC�I���n�� */
{
	io_out8(PIC0_IMR,  0xff  ); /* �֎~���L���f */
	io_out8(PIC1_IMR,  0xff  ); /* �֎~���L���f */

	io_out8(PIC0_ICW1, 0x11  ); /* ?���G?�͎� */
	io_out8(PIC0_ICW2, 0x20  ); /* IRQ0-7�RINT20-27�ڝ� */
	io_out8(PIC0_ICW3, 1 << 2); /* PIC0�^IRQ2?��?�� */
	io_out8(PIC0_ICW4, 0x01  ); /* ��?�t�͎� */

	io_out8(PIC1_ICW1, 0x11  ); /* ?���G?�͎� */
	io_out8(PIC1_ICW2, 0x28  ); /* IRQ8-15�RINT28-2f�ڝ� */
	io_out8(PIC1_ICW3, 2     ); /* PIC1�^IRQ2?��?�� */
	io_out8(PIC1_ICW4, 0x01  ); /* ��?��?�t�͎� */

	io_out8(PIC0_IMR,  0xfb  ); /* 11111011 PIC1�ȊO�S���֎~ */
	io_out8(PIC1_IMR,  0xff  ); /* 11111111 �֎~���L���f */

	return;
}

void inthandler27(int *esp)
/* PIC0����̕s���S���荞�ݑ΍� */
/* Athlon64X2�@�Ȃǂł̓`�b�v�Z�b�g�̓s���ɂ��PIC�̏��������ɂ��̊��荞�݂�1�x���������� */
/* ���̊��荞�ݏ����֐��́A���̊��荞�݂ɑ΂��ĉ������Ȃ��ł��߂��� */
/* �Ȃ��������Ȃ��Ă����́H
	��  ���̊��荞�݂�PIC���������̓d�C�I�ȃm�C�Y�ɂ���Ĕ����������̂Ȃ̂ŁA
		�܂��߂ɉ����������Ă��K�v���Ȃ��B									*/
{
	io_out8(PIC0_OCW2, 0x67); /* IRQ-07��t������PIC�ɒʒm */
	return;
}
