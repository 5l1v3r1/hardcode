#include "wrapper.h"

#include "fisi.h"

/********************** sKROLLER *******************************/

struct{
	int offset;
	int zoom;
}skrl[50];

/*extern char txr_slime[];*/
/*#define skrmap0 txr_slime*/

char skrmap0[256]={
0x00,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,0x00,
0x01,0x01,0x01,0x01,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x00,0x00,
0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x00,
0x01,0x01,0x00,0x01,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,
0x01,0x01,0x00,0x01,0x10,0x10,0x11,0x11,0x11,0x11,0x11,0x11,0x10,0x10,0x01,0x01,
0x01,0x01,0x01,0x01,0x10,0x11,0x11,0x10,0x10,0x10,0x10,0x11,0x11,0x10,0x10,0x01,
0x01,0x01,0x01,0x10,0x10,0x11,0x10,0x10,0x01,0x01,0x10,0x10,0x11,0x11,0x10,0x01,
0x01,0x01,0x01,0x10,0x11,0x11,0x10,0x10,0x01,0x01,0x10,0x10,0x11,0x11,0x10,0x01,
0x01,0x01,0x10,0x10,0x11,0x11,0x10,0x10,0x10,0x10,0x10,0x11,0x11,0x10,0x01,0x01,
0x01,0x10,0x10,0x11,0x11,0x10,0x10,0x10,0x11,0x11,0x11,0x11,0x10,0x10,0x01,0x01,
0x01,0x10,0x11,0x11,0x10,0x01,0x10,0x10,0x11,0x10,0x10,0x10,0x10,0x01,0x01,0x10,
0x01,0x10,0x11,0x10,0x01,0x01,0x01,0x10,0x11,0x10,0x01,0x01,0x01,0x01,0x11,0x10,
0x01,0x10,0x11,0x10,0x10,0x01,0x10,0x10,0x11,0x10,0x01,0x10,0x11,0x10,0x11,0x10,
0x01,0x10,0x10,0x11,0x10,0x10,0x10,0x11,0x10,0x10,0x01,0x10,0x11,0x10,0x01,0x10,
0x01,0x01,0x10,0x11,0x11,0x11,0x11,0x11,0x10,0x01,0x01,0x01,0x01,0x10,0x01,0x00,
0x00,0x01,0x10,0x10,0x10,0x10,0x10,0x10,0x10,0x01,0x01,0x01,0x01,0x01,0x01,0x01
};

char skrmap[512];
unsigned char skramble[256];

extern char sini[];

int skr_parms;
int skr_ambles;

extern char lensb[],txr_neon[],txr_dunneon[],txr_slime[];

scr_txr(int k)
{
      int i;char*j=skrmap;char*txr;
      if(k==0)txr=skrmap0;
      if(k==1)txr=lensb;
      if(k==2)txr=txr_neon;
      if(k==3)txr=txr_dunneon;
      if(k==4)txr=txr_slime;
      for(i=256;i;i--)*j++=*txr++;
}

scroller_init(int parms)
{
	int y;
	skr_parms=parms;

	if(parms&HORIZON){
        for(y=0;y<50;y++){
		skrl[y].offset=(200/(4+y))<<12; /* 10+ */
                skrl[y].zoom  =1000/(10+y);  /* 2400 */
	}
	}else
        for(y=0;y<50;y++){
		skrl[y].offset=(1200/(20+y))<<12;  /* 1200 */
		skrl[y].zoom  =2000/(10+y);        /* 2000 */
	}

	if(parms&NOSKRAMBLE){
		memcpy(skrmap,skrmap0,256);
		skr_ambles=0;
	}
	else
	{
	memset(skrmap,0,256);
	for(y=0;y<256;y++)skramble[y]=y;
	for(y=0;y<256;y++){
		int j=rand()&255,tmp;
		tmp=skramble[j];skramble[j]=skramble[y];skramble[y]=tmp;
	}
	skr_ambles=256;
	}
}

scroller_do(char*buf,int t,int hg)
{

	static int lastt=0;
	char*d=buf;int y,offy;

        if(hg<0)hg=0;else if(hg>49)hg=49;

        memset(d,0,80*(50-hg));
        d+=80*(50-hg);

	if(skr_ambles){int tt=t;if(tt>256)tt=256;
  	  while(lastt<tt)if(skr_ambles){
		int j=skramble[skr_ambles--&255];
                skrmap[j]=skrmap0[j];
		/*skrmap[j+256]=skrmap0[j];*/
		lastt++;
	}}

	if(skr_parms&HORIZON)
		offy=-(t<<6)+(t<<12)&~3;else offy=(t<<6);

        for(y=0;y<hg;y++){
		register int ofz=skrl[y].offset+offy,dofz=skrl[y].zoom;
		#ifndef MSDOS_ASM
		  {int x=80;for(;x;x--)*d++=skrmap[((ofz+=dofz)>>8)&255];}
		#else
  		  skr_dorow(d,skrmap,dofz,ofz);
                  d+=80;
                #endif
	}
}