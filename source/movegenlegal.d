import data, defines, attack;
	import std.stdio;
	
void pushMoveLegal(int from, int to, int flag)
{
	Piece holdme;
	int data = (from << 8) | to | flag;
	if(!makeQuick(data, holdme))
	{
		p.list[p.listc[p.ply+1]++].m = data;
	}
	takeQuick(data, holdme);
}

void pushPawnLegal(int from, int to, int flag)
{
	import std.stdio;	
	if(to > H7 || to < A2)
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

void knightMoveLegal(int f, int t, int xcol)
{
	if(p.board[t].type == edge)
		return;
	else if(p.board[t].type == empty)
	{
		pushMoveLegal(f, t, mNORM);
	}
	else if(p.board[t].color == xcol)
	{
		pushMoveLegal(f, t, mCAP);
	}	
}

void slideMoveLegal(int f, int t, int xcol)
{
	int d = t-f;
	if(p.board[t].type == edge)
		return;
	do
	{
		if(p.board[t].type == empty)
		{
			pushMoveLegal(f, t, mNORM);
			t+=d;
		}
		else if (p.board[t].color == xcol)
		{
			pushMoveLegal(f, t, mCAP);
			break;
		}
		else 
			break;
	} while(p.board[t].type != edge);
}

void moveGenLegal()
{
	int tsq;
	p.listc[p.ply+1] = p.listc[p.ply];
	
	if(p.side == white)
	{
		import std.stdio;
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
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq+11;
					if(p.board[tsq].color == bpco)
					{
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq+12;
					if(p.board[tsq].type == empty)
					{
						pushPawnLegal(sq, tsq, mNORM);
						if(sq < A3 && p.board[tsq+12].type == empty)
						{
							pushMoveLegal(sq, (tsq+12), mPST);
						}
					}
					break;
				case wN:
					knightMoveLegal(sq, sq+14, bpco);
					knightMoveLegal(sq, sq+10, bpco);
					knightMoveLegal(sq, sq+25, bpco);
					knightMoveLegal(sq, sq+23, bpco);
					knightMoveLegal(sq, sq-14, bpco);
					knightMoveLegal(sq, sq-10, bpco);
					knightMoveLegal(sq, sq-25, bpco);
					knightMoveLegal(sq, sq-23, bpco);
					break;
				case wK:
					knightMoveLegal(sq, sq+1, bpco);
					knightMoveLegal(sq, sq+12, bpco);
					knightMoveLegal(sq, sq+11, bpco);
					knightMoveLegal(sq, sq+13, bpco);
					knightMoveLegal(sq, sq-1, bpco);
					knightMoveLegal(sq, sq-12, bpco);
					knightMoveLegal(sq, sq-11, bpco);
					knightMoveLegal(sq, sq-13, bpco);
					if(sq == E1)
					{
						if(p.castleflags & 8)
						{
							if(p.board[H1].type == wR && p.board[F1].type == empty && p.board[G1].type == empty)
							{
								if(!isattacked(F1, black) && !isattacked(E1, black) && !isattacked(G1, black))
								{
									pushMoveLegal(E1, G1, mCA);
								}
							}
						}
						if(p.castleflags & 4)
						{
							if(p.board[A1].type == wR && p.board[D1].type == empty && p.board[C1].type == empty && p.board[B1].type == empty)
							{
								if(!isattacked(D1, black) && !isattacked(E1, black) && !isattacked(C1, black))
								{
									pushMoveLegal(E1, C1, mCA);
								}
							}
						}
					}
					break;
				case wQ:
					slideMoveLegal(sq, sq+13, bpco);
					slideMoveLegal(sq, sq+11, bpco);
					slideMoveLegal(sq, sq-13, bpco);
					slideMoveLegal(sq, sq-11, bpco);
					slideMoveLegal(sq, sq+12, bpco);
					slideMoveLegal(sq, sq+1, bpco);
					slideMoveLegal(sq, sq-12, bpco);
					slideMoveLegal(sq, sq-1, bpco);
					break;
				case wB:
					slideMoveLegal(sq, sq+13, bpco);
					slideMoveLegal(sq, sq+11, bpco);
					slideMoveLegal(sq, sq-13, bpco);
					slideMoveLegal(sq, sq-11, bpco);
					break;
				case wR:
					slideMoveLegal(sq, sq+12, bpco);
					slideMoveLegal(sq, sq+1, bpco);
					slideMoveLegal(sq, sq-12, bpco);
					slideMoveLegal(sq, sq-1, bpco);
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
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq-11;
					if(p.board[tsq].color == wpco)
					{
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq-12;
					if(p.board[tsq].type == empty)
					{
						pushPawnLegal(sq, tsq, mNORM);
						if(sq < A3 && p.board[tsq+12].type == empty)
						{
							pushMoveLegal(sq, (tsq-12), mPST);
						}
					}
					break;
				case bN:
					knightMoveLegal(sq, sq+14, wpco);
					knightMoveLegal(sq, sq+10, wpco);
					knightMoveLegal(sq, sq+25, wpco);
					knightMoveLegal(sq, sq+23, wpco);
					knightMoveLegal(sq, sq-14, wpco);
					knightMoveLegal(sq, sq-10, wpco);
					knightMoveLegal(sq, sq-25, wpco);
					knightMoveLegal(sq, sq-23, wpco);
					break;
				case bK:
					knightMoveLegal(sq, sq+1, wpco);
					knightMoveLegal(sq, sq+12, wpco);
					knightMoveLegal(sq, sq+11, wpco);
					knightMoveLegal(sq, sq+13, wpco);
					knightMoveLegal(sq, sq-1, wpco);
					knightMoveLegal(sq, sq-12, wpco);
					knightMoveLegal(sq, sq-11, wpco);
					knightMoveLegal(sq, sq-13, wpco);
					if(sq == E8)
					{
						if(p.castleflags & 2)
						{
							if(p.board[H8].type == bR && p.board[F8].type == empty && p.board[G8].type == empty)
							{
								if(!isattacked(F8, white) && !isattacked(E8, white) && !isattacked(G8, white))
								{
									pushMoveLegal(E8, G8, mCA);
								}
							}
						}
						if(p.castleflags & 1)
						{
							if(p.board[A8].type == bR && p.board[D8].type == empty && p.board[C8].type == empty && p.board[B8].type == empty)
							{
								if(!isattacked(D8, white) && !isattacked(E8, white) && !isattacked(C8, white))
								{
									pushMoveLegal(E8, C8, mCA);
								}
							}
						}
					}
					break;
				case bQ:
					slideMoveLegal(sq, sq+13, wpco);
					slideMoveLegal(sq, sq+11, wpco);
					slideMoveLegal(sq, sq-13, wpco);
					slideMoveLegal(sq, sq-11, wpco);
					slideMoveLegal(sq, sq+12, wpco);
					slideMoveLegal(sq, sq+1, wpco);
					slideMoveLegal(sq, sq-12, wpco);
					slideMoveLegal(sq, sq-1, wpco);
					break;
				case bB:
					slideMoveLegal(sq, sq+13, wpco);
					slideMoveLegal(sq, sq+11, wpco);
					slideMoveLegal(sq, sq-13, wpco);
					slideMoveLegal(sq, sq-11, wpco);
					break;
				case bR:
					slideMoveLegal(sq, sq+12, wpco);
					slideMoveLegal(sq, sq+1, wpco);
					slideMoveLegal(sq, sq-12, wpco);
					slideMoveLegal(sq, sq-1, wpco);
					break;
				default:
					break;
			}
		}		
	}
}

bool makeQuick(int m, ref Piece holdme)
{
	int from = FROM(m);
	int to = TO(m);
	int flag = FLAG(m);
	
	bool r = false;
	
	holdme.type = p.board[to].type;
	holdme.color = p.board[to].color;
	
	p.board[to] = p.board[from];
	
	p.board[from].type = empty;
	p.board[from].color = npco;
	
	if(p.side == white && p.board[to].type == wK)
	{
		p.k[white] = to;
	}
	else if (p.side  == black && p.board[to].type == bK)
	{
		p.k[black] = to;
	}
	
	if(flag & mProm)
	{
		if(flag & oPQ)
		{
			if(p.side == white)
			{
				p.board[to].type = wQ;
			}
			else
			{
				p.board[to].type = bQ;
			}
		}
		if(flag & oPR)
		{
			if(p.side == white)
			{
				p.board[to].type = wR;
			}
			else
			{
				p.board[to].type = bR;
			}
		}
		if(flag & oPB)
		{
			if(p.side == white)
			{
				p.board[to].type = wB;
			}
			else
			{
				p.board[to].type = bB;
			}
		}
		if(flag & oPN)
		{
			if(p.side == white)
			{
				p.board[to].type = wN;
			}
			else
			{
				p.board[to].type = bN;
			}
		}
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[F1].type = p.board[H1].type;
			p.board[H1].type = empty;
			p.board[F1].color = p.board[H1].color;
			p.board[H1].color = npco;
		}
		if(to == C1)
		{
			p.board[D1].type = p.board[A1].type;
			p.board[A1].type = empty;
			p.board[D1].color = p.board[A1].color;
			p.board[A1].color = npco;
		}
		if(to == G8)
		{
			p.board[F8].type = p.board[H8].type;
			p.board[H8].type = empty;
			p.board[F8].color = p.board[H8].color;
			p.board[H8].color = npco;
		}
		if(to == C8)
		{
			p.board[D8].type = p.board[A8].type;
			p.board[A8].type = empty;
			p.board[D8].color = p.board[A8].color;
			p.board[A8].color = npco;
		}
	}
	else if (flag & oPEP)
	{
		import std.stdio;
		if(p.side == white)
		{
			p.board[to-12].type = empty;
			p.board[to-12].color = npco;
		}
		else
		{
			p.board[to+12].type = empty;
			p.board[to+12].color = npco;
		}
	}
	r = isattacked(p.k[p.side], p.side^1);
	return r;
}

