import std.stdio, io, std.format;
import data, defines, psqt, attack;

void pushMove(int from, int to, int flag)
{
	auto data = (from << 8) | to | flag;
	p.list[p.listc[p.ply + 1]++].m = data;
}

void pushPawn(int from, int to, int flag)
{
	if (to > H7 || to < A2)
	{
		pushMove(from, to, mPQ | flag);
		pushMove(from, to, mPR | flag);
		pushMove(from, to, mPB | flag);
		pushMove(from, to, mPN | flag);
	}
	else
	{
		pushMove(from, to, flag);
	}
}

void knightMove(int f, int t, Side xSide)
{
	if (p.board[t] == SquareType.Edge)
		return;
	if (p.board[t] == SquareType.Empty)
	{
		pushMove(f, t, mNORM);
	}
	else if (SquareTypeColor[p.board[t]] == xSide)
	{
		pushMove(f, t, mCAP);
	}
}

void slideMove(int f, int t, Side xSide)
{
	int d = t - f;
	if (p.board[t] == SquareType.Edge)
		return;
	do
	{
		if (p.board[t] == SquareType.Empty)
		{
			pushMove(f, t, mNORM);
			t += d;
		}
		else if (SquareTypeColor[p.board[t]] == xSide)
		{
			pushMove(f, t, mCAP);
			break;
		}
		else
		{
			break;
		}
	}
	while (p.board[t] != SquareType.Edge);
}

void knightMoveC(int f, int t, Side xSide)
{
	if (p.board[t] == SquareType.Edge)
		return;
	else if (SquareTypeColor[p.board[t]] == xSide)
	{
		pushMove(f, t, mCAP);
	}
}

void slideMoveC(int f, int t, Side xSide)
{
	int d = t - f;
	if (p.board[t] == SquareType.Edge)
		return;
	do
	{
		if (p.board[t] == SquareType.Empty)
		{
			t += d;
		}
		else if (SquareTypeColor[p.board[t]] == xSide)
		{
			pushMove(f, t, mCAP);
			break;
		}
		else
		{
			break;
		}
	}
	while (p.board[t] != SquareType.Edge);
}

