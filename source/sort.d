import defines, data;

void update_killers(s_Move move, int score)
{
	if(score > 9000)
	{
		matekiller[p.ply] = move;
		return;
	}
	if(!(move.m & 0x100000))
	{
		if(score > killerscore[p.ply])
		{
			killerscore2[p.ply] = killerscore[p.ply];
			killerscore[p.ply] = score;
			killer3[p.ply] = killer2[p.ply];
			killer2[p.ply] = killer1[p.ply];
			killer1[p.ply] = move;
		}
		else if(score > killerscore2[p.ply])
		{
			killer3[p.ply] = killer2[p.ply];
			killer2[p.ply] = move;	
			killerscore2[p.ply] = score;			
		}
		else
		{
			killer2[p.ply] = move;
		}
	}
}

void order(s_Move hm)
{
	int i, from, to;
	if(followpv)
	{
		followpv = false;
		for(i = p.listc[p.ply]; i<p.listc[p.ply+1]; i++)
		{
			from = FROM(p.list[i].m);
			to = TO(p.list[i].m);
			if((from == FROM(pv[0][p.ply].m))&& (to == TO(pv[0][p.ply].m)))
			{
				followpv = true;
				p.list[i].score = 10000000;
			}
			else if((from == FROM(hm.m)) && (to == TO(hm.m)))
			{
				p.list[i].score = 10000000;
			}
			else if((from == FROM(matekiller[p.ply].m)) && (to == TO(matekiller[p.ply].m)))
			{
				p.list[i].score = 10000000;
			}
			else
			{
				if((from == FROM(killer1[p.ply].m)) && (to == TO(killer1[p.ply].m)))
				{
					p.list[i].score += 20000;
				}
				else if((from == FROM(killer2[p.ply].m)) && (to == TO(killer2[p.ply].m)))
				{
					p.list[i].score += 19000;
				}
				else if((from == FROM(killer3[p.ply].m)) && (to == TO(killer3[p.ply].m)))
				{
					p.list[i].score += 18000;
				}
			}
		}
	}
	else
	{
		for(i = p.listc[p.ply];i<p.listc[p.ply+1];i++)
		{
			from = FROM(p.list[i].m);
			to = TO(p.list[i].m);
			
			if((from == FROM(hm.m)) && (to == TO(hm.m)))
			{
				p.list[i].score = 10000000;
			}
			else if((from == FROM(matekiller[p.ply].m)) && (to == TO(matekiller[p.ply].m)))
			{
				p.list[i].score = 10000000;
			}
			else
			{
				if((from == FROM(killer1[p.ply].m)) && (to == TO(killer1[p.ply].m)))
				{
					p.list[i].score += 20000;
				}
				else if((from == FROM(killer2[p.ply].m)) && (to == TO(killer2[p.ply].m)))
				{
					p.list[i].score += 19000;
				}
				else if((from == FROM(killer3[p.ply].m)) && (to == TO(killer3[p.ply].m)))
				{
					p.list[i].score += 18000;
				}				
			}
		}
	}
}

int extradepth(s_Move m)
{
	int nd = 0;
	int to = TO(m.m);
	
	if(m.m & 0x200000)
	{
		nd+=48;
		prom++;
	}
	if(check[p.ply-2])
	{
		nd+=12;
		wasincheck++;
	}
	/+
	if(check[p.ply-3])
	{
		nd+=16;
		wasincheck++;
	}	
	+/
	if(p.board[to].typ == wP)
	{
		if(ranks[to] == 6)
		{
			nd+=56;
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
			nd+=56;
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