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

void knightMove(int f, int t, int xcol)
{
	if (p.board[t].type == edge)
		return;
	if (p.board[t].type == empty)
	{
		pushMove(f, t, mNORM);
	}
	else if (p.board[t].color == xcol)
	{
		pushMove(f, t, mCAP);
	}
}

void slideMove(int f, int t, int xcol)
{
	int d = t - f;
	if (p.board[t].type == edge)
		return;
	do
	{
		if (p.board[t].type == empty)
		{
			pushMove(f, t, mNORM);
			t += d;
		}
		else if (p.board[t].color == xcol)
		{
			pushMove(f, t, mCAP);
			break;
		}
		else
		{
			break;
		}
	}
	while (p.board[t].type != edge);
}

void knightMoveC(int f, int t, int xcol)
{
	if (p.board[t].type == edge)
		return;
	else if (p.board[t].color == xcol)
	{
		pushMove(f, t, mCAP);
	}
}

void slideMoveC(int f, int t, int xcol)
{
	int d = t - f;
	if (p.board[t].type == edge)
		return;
	do
	{
		if (p.board[t].type == empty)
		{
			t += d;
		}
		else if (p.board[t].color == xcol)
		{
			pushMove(f, t, mCAP);
			break;
		}
		else
		{
			break;
		}
	}
	while (p.board[t].type != edge);
}

