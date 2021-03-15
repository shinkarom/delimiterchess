import std.stdio,io, std.format;
import data, defines, psqt, attack;

void pushMove(int from, int to, int flag)
{	
	auto data = (from << 8) | to | flag;
	p.list[p.listc[p.ply+1]++].m = data;
}

void pushPawn(int from, int to, int flag)
{
	if(to > H7 || to < A2)
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
	if(p.board[t].type == edge)
		return;		
	if(p.board[t].type == empty)
	{
		pushMove(f, t, mNORM);
	}	
	else if(p.board[t].color == xcol)
	{
		pushMove(f, t, mCAP);
	}	
}

void slideMove(int f, int t, int xcol)
{
	int d = t-f;
	if(p.board[t].type == edge)
		return;
	do
	{
		if(p.board[t].type == empty)
		{
			pushMove(f, t, mNORM);
			t+=d;
		}
		else if(p.board[t].color == xcol)
		{
			pushMove(f, t, mCAP);
			break;			
		}
		else
		{
			break;
		}
	} while(p.board[t].type != edge);
}

void knightMoveC(int f, int t, int xcol)
{
	if(p.board[t].type == edge)
		return;		
	else if(p.board[t].color == xcol)
	{
		pushMove(f, t, mCAP);
	}	
}

void slideMoveC(int f, int t, int xcol)
{
	int d = t-f;
	if(p.board[t].type == edge)
		return;
	do
	{
		if(p.board[t].type == empty)
		{
			t+=d;
		}
		else if(p.board[t].color == xcol)
		{
			pushMove(f, t, mCAP);
			break;			
		}
		else
		{
			break;
		}
	} while(p.board[t].type != edge);	
}

