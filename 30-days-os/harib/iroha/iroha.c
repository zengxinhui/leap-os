#include "apilib.h"

// ?ʸ���shift-jts??��¸����EUC??��¸
void HariMain(void)
{
	static char s[9] = { 0xb2, 0xdb, 0xca, 0xc6, 0xce, 0xcd, 0xc4, 0x0a, 0x00 };
		/* Ⱦ�� */
	//api_putstr0(s);
	//api_putstr0("��Ϻǹ�Ǥ�  ��");
	api_putstr0("���ܸ�EUC�ǽ񤤤Ƥߤ��衼");
	// api_putstr0("��߹���");
	api_end();
}