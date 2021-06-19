import defines, data, psqt, attack;

void updateHistory(Move move, int depth)
{
	his_table[move.m & MOVEBITS] = depth / PLY;
	if (his_table[move.m & MOVEBITS] > MOVEBITS)
	{
		for (int h = 0; h < MOVEBITS; h++)
		{
			his_table[h] = his_table[h] >> 1;
		}
	}
}

void updateKillers(Move move, int score)
{
	if (score > 10000 - p.ply)
	{
		matekiller[p.ply] = move;
		return;
	}
	if (!(move.m & mCAP))
	{
		if (move.m != killer1[p.ply].m)
		{
			killer2[p.ply] = killer1[p.ply];
			killer1[p.ply] = move;
		}
		else if (move.m != killer2[p.ply].m)
		{
			killer2[p.ply] = move;
		}
	}
}

bool scoreKiller(ref Move m)
{
	int from = getFrom(m.m);
	int to = getTo(m.m);
	if (from == getFrom(killer1[p.ply].m) && to == getTo(killer1[p.ply].m))
	{
		m.score = KILLER1;
		return true;
	}
	else if (from == getFrom(p.ply && killer1[p.ply - 1].m) && to == getTo(killer1[p.ply - 1].m))
	{
		m.score = KILLER1_PLY;
		return true;
	}
	else if (from == getFrom(killer2[p.ply].m) && to == getTo(killer2[p.ply].m))
	{
		m.score = KILLER2;
		return true;
	}
	else if (from == getFrom(p.ply && killer2[p.ply - 1].m) && to == getTo(killer2[p.ply - 1].m))
	{
		m.score = KILLER2_PLY;
		return true;
	}
	return false;
}

void scoreCa(ref Move m)
{
	m.score = OO;
}

void scoreProm(ref Move m)
{
	if (m.m & oPQ)
	{
		m.score = Q_PROM;
	}
	else
	{
		m.score = MINORPROM;
	}
}

void scoreCapture(ref Move m)
{
	if (m.m & mProm)
	{
		if (m.m & oPQ)
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
		int from = getFrom(m.m);
		int to = getTo(m.m);
		int val = vals[p.board[getTo(m.m)]] - vals[p.board[getFrom(m.m)]];
		if (val >= 600)
		{
			m.score = WIN_CAPT1;
		}
		else if (val >= 400)
		{
			m.score = WIN_CAPT1;
		}
		else if (val >= 200)
		{
			m.score = WIN_CAPT3;
		}
		else if (val == 0)
		{
			m.score = equalcap[p.board[getFrom(m.m)]];
		}
		else
		{
			if (isAttacked(to, p.side ^ 1))
			{
				m.score = 0;
			}
			else
			{
				m.score = SEECAP;
			}
		}
	}
}

void order(ref Move hm)
{
	int from, to;
	if (followpv)
	{
		followpv = false;
		for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
		{
			from = getFrom(p.list[i].m);
			to = getTo(p.list[i].m);
			if ((from == getFrom(pv[0][p.ply].m)) && (to == getTo(pv[0][p.ply].m)))
			{
				followpv = true;
				p.list[i].score = HASH;
			}
			else if ((from == getFrom(hm.m)) && (to == getTo(hm.m)))
			{
				p.list[i].score = HASH;
			}
			else if ((from == getFrom(matekiller[p.ply].m)) && (to == getTo(matekiller[p.ply].m)))
			{
				p.list[i].score = M_KILLER;
			}
			else if (p.list[i].m & mCAP)
			{
				scoreCapture(p.list[i]);
			}
			else if (p.list[i].m & mProm)
			{
				scoreProm(p.list[i]);
			}
			else if (p.list[i].m & mCA)
			{
				scoreCa(p.list[i]);
			}
			else if (!scoreKiller(p.list[i]))
			{
				p.list[i].score = his_table[p.list[i].m & MOVEBITS];
				int fromType = p.board[getFrom(p.list[i].m)];
				if (p.majors > 4)
				{
					p.list[i].score += returnMidtab(fromType,
							getTo(p.list[i].m)) - returnMidtab(fromType, getFrom(p.list[i].m));
				}
				else
				{
					p.list[i].score += returnEndtab(fromType,
							getTo(p.list[i].m)) - returnEndtab(fromType, getFrom(p.list[i].m));
				}
			}
		}
	}
	else
	{
		for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
		{
			from = getFrom(p.list[i].m);
			to = getTo(p.list[i].m);

			if ((from == getFrom(hm.m)) && (to == getTo(hm.m)))
			{
				p.list[i].score = HASH;
			}
			else if ((from == getFrom(matekiller[p.ply].m)) && (to == getTo(matekiller[p.ply].m)))
			{
				p.list[i].score = M_KILLER;
			}
			else if (p.list[i].m & mCAP)
			{
				scoreCapture(p.list[i]);
			}
			else if (p.list[i].m & mProm)
			{
				scoreProm(p.list[i]);
			}
			else if (p.list[i].m & mCA)
			{
				scoreCa(p.list[i]);
			}
			else if (!scoreKiller(p.list[i]))
			{
				p.list[i].score = his_table[p.list[i].m & MOVEBITS];
				int fromType = p.board[getFrom(p.list[i].m)];
				if (p.majors > 4)
				{
					p.list[i].score += returnMidtab(fromType,
							getTo(p.list[i].m)) - returnMidtab(fromType, getFrom(p.list[i].m));
				}
				else
				{
					p.list[i].score += returnEndtab(fromType,
							getTo(p.list[i].m)) - returnEndtab(fromType, getFrom(p.list[i].m));
				}
			}
		}
	}
}

void qorder()
{
	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		int from = getFrom(p.list[i].m);
		int to = getTo(p.list[i].m);
		p.list[i].score = 0;

		if (p.list[i].m == pv[p.ply][0].m)
		{
			p.list[i].score = HASH;
		}
		else
		{
			int val = vals[p.board[to]] - vals[p.board[from]];
			p.list[i].score = 10000 + val;

			if (val < 0)
			{
				if (isAttacked(to, p.side ^ 1))
					p.list[i].score = 0;
			}
		}
	}
}

int extraDepth(Move m)
{
	int nd = 0;
	int to = getTo(m.m);

	if (m.m & oPQ)
	{
		nd += 48;
		prom++;
	}
	if (p.board[to] == SquareType.wP)
	{
		if (ranks[to] == 6)
		{
			nd += 48;
			pawnsix++;
		}
		if (ranks[to] == 5)
		{
			nd += 24;
			pawnsix++;
		}
	}
	if (p.board[to] == SquareType.bP)
	{
		if (ranks[to] == 1)
		{
			nd += 48;
			pawnsix++;
		}
		if (ranks[to] == 2)
		{
			nd += 24;
			pawnsix++;
		}
	}
	if (nd > PLY)
		nd = PLY;
	return nd;
}
