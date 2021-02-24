import data, defines, attack;
	import std.stdio;
	
void pushMoveLegal(int from, int to, int flag)
{
	Pce holdme;
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
	if(p.board[t].typ == edge)
		return;
	else if(p.board[t].typ == ety)
	{
		pushMoveLegal(f, t, mNORM);
	}
	else if(p.board[t].col == xcol)
	{
		pushMoveLegal(f, t, mCAP);
	}	
}

void slideMoveLegal(int f, int t, int xcol)
{
	int d = t-f;
	if(p.board[t].typ == edge)
		return;
	do
	{
		if(p.board[t].typ == ety)
		{
			pushMoveLegal(f, t, mNORM);
			t+=d;
		}
		else if (p.board[t].col == xcol)
		{
			pushMoveLegal(f, t, mCAP);
			break;
		}
		else 
			break;
	} while(p.board[t].typ != edge);
}

void moveGenLegal()
{
	int tsq;
	p.listc[p.ply+1] = p.listc[p.ply];
	
	if(p.side == white)
	{
		import std.stdio;
		for(int index = 0; index < p.pcenum; index++)
		{			
			if(p.pcenumtosq[index] == 0)
				continue;
				
			int sq = p.pcenumtosq[index];
			switch(p.board[sq].typ)
			{
				case wP:
					tsq = sq+13;					
					if(p.board[tsq].col == bpco)
					{
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq+11;
					if(p.board[tsq].col == bpco)
					{
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq+12;
					if(p.board[tsq].typ == ety)
					{
						pushPawnLegal(sq, tsq, mNORM);
						if(sq < A3 && p.board[tsq+12].typ == ety)
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
							if(p.board[H1].typ == wR && p.board[F1].typ == ety && p.board[G1].typ == ety)
							{
								if(!isattacked(F1, black) && !isattacked(E1, black) && !isattacked(G1, black))
								{
									pushMoveLegal(E1, G1, mCA);
								}
							}
						}
						if(p.castleflags & 4)
						{
							if(p.board[A1].typ == wR && p.board[D1].typ == ety && p.board[C1].typ == ety && p.board[B1].typ == ety)
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
		for(int index = 1; index <= p.pcenum; index++)
		{
			if(p.pcenumtosq[index] == 0)
				continue;
				
			int sq = p.pcenumtosq[index];
			
			switch(p.board[sq].typ)
			{
				case bP:
					tsq = sq-13;
					if(p.board[tsq].col == wpco)
					{
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq-11;
					if(p.board[tsq].col == wpco)
					{
						pushPawnLegal(sq, tsq, mCAP);
					}
					if(p.en_pas == tsq)
					{
						pushMoveLegal(sq, tsq, mPEP);
					}
					tsq = sq-12;
					if(p.board[tsq].typ == ety)
					{
						pushPawnLegal(sq, tsq, mNORM);
						if(sq < A3 && p.board[tsq+12].typ == ety)
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
							if(p.board[H8].typ == bR && p.board[F8].typ == ety && p.board[G8].typ == ety)
							{
								if(!isattacked(F8, white) && !isattacked(E8, white) && !isattacked(G8, white))
								{
									pushMoveLegal(E8, G8, mCA);
								}
							}
						}
						if(p.castleflags & 1)
						{
							if(p.board[A8].typ == bR && p.board[D8].typ == ety && p.board[C8].typ == ety && p.board[B8].typ == ety)
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

bool makeQuick(int m, ref Pce holdme)
{
	int from = FROM(m);
	int to = TO(m);
	int flag = FLAG(m);
	
	bool r = false;
	
	holdme.typ = p.board[to].typ;
	holdme.col = p.board[to].col;
	
	p.board[to] = p.board[from];
	
	p.board[from].typ = ety;
	p.board[from].col = npco;
	
	if(p.side == white && p.board[to].typ == wK)
	{
		p.k[white] = to;
	}
	else if (p.side  == black && p.board[to].typ == bK)
	{
		p.k[black] = to;
	}
	
	if(flag & mProm)
	{
		if(flag & oPQ)
		{
			if(p.side == white)
			{
				p.board[to].typ = wQ;
			}
			else
			{
				p.board[to].typ = bQ;
			}
		}
		if(flag & oPR)
		{
			if(p.side == white)
			{
				p.board[to].typ = wR;
			}
			else
			{
				p.board[to].typ = bR;
			}
		}
		if(flag & oPB)
		{
			if(p.side == white)
			{
				p.board[to].typ = wB;
			}
			else
			{
				p.board[to].typ = bB;
			}
		}
		if(flag & oPN)
		{
			if(p.side == white)
			{
				p.board[to].typ = wN;
			}
			else
			{
				p.board[to].typ = bN;
			}
		}
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[F1].typ = p.board[H1].typ;
			p.board[H1].typ = ety;
			p.board[F1].col = p.board[H1].col;
			p.board[H1].col = npco;
		}
		if(to == C1)
		{
			p.board[D1].typ = p.board[A1].typ;
			p.board[A1].typ = ety;
			p.board[D1].col = p.board[A1].col;
			p.board[A1].col = npco;
		}
		if(to == G8)
		{
			p.board[F8].typ = p.board[H8].typ;
			p.board[H8].typ = ety;
			p.board[F8].col = p.board[H8].col;
			p.board[H8].col = npco;
		}
		if(to == C8)
		{
			p.board[D8].typ = p.board[A8].typ;
			p.board[A8].typ = ety;
			p.board[D8].col = p.board[A8].col;
			p.board[A8].col = npco;
		}
	}
	else if (flag & oPEP)
	{
		import std.stdio;
		if(p.side == white)
		{
			p.board[to-12].typ = ety;
			p.board[to-12].col = npco;
		}
		else
		{
			p.board[to+12].typ = ety;
			p.board[to+12].col = npco;
		}
	}
	r = isattacked(p.k[p.side], p.side^1);
	return r;
}

void takeQuick(int m, ref Pce holdme)
{
	int from  = FROM(m);
	int to = TO(m);
	int flag = FLAG(m);
	
	p.board[from] = p.board[to];
	p.board[to].typ = holdme.typ;
	p.board[to].col = holdme.col;
	
	if(p.side == white && p.board[from].typ == wK)
	{
		p.k[white] = from;
	}
	else if(p.side == black && p.board[from].typ == bK)
	{
		p.k[black] = from;
	}
	
	if(flag & mProm)
	{
		if(p.side == white)
		{
			p.board[from].typ = wP;
		}
		else
		{
			p.board[from].typ = bP;
		}
	}
	else if (flag & mCA)
	{
		if(to == G1)
		{
			p.board[H1].typ = p.board[F1].typ;
			p.board[F1].typ = ety;
			p.board[H1].col = p.board[F1].col;
			p.board[F1].col = npco;
		}
		if(to == C1)
		{
			p.board[A1].typ = p.board[D1].typ;
			p.board[D1].typ = ety;
			p.board[A1].col = p.board[D1].col;
			p.board[D1].col = npco;
		}
		if(to == G8)
		{
			p.board[H8].typ = p.board[F8].typ;
			p.board[F8].typ = ety;
			p.board[H8].col = p.board[F8].col;
			p.board[F8].col = npco;
		}
		if(to == C8)
		{
			p.board[A8].typ = p.board[D8].typ;
			p.board[D8].typ = ety;
			p.board[A8].col = p.board[D8].col;
			p.board[D8].col = npco;
		}
	}
	else if (flag & mPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].typ = bP;
			p.board[to-12].col = bpco;
		}
		else
		{
			p.board[to+12].typ = wP;
			p.board[to+12].col = wpco;
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
	
	p.hashkey ^= hash_s[p.side];
	p.hashkey ^= hash_ca[p.castleflags];
	p.hashkey ^= hash_enp[p.en_pas];
	
	p.en_pas = noenpas;
	p.castleflags &= castleBits[to];
	p.castleflags &= castleBits[from];
	
	hist[histply].pList = p.sqtopcenum[to];	
	p.pcenumtosq[p.sqtopcenum[to]] = 0;
	p.pcenumtosq[p.sqtopcenum[from]] = to;
	p.sqtopcenum[to] = p.sqtopcenum[from];
	p.sqtopcenum[from] = 0;
	
	p.board[to].typ = p.board[from].typ;
	p.board[to].col = p.board[from].col;
	p.board[from].typ = ety;
	p.board[from].col = npco;
	
	
	if(p.side == white && p.board[to].typ == wK)
	{
		p.k[white] = to;
	}
	else if(p.side == black && p.board[to].typ == bK)
	{
		p.k[black] = to;
	}
	
	p.hashkey ^= hash_p[p.board[to].typ][from];
	p.hashkey ^= hash_p[p.board[to].typ][to];
	
	p.fifty++;
	
	if(hist[histply].captured.typ != ety)
	{
		if(hist[histply].captured.typ > 2)
		{
			p.majors--;
		}
		p.material[p.side] -= vals[hist[histply].captured.typ];
		p.hashkey ^= hash_p[hist[histply].captured.typ][to];
		p.fifty = 0;
	}
	if(p.board[to].typ < 3)
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
				p.board[to].typ = wQ;
				p.material[white] += vQ-vP;
				p.hashkey ^= hash_p[wP][to];
				p.hashkey ^= hash_p[wQ][to];
			}
			else
			{
				p.board[to].typ = bQ;
				p.material[black] += vQ-vP;
				p.hashkey ^= hash_p[bP][to];
				p.hashkey ^= hash_p[bQ][to];				
			}
		}
		else if(flag & oPR)
		{
			if(p.side == white)
			{
				p.board[to].typ = wR;
				p.material[white] += vR-vP;
				p.hashkey ^= hash_p[wP][to];
				p.hashkey ^= hash_p[wR][to];
			}
			else
			{
				p.board[to].typ = bR;
				p.material[black] += vR-vP;
				p.hashkey ^= hash_p[bP][to];
				p.hashkey ^= hash_p[bR][to];				
			}
		}
		else if(flag & oPB)
		{
			if(p.side == white)
			{
				p.board[to].typ = wB;
				p.material[white] += vB-vP;
				p.hashkey ^= hash_p[wP][to];
				p.hashkey ^= hash_p[wB][to];
			}
			else
			{
				p.board[to].typ = bB;
				p.material[black] += vB-vP;
				p.hashkey ^= hash_p[bP][to];
				p.hashkey ^= hash_p[bB][to];				
			}
		}
		else if(flag & oPN)
		{
			if(p.side == white)
			{
				p.board[to].typ = wN;
				p.material[white] += vN-vP;
				p.hashkey ^= hash_p[wP][to];
				p.hashkey ^= hash_p[wN][to];
			}
			else
			{
				p.board[to].typ = bN;
				p.material[black] += vN-vP;
				p.hashkey ^= hash_p[bP][to];
				p.hashkey ^= hash_p[bN][to];				
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
			p.board[F1].typ = p.board[H1].typ;
			p.board[H1].typ = ety;
			p.board[F1].col = p.board[H1].col;
			p.board[H1].col = npco;
			
			p.hashkey ^= hash_p[wR][H1];
			p.hashkey ^= hash_p[wR][F1];
			
			p.pcenumtosq[p.sqtopcenum[H1]] = F1;
			p.sqtopcenum[F1] = p.sqtopcenum[H1];
			p.sqtopcenum[H1] = 0;
		}
		if(to == C1)
		{
			p.board[D1].typ = p.board[A1].typ;
			p.board[A1].typ = ety;
			p.board[D1].col = p.board[A1].col;
			p.board[A1].col = npco;
			
			p.hashkey ^= hash_p[wR][A1];
			p.hashkey ^= hash_p[wR][D1];
			
			p.pcenumtosq[p.sqtopcenum[A1]] = D1;
			p.sqtopcenum[D1] = p.sqtopcenum[A1];
			p.sqtopcenum[A1] = 0;
		}
		if(to == G8)
		{
			p.board[F8].typ = p.board[H8].typ;
			p.board[H8].typ = ety;
			p.board[F8].col = p.board[H8].col;
			p.board[H8].col = npco;
			
			p.hashkey ^= hash_p[wR][H8];
			p.hashkey ^= hash_p[wR][F8];
			
			p.pcenumtosq[p.sqtopcenum[H8]] = F8;
			p.sqtopcenum[F8] = p.sqtopcenum[H8];
			p.sqtopcenum[H8] = 0;
		}
		if(to == C8)
		{
			p.board[D8].typ = p.board[A8].typ;
			p.board[A8].typ = ety;
			p.board[D8].col = p.board[A8].col;
			p.board[A8].col = npco;
			
			p.hashkey ^= hash_p[wR][A8];
			p.hashkey ^= hash_p[wR][D8];
			
			p.pcenumtosq[p.sqtopcenum[A8]] = D8;
			p.sqtopcenum[D8] = p.sqtopcenum[A8];
			p.sqtopcenum[A8] = 0;
		}
	}
	else if(flag & oPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].typ = ety;
			p.board[to-12].col = npco;
			
			p.hashkey ^= hash_p[bP][to-12];
			p.material[black] -= vP;
			
			hist[histply].pList = p.sqtopcenum[to-12];
			p.pcenumtosq[p.sqtopcenum[to-12]] = 0;
			p.sqtopcenum[to-12] = 0;
		}
		else
		{
			p.board[to+12].typ = ety;
			p.board[to+12].col = npco;
			
			p.hashkey ^= hash_p[wP][to+12];
			p.material[white] -= vP;
			
			hist[histply].pList = p.sqtopcenum[to+12];
			p.pcenumtosq[p.sqtopcenum[to+12]] = 0;
			p.sqtopcenum[to+12] = 0;			
		}
	}
	
	p.ply++;
	p.side ^= 1;
	histply++;
	
	p.hashkey ^= hash_s[p.side];
	p.hashkey ^= hash_ca[p.castleflags];
	p.hashkey ^= hash_enp[p.en_pas];
	return r;
}