void moveGen()
{
	int tsq;
	p.listc[p.ply+1] = p.listc[p.ply];
	if(p.side == white)
	{
		for(int index = 1; index <= p.pceNum; index++)
		{
			if(p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch(p.board[sq].type)
			{
				case wP:
					tsq = sq+13;
					if(p.board[tsq].color == bpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}
					tsq = sq+11;
					if(p.board[tsq].color == bpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}		
					tsq = sq+12;
					if(p.board[tsq].type == empty)
					{
						pushPawn(sq, tsq, mNORM);
						if(sq < A3 && p.board[tsq+12].type == empty)
						{
							pushMove(sq, (tsq+12), mPST);
						}
					}
					break;
				case wN:
					knightMove(sq, sq+14, bpco);
					knightMove(sq, sq+10, bpco);
					knightMove(sq, sq+25, bpco);
					knightMove(sq, sq+23, bpco);
					knightMove(sq, sq-14, bpco);
					knightMove(sq, sq-10, bpco);
					knightMove(sq, sq-25, bpco);
					knightMove(sq, sq-23, bpco);
					break;
				case wK:
					knightMove(sq, sq+1, bpco);
					knightMove(sq, sq+12, bpco);
					knightMove(sq, sq+11, bpco);
					knightMove(sq, sq+13, bpco);
					knightMove(sq, sq-1, bpco);
					knightMove(sq, sq-12, bpco);
					knightMove(sq, sq-11, bpco);
					knightMove(sq, sq-13, bpco);
					if(sq == E1)
					{
						if(p.castleflags & WKC)
						{
							if(p.board[H1].type == wR && p.board[F1].type == empty && p.board[G1].type == empty)
							{
								if(!isattacked(F1, black) && !isattacked(E1, black) && !isattacked(G1, black))
								{
									pushMove(E1, G1, mCA);
								}
							}
						}
						if(p.castleflags & WQC)
						{
							if(p.board[A1].type == wR && p.board[D1].type == empty && p.board[C1].type == empty && p.board[B1].type == empty)
							{
								if(!isattacked(D1, black) && !isattacked(E1, black) && !isattacked(C1, black))
								{
									pushMove(E1, C1, mCA);
								}
							}
						}
					}
					break;
				case wQ:
					slideMove(sq, sq+13, bpco);
					slideMove(sq, sq+11, bpco);
					slideMove(sq, sq+12, bpco);
					slideMove(sq, sq+1, bpco);
					slideMove(sq, sq-13, bpco);
					slideMove(sq, sq-11, bpco);
					slideMove(sq, sq-12, bpco);
					slideMove(sq, sq-1, bpco);
					break;
				case wB:
					slideMove(sq, sq+13, bpco);
					slideMove(sq, sq+11, bpco);
					slideMove(sq, sq-13, bpco);
					slideMove(sq, sq-11, bpco);
					break;
				case wR:
					slideMove(sq, sq+12, bpco);
					slideMove(sq, sq+1, bpco);
					slideMove(sq, sq-12, bpco);
					slideMove(sq, sq-1, bpco);
					break;
				default:
					break;
			}
		}
	}
	else
	{
		for(int index = 1; index <= p.pceNum; index++)
		{
			if(p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch(p.board[sq].type)
			{
				case bP:
					tsq = sq-13;
					if(p.board[tsq].color == wpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}
					tsq = sq-11;
					if(p.board[tsq].color == wpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}		
					tsq = sq-12;
					if(p.board[tsq].type == empty)
					{
						pushPawn(sq, tsq, mNORM);
						if(sq > H6 && p.board[tsq-12].type == empty)
						{
							pushMove(sq, (tsq-12), mPST);
						}
					}
					break;
				case bN:
					knightMove(sq, sq+14, wpco);
					knightMove(sq, sq+10, wpco);
					knightMove(sq, sq+25, wpco);
					knightMove(sq, sq+23, wpco);
					knightMove(sq, sq-14, wpco);
					knightMove(sq, sq-10, wpco);
					knightMove(sq, sq-25, wpco);
					knightMove(sq, sq-23, wpco);
					break;
				case bK:
					knightMove(sq, sq+1, wpco);
					knightMove(sq, sq+12, wpco);
					knightMove(sq, sq+11, wpco);
					knightMove(sq, sq+13, wpco);
					knightMove(sq, sq-1, wpco);
					knightMove(sq, sq-12, wpco);
					knightMove(sq, sq-11, wpco);
					knightMove(sq, sq-13, wpco);
					if(sq == E8)
					{
						if(p.castleflags & BKC)
						{
							if(p.board[H8].type == bR && p.board[F8].type == empty && p.board[G8].type == empty)
							{
								if(!isattacked(F8, white) && !isattacked(E8, white) && !isattacked(G8, white))
								{
									pushMove(E8 , G8, mCA);
								}
							}
						}
						if(p.castleflags & BQC)
						{
							if(p.board[A8].type == bR && p.board[D8].type == empty && p.board[C8].type == empty && p.board[B8].type == empty)
							{
								if(!isattacked(D8, white) && !isattacked(E8, white) && !isattacked(C8, white))
								{
									pushMove(E8, C8, mCA);
								}
							}
						}					
					}
					break;
				case bQ:
					slideMove(sq, sq+13, wpco);
					slideMove(sq, sq+11, wpco);
					slideMove(sq, sq+12, wpco);
					slideMove(sq, sq+1, wpco);
					slideMove(sq, sq-13, wpco);
					slideMove(sq, sq-11, wpco);
					slideMove(sq, sq-12, wpco);
					slideMove(sq, sq-1, wpco);
					break;
				case bB:
					slideMove(sq, sq+13, wpco);
					slideMove(sq, sq+11, wpco);
					slideMove(sq, sq-13, wpco);
					slideMove(sq, sq-11, wpco);
					break;
				case bR:
					slideMove(sq, sq+12, wpco);
					slideMove(sq, sq+1, wpco);
					slideMove(sq, sq-12, wpco);
					slideMove(sq, sq-1, wpco);
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
	p.listc[p.ply+1] = p.listc[p.ply];
	if(p.side == white)
	{
		for(int index = 1; index <= p.pceNum; index++)
		{
			if(p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch(p.board[sq].type)
			{
				case wP:
					tsq = sq+13;
					if(p.board[tsq].color == bpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}
					tsq = sq+11;
					if(p.board[tsq].color == bpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}		
					break;
				case wN:
					knightMoveC(sq, sq+14, bpco);
					knightMoveC(sq, sq+10, bpco);
					knightMoveC(sq, sq+25, bpco);
					knightMoveC(sq, sq+23, bpco);
					knightMoveC(sq, sq-14, bpco);
					knightMoveC(sq, sq-10, bpco);
					knightMoveC(sq, sq-25, bpco);
					knightMoveC(sq, sq-23, bpco);
					break;
				case wK:
					knightMoveC(sq, sq+1, bpco);
					knightMoveC(sq, sq+12, bpco);
					knightMoveC(sq, sq+11, bpco);
					knightMoveC(sq, sq+13, bpco);
					knightMoveC(sq, sq-1, bpco);
					knightMoveC(sq, sq-12, bpco);
					knightMoveC(sq, sq-11, bpco);
					knightMoveC(sq, sq-13, bpco);
					break;
				case wQ:
					slideMoveC(sq, sq+13, bpco);
					slideMoveC(sq, sq+11, bpco);
					slideMoveC(sq, sq+12, bpco);
					slideMoveC(sq, sq+1, bpco);
					slideMoveC(sq, sq-13, bpco);
					slideMoveC(sq, sq-11, bpco);
					slideMoveC(sq, sq-12, bpco);
					slideMoveC(sq, sq-1, bpco);
					break;
				case wB:
					slideMoveC(sq, sq+13, bpco);
					slideMoveC(sq, sq+11, bpco);
					slideMoveC(sq, sq-13, bpco);
					slideMoveC(sq, sq-11, bpco);
					break;
				case wR:
					slideMoveC(sq, sq+12, bpco);
					slideMoveC(sq, sq+1, bpco);
					slideMoveC(sq, sq-12, bpco);
					slideMoveC(sq, sq-1, bpco);
					break;
				default:
					break;
			}
		}
	}
	else
	{
		for(int index = 1; index <= p.pceNum; index++)
		{
			if(p.pceNumToSq[index] == 0)
				continue;
			int sq = p.pceNumToSq[index];
			switch(p.board[sq].type)
			{
				case bP:
					tsq = sq-13;
					if(p.board[tsq].color == wpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}
					tsq = sq-11;
					if(p.board[tsq].color == wpco)
					{
						pushPawn(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMove(sq, tsq, mPEP);
					}		
					break;
				case bN:
					knightMoveC(sq, sq+14, wpco);
					knightMoveC(sq, sq+10, wpco);
					knightMoveC(sq, sq+25, wpco);
					knightMoveC(sq, sq+23, wpco);
					knightMoveC(sq, sq-14, wpco);
					knightMoveC(sq, sq-10, wpco);
					knightMoveC(sq, sq-25, wpco);
					knightMoveC(sq, sq-23, wpco);
					break;
				case bK:
					knightMoveC(sq, sq+1, wpco);
					knightMoveC(sq, sq+12, wpco);
					knightMoveC(sq, sq+11, wpco);
					knightMoveC(sq, sq+13, wpco);
					knightMoveC(sq, sq-1, wpco);
					knightMoveC(sq, sq-12, wpco);
					knightMoveC(sq, sq-11, wpco);
					knightMoveC(sq, sq-13, wpco);
					break;
				case bQ:
					slideMoveC(sq, sq+13, wpco);
					slideMoveC(sq, sq+11, wpco);
					slideMoveC(sq, sq+12, wpco);
					slideMoveC(sq, sq+1, wpco);
					slideMoveC(sq, sq-13, wpco);
					slideMoveC(sq, sq-11, wpco);
					slideMoveC(sq, sq-12, wpco);
					slideMoveC(sq, sq-1, wpco);
					break;
				case bB:
					slideMoveC(sq, sq+13, wpco);
					slideMoveC(sq, sq+11, wpco);
					slideMoveC(sq, sq-13, wpco);
					slideMoveC(sq, sq-11, wpco);
					break;
				case bR:
					slideMoveC(sq, sq+12, wpco);
					slideMoveC(sq, sq+1, wpco);
					slideMoveC(sq, sq-12, wpco);
					slideMoveC(sq, sq-1, wpco);
					break;
				default:
					break;
			}
		}		
	}	
}