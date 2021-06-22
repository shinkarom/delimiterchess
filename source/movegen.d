import std.stdio, io, std.format;
import data, defines, psqt, attack;

void pushMove(Square from, Square to, int flag)
{
	auto data = (from << 8) | to | flag;
	p.list[p.listc[p.ply + 1]++].m = data;
}

void pushPawn(Square from, Square to, int flag)
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

void knightMove(Square from, int dir, Side xSide)
{
	Square to = cast(Square)(from + dir);
	if (p.board[to] == SquareType.Edge)
		return;
	if (p.board[to] == SquareType.Empty)
	{
		pushMove(from, to, mNORM);
	}
	else if (SquareTypeSide[p.board[to]] == xSide)
	{
		pushMove(from, to, mCAP);
	}
}

void slideMove(Square from, int dir, Side xSide)
{
	Square to = cast(Square)(from + dir);
	if (p.board[to] == SquareType.Edge)
		return;
	do
	{
		if (p.board[to] == SquareType.Empty)
		{
			pushMove(from, to, mNORM);
			to += dir;
		}
		else if (SquareTypeSide[p.board[to]] == xSide)
		{
			pushMove(from, to, mCAP);
			break;
		}
		else
		{
			break;
		}
	}
	while (p.board[to] != SquareType.Edge);
}

void knightMoveC(Square from, int dir, Side xSide)
{
	Square to = cast(Square)(from + dir);
	if (p.board[to] == SquareType.Edge)
		return;
	else if (SquareTypeSide[p.board[to]] == xSide)
	{
		pushMove(from, to, mCAP);
	}
}

void slideMoveC(Square from, int dir, Side xSide)
{
	Square to = cast(Square)(from + dir);
	if (p.board[to] == SquareType.Edge)
		return;
	do
	{
		if (p.board[to] == SquareType.Empty)
		{
			to += dir;
		}
		else if (SquareTypeSide[p.board[to]] == xSide)
		{
			pushMove(from, to, mCAP);
			break;
		}
		else
		{
			break;
		}
	}
	while (p.board[to] != SquareType.Edge);
}