void takeQuick(int m, ref Piece holdme)
{
	int from  = FROM(m);
	int to = TO(m);
	int flag = FLAG(m);
	
	p.board[from] = p.board[to];
	p.board[to].type = holdme.type;
	p.board[to].color = holdme.color;
	
	if(p.side == white && p.board[from].type == wK)
	{
		p.k[white] = from;
	}
	else if(p.side == black && p.board[from].type == bK)
	{
		p.k[black] = from;
	}
	
	if(flag & mProm)
	{
		if(p.side == white)
		{
			p.board[from].type = wP;
		}
		else
		{
			p.board[from].type = bP;
		}
	}
	else if (flag & mCA)
	{
		if(to == G1)
		{
			p.board[H1].type = p.board[F1].type;
			p.board[F1].type = empty;
			p.board[H1].color = p.board[F1].color;
			p.board[F1].color = npco;
		}
		if(to == C1)
		{
			p.board[A1].type = p.board[D1].type;
			p.board[D1].type = empty;
			p.board[A1].color = p.board[D1].color;
			p.board[D1].color = npco;
		}
		if(to == G8)
		{
			p.board[H8].type = p.board[F8].type;
			p.board[F8].type = empty;
			p.board[H8].color = p.board[F8].color;
			p.board[F8].color = npco;
		}
		if(to == C8)
		{
			p.board[A8].type = p.board[D8].type;
			p.board[D8].type = empty;
			p.board[A8].color = p.board[D8].color;
			p.board[D8].color = npco;
		}
	}
	else if (flag & mPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].type = bP;
			p.board[to-12].color = bpco;
		}
		else
		{
			p.board[to+12].type = wP;
			p.board[to+12].color = wpco;
		}
	}
}

