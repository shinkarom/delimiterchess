import data, defines, attack;

bool makemove(Move m)
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
	
	p.board[to] = p.board[from];
	p.board[from].typ = ety;
	p.board[from].col = npco;
	
	hist[histply].pList = p.sqtopcenum[to];
	p.pcenumtosq[p.sqtopcenum[to]] = 0;
	p.pcenumtosq[p.sqtopcenum[from]] = to;
	p.sqtopcenum[to] = p.sqtopcenum[from];
	p.sqtopcenum[from] = 0;
	
	if(p.side==white && p.board[to].typ == wK)
	{
		p.k[white] = to;
	}
	else if (p.side==black && p.board[to].typ == bK)
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
		p.fifty = 0;
		
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
		else if (flag & oPR)
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
		else if (flag & oPB)
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
		else if (flag & oPN)
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
			p.en_pas = to - 12;
		else
			p.en_pas = to + 12;
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[F1].typ = p.board[H1].typ;
			p.board[H1].typ = ety;
			p.board[F1].col = p.board[H1].col;
			p.board[H1].col = ety;
			
			p.hashkey ^= hash_p[wR][H1];
			p.hashkey ^= hash_p[wR][F1];
			
			p.pcenumtosq[p.sqtopcenum[H1]] = F1;
			p.sqtopcenum[F1] = p.sqtopcenum[H1];
			p.sqtopcenum[H1] = 0;
		}
		else if(to == C1)
		{
			p.board[D1].typ = p.board[A1].typ;
			p.board[A1].typ = ety;
			p.board[D1].col = p.board[A1].col;
			p.board[A1].col = ety;
			
			p.hashkey ^= hash_p[wR][A1];
			p.hashkey ^= hash_p[wR][D1];
			
			p.pcenumtosq[p.sqtopcenum[A1]] = D1;
			p.sqtopcenum[D1] = p.sqtopcenum[A1];
			p.sqtopcenum[A1] = 0;
		}
		else if(to == G8)
		{
			p.board[F8].typ = p.board[H8].typ;
			p.board[H8].typ = ety;
			p.board[F8].col = p.board[H8].col;
			p.board[H8].col = ety;
			
			p.hashkey ^= hash_p[wR][H8];
			p.hashkey ^= hash_p[wR][F8];
			
			p.pcenumtosq[p.sqtopcenum[H8]] = F8;
			p.sqtopcenum[F8] = p.sqtopcenum[H8];
			p.sqtopcenum[H8] = 0;
		}
		else if(to == C8)
		{
			p.board[D8].typ = p.board[A8].typ;
			p.board[A8].typ = ety;
			p.board[D8].col = p.board[A8].col;
			p.board[A8].col = ety;
			
			p.hashkey ^= hash_p[wR][A8];
			p.hashkey ^= hash_p[wR][D8];
			
			p.pcenumtosq[p.sqtopcenum[A8]] = D8;
			p.sqtopcenum[D8] = p.sqtopcenum[A8];
			p.sqtopcenum[A8] = 0;
		}
	}
	else if (flag & oPEP)
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
	
	r = isattacked(p.k[p.side], p.side^1);
	
	p.ply++;
	p.side ^= 1;
	histply++;
	
	p.hashkey ^= hash_s[p.side];
	p.hashkey ^= hash_ca[p.castleflags];
	p.hashkey ^= hash_enp[p.en_pas];
	
	return r;
}

void takemove()
{
	p.ply--;
	p.side ^= 1;
	histply--;
	
	p.castleflags = hist[histply].castleFlags;
	p.en_pas = hist[histply].enPas;
	p.hashkey = hist[histply].hashKey;
	p.fifty = hist[histply].fifty;
	
	int from = FROM(hist[histply].data);
	int to = TO(hist[histply].data);
	int flag = FLAG(hist[histply].data);
	
	p.board[from] = p.board[to];
	p.board[to] = hist[histply].captured;
	
	p.sqtopcenum[from] = p.sqtopcenum[to];
	p.sqtopcenum[to] = hist[histply].pList;
	p.pcenumtosq[p.sqtopcenum[to]] = to;
	p.pcenumtosq[p.sqtopcenum[from]] = from;
	
	if(p.side == white && p.board[from].typ == wK)
	{
		p.k[white] = from;
	}
	else if (p.side == black && p.board[from].typ == bK)
	{
		p.k[black] = from;
	}
	
	if(hist[histply].captured.typ != ety)
	{
		p.material[p.side] += vals[hist[histply].captured.typ];
		if(hist[histply].captured.typ > 2)
		{
			p.majors++;
		}
	}
	
	if(flag & mProm)
	{
		p.majors--;
		if(p.side == white)
		{
			p.board[from].typ = wP;
		}
		else
		{
			p.board[from].typ = bP;
		}
		if(flag & oPQ)
			p.material[p.side] -= vQ - vP;
		else if(flag & oPR)
			p.material[p.side] -= vR - vP;
		else if(flag & oPB)
			p.material[p.side] -= vB - vP;
		else if(flag & oPN)
			p.material[p.side] -= vN - vP;
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[H1].typ = p.board[F1].typ;
			p.board[F1].typ = ety;
			p.board[H1].col = p.board[F1].col;
			p.board[F1].col = npco;
			
			p.sqtopcenum[H1] = p.sqtopcenum[F1];
			p.sqtopcenum[F1] = 0;
			p.pcenumtosq[p.sqtopcenum[H1]] = H1;
		}
		else if(to == C1)
		{
			p.board[A1].typ = p.board[D1].typ;
			p.board[D1].typ = ety;
			p.board[A1].col = p.board[D1].col;
			p.board[D1].col = npco;
			
			p.sqtopcenum[A1] = p.sqtopcenum[D1];
			p.sqtopcenum[D1] = 0;
			p.pcenumtosq[p.sqtopcenum[A1]] = A1;			
		}
		else if(to == G8)
		{
			p.board[H8].typ = p.board[F8].typ;
			p.board[F8].typ = ety;
			p.board[H8].col = p.board[F8].col;
			p.board[F8].col = npco;
			
			p.sqtopcenum[H8] = p.sqtopcenum[F8];
			p.sqtopcenum[F8] = 0;
			p.pcenumtosq[p.sqtopcenum[H8]] = H8;
		}
		else if(to == C8)
		{
			p.board[A8].typ = p.board[D8].typ;
			p.board[D8].typ = ety;
			p.board[A8].col = p.board[D8].col;
			p.board[D8].col = npco;
			
			p.sqtopcenum[A8] = p.sqtopcenum[D8];
			p.sqtopcenum[D8] = 0;
			p.pcenumtosq[p.sqtopcenum[A8]] = A8;			
		}
	}
	else if(flag & oPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].typ = bP;
			p.board[to-12].col = bpco;
			p.material[black] += vP;
			
			p.sqtopcenum[to-12] = hist[histply].pList;
			p.pcenumtosq[hist[histply].pList] = to-12;
			p.sqtopcenum[to] = 0;
		}
		else
		{
			p.board[to+12].typ = wP;
			p.board[to+12].col = wpco;
			p.material[white] += vP;
			
			p.sqtopcenum[to+12] = hist[histply].pList;
			p.pcenumtosq[hist[histply].pList] = to+12;
			p.sqtopcenum[to] = 0;			
		}
	}
	
}