import data, defines, attack;
import std.stdio;

void pushMoveLegal(int from, int to, int flag)
{
	SquareType holdme;
	int data = (from << 8) | to | flag;
	if (!makeQuick(data, holdme))
	{
		p.list[p.listc[p.ply + 1]++].m = data;
	}
	takeQuick(data, holdme);
}

void pushPawnLegal(int from, int to, int flag)
{
	import std.stdio;

	if (to > Square.H7 || to < Square.A2)
	{
		pushMoveLegal(from, to, mPQ);
		pushMoveLegal(from, to, mPR);
		pushMoveLegal(from, to, mPB);
		pushMoveLegal(from, to, mPN);
	}
	else
	{
		pushMoveLegal(from, to, flag);
	}
}

void knightMoveLegal(int f, int t, Side xSide)
{
	if (p.board[t] == SquareType.Edge)
		return;
	else if (p.board[t] == SquareType.Empty)
	{
		pushMoveLegal(f, t, mNORM);
	}
	else if (SquareTypeSide[p.board[t]] == xSide)
	{
		pushMoveLegal(f, t, mCAP);
	}
}

void slideMoveLegal(int f, int t, Side xSide)
{
	int d = t - f;
	if (p.board[t] == SquareType.Edge)
		return;
	do
	{
		if (p.board[t] == SquareType.Empty)
		{
			pushMoveLegal(f, t, mNORM);
			t += d;
		}
		else if (SquareTypeSide[p.board[t]] == xSide)
		{
			pushMoveLegal(f, t, mCAP);
			break;
		}
		else
			break;
	}
	while (p.board[t] != SquareType.Edge);
}