void moveGen()
{
	Square tsq;
	p.listc[p.ply + 1] = p.listc[p.ply];
	if (p.side == Side.White)
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			Square sq = cast(Square) p.pceNumToSq[index];
			switch (p.board[sq])
			{
			case SquareType.wP:
				tsq = cast(Square)(sq + 13);
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = cast(Square)(sq + 11);
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = cast(Square)(sq + 12);
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq < Square.A3 && p.board[tsq + 12] == SquareType.Empty)
					{
						pushMove(sq, cast(Square)(tsq + 12), mPST);
					}
				}
				break;
			case SquareType.wN:
				knightMove(sq, 14, Side.Black);
				knightMove(sq, 10, Side.Black);
				knightMove(sq, 25, Side.Black);
				knightMove(sq, 23, Side.Black);
				knightMove(sq, -14, Side.Black);
				knightMove(sq, -10, Side.Black);
				knightMove(sq, -25, Side.Black);
				knightMove(sq, -23, Side.Black);
				break;
			case SquareType.wK:
				knightMove(sq, 1, Side.Black);
				knightMove(sq, 12, Side.Black);
				knightMove(sq, 11, Side.Black);
				knightMove(sq, 13, Side.Black);
				knightMove(sq, -1, Side.Black);
				knightMove(sq, -12, Side.Black);
				knightMove(sq, -11, Side.Black);
				knightMove(sq, -13, Side.Black);
				if (sq == Square.E1)
				{
					if (p.castleFlags & WKC)
					{
						if (p.board[Square.H1] == SquareType.wR
								&& p.board[Square.F1] == SquareType.Empty
								&& p.board[Square.G1] == SquareType.Empty)
						{
							if (!p.isAttacked(Square.F1, Side.Black)
									&& !p.isAttacked(Square.E1, Side.Black)
									&& !p.isAttacked(Square.G1, Side.Black))
							{
								pushMove(Square.E1, Square.G1, mCA);
							}
						}
					}
					if (p.castleFlags & WQC)
					{
						if (p.board[Square.A1] == SquareType.wR
								&& p.board[Square.D1] == SquareType.Empty
								&& p.board[Square.C1] == SquareType.Empty
								&& p.board[Square.B1] == SquareType.Empty)
						{
							if (!p.isAttacked(Square.D1, Side.Black)
									&& !p.isAttacked(Square.E1, Side.Black)
									&& !p.isAttacked(Square.C1, Side.Black))
							{
								pushMove(Square.E1, Square.C1, mCA);
							}
						}
					}
				}
				break;
			case SquareType.wQ:
				slideMove(sq, 13, Side.Black);
				slideMove(sq, 11, Side.Black);
				slideMove(sq, 12, Side.Black);
				slideMove(sq, 1, Side.Black);
				slideMove(sq, -13, Side.Black);
				slideMove(sq, -11, Side.Black);
				slideMove(sq, -12, Side.Black);
				slideMove(sq, -1, Side.Black);
				break;
			case SquareType.wB:
				slideMove(sq, 13, Side.Black);
				slideMove(sq, 11, Side.Black);
				slideMove(sq, - 13, Side.Black);
				slideMove(sq, - 11, Side.Black);
				break;
			case SquareType.wR:
				slideMove(sq, 12, Side.Black);
				slideMove(sq, 1, Side.Black);
				slideMove(sq, -12, Side.Black);
				slideMove(sq, -1, Side.Black);
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
			Square sq = cast(Square)(p.pceNumToSq[index]);
			switch (p.board[sq])
			{
			case SquareType.bP:
				tsq = cast(Square)(sq - 13);
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = cast(Square)(sq - 11);
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = cast(Square)(sq - 12);
				if (p.board[tsq] == SquareType.Empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq > Square.H6 && p.board[tsq - 12] == SquareType.Empty)
					{
						pushMove(sq, cast(Square)(tsq - 12), mPST);
					}
				}
				break;
			case SquareType.bN:
				knightMove(sq, 14, Side.White);
				knightMove(sq, 10, Side.White);
				knightMove(sq, 25, Side.White);
				knightMove(sq, 23, Side.White);
				knightMove(sq, -14, Side.White);
				knightMove(sq, -10, Side.White);
				knightMove(sq, -25, Side.White);
				knightMove(sq, -23, Side.White);
				break;
			case SquareType.bK:
				knightMove(sq, 1, Side.White);
				knightMove(sq, 12, Side.White);
				knightMove(sq, 11, Side.White);
				knightMove(sq, 13, Side.White);
				knightMove(sq, -1, Side.White);
				knightMove(sq, -12, Side.White);
				knightMove(sq, -11, Side.White);
				knightMove(sq, -13, Side.White);
				if (sq == Square.E8)
				{
					if (p.castleFlags & BKC)
					{
						if (p.board[Square.H8] == SquareType.bR
								&& p.board[Square.F8] == SquareType.Empty
								&& p.board[Square.G8] == SquareType.Empty)
						{
							if (!p.isAttacked(Square.F8, Side.White)
									&& !p.isAttacked(Square.E8, Side.White)
									&& !p.isAttacked(Square.G8, Side.White))
							{
								pushMove(Square.E8, Square.G8, mCA);
							}
						}
					}
					if (p.castleFlags & BQC)
					{
						if (p.board[Square.A8] == SquareType.bR
								&& p.board[Square.D8] == SquareType.Empty
								&& p.board[Square.C8] == SquareType.Empty
								&& p.board[Square.B8] == SquareType.Empty)
						{
							if (!p.isAttacked(Square.D8, Side.White)
									&& !p.isAttacked(Square.E8, Side.White)
									&& !p.isAttacked(Square.C8, Side.White))
							{
								pushMove(Square.E8, Square.C8, mCA);
							}
						}
					}
				}
				break;
			case SquareType.bQ:
				slideMove(sq, 13, Side.White);
				slideMove(sq, 11, Side.White);
				slideMove(sq, 12, Side.White);
				slideMove(sq, 1, Side.White);
				slideMove(sq, -13, Side.White);
				slideMove(sq, -11, Side.White);
				slideMove(sq, -12, Side.White);
				slideMove(sq, -1, Side.White);
				break;
			case SquareType.bB:
				slideMove(sq, 13, Side.White);
				slideMove(sq, 11, Side.White);
				slideMove(sq, -13, Side.White);
				slideMove(sq, -11, Side.White);
				break;
			case SquareType.bR:
				slideMove(sq, 12, Side.White);
				slideMove(sq, 1, Side.White);
				slideMove(sq, -12, Side.White);
				slideMove(sq, -1, Side.White);
				break;
			default:
				break;
			}
		}
	}
}

