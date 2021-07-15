; naskfunc
; TAB=4

; intel家族
; 8086->80186->286->386->486->Pentium->PentiumPro->PentiumII
; 286的CPUcpu地址总线还是16位  386开始CPU地址总线就是32位

[FORMAT "WCOFF"]
[INSTRSET "i486p"]				; 使用486的语言，避免EAX当成标签
[BITS 32]						; 位数是32位


[FILE "naskfunc.nas"]			; 

		GLOBAL	_io_hlt, _io_cli, _io_sti, _io_stihlt
		GLOBAL	_io_in8,  _io_in16,  _io_in32
		GLOBAL	_io_out8, _io_out16, _io_out32
		GLOBAL	_io_load_eflags, _io_store_eflags
		GLOBAL	_load_gdtr, _load_idtr
		GLOBAL	_load_cr0, _store_cr0
		GLOBAL  _load_tr
		GLOBAL	_asm_inthandler0c, _asm_inthandler0d, _asm_inthandler20, _asm_inthandler21, _asm_inthandler27, _asm_inthandler2c
		GLOBAL	_asm_end_app, _memtest_sub
		GLOBAL	_farjmp
		GLOBAL  _farcall
		GLOBAL	_asm_hrb_api, _start_app
		EXTERN	_inthandler0c, _inthandler0d, _inthandler20, _inthandler21, _inthandler27, _inthandler2c
		EXTERN  _hrb_api

[SECTION .text]

_io_hlt:	; void io_hlt(void); 暂停cpu
		HLT
		RET

_io_cli:	; void io_cli(void); 禁止中断
		CLI
		RET

_io_sti:	; void io_sti(void); 允许中断
		STI
		RET

_io_stihlt:	; void io_stihlt(void);
		STI
		HLT
		RET

