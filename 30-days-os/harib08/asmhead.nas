; leap-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; bootpackĿ�ĵ�
DSKCAC	EQU		0x00100000		; ���̻���λ��
DSKCAC0	EQU		0x00008000		; ���̻���λ�ã�ʵʱģʽ��


; �й�BOOT_INFO��ŵ�ַ
CYLS	EQU		0x0ff0			; �趨������
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; ������ɫ��Ŀ��Ϣ����ɫλ��
SCRNX	EQU		0x0ff4			; �ֱ���x
SCRNY	EQU		0x0ff6			; �ֱ���x
VRAM	EQU		0x0ff8			; ���ͼ�񻺳����Ŀ�ʼ��ַ


	ORG  0xc200
	
; �����趨
    MOV  AL,0x13  ; VGA�Կ���320*200*8λ��ɫ
	MOV  AH,0x00
	INT  0x10
	MOV  BYTE [VMODE],8  ; ��¼����ģʽ
	MOV  WORD [SCRNX], 320
	MOV  WORD [SCRNY], 200
	MOV  DWORD [VRAM], 0x000a0000
	
; ��BIOSȡ�ü����ϸ���LEDָʾ�Ƶ�״̬
    MOV  AH,0x02
	INT  0x16 			; keyboard BIOS
	MOV	 [LEDS],AL
	
; PIC�ر�һ���жϣ�cpuģʽת��ʱ��ֹ�ж�
;   ����AT���ݻ�������Ҫ��ʼ��PIC, ������CLI֮ǰ��������ʱ�����
;   ������PIC��ʼ��
; OUT 0x21,AL �� io_out(PIC0_IMR, 0xff)
; OUT 0xa1,AL �� io_out(PIC1_IMR, 0xff)
	MOV	 AL,0xff
	OUT	 0x21,AL
	NOP	 				; OUT����ʲôҲ������CPU��Ϣһ��ʱ������
	OUT	 0xa1,AL

	CLI					; ��ֹCPU������ж�
	
; Ϊ��CPU�ܹ�����1M�����ڴ�ռ䣬�趨A20GATE
; ����̿��Ƶ�·����ָ��
; ����ĵ�ָ����ָ����̿��Ƶ�·�����˿����0xdf
; ��������˿������������ط������Ͳ�ָͬ�ʵ�ֲ�ͬ�Ŀ��ƹ���
; 0xdf���A20GATE�źű��ON, ����ʹ�ڴ�1MB���ϱ�ɿ�ʹ��״̬
	CALL  waitkbdout     ; wait_KBC_sendready
	MOV	  AL,0xd1
	OUT	  0x64,AL
	CALL  waitkbdout
	MOV	  AL,0xdf			; enable A20
	OUT	  0x60,AL
	CALL  waitkbdout
		
		
; �л�������ģʽ
; CR0(control register 0),ֻ�в���ϵͳ���ܲ���
; ����ģʽ����ǰ16λģʽ��ͬ���μĴ������Ͳ��ǳ���16������ʹ��GDT
; ������Ӧ�ó��������ı�ϵ���㣬Ҳ����ʹ�ò���ϵͳר�ö�
; �л�������ģʽ������ִ��JMPָ��������Խ��ͷ����ı䣬CPU����ָ����ı䣬ʹ��pipeline����
[INSTRSET "i486p"]				; ʹ��486ָ��
	LGDT  [GDTR0]			; ������ʱGDT
	MOV	  EAX,CR0
	AND	  EAX,0x7fffffff	; ��bit31Ϊ0����ֹ��ҳ��
	OR	  EAX,0x00000001	; ��bit0Ϊ1���л�������ģʽ��
	MOV	  CR0,EAX
	JMP	  pipelineflush

; ���뱣��ģʽ���μĴ�����˼�����ı䣬����CS�������жμĴ���ֵ��0x0000���0x0008
; 0x0008�൱��gdt+1�Ķ�
pipelineflush:
	MOV	 AX,1*8			;  �i�ߕ������ܥ�������32bit
	MOV	 DS,AX
	MOV	 ES,AX
	MOV	 FS,AX
	MOV	 GS,AX
	MOV	 SS,AX
	
; bootpack����
	MOV	 ESI,bootpack	; ����Դ
	MOV	 EDI,BOTPAK		; ����Ŀ��
	MOV	 ECX,512*1024/4
	CALL memcpy

; �����������մ��͵�����λ��

; ������
	MOV		ESI,0x7c00		; ����Դ
	MOV		EDI,DSKCAC		; ����Ŀ��
	MOV		ECX,512/4
	CALL	memcpy

; ʣ�µ�
	MOV		ESI,DSKCAC0+512	; ����Դ
	MOV		EDI,DSKCAC+512	; ����Ŀ��
	MOV		ECX,0
	MOV		CL,BYTE [CYLS]
	IMUL	ECX,512*18*2/4	; �������任Ϊ�ֽ�������4
	SUB		ECX,512/4		; ��ȥIPL
	CALL	memcpy

; ������asmhead����ɵĹ������
; �Ժ���bootpack�����

; bootpack����
; ����bootpack��ͷ����ֵ���ܲ�ͬ
; [EBX+16] bootpack.hrb�ĵ�16�ŵ�ַ����0x11a8
; [EBX+20] bootpack.hrb�ĵ�20�ŵ�ַ����0x10c8
; [EBX+12] bootpack.hrb�ĵ�12�ŵ�ַ����0x00310000
; ����[EBX+20]��ʼ[EBX+16]���ֽڸ��Ƶ�[EBX+12]��ַȥ
	MOV		EBX,BOTPAK
	MOV		ECX,[EBX+16]
	ADD		ECX,3			; ECX += 3;
	SHR		ECX,2			; ECX /= 4;
	JZ		skip			; JZ jump zero
	MOV		ESI,[EBX+20]	; ܞ��Ԫ
	ADD		ESI,EBX
	MOV		EDI,[EBX+12]	; ܞ����
	CALL	memcpy
skip:
	MOV		ESP,[EBX+12]	; ջ��ʼֵ
	JMP		DWORD 2*8:0x0000001b  ; 2*8����CS��ƶ�0x1b��ַ������0x280000+0x1b,��ʼִ��bootpack

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout
		RET

memcpy:
	MOV		EAX,[ESI]
	ADD		ESI,4
	MOV		[EDI],EAX
	ADD		EDI,4
	SUB		ECX,1
	JNZ		memcpy			; �����������������0����ת��memcpy
	RET

; һֱ���DB 0��ֱ����ַ�ܱ�16����
	ALIGNB	16

; GDT0���ض���GDT, 0���ǿ����򣬲������
GDT0:
		RESB	8
		DW		0xffff,0x0000,0x9200,0x00cf	; �ɶ�д��32����
		DW		0xffff,0x0000,0x9a28,0x0047	; ��ִ�ж�32���أ�����bootpack��

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
