import std.stdio;
import data, defines, sort, attack, searchm, doundo, movegenlegal, movegen, io;

immutable int ROOTLEGAL = 0, ROOTILLEGAL = 1, ILLEGALSCORE = -32000;

void rootInit()
{
	rootMoveList();
	scoreRootMoves();
	rootSort();
}

void rootMoveList()
{
	moveGen();
}

void scoreRootMoves()
{
	int now = p.ply;
	for (int i = p.listc[now]; i < p.listc[now + 1]; i++)
	{
		auto f = getFrom(p.list[i].m);
		auto t = getTo(p.list[i].m);
		if (makeMove(p.list[i]))
		{
			takeMove();
			continue;
		}
		p.list[i].score = -quies(-10000, 10000);
		takeMove();
	}
}

void rootSort()
{
	int now = p.ply;
	for (int i = p.listc[now]; i < p.listc[now + 1]; i++)
	{
		for (int j = p.listc[now]; j < p.listc[now + 1] - 1; j++)
		{
			if (p.list[j + 1].score > p.list[j].score)
			{
				Move temp = p.list[j];
				p.list[j] = p.list[j + 1];
				p.list[j + 1] = temp;
			}
		}
	}
}

int rootSearch(int alpha, int beta, int depth)
{
	int score;
	int inc = 0;
	int oalpha = alpha;
	pvindex[p.ply] = p.ply;

	order(nomove);
	int played = 0;
	int bestscore = -10001;
	Move bestmove;
	import std.stdio;

	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		pick(i);
		if (makeMove(p.list[i]))
		{
			takeMove();
			continue;
		}
		if (isAttacked(p.k[p.side], p.side ^ 1))
		{
			inc = PLY;
		}
		played++;
		if (played == 1)
		{
			score = -search(-beta, -alpha, depth - PLY + inc, true);
		}
		else
		{
			score = -search(-alpha - 1, -alpha, depth - PLY + inc, true);
			pvs++;
			if (score > alpha && score < beta)
			{
				pvsh++;
				score = -search(-beta, -alpha, depth - PLY + inc, true);
			}
		}
		takeMove();
		inc = 0;

		if (stopsearch)
			return 0;

		if (score > bestscore)
		{
			bestscore = score;
			bestmove = p.list[i];

			if (score > alpha)
			{
				alpha = score;
				pv[p.ply][p.ply] = p.list[i];
				for (int j = p.ply + 1; j < pvindex[p.ply + 1]; j++)
				{
					pv[p.ply][j] = pv[p.ply + 1][j];
				}
				pvindex[p.ply] = pvindex[p.ply + 1];

				if (score >= beta)
				{
					if (played == 1)
						fhf++;
					fh++;
					return score;
				}
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
	else
	{
		return bestscore;
	}
}
