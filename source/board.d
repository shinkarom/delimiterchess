import defines, data;

void clearBoard()
{
	for(int sq = 0; sq<144;sq++)
	{
		if(ranks[sq]==-1 || files[sq]==-1)
		{
			p.board[sq].col = edge;
			p.board[sq].typ =edge;
			continue;
		}
		p.board[sq].col = npco;
		p.board[sq].typ = ety;
		continue;
	}
	p.material[0] = 0;
	p.material[1] = 0;
}

void initCastleBits()
{
	for(int sq = 0; sq<144;sq++)
	{
		switch(sq)
		{
			case A1:
				castleBits[sq] = 11;
				break;
			case H1:
				castleBits[sq] = 7;
				break;
			case A8:
				castleBits[sq] = 14;
				break;
			case H8:
				castleBits[sq] = 13;
				break;
			case E1:
				castleBits[sq] = 3;
				break;
			case E8:
				castleBits[sq] = 12;
				break;	
			default:
				castleBits[sq] = 15;
				break;
		}
	}
}

int fileranktosquare(const int r, const int f)
{
	return (r+2)*12 + 2 + f;
}

int chartofile(const char file)
{
	if(file=='a') return 0;
	if(file=='b') return 1;
	if(file=='c') return 2;
	if(file=='d') return 3;
	if(file=='e') return 4;
	if(file=='f') return 5;
	if(file=='g') return 6;
	if(file=='h') return 7;

	return 0;
}

int chartorank(const char rank)
{
	if(rank=='1') return 0;
	if(rank=='2') return 1;
	if(rank=='3') return 2;
	if(rank=='4') return 3;
	if(rank=='5') return 4;
	if(rank=='6') return 5;
	if(rank=='7') return 6;
	if(rank=='8') return 7;
	return 0;
}

char ranktochar(int rank)
{
	return brdranks[rank];
}

char filetochar(int file)
{
	return brdfiles[file];
}

char piece(int piece)
{
	return piecetochar[piece];
}

void initPieceLists()
{
	int sq, pce;
	
	p.pcenum = 0;
	
	for(sq = 0; sq<144;sq++)
	{
		p.sqtopcenum[sq] = nopiece;
	}
	for(pce = 0;pce<17;pce++)
	{
		p.pcenumtosq[pce] = deadsquare;
	}
	
	p.majors = 0;
	
	for(sq = 0; sq<144;sq++)
	{
		if(p.board[sq].typ == edge)
		{
			continue;
		}
		if(p.board[sq].typ != ety)
		{
			if(p.board[sq].typ != wP && p.board[sq].typ != bP)
			{
				p.majors++;
			}
			
			p.pcenumtosq[p.pcenum] = sq;
			p.sqtopcenum[sq] = p.pcenum;
			p.pcenum++;
		}
	}
}