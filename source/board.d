import defines, data;

void clearBoard(ref Position p)
{
	for (int sq = 0; sq < 144; sq++)
	{
		if (ranks[sq] == -1 || files[sq] == -1)
		{
			p.board[sq] = SquareType.Edge;
			continue;
		}
		p.board[sq] = SquareType.Empty;
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
		case Square.A1:
			castleBits[sq] = ~WQC;
			break;
		case Square.H1:
			castleBits[sq] = ~WKC;
			break;
		case Square.A8:
			castleBits[sq] = ~BQC;
			break;
		case Square.H8:
			castleBits[sq] = ~BKC;
			break;
		case Square.E1:
			castleBits[sq] = ~(WKC | WQC);
			break;
		case Square.E8:
			castleBits[sq] = ~(BKC | BQC);
			break;
		default:
			castleBits[sq] = WKC | WQC | BKC | BQC;
			break;
		}
	}
}

void initPieceLists()
{
	int sq, pce;

	p.pceNum = 0;

	for (sq = 0; sq < 144; sq++)
	{
		p.sqToPceNum[sq] = noPiece;
	}
	for (pce = 0; pce < 17; pce++)
	{
		p.pceNumToSq[pce] = deadSquare;
	}

	p.majors = 0;

	for (sq = 0; sq < 144; sq++)
	{
		if (p.board[sq] == SquareType.Edge)
		{
			continue;
		}
		if (p.board[sq] != SquareType.Empty)
		{
			if (p.board[sq] != SquareType.wP && p.board[sq] != SquareType.bP)
			{
				p.majors++;
			}

			p.pceNum++;
			p.pceNumToSq[p.pceNum] = sq;
			p.sqToPceNum[sq] = p.pceNum;
		}
	}
}