bool makeLegalMove(Move m)
{
	int from = FROM(m.m);
	int to = TO(m.m);
	int flag = FLAG(m.m);
	
	bool r = false;
	
	hist[histply].data = m.m;
	hist[histply].enPas = p.en_pas;
	hist[histply].fifty = p.fifty;
	hist[histply].hashKey = p.hashkey;
	hist[histply].castleFlags = p.castleflags;
	hist[histply].captured = p.board[to];
	
	p.hashkey ^= hashTurn;
	p.hashkey ^= hashCastleCombinations[p.castleflags];
	p.hashkey ^= hashEnPassant[files[p.en_pas]];
	
	p.en_pas = noenpas;
	p.castleflags &= castleBits[to];
	p.castleflags &= castleBits[from];
	
	hist[histply].pList = p.sqToPceNum[to];	
	p.pceNumToSq[p.sqToPceNum[to]] = 0;
	p.pceNumToSq[p.sqToPceNum[from]] = to;
	p.sqToPceNum[to] = p.sqToPceNum[from];
	p.sqToPceNum[from] = 0;
	
	p.board[to].type = p.board[from].type;
	p.board[to].color = p.board[from].color;
	p.board[from].type = empty;
	p.board[from].color = npco;
	
	
	if(p.side == white && p.board[to].type == wK)
	{
		p.k[white] = to;
	}
	else if(p.side == black && p.board[to].type == bK)
	{
		p.k[black] = to;
	}
	
	p.hashkey ^= hashPieces[64*p.board[to].type+8*ranks[from]+files[from]];
	p.hashkey ^= hashPieces[64*p.board[to].type+8*ranks[to]+files[to]];
	
	p.fifty++;
	
	if(hist[histply].captured.type != empty)
	{
		if(hist[histply].captured.type > 2)
		{
			p.majors--;
		}
		p.material[p.side] -= vals[hist[histply].captured.type];
		p.hashkey ^= hashPieces[64*hist[histply].captured.type+8*ranks[to]+files[to]];
		p.fifty = 0;
	}
	if(p.board[to].type < 3)
	{
		p.fifty = 0;
	}
	
	if(flag & mProm)
	{
		p.majors++;
		
		if(flag & oPQ)
		{
			if(p.side == white)
			{
				p.board[to].type = wQ;
				p.material[white] += vQ-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wQ+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bQ;
				p.material[black] += vQ-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bQ+8*ranks[to]+files[to]];				
			}
		}
		else if(flag & oPR)
		{
			if(p.side == white)
			{
				p.board[to].type = wR;
				p.material[white] += vR-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wR+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bR;
				p.material[black] += vR-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bR+8*ranks[to]+files[to]];				
			}
		}
		else if(flag & oPB)
		{
			if(p.side == white)
			{
				p.board[to].type = wB;
				p.material[white] += vB-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wB+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bB;
				p.material[black] += vB-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bB+8*ranks[to]+files[to]];				
			}
		}
		else if(flag & oPN)
		{
			if(p.side == white)
			{
				p.board[to].type = wN;
				p.material[white] += vN-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wN+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bN;
				p.material[black] += vN-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bN+8*ranks[to]+files[to]];				
			}
		}
	}
	else if(flag & mPST)
	{
		if(p.side == white)
		{
			p.en_pas = to-12;
		}
		else
		{
			p.en_pas = to+12;
		}
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[F1].type = p.board[H1].type;
			p.board[H1].type = empty;
			p.board[F1].color = p.board[H1].color;
			p.board[H1].color = npco;
			
			p.hashkey ^= hashPieces[64*wR+8*ranks[H1]+files[H1]];
			p.hashkey ^= hashPieces[64*wR+8*ranks[F1]+files[F1]];
			
			p.pceNumToSq[p.sqToPceNum[H1]] = F1;
			p.sqToPceNum[F1] = p.sqToPceNum[H1];
			p.sqToPceNum[H1] = 0;
		}
		if(to == C1)
		{
			p.board[D1].type = p.board[A1].type;
			p.board[A1].type = empty;
			p.board[D1].color = p.board[A1].color;
			p.board[A1].color = npco;
			
			p.hashkey ^= hashPieces[64*wR+8*ranks[A1]+files[A1]];
			p.hashkey ^= hashPieces[64*wR+8*ranks[D1]+files[D1]];
			
			p.pceNumToSq[p.sqToPceNum[A1]] = D1;
			p.sqToPceNum[D1] = p.sqToPceNum[A1];
			p.sqToPceNum[A1] = 0;
		}
		if(to == G8)
		{
			p.board[F8].type = p.board[H8].type;
			p.board[H8].type = empty;
			p.board[F8].color = p.board[H8].color;
			p.board[H8].color = npco;
			
			p.hashkey ^= hashPieces[64*bR+8*ranks[H8]+files[H8]];
			p.hashkey ^= hashPieces[64*bR+8*ranks[F8]+files[F8]];
			
			p.pceNumToSq[p.sqToPceNum[H8]] = F8;
			p.sqToPceNum[F8] = p.sqToPceNum[H8];
			p.sqToPceNum[H8] = 0;
		}
		if(to == C8)
		{
			p.board[D8].type = p.board[A8].type;
			p.board[A8].type = empty;
			p.board[D8].color = p.board[A8].color;
			p.board[A8].color = npco;
			
			p.hashkey ^= hashPieces[64*bR+8*ranks[A8]+files[A8]];
			p.hashkey ^= hashPieces[64*bR+8*ranks[D8]+files[D8]];
			
			p.pceNumToSq[p.sqToPceNum[A8]] = D8;
			p.sqToPceNum[D8] = p.sqToPceNum[A8];
			p.sqToPceNum[A8] = 0;
		}
	}
	else if(flag & oPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].type = empty;
			p.board[to-12].color = npco;
			
			p.hashkey ^= hashPieces[64*bP+8*ranks[to-12]+files[to-12]];
			p.material[black] -= vP;
			
			hist[histply].pList = p.sqToPceNum[to-12];
			p.pceNumToSq[p.sqToPceNum[to-12]] = 0;
			p.sqToPceNum[to-12] = 0;
		}
		else
		{
			p.board[to+12].type = empty;
			p.board[to+12].color = npco;
			
			p.hashkey ^= hashPieces[64*wP+8*ranks[to+12]+files[to+12]];
			p.material[white] -= vP;
			
			hist[histply].pList = p.sqToPceNum[to+12];
			p.pceNumToSq[p.sqToPceNum[to+12]] = 0;
			p.sqToPceNum[to+12] = 0;			
		}
	}
	
	p.ply++;
	p.side ^= 1;
	histply++;
	
	p.hashkey ^= hashTurn;
	p.hashkey ^= hashCastleCombinations[p.castleflags];
	p.hashkey ^= hashEnPassant[files[p.en_pas]];
	return r;
}