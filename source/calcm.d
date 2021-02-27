import core.time, std.stdio;
import data, defines, io, book, root, doundo, hash, sort, searchm, movegen;

void calc()
{
	int score = 0;
	int loopDepth = 0;
	int bk = -1;
	if(!searchParam.inf && searchParam.usebook)
	{
		bk = wfindhashbookmove();
		if(bk != -1)
		{
			best = p.list[bk];
			writeln("tellothers Book move ", returnmove(p.list[bk]));
			return;
		}
	}
	p.ply = 0;
	ponderMove = nomove;
	if(searchParam.depth == -1)
		loopDepth = 32;
	else
		loopDepth = searchParam.depth;
	initSearch();
	rootInit();
	int lastScore = 0;
	if(p.listc[p.ply+1]-p.listc[p.ply] == 1)
		loopDepth = 5;
	for(int itDepth = 1; itDepth <= loopDepth; itDepth++)
	{		
		followpv = true;
		score = rootSearch(-10000, 10000, itDepth*PLY);
		best = pv[0][0];
		ponderMove = pv[0][1];
		if(timeUp())
			return;
		lastScore = score;
		if(itDepth > 3)
			printpv(score);
		for(int l = 0; l<48; l++)
		{
			killerscore[l] = -10000;
			killerscore2[l] = -10000;
		}
		if(timeCheck())
			stopsearch = true;
	}
}

bool timeUp()
{
	return stopsearch;
}

bool timeCheck()
{
	if(itdepth < 6)
		return false;
	double timeNow = MonoTime.currTime.ticks;
	double timeToLastPly = timeNow - searchParam.starttime;
	double timeForNextPly = timeToLastPly * 2;
	if(timeForNextPly+timeNow > searchParam.stoptime)
		return true;
	return false;
}

Move findHashMove(Move m)
{
	int fakeDepth = 0;
	bool fakeNull = false;
	int fakeScore = 0;
	int fbeta = 0;
	
	Move hashMove = nomove;
	makemove(m);
	fakeScore = probe_hash_table(fakeDepth, hashMove, fakeNull, fakeScore, fbeta);
	if(nopvmove(returnmove(hashMove)))
	{
		moveGen();
		order(nomove);
		for(int i = p.listc[p.ply]; i<p.listc[p.ply+1]; i++)
		{
			pick(i);
			if(makemove(p.list[i]))
			{
				takemove();
				continue;
			}
			else
			{
				pick(p.listc[p.ply]);
				hashMove = p.list[i];
				break;
			}
		}
	}
	takemove();
	
	return hashMove;
}

void initSearch()
{
	stopsearch = false;
	nomove.m = 0;
	for(int l = 0; l<48; l++)
	{
		killerscore[l] = -10000;
		killerscore2[l] = -10000;
		killer1[l] = nomove;
		killer2[l] = nomove;
		pvindex[l] = 0;
		check[l] = 0;
		red[l] = 0;
		for(int j = 0; j<48; j++)
		{
			pv[l][j] = nomove;
		}
	}
	for(int k = 0; k<2; k++)
	{
		for(int j = 0; j<144; j++)
		{
			for(int l = 0; l<144; l++)
			{
				history[j][l] = 0;
				hisall[k][j][l] = 8192;
				hisfh[k][j][l] = 8192;
			}
		}
	}
	for(int k = 0; k<MOVEBITS; k++)
	{
		his_table[k] = 0;
	}
	nodes = 0;
	qnodes = 0;
	fh = 0; 
	fhf = 0;
	pvs = 0;
	pvsh = 0;
	nulltry = 0;
	nullcut = 0;
	hashprobe = 0;
	hashhit = 0;
	incheckext = 0; 
	wasincheck = 0;
	matethrt = 0;
	pawnfifth = 0;
	pawnsix = 0;
	prom = 0;
	reduct = 0;
	single = 0;
	resethis = 0;
}