void moveGenLegal()
{
	int tsq;
	p.listc[p.ply + 1] = p.listc[p.ply];

	if (p.side == Side.White)
	{
		import std.stdio;

		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch (p.board[sq])
			{
			case SquareType.wP:
				tsq = sq + 13;
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawnLegal(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMoveLegal(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawnLegal(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMoveLegal(sq, tsq, mPEP);
				}
				tsq = sq + 12;
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawnLegal(sq, tsq, mNORM);
					if (sq < Square.A3 && p.board[tsq + 12] == SquareType.Empty)
					{
						pushMoveLegal(sq, (tsq + 12), mPST);
					}
				}
				break;
			case SquareType.wN:
				knightMoveLegal(sq, sq + 14, Side.Black);
				knightMoveLegal(sq, sq + 10, Side.Black);
				knightMoveLegal(sq, sq + 25, Side.Black);
				knightMoveLegal(sq, sq + 23, Side.Black);
				knightMoveLegal(sq, sq - 14, Side.Black);
				knightMoveLegal(sq, sq - 10, Side.Black);
				knightMoveLegal(sq, sq - 25, Side.Black);
				knightMoveLegal(sq, sq - 23, Side.Black);
				break;
			case SquareType.wK:
				knightMoveLegal(sq, sq + 1, Side.Black);
				knightMoveLegal(sq, sq + 12, Side.Black);
				knightMoveLegal(sq, sq + 11, Side.Black);
				knightMoveLegal(sq, sq + 13, Side.Black);
				knightMoveLegal(sq, sq - 1, Side.Black);
				knightMoveLegal(sq, sq - 12, Side.Black);
				knightMoveLegal(sq, sq - 11, Side.Black);
				knightMoveLegal(sq, sq - 13, Side.Black);
				if (sq == Square.E1)
				{
					if (p.castleFlags & 8)
					{
						if (p.board[Square.H1] == SquareType.wR && p.board[Square.F1] == SquareType.Empty
								&& p.board[Square.G1] == SquareType.Empty)
						{
							if (!isAttacked(Square.F1, Side.Black) && !isAttacked(Square.E1,
									Side.Black) && !isAttacked(Square.G1, Side.Black))
							{
								pushMoveLegal(Square.E1, Square.G1, mCA);
							}
						}
					}
					if (p.castleFlags & 4)
					{
						if (p.board[Square.A1] == SquareType.wR && p.board[Square.D1] == SquareType.Empty
								&& p.board[Square.C1] == SquareType.Empty && p.board[Square.B1] == SquareType.Empty)
						{
							if (!isAttacked(Square.D1, Side.Black) && !isAttacked(Square.E1,
									Side.Black) && !isAttacked(Square.C1, Side.Black))
							{
								pushMoveLegal(Square.E1, Square.C1, mCA);
							}
						}
					}
				}
				break;
			case SquareType.wQ:
				slideMoveLegal(sq, sq + 13, Side.Black);
				slideMoveLegal(sq, sq + 11, Side.Black);
				slideMoveLegal(sq, sq - 13, Side.Black);
				slideMoveLegal(sq, sq - 11, Side.Black);
				slideMoveLegal(sq, sq + 12, Side.Black);
				slideMoveLegal(sq, sq + 1, Side.Black);
				slideMoveLegal(sq, sq - 12, Side.Black);
				slideMoveLegal(sq, sq - 1, Side.Black);
				break;
			case SquareType.wB:
				slideMoveLegal(sq, sq + 13, Side.Black);
				slideMoveLegal(sq, sq + 11, Side.Black);
				slideMoveLegal(sq, sq - 13, Side.Black);
				slideMoveLegal(sq, sq - 11, Side.Black);
				break;
			case SquareType.wR:
				slideMoveLegal(sq, sq + 12, Side.Black);
				slideMoveLegal(sq, sq + 1, Side.Black);
				slideMoveLegal(sq, sq - 12, Side.Black);
				slideMoveLegal(sq, sq - 1, Side.Black);
				break;
			default:
				break;
			}
		}
	}
	else
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;

			int sq = p.pceNumToSq[index];
			switch (p.board[sq])
			{
			case SquareType.bP:
				tsq = sq - 13;
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawnLegal(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMoveLegal(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawnLegal(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMoveLegal(sq, tsq, mPEP);
				}
				tsq = sq - 12;
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawnLegal(sq, tsq, mNORM);
					if (sq < Square.A3 && p.board[tsq + 12] == SquareType.Empty)
					{
						pushMoveLegal(sq, (tsq - 12), mPST);
					}
				}
				break;
			case SquareType.bN:
				knightMoveLegal(sq, sq + 14, Side.White);
				knightMoveLegal(sq, sq + 10, Side.White);
				knightMoveLegal(sq, sq + 25, Side.White);
				knightMoveLegal(sq, sq + 23, Side.White);
				knightMoveLegal(sq, sq - 14, Side.White);
				knightMoveLegal(sq, sq - 10, Side.White);
				knightMoveLegal(sq, sq - 25, Side.White);
				knightMoveLegal(sq, sq - 23, Side.White);
				break;
			case SquareType.bK:
				knightMoveLegal(sq, sq + 1, Side.White);
				knightMoveLegal(sq, sq + 12, Side.White);
				knightMoveLegal(sq, sq + 11, Side.White);
				knightMoveLegal(sq, sq + 13, Side.White);
				knightMoveLegal(sq, sq - 1, Side.White);
				knightMoveLegal(sq, sq - 12, Side.White);
				knightMoveLegal(sq, sq - 11, Side.White);
				knightMoveLegal(sq, sq - 13, Side.White);
				if (sq == Square.E8)
				{
					if (p.castleFlags & 2)
					{
						if (p.board[Square.H8] == SquareType.bR && p.board[Square.F8] == SquareType.Empty
								&& p.board[Square.G8] == SquareType.Empty)
						{
							if (!isAttacked(Square.F8, Side.White) && !isAttacked(Square.E8,
									Side.White) && !isAttacked(Square.G8, Side.White))
							{
								pushMoveLegal(Square.E8, Square.G8, mCA);
							}
						}
					}
					if (p.castleFlags & 1)
					{
						if (p.board[Square.A8] == SquareType.bR && p.board[Square.D8] == SquareType.Empty
								&& p.board[Square.C8] == SquareType.Empty && p.board[Square.B8] == SquareType.Empty)
						{
							if (!isAttacked(Square.D8, Side.White) && !isAttacked(Square.E8,
									Side.White) && !isAttacked(Square.C8, Side.White))
							{
								pushMoveLegal(Square.E8, Square.C8, mCA);
							}
						}
					}
				}
				break;
			case SquareType.bQ:
				slideMoveLegal(sq, sq + 13, Side.White);
				slideMoveLegal(sq, sq + 11, Side.White);
				slideMoveLegal(sq, sq - 13, Side.White);
				slideMoveLegal(sq, sq - 11, Side.White);
				slideMoveLegal(sq, sq + 12, Side.White);
				slideMoveLegal(sq, sq + 1, Side.White);
				slideMoveLegal(sq, sq - 12, Side.White);
				slideMoveLegal(sq, sq - 1, Side.White);
				break;
			case SquareType.bB:
				slideMoveLegal(sq, sq + 13, Side.White);
				slideMoveLegal(sq, sq + 11, Side.White);
				slideMoveLegal(sq, sq - 13, Side.White);
				slideMoveLegal(sq, sq - 11, Side.White);
				break;
			case SquareType.bR:
				slideMoveLegal(sq, sq + 12, Side.White);
				slideMoveLegal(sq, sq + 1, Side.White);
				slideMoveLegal(sq, sq - 12, Side.White);
				slideMoveLegal(sq, sq - 1, Side.White);
				break;
			default:
				break;
			}
		}
	}
}

