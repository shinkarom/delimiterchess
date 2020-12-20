import core.stdc.stdio;

void unbufferStreams()
{
	setbuf(stdout, null);
	setbuf(stdin, null);
	setvbuf(stdout, null, _IONBF, 0);
	setvbuf(stdin, null, _IONBF, 0);
}

void initMidtabEndtab()
{
	import psqt;
	midtab[1] = &mwPawn;
	midtab[2] = &mbPawn;
	endtab[1] = &ewPawn;
	endtab[1] = &ebPawn;
	midtab[3] = midtab[4] = endtab[3] = endtab[4] = &mKnight;
	midtab[5] = midtab[6] = endtab[5] = endtab[6] = &mBishop;	
	midtab[7] = endtab[7] = &mwRook;
	midtab[8] = endtab[8] = &mbRook;	
	midtab[9] = endtab[9] = &mwQueen;
	midtab[10] = endtab[10] = &mbQueen;	
	midtab[11] = &mwKing;
	midtab[12] = &mbKing;
	endtab[11] = endtab[12] = &eKing;
}