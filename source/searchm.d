import data, defines, interrupt, sort, doundo, hash, attack, movegen, eval, movegenlegal;

int search(int alpha, int beta, int depth, bool nul)
{
	int score = 0, hashscore = 0;
	auto hflag = TableMoveType.None;
	int inc = 0;
	Move hashmove = nomove;
	int old_alpha = alpha;

	if (((nodes + qnodes) & 2047) == 0)
		checkup();
	if (stopsearch)
		return 0;
	if (p.ply && isRep())
		return 0;
	if (p.ply > 31)
		return gameEval();
	nodes++;
	pvindex[p.ply] = p.ply;
	hflag = probe_hash_table(depth, hashmove, nul, hashscore, beta);
	switch (hflag)
	{
	case TableMoveType.Exact:
		return hashscore;
	case TableMoveType.Upper:
		if (hashscore <= alpha)
			return hashscore;
		else
			break;
	case TableMoveType.Lower:
		if (hashscore >= beta)
			return hashscore;
		else
			break;
	default:
		break;
	}
	int extend = 0;
	inc = p.isAttacked(p.kingSquares[p.side], p.side ^ 1);
	bool opv = followpv;
	if (inc)
	{
		extend = PLY;
		check[p.ply] = 1;
		incheckext++;
	}
	else
	{
		check[p.ply] = 0;
		if (p.pceNum > 4 && nul && depth > PLY && !followpv)
		{
			int tep = p.enPas;
			p.hashKey ^= hashTurn;
			if (p.enPas != noEnPas)
				p.hashKey ^= hashEnPassant[files[p.enPas]];
			p.enPas = noEnPas;
			p.side ^= 1;
			p.hashKey ^= hashTurn;
			if (p.enPas != noEnPas)
				p.hashKey ^= hashEnPassant[files[p.enPas]];
			int ns;
			if (depth > 7)
			{
				ns = -search(-beta, -beta + 1, depth - 4 * PLY, false);
			}
			else
			{
				ns = -search(-beta, -beta + 1, depth - 3 * PLY, false);
			}
			followpv = opv;
			tep = p.enPas;
			p.hashKey ^= hashTurn;
			if (p.enPas != noEnPas)
				p.hashKey ^= hashEnPassant[files[p.enPas]];
			p.enPas = tep;
			p.side ^= 1;
			p.hashKey ^= hashTurn;
			if (p.enPas != noEnPas)
				p.hashKey ^= hashEnPassant[files[p.enPas]];
			if (stopsearch)
				return 0;
			if (ns >= beta)
			{
				return beta;
			}
			if (ns < -9900)
			{
				extend = PLY;
			}
		}
	}

	if (depth < PLY && !extend)
	{
		return quies(alpha, beta);
	}

	if (!hashmove.m)
		hashmove = pv[p.ply][0];

	moveGen();

	order(hashmove);

	int played = 0;
	int nd = 0;
	int iend = p.listc[p.ply + 1] - 1;
	Move bestmove = nomove;
	int bestscore = -10001;
	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		pick(i);
		if (p.makeMove(p.list[i]))
		{
			p.takeMove();
			continue;
		}
		played++;
		if (i == iend && played == 1)
		{
			extend = PLY;
			single++;
		}
		if (!extend)
		{
			nd = extraDepth(p.list[i]);
		}
		if (played == 1)
		{
			score = -search(-beta, -alpha, depth - PLY + extend + nd, true);
		}
		else
		{
			score = -search(-alpha - 1, -alpha, depth - PLY + extend + nd, true);
			pvs++;
			if (score > alpha && score < beta)
			{
				pvsh++;
				score = -search(-beta, -alpha, depth - PLY + extend + nd, true);
			}
		}
		p.takeMove();
		if (stopsearch)
			return 0;
		if (score > bestscore)
		{
			bestscore = score;
			bestmove = p.list[i];

			if (score > alpha)
			{
				alpha = score;
				updateHistory(p.list[i], depth);
				if (score >= beta)
				{
					if (played == 1)
						fhf++;
					fh++;
					updateKillers(p.list[i], score);
					store_hash(depth, score, TableMoveType.Lower, nul, bestmove);
					return beta;
				}

				pv[p.ply][p.ply] = p.list[i];
				for (int j = p.ply + 1; j < pvindex[p.ply + 1]; j++)
					pv[p.ply][j] = pv[p.ply + 1][j];
				pvindex[p.ply] = pvindex[p.ply + 1];
			}
		}
	}

	if (played == 0)
	{
		if (inc)
		{
			return -10000 + p.ply;
		}
		else
		{
			return 0;
		}
	}
	if (alpha > old_alpha)
	{
		store_hash(depth, bestscore, TableMoveType.Exact, nul, bestmove);
	}
	else
	{
		store_hash(depth, alpha, TableMoveType.Upper, nul, bestmove);
	}

	return alpha;
}

int firstQuies(int alpha, int beta)
{
	return alpha;
}

int quies(int alpha, int beta)
{
	int score;
	if (((nodes + qnodes) & 2047) == 0)
		checkup();
	if (stopsearch)
		return 0;
	qnodes++;
	if (p.ply > 31)
		return gameEval();
	pvindex[p.ply] = p.ply;
	score = gameEval();
	if (score >= beta)
		return beta;
	if (score > alpha)
		alpha = score;

	capGen();

	qorder();
	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		pick(i);
		if (p.makeMove(p.list[i]))
		{
			p.takeMove();
			continue;
		}
		score = -quies(-beta, -alpha);
		p.takeMove();
		if (stopsearch)
			return 0;
		if (score > alpha)
		{
			alpha = score;
			if (score >= beta)
				return beta;
			pv[p.ply][p.ply] = p.list[i];
			for (int j = p.ply + 1; j < pvindex[p.ply + 1]; j++)
			{
				pv[p.ply][j] = pv[p.ply + 1][j];
			}
			pvindex[p.ply] = pvindex[p.ply + 1];
		}
	}
	return alpha;
}

void pick(int from)
{
	int bs = -1000000;
	int bi = from;
	for (int i = from; i < p.listc[p.ply + 1]; i++)
	{
		if (p.list[i].score > bs)
		{
			bs = p.list[i].score;
			bi = i;
		}
	}
	Move g = p.list[from];
	p.list[from] = p.list[bi];
	p.list[bi] = g;
}

bool isRep()
{
	if (p.fifty > 101)
		return true;
	for (int i = 0; i < histply; i++)
	{
		if (hist[i].hashKey == p.hashKey)
			return true;
	}
	return false;
}