void moveGen()
{
	int tsq;
	p.listc[p.ply + 1] = p.listc[p.ply];
	if (p.side == Side.White)
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch (p.board[sq])
			{
			case SquareType.wP:
				tsq = sq + 13;
				if (SquareTypeColor[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (SquareTypeColor[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 12;
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq < A3 && p.board[tsq + 12] == SquareType.Empty)
					{
						pushMove(sq, (tsq + 12), mPST);
					}
				}
				break;
			case SquareType.wN:
				knightMove(sq, sq + 14, Side.Black);
				knightMove(sq, sq + 10, Side.Black);
				knightMove(sq, sq + 25, Side.Black);
				knightMove(sq, sq + 23, Side.Black);
				knightMove(sq, sq - 14, Side.Black);
				knightMove(sq, sq - 10, Side.Black);
				knightMove(sq, sq - 25, Side.Black);
				knightMove(sq, sq - 23, Side.Black);
				break;
			case SquareType.wK:
				knightMove(sq, sq + 1, Side.Black);
				knightMove(sq, sq + 12, Side.Black);
				knightMove(sq, sq + 11, Side.Black);
				knightMove(sq, sq + 13, Side.Black);
				knightMove(sq, sq - 1, Side.Black);
				knightMove(sq, sq - 12, Side.Black);
				knightMove(sq, sq - 11, Side.Black);
				knightMove(sq, sq - 13, Side.Black);
				if (sq == E1)
				{
					if (p.castleflags & WKC)
					{
						if (p.board[H1] == SquareType.wR && p.board[F1] == SquareType.Empty
								&& p.board[G1] == SquareType.Empty)
						{
							if (!isAttacked(F1, Side.Black) && !isAttacked(E1,
									Side.Black) && !isAttacked(G1, Side.Black))
							{
								pushMove(E1, G1, mCA);
							}
						}
					}
					if (p.castleflags & WQC)
					{
						if (p.board[A1] == SquareType.wR && p.board[D1] == SquareType.Empty
								&& p.board[C1] == SquareType.Empty && p.board[B1] == SquareType.Empty)
						{
							if (!isAttacked(D1, Side.Black) && !isAttacked(E1,
									Side.Black) && !isAttacked(C1, Side.Black))
							{
								pushMove(E1, C1, mCA);
							}
						}
					}
				}
				break;
			case SquareType.wQ:
				slideMove(sq, sq + 13, Side.Black);
				slideMove(sq, sq + 11, Side.Black);
				slideMove(sq, sq + 12, Side.Black);
				slideMove(sq, sq + 1, Side.Black);
				slideMove(sq, sq - 13, Side.Black);
				slideMove(sq, sq - 11, Side.Black);
				slideMove(sq, sq - 12, Side.Black);
				slideMove(sq, sq - 1, Side.Black);
				break;
			case SquareType.wB:
				slideMove(sq, sq + 13, Side.Black);
				slideMove(sq, sq + 11, Side.Black);
				slideMove(sq, sq - 13, Side.Black);
				slideMove(sq, sq - 11, Side.Black);
				break;
			case SquareType.wR:
				slideMove(sq, sq + 12, Side.Black);
				slideMove(sq, sq + 1, Side.Black);
				slideMove(sq, sq - 12, Side.Black);
				slideMove(sq, sq - 1, Side.Black);
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
				if (SquareTypeColor[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (SquareTypeColor[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 12;
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq > H6 && p.board[tsq - 12] == SquareType.Empty)
					{
						pushMove(sq, (tsq - 12), mPST);
					}
				}
				break;
			case SquareType.bN:
				knightMove(sq, sq + 14, Side.White);
				knightMove(sq, sq + 10, Side.White);
				knightMove(sq, sq + 25, Side.White);
				knightMove(sq, sq + 23, Side.White);
				knightMove(sq, sq - 14, Side.White);
				knightMove(sq, sq - 10, Side.White);
				knightMove(sq, sq - 25, Side.White);
				knightMove(sq, sq - 23, Side.White);
				break;
			case SquareType.bK:
				knightMove(sq, sq + 1, Side.White);
				knightMove(sq, sq + 12, Side.White);
				knightMove(sq, sq + 11, Side.White);
				knightMove(sq, sq + 13, Side.White);
				knightMove(sq, sq - 1, Side.White);
				knightMove(sq, sq - 12, Side.White);
				knightMove(sq, sq - 11, Side.White);
				knightMove(sq, sq - 13, Side.White);
				if (sq == E8)
				{
					if (p.castleflags & BKC)
					{
						if (p.board[H8] == SquareType.bR && p.board[F8] == SquareType.Empty
								&& p.board[G8] == SquareType.Empty)
						{
							if (!isAttacked(F8, Side.White) && !isAttacked(E8,
									Side.White) && !isAttacked(G8, Side.White))
							{
								pushMove(E8, G8, mCA);
							}
						}
					}
					if (p.castleflags & BQC)
					{
						if (p.board[A8] == SquareType.bR && p.board[D8] == SquareType.Empty
								&& p.board[C8] == SquareType.Empty && p.board[B8] == SquareType.Empty)
						{
							if (!isAttacked(D8, Side.White) && !isAttacked(E8,
									Side.White) && !isAttacked(C8, Side.White))
							{
								pushMove(E8, C8, mCA);
							}
						}
					}
				}
				break;
			case SquareType.bQ:
				slideMove(sq, sq + 13, Side.White);
				slideMove(sq, sq + 11, Side.White);
				slideMove(sq, sq + 12, Side.White);
				slideMove(sq, sq + 1, Side.White);
				slideMove(sq, sq - 13, Side.White);
				slideMove(sq, sq - 11, Side.White);
				slideMove(sq, sq - 12, Side.White);
				slideMove(sq, sq - 1, Side.White);
				break;
			case SquareType.bB:
				slideMove(sq, sq + 13, Side.White);
				slideMove(sq, sq + 11, Side.White);
				slideMove(sq, sq - 13, Side.White);
				slideMove(sq, sq - 11, Side.White);
				break;
			case SquareType.bR:
				slideMove(sq, sq + 12, Side.White);
				slideMove(sq, sq + 1, Side.White);
				slideMove(sq, sq - 12, Side.White);
				slideMove(sq, sq - 1, Side.White);
				break;
			default:
				break;
			}
		}
	}
}

void capGen()
{
	int tsq;
	p.listc[p.ply + 1] = p.listc[p.ply];
	if (p.side == Side.White)
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch (p.board[sq])
			{
			case SquareType.wP:
				tsq = sq + 13;
				if (SquareTypeColor[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (SquareTypeColor[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				break;
			case SquareType.wN:
				knightMoveC(sq, sq + 14, Side.Black);
				knightMoveC(sq, sq + 10, Side.Black);
				knightMoveC(sq, sq + 25, Side.Black);
				knightMoveC(sq, sq + 23, Side.Black);
				knightMoveC(sq, sq - 14, Side.Black);
				knightMoveC(sq, sq - 10, Side.Black);
				knightMoveC(sq, sq - 25, Side.Black);
				knightMoveC(sq, sq - 23, Side.Black);
				break;
			case SquareType.wK:
				knightMoveC(sq, sq + 1, Side.Black);
				knightMoveC(sq, sq + 12, Side.Black);
				knightMoveC(sq, sq + 11, Side.Black);
				knightMoveC(sq, sq + 13, Side.Black);
				knightMoveC(sq, sq - 1, Side.Black);
				knightMoveC(sq, sq - 12, Side.Black);
				knightMoveC(sq, sq - 11, Side.Black);
				knightMoveC(sq, sq - 13, Side.Black);
				break;
			case SquareType.wQ:
				slideMoveC(sq, sq + 13, Side.Black);
				slideMoveC(sq, sq + 11, Side.Black);
				slideMoveC(sq, sq + 12, Side.Black);
				slideMoveC(sq, sq + 1, Side.Black);
				slideMoveC(sq, sq - 13, Side.Black);
				slideMoveC(sq, sq - 11, Side.Black);
				slideMoveC(sq, sq - 12, Side.Black);
				slideMoveC(sq, sq - 1, Side.Black);
				break;
			case SquareType.wB:
				slideMoveC(sq, sq + 13, Side.Black);
				slideMoveC(sq, sq + 11, Side.Black);
				slideMoveC(sq, sq - 13, Side.Black);
				slideMoveC(sq, sq - 11, Side.Black);
				break;
			case SquareType.wR:
				slideMoveC(sq, sq + 12, Side.Black);
				slideMoveC(sq, sq + 1, Side.Black);
				slideMoveC(sq, sq - 12, Side.Black);
				slideMoveC(sq, sq - 1, Side.Black);
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
				if (SquareTypeColor[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (SquareTypeColor[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				break;
			case SquareType.bN:
				knightMoveC(sq, sq + 14, Side.White);
				knightMoveC(sq, sq + 10, Side.White);
				knightMoveC(sq, sq + 25, Side.White);
				knightMoveC(sq, sq + 23, Side.White);
				knightMoveC(sq, sq - 14, Side.White);
				knightMoveC(sq, sq - 10, Side.White);
				knightMoveC(sq, sq - 25, Side.White);
				knightMoveC(sq, sq - 23, Side.White);
				break;
			case SquareType.bK:
				knightMoveC(sq, sq + 1, Side.White);
				knightMoveC(sq, sq + 12, Side.White);
				knightMoveC(sq, sq + 11, Side.White);
				knightMoveC(sq, sq + 13, Side.White);
				knightMoveC(sq, sq - 1, Side.White);
				knightMoveC(sq, sq - 12, Side.White);
				knightMoveC(sq, sq - 11, Side.White);
				knightMoveC(sq, sq - 13, Side.White);
				break;
			case SquareType.bQ:
				slideMoveC(sq, sq + 13, Side.White);
				slideMoveC(sq, sq + 11, Side.White);
				slideMoveC(sq, sq + 12, Side.White);
				slideMoveC(sq, sq + 1, Side.White);
				slideMoveC(sq, sq - 13, Side.White);
				slideMoveC(sq, sq - 11, Side.White);
				slideMoveC(sq, sq - 12, Side.White);
				slideMoveC(sq, sq - 1, Side.White);
				break;
			case SquareType.bB:
				slideMoveC(sq, sq + 13, Side.White);
				slideMoveC(sq, sq + 11, Side.White);
				slideMoveC(sq, sq - 13, Side.White);
				slideMoveC(sq, sq - 11, Side.White);
				break;
			case SquareType.bR:
				slideMoveC(sq, sq + 12, Side.White);
				slideMoveC(sq, sq + 1, Side.White);
				slideMoveC(sq, sq - 12, Side.White);
				slideMoveC(sq, sq - 1, Side.White);
				break;
			default:
				break;
			}
		}
	}
}