_io_in8:	; int io_in8(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AL,DX
		RET

_io_in16:	; int io_in16(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AX,DX
		RET

_io_in32:	; int io_in32(int port);
		MOV		EDX,[ESP+4]		; port
		IN		EAX,DX
		RET

_io_out8:	; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		AL,[ESP+8]		; data
		OUT		DX,AL
		RET

_io_out16:	; void io_out16(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,AX
		RET

_io_out32:	; void io_out32(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,EAX
		RET

_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; wpush EFLAGS到EAX
		POP		EAX
		RET

_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; POP EFLAGS从EAX
		RET

_load_gdtr:		; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LGDT	[ESP+6]
		RET

_load_idtr:		; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET

_load_cr0:		; int load_cr0(void);
		MOV		EAX,CR0
		RET

_store_cr0:		; void store_cr0(int cr0);
		MOV		EAX,[ESP+4]
		MOV		CR0,EAX
		RET
		
; void load_tr(int tr)
; 改变TR(task register<任务寄存器:用来记录当前运行的任务>)的值，为任务切换做准备
_load_tr:
		LTR    [ESP+4]
		RET

_asm_inthandler0c:
		STI
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler0c
		CMP		EAX,0
		JNE		_asm_end_app
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		ADD		ESP,4			; INT 0x0c 需要
		IRETD

_asm_inthandler0d:
		STI
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler0d
		CMP		EAX,0
		JNE		_asm_end_app
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		ADD		ESP,4			; INT 0x0d 需要这句
		IRETD

; 处理中断时，可能发生在正在执行的函数中，所以需要将寄存器的值保存下来
_asm_inthandler20:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler20
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler21
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler27:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler27
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler2c
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD
		
_memtest_sub:	; unsigned int memtest_sub(unsigned int start, unsigned int end)
		PUSH	EDI						; （由于本程序会使用EBX,ESI,EDI会改变这里值，所以要先保存起来，程序执行完再恢复）
		PUSH	ESI
		PUSH	EBX
		MOV		ESI,0xaa55aa55			; pat0 = 0xaa55aa55;
		MOV		EDI,0x55aa55aa			; pat1 = 0x55aa55aa;
		MOV		EAX,[ESP+12+4]			; i = start;
		
; 每0x1000检查一次，检查0x1000最后四个字节
mts_loop:
		MOV		EBX,EAX
		ADD		EBX,0xffc				; p = i + 0xffc;
		MOV		EDX,[EBX]				; old = *p 先记住修改前的值
		MOV		[EBX],ESI				; *p = pat0; 试写
		XOR		DWORD [EBX],0xffffffff	; *p ^= 0xffffffff; 反转，异或达到取反的效果，pat0的二进制是10交差
		CMP		EDI,[EBX]				; if (*p != pat1) goto fin; 检查反转结果
		JNE		mts_fin
		XOR		DWORD [EBX],0xffffffff	; *p ^= 0xffffffff;  再次反转
		CMP		ESI,[EBX]				; if (*p != pat0) goto fin; 检查是否恢复
		JNE		mts_fin
		MOV		[EBX],EDX				; *p = old;  恢复修改之前的值
		ADD		EAX,0x1000				; i += 0x1000;
		CMP		EAX,[ESP+12+8]			; if (i <= end) goto mts_loop;
		JBE		mts_loop
		POP		EBX
		POP		ESI
		POP		EDI
		RET
mts_fin:
		MOV		[EBX],EDX				; *p = old;
		POP		EBX
		POP		ESI
		POP		EDI
		RET

; 使用far模式jmp来实现任务切换 段号*8:0, 跳转到地址是TSS，执行任务切换的操作
;_taskswitch4:	; void taskswitch4(void);  切换到任务4
;		JMP		4*8:0  
;		RET

; JMP FAR”指令的功能是执行far跳转。在JMP FAR指令中，可以指定一个内存地址，
; CPU会从指定的内存地址中读取4个字节的数据，
; 并将其存入EIP寄存器，再继续读取2个字节的数据，并将其存入CS寄存器
_farjmp:		; void farjmp(int eip, int cs);
		JMP		FAR	[ESP+4]				; eip, cs
		RET

; 不同段的函数调用, 形式同_farjmp
_farcall:       ; void farcall(int eip, int cs);
		CALL    FAR [ESP+4]             ; eip, cs
		RET

;_asm_cons_putchar:
;		STI                 ; INT调用时，对于CPU来说相当于执行了中断处理程序，
;		                    ; 因此在调用的同时CPU会自动执行CLI指令来禁止中断请求, 我们使用STI允许中断
;		PUSHAD
;		PUSH	1
;		AND		EAX,0xff	; 将AH和EAX的高位置0
;		PUSH	EAX         ; 将EAX置为已存入字符编码的状态
;		PUSH	DWORD [0x0fec]	; 读取内存并push该值
;		CALL	_cons_putchar
;		ADD		ESP,12		; 栈中数据丢弃
;		POPAD
;		IRETD               ; 使用INT调用时返回


_asm_hrb_api:
		STI
		PUSH	DS
		PUSH	ES
		PUSHAD		; 用于保存的PUSH
		PUSHAD		; 用于向hrb_api传值的push
		MOV		AX,SS
		MOV		DS,AX		; 将操作系统用段地址存入DS和ES
		MOV		ES,AX
		CALL	_hrb_api
		CMP		EAX,0		; _hrb_api的返回值EAX不为0时程序结束
		JNE		_asm_end_app
		ADD		ESP,32
		POPAD
		POP		ES
		POP		DS
		IRETD
_asm_end_app:
;	EAX为tss.esp0的地址
		MOV		ESP,[EAX]
		MOV     DWORD [EAX+4],0
		POPAD
		RET					; 返回cmd_app

_start_app:		; void start_app(int eip, int cs, int esp, int ds, int* tss_esp0);
		PUSHAD		; 将32位寄存器的值全部保存起来
		MOV		EAX,[ESP+36]	; 应用程序用EIP
		MOV		ECX,[ESP+40]	; 应用程序用CS
		MOV		EDX,[ESP+44]	; 应用程序用ESP
		MOV		EBX,[ESP+48]	; 应用程序用DS/SS
		MOV     EBP,[ESP+52]    ; tss.esp0的地址
		MOV		[EBP],ESP		; 操作系统用ESP
		MOV		[EBP+4],SS		; 操作系统用SS

		MOV		ES,BX
		MOV		DS,BX
		MOV		FS,BX
		MOV		GS,BX

; 调整栈，用RETF跳转到应用程序
		OR      ECX,3    ; 将应用程序用段号和3进行或运算(代码段)
		OR      EBX,3    ; 将应用程序用段号和3进行或运算(数据段)
		PUSH	EBX				; 应用程序SS
		PUSH	EDX				; 应用程序ESP
		PUSH	ECX				; 应用程序CS
		PUSH	EAX				; 应用程序EIP
		RETF

;	应用程序程序结束后不会返回此处