void moveGen()
{
	int tsq;
	p.listc[p.ply + 1] = p.listc[p.ply];
	if (p.side == white)
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch (p.board[sq].type)
			{
			case wP:
				tsq = sq + 13;
				if (p.board[tsq].color == PieceColor.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (p.board[tsq].color == PieceColor.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 12;
				if (p.board[tsq].type == empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq < A3 && p.board[tsq + 12].type == empty)
					{
						pushMove(sq, (tsq + 12), mPST);
					}
				}
				break;
			case wN:
				knightMove(sq, sq + 14, PieceColor.Black);
				knightMove(sq, sq + 10, PieceColor.Black);
				knightMove(sq, sq + 25, PieceColor.Black);
				knightMove(sq, sq + 23, PieceColor.Black);
				knightMove(sq, sq - 14, PieceColor.Black);
				knightMove(sq, sq - 10, PieceColor.Black);
				knightMove(sq, sq - 25, PieceColor.Black);
				knightMove(sq, sq - 23, PieceColor.Black);
				break;
			case wK:
				knightMove(sq, sq + 1, PieceColor.Black);
				knightMove(sq, sq + 12, PieceColor.Black);
				knightMove(sq, sq + 11, PieceColor.Black);
				knightMove(sq, sq + 13, PieceColor.Black);
				knightMove(sq, sq - 1, PieceColor.Black);
				knightMove(sq, sq - 12, PieceColor.Black);
				knightMove(sq, sq - 11, PieceColor.Black);
				knightMove(sq, sq - 13, PieceColor.Black);
				if (sq == E1)
				{
					if (p.castleflags & WKC)
					{
						if (p.board[H1].type == wR && p.board[F1].type == empty
								&& p.board[G1].type == empty)
						{
							if (!isAttacked(F1, black) && !isAttacked(E1,
									black) && !isAttacked(G1, black))
							{
								pushMove(E1, G1, mCA);
							}
						}
					}
					if (p.castleflags & WQC)
					{
						if (p.board[A1].type == wR && p.board[D1].type == empty
								&& p.board[C1].type == empty && p.board[B1].type == empty)
						{
							if (!isAttacked(D1, black) && !isAttacked(E1,
									black) && !isAttacked(C1, black))
							{
								pushMove(E1, C1, mCA);
							}
						}
					}
				}
				break;
			case wQ:
				slideMove(sq, sq + 13, PieceColor.Black);
				slideMove(sq, sq + 11, PieceColor.Black);
				slideMove(sq, sq + 12, PieceColor.Black);
				slideMove(sq, sq + 1, PieceColor.Black);
				slideMove(sq, sq - 13, PieceColor.Black);
				slideMove(sq, sq - 11, PieceColor.Black);
				slideMove(sq, sq - 12, PieceColor.Black);
				slideMove(sq, sq - 1, PieceColor.Black);
				break;
			case wB:
				slideMove(sq, sq + 13, PieceColor.Black);
				slideMove(sq, sq + 11, PieceColor.Black);
				slideMove(sq, sq - 13, PieceColor.Black);
				slideMove(sq, sq - 11, PieceColor.Black);
				break;
			case wR:
				slideMove(sq, sq + 12, PieceColor.Black);
				slideMove(sq, sq + 1, PieceColor.Black);
				slideMove(sq, sq - 12, PieceColor.Black);
				slideMove(sq, sq - 1, PieceColor.Black);
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
			switch (p.board[sq].type)
			{
			case bP:
				tsq = sq - 13;
				if (p.board[tsq].color == PieceColor.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (p.board[tsq].color == PieceColor.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 12;
				if (p.board[tsq].type == empty)
				{
					pushPawn(sq, tsq, mNORM);
					if (sq > H6 && p.board[tsq - 12].type == empty)
					{
						pushMove(sq, (tsq - 12), mPST);
					}
				}
				break;
			case bN:
				knightMove(sq, sq + 14, PieceColor.White);
				knightMove(sq, sq + 10, PieceColor.White);
				knightMove(sq, sq + 25, PieceColor.White);
				knightMove(sq, sq + 23, PieceColor.White);
				knightMove(sq, sq - 14, PieceColor.White);
				knightMove(sq, sq - 10, PieceColor.White);
				knightMove(sq, sq - 25, PieceColor.White);
				knightMove(sq, sq - 23, PieceColor.White);
				break;
			case bK:
				knightMove(sq, sq + 1, PieceColor.White);
				knightMove(sq, sq + 12, PieceColor.White);
				knightMove(sq, sq + 11, PieceColor.White);
				knightMove(sq, sq + 13, PieceColor.White);
				knightMove(sq, sq - 1, PieceColor.White);
				knightMove(sq, sq - 12, PieceColor.White);
				knightMove(sq, sq - 11, PieceColor.White);
				knightMove(sq, sq - 13, PieceColor.White);
				if (sq == E8)
				{
					if (p.castleflags & BKC)
					{
						if (p.board[H8].type == bR && p.board[F8].type == empty
								&& p.board[G8].type == empty)
						{
							if (!isAttacked(F8, white) && !isAttacked(E8,
									white) && !isAttacked(G8, white))
							{
								pushMove(E8, G8, mCA);
							}
						}
					}
					if (p.castleflags & BQC)
					{
						if (p.board[A8].type == bR && p.board[D8].type == empty
								&& p.board[C8].type == empty && p.board[B8].type == empty)
						{
							if (!isAttacked(D8, white) && !isAttacked(E8,
									white) && !isAttacked(C8, white))
							{
								pushMove(E8, C8, mCA);
							}
						}
					}
				}
				break;
			case bQ:
				slideMove(sq, sq + 13, PieceColor.White);
				slideMove(sq, sq + 11, PieceColor.White);
				slideMove(sq, sq + 12, PieceColor.White);
				slideMove(sq, sq + 1, PieceColor.White);
				slideMove(sq, sq - 13, PieceColor.White);
				slideMove(sq, sq - 11, PieceColor.White);
				slideMove(sq, sq - 12, PieceColor.White);
				slideMove(sq, sq - 1, PieceColor.White);
				break;
			case bB:
				slideMove(sq, sq + 13, PieceColor.White);
				slideMove(sq, sq + 11, PieceColor.White);
				slideMove(sq, sq - 13, PieceColor.White);
				slideMove(sq, sq - 11, PieceColor.White);
				break;
			case bR:
				slideMove(sq, sq + 12, PieceColor.White);
				slideMove(sq, sq + 1, PieceColor.White);
				slideMove(sq, sq - 12, PieceColor.White);
				slideMove(sq, sq - 1, PieceColor.White);
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
	if (p.side == white)
	{
		for (int index = 1; index <= p.pceNum; index++)
		{
			if (p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch (p.board[sq].type)
			{
			case wP:
				tsq = sq + 13;
				if (p.board[tsq].color == PieceColor.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq + 11;
				if (p.board[tsq].color == PieceColor.Black)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				break;
			case wN:
				knightMoveC(sq, sq + 14, PieceColor.Black);
				knightMoveC(sq, sq + 10, PieceColor.Black);
				knightMoveC(sq, sq + 25, PieceColor.Black);
				knightMoveC(sq, sq + 23, PieceColor.Black);
				knightMoveC(sq, sq - 14, PieceColor.Black);
				knightMoveC(sq, sq - 10, PieceColor.Black);
				knightMoveC(sq, sq - 25, PieceColor.Black);
				knightMoveC(sq, sq - 23, PieceColor.Black);
				break;
			case wK:
				knightMoveC(sq, sq + 1, PieceColor.Black);
				knightMoveC(sq, sq + 12, PieceColor.Black);
				knightMoveC(sq, sq + 11, PieceColor.Black);
				knightMoveC(sq, sq + 13, PieceColor.Black);
				knightMoveC(sq, sq - 1, PieceColor.Black);
				knightMoveC(sq, sq - 12, PieceColor.Black);
				knightMoveC(sq, sq - 11, PieceColor.Black);
				knightMoveC(sq, sq - 13, PieceColor.Black);
				break;
			case wQ:
				slideMoveC(sq, sq + 13, PieceColor.Black);
				slideMoveC(sq, sq + 11, PieceColor.Black);
				slideMoveC(sq, sq + 12, PieceColor.Black);
				slideMoveC(sq, sq + 1, PieceColor.Black);
				slideMoveC(sq, sq - 13, PieceColor.Black);
				slideMoveC(sq, sq - 11, PieceColor.Black);
				slideMoveC(sq, sq - 12, PieceColor.Black);
				slideMoveC(sq, sq - 1, PieceColor.Black);
				break;
			case wB:
				slideMoveC(sq, sq + 13, PieceColor.Black);
				slideMoveC(sq, sq + 11, PieceColor.Black);
				slideMoveC(sq, sq - 13, PieceColor.Black);
				slideMoveC(sq, sq - 11, PieceColor.Black);
				break;
			case wR:
				slideMoveC(sq, sq + 12, PieceColor.Black);
				slideMoveC(sq, sq + 1, PieceColor.Black);
				slideMoveC(sq, sq - 12, PieceColor.Black);
				slideMoveC(sq, sq - 1, PieceColor.Black);
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
			switch (p.board[sq].type)
			{
			case bP:
				tsq = sq - 13;
				if (p.board[tsq].color == PieceColor.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				tsq = sq - 11;
				if (p.board[tsq].color == PieceColor.White)
				{
					pushPawn(sq, tsq, mCAP);
				}
				if (p.en_pas == tsq)
				{
					pushMove(sq, tsq, mPEP);
				}
				break;
			case bN:
				knightMoveC(sq, sq + 14, PieceColor.White);
				knightMoveC(sq, sq + 10, PieceColor.White);
				knightMoveC(sq, sq + 25, PieceColor.White);
				knightMoveC(sq, sq + 23, PieceColor.White);
				knightMoveC(sq, sq - 14, PieceColor.White);
				knightMoveC(sq, sq - 10, PieceColor.White);
				knightMoveC(sq, sq - 25, PieceColor.White);
				knightMoveC(sq, sq - 23, PieceColor.White);
				break;
			case bK:
				knightMoveC(sq, sq + 1, PieceColor.White);
				knightMoveC(sq, sq + 12, PieceColor.White);
				knightMoveC(sq, sq + 11, PieceColor.White);
				knightMoveC(sq, sq + 13, PieceColor.White);
				knightMoveC(sq, sq - 1, PieceColor.White);
				knightMoveC(sq, sq - 12, PieceColor.White);
				knightMoveC(sq, sq - 11, PieceColor.White);
				knightMoveC(sq, sq - 13, PieceColor.White);
				break;
			case bQ:
				slideMoveC(sq, sq + 13, PieceColor.White);
				slideMoveC(sq, sq + 11, PieceColor.White);
				slideMoveC(sq, sq + 12, PieceColor.White);
				slideMoveC(sq, sq + 1, PieceColor.White);
				slideMoveC(sq, sq - 13, PieceColor.White);
				slideMoveC(sq, sq - 11, PieceColor.White);
				slideMoveC(sq, sq - 12, PieceColor.White);
				slideMoveC(sq, sq - 1, PieceColor.White);
				break;
			case bB:
				slideMoveC(sq, sq + 13, PieceColor.White);
				slideMoveC(sq, sq + 11, PieceColor.White);
				slideMoveC(sq, sq - 13, PieceColor.White);
				slideMoveC(sq, sq - 11, PieceColor.White);
				break;
			case bR:
				slideMoveC(sq, sq + 12, PieceColor.White);
				slideMoveC(sq, sq + 1, PieceColor.White);
				slideMoveC(sq, sq - 12, PieceColor.White);
				slideMoveC(sq, sq - 1, PieceColor.White);
				break;
			default:
				break;
			}
		}
	}
}
