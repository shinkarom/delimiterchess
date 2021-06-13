import defines, data;

void clearBoard()
{
	for (int sq = 0; sq < 144; sq++)
	{
		if (ranks[sq] == -1 || files[sq] == -1)
		{
			p.board[sq].color = edge;
			p.board[sq].type = edge;
			continue;
		}
		p.board[sq].color = pieceColorNone;
		p.board[sq].type = empty;
		continue;
	}
	p.material[0] = 0;
	p.material[1] = 0;
}

void initCastleBits()
{
	for (int sq = 0; sq < 144; sq++)
	{
		switch (sq)
		{
		case A1:
			castleBits[sq] = ~WQC;
			break;
		case H1:
			castleBits[sq] = ~WKC;
			break;
		case A8:
			castleBits[sq] = ~BQC;
			break;
		case H8:
			castleBits[sq] = ~BKC;
			break;
		case E1:
			castleBits[sq] = ~(WKC | WQC);
			break;
		case E8:
			castleBits[sq] = ~(BKC | BQC);
			break;
		default:
			castleBits[sq] = WKC | WQC | BKC | BQC;
			break;
		}
	}
}

int fileRankToSquare(const int r, const int f)
{
	return (r + 2) * 12 + 2 + f;
}

int charToFile(const char file)
{
	if (file == 'a')
		return 0;
	if (file == 'b')
		return 1;
	if (file == 'c')
		return 2;
	if (file == 'd')
		return 3;
	if (file == 'e')
		return 4;
	if (file == 'f')
		return 5;
	if (file == 'g')
		return 6;
	if (file == 'h')
		return 7;

	return 0;
}

int charToRank(const char rank)
{
	if (rank == '1')
		return 0;
	if (rank == '2')
		return 1;
	if (rank == '3')
		return 2;
	if (rank == '4')
		return 3;
	if (rank == '5')
		return 4;
	if (rank == '6')
		return 5;
	if (rank == '7')
		return 6;
	if (rank == '8')
		return 7;
	return 0;
}

char rankToChar(int rank)
{
	return brdranks[rank];
}

char fileToChar(int file)
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

	p.pceNum = 0;

	for (sq = 0; sq < 144; sq++)
	{
		p.sqToPceNum[sq] = nopiece;
	}
	for (pce = 0; pce < 17; pce++)
	{
		p.pceNumToSq[pce] = deadsquare;
	}

	p.majors = 0;

	for (sq = 0; sq < 144; sq++)
	{
		if (p.board[sq].type == edge)
		{
			continue;
		}
		if (p.board[sq].type != empty)
		{
			if (p.board[sq].type != wP && p.board[sq].type != bP)
			{
				p.majors++;
			}

			p.pceNum++;
			p.pceNumToSq[p.pceNum] = sq;
			p.sqToPceNum[sq] = p.pceNum;
		}
	}
}