void capGen()
{
	Square tsq;
	p.listc[p.ply + 1] = p.listc[p.ply];
	if (p.side == Side.White)
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			Square sq = cast(Square)(p.pceNumToSq[index]);
			switch (p.board[sq])
			{
			case SquareType.wP:
				tsq = cast(Square)(sq + 13);
				if (SquareTypeSide[p.board[tsq]] == Side.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = cast(Square)(sq + 11);
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
				knightMoveC(sq, 14, Side.Black);
				knightMoveC(sq, 10, Side.Black);
				knightMoveC(sq, 25, Side.Black);
				knightMoveC(sq, 23, Side.Black);
				knightMoveC(sq, -14, Side.Black);
				knightMoveC(sq, -10, Side.Black);
				knightMoveC(sq, -25, Side.Black);
				knightMoveC(sq, -23, Side.Black);
				break;
			case SquareType.wK:
				knightMoveC(sq, 1, Side.Black);
				knightMoveC(sq, 12, Side.Black);
				knightMoveC(sq, 11, Side.Black);
				knightMoveC(sq, 13, Side.Black);
				knightMoveC(sq, -1, Side.Black);
				knightMoveC(sq, -12, Side.Black);
				knightMoveC(sq, -11, Side.Black);
				knightMoveC(sq, -13, Side.Black);
				break;
			case SquareType.wQ:
				slideMoveC(sq, 13, Side.Black);
				slideMoveC(sq, 11, Side.Black);
				slideMoveC(sq, 12, Side.Black);
				slideMoveC(sq, 1, Side.Black);
				slideMoveC(sq, -13, Side.Black);
				slideMoveC(sq, -11, Side.Black);
				slideMoveC(sq, -12, Side.Black);
				slideMoveC(sq, -1, Side.Black);
				break;
			case SquareType.wB:
				slideMoveC(sq, 13, Side.Black);
				slideMoveC(sq, 11, Side.Black);
				slideMoveC(sq, -13, Side.Black);
				slideMoveC(sq, -11, Side.Black);
				break;
			case SquareType.wR:
				slideMoveC(sq, 12, Side.Black);
				slideMoveC(sq, 1, Side.Black);
				slideMoveC(sq, -12, Side.Black);
				slideMoveC(sq, -1, Side.Black);
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
			Square sq = cast(Square)(p.pceNumToSq[index]);
			switch (p.board[sq])
			{
			case SquareType.bP:
				tsq = cast(Square)(sq - 13);
				if (SquareTypeSide[p.board[tsq]] == Side.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.enPas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = cast(Square)(sq - 11);
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
				knightMoveC(sq, 14, Side.White);
				knightMoveC(sq, 10, Side.White);
				knightMoveC(sq, 25, Side.White);
				knightMoveC(sq, 23, Side.White);
				knightMoveC(sq, -14, Side.White);
				knightMoveC(sq, -10, Side.White);
				knightMoveC(sq, -25, Side.White);
				knightMoveC(sq, -23, Side.White);
				break;
			case SquareType.bK:
				knightMoveC(sq, 1, Side.White);
				knightMoveC(sq, 12, Side.White);
				knightMoveC(sq, 11, Side.White);
				knightMoveC(sq, 13, Side.White);
				knightMoveC(sq, -1, Side.White);
				knightMoveC(sq, -12, Side.White);
				knightMoveC(sq, -11, Side.White);
				knightMoveC(sq, -13, Side.White);
				break;
			case SquareType.bQ:
				slideMoveC(sq, 13, Side.White);
				slideMoveC(sq, 11, Side.White);
				slideMoveC(sq, 12, Side.White);
				slideMoveC(sq, 1, Side.White);
				slideMoveC(sq, -13, Side.White);
				slideMoveC(sq, -11, Side.White);
				slideMoveC(sq, -12, Side.White);
				slideMoveC(sq, -1, Side.White);
				break;
			case SquareType.bB:
				slideMoveC(sq, 13, Side.White);
				slideMoveC(sq, 11, Side.White);
				slideMoveC(sq, -13, Side.White);
				slideMoveC(sq, -11, Side.White);
				break;
			case SquareType.bR:
				slideMoveC(sq, 12, Side.White);
				slideMoveC(sq, 1, Side.White);
				slideMoveC(sq, -12, Side.White);
				slideMoveC(sq, -1, Side.White);
				break;
			default:
				break;
			}
		}
	}
}