bool makeQuick(int m, ref SquareType holdme)
{
	int from = getFrom(m);
	int to = getTo(m);
	int flag = getFlag(m);

	bool r = false;

	holdme = p.board[to];

	p.board[to] = p.board[from];

	p.board[from] = SquareType.Empty;

	if (p.side == Side.White && p.board[to] == SquareType.wK)
	{
		p.k[Side.White] = to;
	}
	else if (p.side == Side.Black && p.board[to] == SquareType.bK)
	{
		p.k[Side.Black] = to;
	}

	if (flag & mProm)
	{
		if (flag & oPQ)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wQ;
			}
			else
			{
				p.board[to] = SquareType.bQ;
			}
		}
		if (flag & oPR)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wR;
			}
			else
			{
				p.board[to] = SquareType.bR;
			}
		}
		if (flag & oPB)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wB;
			}
			else
			{
				p.board[to] = SquareType.bB;
			}
		}
		if (flag & oPN)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wN;
			}
			else
			{
				p.board[to] = SquareType.bN;
			}
		}
	}
	else if (flag & mCA)
	{
		if (to == Square.G1)
		{
			p.board[Square.F1] = p.board[Square.H1];
			p.board[Square.H1] = SquareType.Empty;
		}
		if (to == Square.C1)
		{
			p.board[Square.D1] = p.board[Square.A1];
			p.board[Square.A1] = SquareType.Empty;
		}
		if (to == Square.G8)
		{
			p.board[Square.F8] = p.board[Square.H8];
			p.board[Square.H8] = SquareType.Empty;
		}
		if (to == Square.C8)
		{
			p.board[Square.D8] = p.board[Square.A8];
			p.board[Square.A8] = SquareType.Empty;
		}
	}
	else if (flag & oPEP)
	{
		import std.stdio;

		if (p.side == Side.White)
		{
			p.board[to - 12] = SquareType.Empty;
		}
		else
		{
			p.board[to + 12] = SquareType.Empty;
		}
	}
	r = isAttacked(p.k[p.side], p.side ^ 1);
	return r;
}

void takeQuick(int m, ref SquareType holdme)
{
	int from = getFrom(m);
	int to = getTo(m);
	int flag = getFlag(m);

	p.board[from] = p.board[to];
	p.board[to] = holdme;

	if (p.side == Side.White && p.board[from] == SquareType.wK)
	{
		p.k[Side.White] = from;
	}
	else if (p.side == Side.Black && p.board[from] == SquareType.bK)
	{
		p.k[Side.Black] = from;
	}

	if (flag & mProm)
	{
		if (p.side == Side.White)
		{
			p.board[from] = SquareType.wP;
		}
		else
		{
			p.board[from] = SquareType.bP;
		}
	}
	else if (flag & mCA)
	{
		if (to == Square.G1)
		{
			p.board[Square.H1] = p.board[Square.F1];
			p.board[Square.F1] = SquareType.Empty;
		}
		if (to == Square.C1)
		{
			p.board[Square.A1] = p.board[Square.D1];
			p.board[Square.D1] = SquareType.Empty;
		}
		if (to == Square.G8)
		{
			p.board[Square.H8] = p.board[Square.F8];
			p.board[Square.F8] = SquareType.Empty;
		}
		if (to == Square.C8)
		{
			p.board[Square.A8] = p.board[Square.D8];
			p.board[Square.D8] = SquareType.Empty;
		}
	}
	else if (flag & mPEP)
	{
		if (p.side == Side.White)
		{
			p.board[to - 12] = SquareType.bP;
		}
		else
		{
			p.board[to + 12] = SquareType.wP;
		}
	}
}

