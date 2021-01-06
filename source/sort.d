import defines, data, psqt, attack;

immutable int HASH = 65536, M_KILLER = 65526, WIN_CAPT1 = 65516, WIN_CAPT2 = 65506, WIN_CAPT3 = 65496, Q_PROM_CAPT = 65486, Q_PROM = 65476, GCAP_QQ = 65466, GCAP_RR = 65456, GCAP_BB = 65446, GCAP_NN = 65436, GCAP_PP = 65426, SEECAP = 65416, KILLER1 = 65406, KILLER1_PLY = 65396, KILLER2 = 65376, KILLER2_PLY = 65366, OO = 65356, OOO = 65346, MINORPROM = 65366;

immutable int[16] equalcap = [0, GCAP_PP, GCAP_PP, GCAP_NN, GCAP_NN, GCAP_BB, GCAP_BB, GCAP_RR, GCAP_RR, GCAP_QQ, GCAP_QQ, 10000, 10000, 0, 0, 0];

void update_history(Move move, int depth)
{
	his_table[move.m&MOVEBITS] = depth/PLY;
	if(his_table[move.m&MOVEBITS] > MOVEBITS)
	{
		for(int h = 0; h < MOVEBITS; h++)
		{
			his_table[h] = his_table[h]>>1;
		}
	}
}

void update_killers(Move move, int score)
{
	if(score > 10000-p.ply)
	{
		matekiller[p.ply] = move;
		return;
	}
	if(!(move.m & mCAP))
	{
		if(move.m != killer1[p.ply].m)
		{
			killer2[p.ply] = killer1[p.ply];
			killer1[p.ply] = move;
		}
		else if(move.m != killer2[p.ply].m)
		{
			killer2[p.ply] = move;
		}
	}
}

bool score_killer(ref Move m)
{
	int from = FROM(m.m);
	int to = TO(m.m);
	
	if(from == FROM(killer1[p.ply].m) && to == TO(killer1[p.ply].m))
	{
		m.score = KILLER1;
		return true;
	}
	else if(from == FROM(killer1[p.ply-1].m) && to == TO(killer1[p.ply-1].m) && p.ply)
	{
		m.score = KILLER1_PLY;
		return true;
	}
	else if(from == FROM(killer2[p.ply].m) && to == TO(killer2[p.ply].m))
	{
		m.score = KILLER2;
		return true;
	}
	else if(from == FROM(killer2[p.ply-1].m) && to == TO(killer2[p.ply-1].m) && p.ply)
	{
		m.score = KILLER2_PLY;
		return true;
	}	
	return false;
}

void score_ca(ref Move m)
{
	m.score = OO;
}

void score_prom(ref Move m)
{
	if(m.m & oPQ)
	{
		m.score = Q_PROM;
	}
	else
	{
		m.score = MINORPROM;
	}
}

void score_capture(ref Move m)
{
	if(m.m & mProm)
	{
		if(m.m & oPQ)
		{
			m.score = Q_PROM;
		}
		else
		{
			m.score = MINORPROM;
		}		
	}
	else
	{
		int from = FROM(m.m);
		int to = TO(m.m);
		int val = vals[p.board[TO(m.m)].typ] - vals[p.board[FROM(m.m)].typ];
		if(val >= 600)
		{
			m.score = WIN_CAPT1;
		}
		else if(val >= 400)
		{
			m.score = WIN_CAPT1;
		}
		else if(val >= 200)
		{
			m.score = WIN_CAPT3;
		}
		else if(val == 0)
		{
			m.score = equalcap[p.board[FROM(m.m)].typ];
		}
		else
		{
		/+
			if(isattacked(to,p.side^1))
			{
				m.score = 0;
			}
			else
			{
				m.score = SEECAP;
			}
		+/
		}
	}
}

