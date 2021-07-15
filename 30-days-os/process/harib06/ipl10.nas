; leapos-ipl
; TAB=4
; ������512�ֽ�
; ��������д���̵�ʱ�򣬲�����1�ֽڵĶ�д�ģ�������512�ֽ�Ϊ��λ��д��
; ������̵�512�ֽھͳ�Ϊһ��������һ�����̹���2880������
; ��һ��������Ϊ������


CYLS   EQU  10      ; define

	ORG  0x7c00     ; ����Ҫ������λ��
	
; �����Ǳ�׼FAT12��ʽ���̵�����
    JMP  entry      ; JMP��������ת
	DB   0x90       ; define byte, ���һ���ֽ�
	DB   "LEAPIPL " ; ������������(������8�ֽ�), ipl(initial program loader)
	DW   512        ; define word=2*DB,ÿ�������Ĵ�С������512
	DB   1          ; �صĴ�С(������1������)
	DW   1          ; FAT����ʼλ��(һ���ǵ�1������)
	DB   2          ; FAT�ĸ�����������2��
	DW	 224		; ��Ŀ¼�Ĵ�С(һ�����224��)
	DW	 2880		; �ô��̵Ĵ�С��������2880������
	DB	 0xf0		; ���̵����ࣨ������0xf0��
	DW	 9			; FAT�ĳ��ȣ�������9������
	DW	 18			; 1���ŵ���track���м���������������18��
	DW	 2			; ��ͷ����������2��
	DD	 0			; ��ʹ�÷�����������0��define double word=2*DW
	DD	 2880		; ��дһ�δ��̴�С
	DB	 0,0,0x29		; ���岻�����̶�
	DD	 0xffffffff		; �������ǣ�������
	DB	 "LEAP-OS    "	; ���̵����ƣ�������11�ֽڣ�
	DB	 "FAT12   "		; ���̸�ʽ���ƣ�������8�ֽڣ�
	RESB 18				; �ճ�18�ֽ�
	
; ��������
entry:
	MOV  AX,0
	MOV  SS,AX
	MOV  SP,0x7c00
	MOV  DS,AX

; ���̹���80�����棬2����ͷ��ÿ������18��������ÿ������512�ֽ�
; ������CYLS(10)����������ݵ�0x08200��0x34fff
; IPL����������λ��C0-H0-S1������0����ͷ0������1����д��
; ָ���ڴ�ĵ�ַ������ͬʱָ���μĴ��������ʡ��DS��ΪĬ�ϵĶμĴ���
; ����BIOS����ʱ��ES:BX=�����ַ��(У�鼰Ѱ��ʱ��ʹ��)
;     ����ֵ��FLACS.CF==0��û�д���AH==0 
;             FLAGS.CF==1���д��󣬴���������AH�ڣ������ã�reset������һ����
	MOV  AX,0x0820
	MOV  ES,AX      ; ָ��[ES:BX]Ϊ��ȡ��λ�ã����ص�ES*16+AX=0x8200λ��
	MOV  CH,0       ; ����0
	MOV  DH,0       ; ��ͷ0
	MOV	 CL,2		; ����2
	
readloop:
	MOV	 SI,0		; ʧ�ܴ���
	
retry:
	MOV	 AH,0x02	; AH=0x02,��ʾ����BIOS��ȡ����
	MOV	 AL,1		; 1������
	MOV	 BX,0
	MOV	 DL,0x00	; A������
	INT	 0x13		; �����жϵ���BIOS
	JNC	 next		; JNC,jump not carry(��λ), ��ʾû�������ת
	ADD	 SI,1		; SI��1
	CMP	 SI,5		; SI��5�Ƚ�
	JAE	 error		; SI >= 5ʱ����error, JAE,jump above or equal
	MOV	 AH,0x00
	MOV	 DL,0x00
	INT	 0x13		; AH=0,DL=0,����������,�������¶�ȡ
	JMP	 retry
	
next:
	MOV	 AX,ES		; �ڴ��ַ����0x200
	ADD	 AX,0x0020
	MOV	 ES,AX		; ADD ES,0x020 ��Ϊû��ADD ES,������������
	ADD	 CL,1		; CL��1����һ������
	CMP	 CL,18		; CL��18�Ƚ�
	JBE	 readloop	; CL <= 18����readloop��JBE,jump below equal
	MOV	 CL,1
	ADD	 DH,1       ; ��һ����ͷ
	CMP	 DH,2
	JB	 readloop	; DH < 2����readloop, JE,jump below
	MOV	 DH,0
	ADD	 CH,1       ; ��һ������
	CMP	 CH,CYLS
	JB	 readloop	; CH < CYLS����readloop
	
	MOV		[0x0ff0],CH  ; IPL��¼CH�Ķ�ȡλ��
	JMP		0xc200       ; ִ�г���д��0x4200�Ժ�ĵط�����������0x8200+0x4200=0xc200����ʼִ�г���   

error:
	MOV  SI,msg
putloop:
	MOV	 AL,[SI]
	ADD	 SI,1			; SI��1
	CMP	 AL,0
	JE	 fin
	MOV	 AH,0x0e		; ��ʾ����
	MOV	 BX,15			; ָ����ɫ
	INT	 0x10			; �����Կ�BIOS
	JMP	 putloop
fin:
	HLT			
	JMP		fin
msg:
	DB		0x0a, 0x0a		; ����
	DB		"load error"
	DB		0x0a			; ����
	DB		0

	RESB	0x7dfe-$		; 0x7dfe��ַ���˴����0

	DB		0x55, 0xaa      ; ����������������ֽ���0x55��0xaa��ʾ�ǲ���ϵͳ����
