import std.stdio, io, std.format;
import data, defines, psqt, attack;

void pushMove(int from, int to, int flag)
{
	auto data = (from << 8) | to | flag;
	p.list[p.listc[p.ply + 1]++].m = data;
}

void pushPawn(int from, int to, int flag)
{
	if (to > Square.H7 || to < Square.A2)
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
	else if (SquareTypeSide[p.board[t]] == xSide)
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
		else if (SquareTypeSide[p.board[t]] == xSide)
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
	else if (SquareTypeSide[p.board[t]] == xSide)
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
		else if (SquareTypeSide[p.board[t]] == xSide)
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
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 12;
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq < Square.A3 && p.board[tsq + 12] == SquareType.Empty)
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
				if (sq == Square.E1)
				{
					if (p.castleFlags & WKC)
					{
						if (p.board[Square.H1] == SquareType.wR && p.board[Square.F1] == SquareType.Empty
								&& p.board[Square.G1] == SquareType.Empty)
						{
							if (!isAttacked(Square.F1, Side.Black) && !isAttacked(Square.E1,
									Side.Black) && !isAttacked(Square.G1, Side.Black))
							{
								pushMove(Square.E1, Square.G1, mCA);
							}
						}
					}
					if (p.castleFlags & WQC)
					{
						if (p.board[Square.A1] == SquareType.wR && p.board[Square.D1] == SquareType.Empty
								&& p.board[Square.C1] == SquareType.Empty && p.board[Square.B1] == SquareType.Empty)
						{
							if (!isAttacked(Square.D1, Side.Black) && !isAttacked(Square.E1,
									Side.Black) && !isAttacked(Square.C1, Side.Black))
							{
								pushMove(Square.E1, Square.C1, mCA);
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
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 12;
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq > Square.H6 && p.board[tsq - 12] == SquareType.Empty)
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
				if (sq == Square.E8)
				{
					if (p.castleFlags & BKC)
					{
						if (p.board[Square.H8] == SquareType.bR && p.board[Square.F8] == SquareType.Empty
								&& p.board[Square.G8] == SquareType.Empty)
						{
							if (!isAttacked(Square.F8, Side.White) && !isAttacked(Square.E8,
									Side.White) && !isAttacked(Square.G8, Side.White))
							{
								pushMove(Square.E8, Square.G8, mCA);
							}
						}
					}
					if (p.castleFlags & BQC)
					{
						if (p.board[Square.A8] == SquareType.bR && p.board[Square.D8] == SquareType.Empty
								&& p.board[Square.C8] == SquareType.Empty && p.board[Square.B8] == SquareType.Empty)
						{
							if (!isAttacked(Square.D8, Side.White) && !isAttacked(Square.E8,
									Side.White) && !isAttacked(Square.C8, Side.White))
							{
								pushMove(Square.E8, Square.C8, mCA);
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
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
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
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
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