void order(ref Move hm)
{
	int from, to;
	if(followpv)
	{
		followpv = false;
		for(int i = p.listc[p.ply]; i<p.listc[p.ply+1]; i++)
		{
			from = FROM(p.list[i].m);
			to = TO(p.list[i].m);
			if((from == FROM(pv[0][p.ply].m))&& (to == TO(pv[0][p.ply].m)))
			{
				followpv = true;
				p.list[i].score = HASH;
			}
			else if((from == FROM(hm.m)) && (to == TO(hm.m)))
			{
				p.list[i].score = HASH;
			}
			else if((from == FROM(matekiller[p.ply].m)) && (to == TO(matekiller[p.ply].m)))
			{
				p.list[i].score = M_KILLER;
			}
			else if(p.list[i].m & mCAP)
			{
				score_capture(p.list[i]);
			}
			else if(p.list[i].m & mProm)
			{
				score_prom(p.list[i]);
			}
			else if(p.list[i].m & mCA)
			{
				score_ca(p.list[i]);
			}
			else if (!score_killer(p.list[i]))
			{
				p.list[i].score = his_table[p.list[i].m & MOVEBITS];
				int fromType = p.board[FROM(p.list[i].m)].typ;
				if(p.majors > 4)
				{
					p.list[i].score += returnMidtab(fromType, TO(p.list[i].m)) - returnMidtab(fromType, FROM(p.list[i].m));
				}
				else
				{
					p.list[i].score += returnEndtab(fromType, TO(p.list[i].m)) - returnEndtab(fromType, FROM(p.list[i].m));					
				}		
			}
		}
	}
	else
	{
		for(int i = p.listc[p.ply];i<p.listc[p.ply+1];i++)
		{
			from = FROM(p.list[i].m);
			to = TO(p.list[i].m);
			
			if((from == FROM(hm.m)) && (to == TO(hm.m)))
			{
				p.list[i].score = HASH;
			}
			else if((from == FROM(matekiller[p.ply].m)) && (to == TO(matekiller[p.ply].m)))
			{
				p.list[i].score = M_KILLER;
			}
			else if(p.list[i].m & mCAP)
			{
				score_capture(p.list[i]);
			}
			else if(p.list[i].m & mProm)
			{
				score_prom(p.list[i]);
			}
			else if(p.list[i].m & mCA)
			{
				score_ca(p.list[i]);
			}
			else if (!score_killer(p.list[i]))
			{
				p.list[i].score = his_table[p.list[i].m & MOVEBITS];
				int fromType = p.board[FROM(p.list[i].m)].typ;
				if(p.majors > 4)
				{
					p.list[i].score += returnMidtab(fromType, TO(p.list[i].m)) - returnMidtab(fromType, FROM(p.list[i].m));
				}
				else
				{
					p.list[i].score += returnEndtab(fromType, TO(p.list[i].m)) - returnEndtab(fromType, FROM(p.list[i].m));					
				}		
			}
		}
	}
}

void qorder()
{
	for(int i = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		int from = FROM(p.list[i].m);
		int to = TO(p.list[i].m);
		p.list[i].score = 0;
		
		if(p.list[i].m == pv[p.ply][0].m)
		{
			p.list[i].score = HASH;
		}
		else
		{
			int val = vals[p.board[to].typ] - vals[p.board[from].typ];
			p.list[i].score = 10000 + val;
			
			if(val < 0)
			{
				if(isattacked(to, p.side^1))
					p.list[i].score = 0;
			}
		}
	}
}

int extradepth(Move m)
{
	int nd = 0;
	int to = TO(m.m);
	
	if(m.m & oPQ)
	{
		nd+=48;
		prom++;
	}
	if(p.board[to].typ == wP)
	{
		if(ranks[to] == 6)
		{
			nd+=48;
			pawnsix++;
		}
		if(ranks[to] == 5)
		{
			nd+=24;
			pawnsix++;
		}
	}
	if(p.board[to].typ == bP)
	{
		if(ranks[to] == 1)
		{
			nd+=48;
			pawnsix++;
		}
		if(ranks[to] == 2)
		{
			nd+=24;
			pawnsix++;
		}
	}	
	if(nd>PLY) nd = PLY;
	return nd;
}