bool makeLegalMove(Move m)
{
	int from = getFrom(m.m);
	int to = getTo(m.m);
	int flag = getFlag(m.m);

	bool r = false;

	hist[histply].data = m.m;
	hist[histply].enPas = p.enPas;
	hist[histply].fifty = p.fifty;
	hist[histply].hashKey = p.hashKey;
	hist[histply].castleFlags = p.castleFlags;
	hist[histply].captured = p.board[to];

	p.hashKey ^= hashTurn;
	p.hashKey ^= hashCastleCombinations[p.castleFlags];
	p.hashKey ^= hashEnPassant[files[p.enPas]];

	p.enPas = noEnPas;
	p.castleFlags &= castleBits[to];
	p.castleFlags &= castleBits[from];

	hist[histply].pList = p.sqToPceNum[to];
	p.pceNumToSq[p.sqToPceNum[to]] = 0;
	p.pceNumToSq[p.sqToPceNum[from]] = to;
	p.sqToPceNum[to] = p.sqToPceNum[from];
	p.sqToPceNum[from] = 0;

	p.board[to] = p.board[from];
	p.board[from] = SquareType.Empty;

	if (p.side == Side.White && p.board[to] == SquareType.wK)
	{
		p.k[Side.White] = to;
	}
	else if (p.side == Side.Black && p.board[to] == SquareType.bK)
	{
		p.k[Side.Black] = to;
	}

	p.hashKey ^= hashPieces[64 * p.board[to] + 8 * ranks[from] + files[from]];
	p.hashKey ^= hashPieces[64 * p.board[to] + 8 * ranks[to] + files[to]];

	p.fifty++;

	if (hist[histply].captured != SquareType.Empty)
	{
		if (hist[histply].captured > 2)
		{
			p.majors--;
		}
		p.material[p.side] -= vals[hist[histply].captured];
		p.hashKey ^= hashPieces[64 * hist[histply].captured + 8 * ranks[to] + files[to]];
		p.fifty = 0;
	}
	if (p.board[to] < 3)
	{
		p.fifty = 0;
	}

	if (flag & mProm)
	{
		p.majors++;

		if (flag & oPQ)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wQ;
				p.material[Side.White] += vQ - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wQ + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bQ;
				p.material[Side.Black] += vQ - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bQ + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPR)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wR;
				p.material[Side.White] += vR - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bR;
				p.material[Side.Black] += vR - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPB)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wB;
				p.material[Side.White] += vB - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wB + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bB;
				p.material[Side.Black] += vB - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bB + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPN)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wN;
				p.material[Side.White] += vN - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wN + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bN;
				p.material[Side.Black] += vN - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bN + 8 * ranks[to] + files[to]];
			}
		}
	}
	else if (flag & mPST)
	{
		if (p.side == Side.White)
		{
			p.enPas = to - 12;
		}
		else
		{
			p.enPas = to + 12;
		}
	}
	else if (flag & mCA)
	{
		if (to == Square.G1)
		{
			p.board[Square.F1] = p.board[Square.H1];
			p.board[Square.H1] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[Square.H1] + files[Square.H1]];
			p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[Square.F1] + files[Square.F1]];

			p.pceNumToSq[p.sqToPceNum[Square.H1]] = Square.F1;
			p.sqToPceNum[Square.F1] = p.sqToPceNum[Square.H1];
			p.sqToPceNum[Square.H1] = 0;
		}
		if (to == Square.C1)
		{
			p.board[Square.D1] = p.board[Square.A1];
			p.board[Square.A1] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[Square.A1] + files[Square.A1]];
			p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[Square.D1] + files[Square.D1]];

			p.pceNumToSq[p.sqToPceNum[Square.A1]] = Square.D1;
			p.sqToPceNum[Square.D1] = p.sqToPceNum[Square.A1];
			p.sqToPceNum[Square.A1] = 0;
		}
		if (to == Square.G8)
		{
			p.board[Square.F8] = p.board[Square.H8];
			p.board[Square.H8] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.H8] + files[Square.H8]];
			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.F8] + files[Square.F8]];

			p.pceNumToSq[p.sqToPceNum[Square.H8]] = Square.F8;
			p.sqToPceNum[Square.F8] = p.sqToPceNum[Square.H8];
			p.sqToPceNum[Square.H8] = 0;
		}
		if (to == Square.C8)
		{
			p.board[Square.D8] = p.board[Square.A8];
			p.board[Square.A8] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.A8] + files[Square.A8]];
			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.D8] + files[Square.D8]];

			p.pceNumToSq[p.sqToPceNum[Square.A8]] = Square.D8;
			p.sqToPceNum[Square.D8] = p.sqToPceNum[Square.A8];
			p.sqToPceNum[Square.A8] = 0;
		}
	}
	else if (flag & oPEP)
	{
		if (p.side == Side.White)
		{
			p.board[to - 12] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to - 12] + files[to - 12]];
			p.material[Side.Black] -= vP;

			hist[histply].pList = p.sqToPceNum[to - 12];
			p.pceNumToSq[p.sqToPceNum[to - 12]] = 0;
			p.sqToPceNum[to - 12] = 0;
		}
		else
		{
			p.board[to + 12] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to + 12] + files[to + 12]];
			p.material[Side.White] -= vP;

			hist[histply].pList = p.sqToPceNum[to + 12];
			p.pceNumToSq[p.sqToPceNum[to + 12]] = 0;
			p.sqToPceNum[to + 12] = 0;
		}
	}

	p.ply++;
	p.side ^= 1;
	histply++;

	p.hashKey ^= hashTurn;
	p.hashKey ^= hashCastleCombinations[p.castleFlags];
	p.hashKey ^= hashEnPassant[files[p.enPas]];
	return r;
}
