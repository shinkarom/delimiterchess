import std.math;
import data, defines, psqt;

const int beg = 0, end = 1;
const int[16] blockerbonus = [0, 0, 0, 15, 15, 12, 12, 7, 7, 2, 2, 0, 0, 0, 0, 0];
const int[16] developpenalty = [0, 5, 8, 12, 18, 25, 35, 47, 68, 80, 105, 130, 130, 130, 130, 130];
const int[32] bishoppairbonus = [
							20, 18, 17, 15, 12, 10, 6, 6, 6, 0, 0, 0, -5, -10, -15, -20, -20, 
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
							];
const int[8] wstorm = [0, -5, 0, 5, 10, 15, 20, 0];
const int[8] bstorm = [0, 20, 15, 10, 5, 0, -5, 0];
const int[9] pdefect = [0, 0, 5, 10, 15, 20, 60, 60, 60];
const int[8] pbit = [1, 2, 4, 8, 16, 32, 64, 128];
const int[8][2] mppawn = [
						[0, 50, 30, 20, 10, 0, 0, 0],
						[0, 0, 0, 10, 20, 30, 50, 0]
						];
const int[8][2] eppawn = [
						[0, 75, 60, 45, 30, 15, 5, 0],
						[0, 5, 15, 30, 45, 60, 75, 0]
						];
const int[8] kmdppawn = [0, 150, 100, 50, 25, 10, 5, 0];
const int[8] kdeppawn = [0, 200, 150, 80, 40, 25, 10, 0];
const int[8] kpdist = [0, 0, 10, 20, 26, 31, 35, 38];
const int[8] ntrop = [0, 10, 7, 4, 2, 0, 0, 0];
const int[8] ptrop = [0, 15, 10, 6, 4, 0, 0, 0];
const int[8] rtrop = [0, 8, 5, 2, 1, 0, 0, 0];
const int[8] qtrop = [0, 6, 4, 2, 1, 0, 0, 0];

int[144][144] distancetable;

void init_distancetable()
{
	for(int i = 0; i<144; i++)
		for(int j = 0; j<144;j++)
			distancetable[i][j] = 0;
			
	for(int i = 0; i<144;i++)
	{
		int ri = ranks[i];
		int fi = files[i];
		for(int j = 0; j<144; j++)
		{
			int rj = ranks[j];
			int fj = files[j];
			distancetable[i][j] = abs(ri-rj) > abs(fi-fj) ? abs(ri-rj) : abs(ri-rj);
		}
	}
}

void initeval()
{
	mymemset();
	for(int index = 1; index <= p.pcenum; index++)
	{
		if(p.pcenumtosq[index] == 0)
			continue;
		int sq = p.pcenumtosq[index];
		switch(p.board[sq].typ)
		{
			case wR:
				evalData.wRc++;
				evalData.wmajors++;
				break;
			case wN:
				evalData.wNc++;
				evalData.wmajors++;
				break;
			case wB:
				evalData.wBc++;
				evalData.wmajors++;
				evalData.wBsq = sq;
				break;
			case wQ:
				evalData.wQc++;
				evalData.wmajors++;
				break;
			case wK:
				break;
			case wP:
				int f = files[sq]+1;
				if(evalData.pawn_set[white][f] > ranks[sq])
				{
					evalData.pawn_set[white][f] = ranks[sq];
				}
				evalData.wpawns++;
				evalData.pawns[white][f]++;
				evalData.pawnbits[white] += pbit[ranks[sq]];
				break;
			case bR:
				evalData.bRc++;
				evalData.bmajors++;
				break;
			case bN:
				evalData.bNc++;
				evalData.bmajors++;
				break;
			case bB:
				evalData.bBc++;
				evalData.bmajors++;
				evalData.bBsq = sq;
				break;
			case bQ:
				evalData.bQc++;
				evalData.bmajors++;
				break;
			case bK:
				break;
			case bP:
				int f = files[sq]+1;
				if(evalData.pawn_set[black][f] > ranks[sq])
				{
					evalData.pawn_set[black][f] = ranks[sq];
				}
				evalData.bpawns++;
				evalData.pawns[black][f]++;
				evalData.pawnbits[black] += pbit[ranks[sq]];
				break;
			default:
				break;
		}
	}
}

int gameeval()
{
	initeval();
	midgameeval();	
	int phase = 24-((evalData.wQc+evalData.bQc)*4  +
					(evalData.wRc+evalData.bRc)*2 +
					(evalData.wBc+evalData.bBc) + (evalData.wNc+evalData.bNc));
	if(phase<0)
		phase = 0;
	phase = (phase*256 +(24*2))/24;
	int send = evalData.score[white][end]-evalData.score[black][end];
	int sbeg = evalData.score[white][beg]-evalData.score[black][beg];
	int score = ((sbeg*(256-phase))+(send*phase))/256;
	if(p.side == white)
	{
		return score;
	}
	else
	{
		return -score;
	}
}

void midgameeval()
{
	if(evalData.wpawns + evalData.bpawns == 0)
	{
		if(!isdrawnp())
		{
			evalData.score[white][beg] = 0;
			evalData.score[white][end] = 0;
			evalData.score[black][beg] = 0;
			evalData.score[black][end] = 0;
		}
	}
	
	for(int index = 1; index <= p.pcenum; index++)
	{
		if(p.pcenumtosq[index] == 0)
			continue;
			
		int sq = p.pcenumtosq[index];
		
		switch(p.board[sq].typ)
		{
			case wP:
				evalData.score[white][beg] += vP;
				evalData.score[white][beg] += Pawn[sq];
				evalData.score[white][end] += vP;
				whitepawnsstructure(sq);
				break;
			case wN:
				evalData.score[white][beg] += vN;
				evalData.score[white][beg] += Knight[sq];
				evalData.score[white][end] += vN;
				evalData.score[white][end] += eKnight[sq];
				evalData.score[white][beg] += wNsupport(sq);
				wknightmob(sq);
				break;
			case wB:
				evalData.score[white][beg] += vB;
				evalData.score[white][beg] += Bishop[sq];
				evalData.score[white][end] += vB;
				evalData.score[white][end] += eBishop[sq];
				wbishopmob(sq);
				break;
			case wR:
				evalData.score[white][beg] += vR;
				evalData.score[white][beg] += Rook[sq];
				evalData.score[white][end] += vR;
				wrooktrapped(sq);
				wrookmob(sq);
				if(evalData.pawns[white][files[sq]+1] == 0)
				{
					evalData.score[white][beg] += 8;
					evalData.score[white][end] += 15;
					if(evalData.score[black][files[sq]+1] == 0)
					{
						evalData.score[white][beg] += 5;
						evalData.score[white][end] += 10;
					}
					if(abs(files[sq]-files[p.k[black]]) <= 1)
					{
						evalData.score[white][beg] += 8;
						if(files[sq] == files[p.k[black]])
						{
							evalData.score[white][beg] += 8;
						}
					}
				}
				if(ranks[sq] == 6 && wrseven())
				{
					evalData.score[white][beg] += 10;
					evalData.score[white][end] += 20;
				}
				break;
			case wQ:
				evalData.score[white][beg] += vQ;
				evalData.score[white][end] += vQ;
				wqueenmob(sq);
				if(ranks[sq] == 6 && wrseven())
				{
					evalData.score[white][beg] += 5;
					evalData.score[white][end] += 10;
				}
				break;
			case wK:
				evalData.score[white][beg] += KingMid[sq];
				evalData.score[white][end] += KingEnd[sq];
				if(dowks())
				{
					evalData.score[white][beg] += whitekingsafety(sq);
				}
				break;
			case bP:
				evalData.score[black][beg] += vP;
				evalData.score[black][beg] += Pawn[opp[sq]];
				evalData.score[black][end] += vP;
				blackpawnsstructure(sq);
				break;
			case bN:
				evalData.score[black][beg] += vN;
				evalData.score[black][beg] += Knight[opp[sq]];
				evalData.score[black][end] += vN;
				evalData.score[black][end] += eKnight[opp[sq]];
				evalData.score[black][beg] += bNsupport(sq);
				bknightmob(sq);
				break;
			case bB:
				evalData.score[black][beg] += vB;
				evalData.score[black][beg] += Bishop[opp[sq]];
				evalData.score[black][end] += vB;
				evalData.score[black][end] += eBishop[opp[sq]];
				bbishopmob(sq);
				break;
			case bR:
				evalData.score[black][beg] += vR;
				evalData.score[black][beg] += Rook[opp[sq]];
				evalData.score[black][end] += vR;
				brooktrapped(sq);
				brookmob(sq);
				if(evalData.pawns[black][files[sq]+1] == 0)
				{
					evalData.score[black][beg] += 8;
					evalData.score[black][end] += 15;
					if(evalData.score[white][files[sq]+1] == 0)
					{
						evalData.score[black][beg] += 5;
						evalData.score[black][end] += 10;
					}
					if(abs(files[sq]-files[p.k[white]]) <= 1)
					{
						evalData.score[black][beg] += 8;
						if(files[sq] == files[p.k[white]])
						{
							evalData.score[black][beg] += 8;
						}
					}
				}
				if(ranks[sq] == 1 && brseven())
				{
					evalData.score[black][beg] += 10;
					evalData.score[black][end] += 20;
				}
				break;
			case bQ:
				evalData.score[black][beg] += vQ;
				evalData.score[black][end] += vQ;
				bqueenmob(sq);
				if(ranks[sq] == 1 && brseven())
				{
					evalData.score[black][beg] += 5;
					evalData.score[black][end] += 10;
				}
				break;
			case bK:
				evalData.score[black][beg] += KingMid[opp[sq]];
				evalData.score[black][end] += KingEnd[opp[sq]];
				if(dobks())
				{
					evalData.score[black][beg] += blackkingsafety(sq);
				}
				break;
			default:
				break;
		}
	}
	development();
	blockedpawn();
	bishoppair();
	if(abs(files[p.k[white]] - files[p.k[black]]) > 2)
	{
		pawnstorm();
	}
}

bool wrseven()
{
	return (64 & evalData.pawnbits[black]) || (ranks[p.k[black]] == 7);
}

bool brseven()
{
	return (2 & evalData.pawnbits[white]) || (ranks[p.k[white]] == 0);
}

void development()
{
	int wdev = 0, bdev = 0;
	if(p.board[C1].typ == wB) wdev++;
	if(p.board[B1].typ == wN) wdev++;
	if(p.board[F1].typ == wB) wdev++;
	if(p.board[G1].typ == wN) wdev++;
	if(p.board[C8].typ == bB) bdev++;
	if(p.board[B8].typ == bN) bdev++;
	if(p.board[F8].typ == bB) bdev++;
	if(p.board[G8].typ == bN) bdev++;
	
	evalData.score[black][beg] -= developpenalty[bdev];
	evalData.score[white][beg] -= developpenalty[wdev];
}

bool dowks()
{
	return (evalData.bQc > 0)&&(evalData.bRc+evalData.bBc+evalData.bNc > 1);
}

bool dobks()
{
	return (evalData.wQc > 0)&&(evalData.wRc+evalData.wBc+evalData.wNc > 1);
}

void blockedpawn()
{
	if(p.board[D2].typ == wP && p.board[D3].typ != ety)
	{
		evalData.score[white][beg] -= 40;
	}
	if(p.board[E2].typ == wP && p.board[E3].typ != ety)
	{
		evalData.score[white][beg] -= 40;
	}
	if(p.board[D7].typ == bP && p.board[D6].typ != ety)
	{
		evalData.score[black][beg] -= 40;
	}
	if(p.board[E7].typ == bP && p.board[E6].typ != ety)
	{
		evalData.score[black][beg] -= 40;
	}
}

void wrooktrapped(int sq)
{
	if(sq == H1 || sq == G1)
	{
		if(p.k[white] == F1 || p.k[white] == G1)
		{
			evalData.score[white][beg] -= 70;
		}
	}
	else if(sq == A1 || sq == B1)
	{
		if(p.k[white] == C1 || p.k[white] == B1)
		{
			evalData.score[white][beg] -= 70;
		}
	}
}

void brooktrapped(int sq)
{
	if(sq == H8 || sq == G8)
	{
		if(p.k[black] == F8 || p.k[black] == G8)
		{
			evalData.score[black][beg] -= 70;
		}
	}
	else if(sq == A8 || sq == B8)
	{
		if(p.k[black] == C8 || p.k[black] == B8)
		{
			evalData.score[black][beg] -= 70;
		}
	}	
}

void bishoppair()
{
	if(evalData.wBc == 2)
	{
		evalData.score[white][beg] += 50;
		evalData.score[white][end] += 50;
	}
	if(evalData.bBc == 2)
	{
		evalData.score[black][beg] += 50;
		evalData.score[black][end] += 50;
	}
}

int whitekingsafety(int sq)
{
	int file = files[sq]+1;
	int rank = ranks[sq];
	int fpen = 0;
	fpen += whitepawncover(file, rank);
	if(file > 1)
		fpen += whitepawncover(file-1, rank);
	if(file < 8)
		fpen += whitepawncover(file+1, rank);
	int ourscore = 0;
	if(p.castleflags & 12)
	{
		if(fpen < 21)
			ourscore -= 25;
		if(evalData.pawns[white][file] == 0)
		{
			ourscore -= 10;
		}
		if(evalData.pawns[black][file] == 0)
		{
			ourscore -= 10;
		}
	}
	else
	{
		ourscore += fpen;
	}
	return (ourscore * eo.kingSafety) / 128;
}

int blackkingsafety(int sq)
{
	int file = files[sq]+1;
	int rank = ranks[sq];
	int fpen = 0;
	fpen += whitepawncover(file, rank);
	if(file > 1)
		fpen += whitepawncover(file-1, rank);
	if(file < 8)
		fpen += whitepawncover(file+1, rank);
	int ourscore = 0;
	if(p.castleflags & 3)
	{
		if(fpen < 21)
			ourscore -= 25;
		if(evalData.pawns[white][file] == 0)
		{
			ourscore -= 10;
		}
		if(evalData.pawns[black][file] == 0)
		{
			ourscore -= 10;
		}
	}
	else
	{
		ourscore += fpen;
	}
	return (ourscore * eo.kingSafety) / 128;
}

int whitepawncover(int file, int rank)
{
	int ourscore = 0;
	if(evalData.pawns[white][file] && rank < evalData.pawn_set[white][file]-rank)
	{
		ourscore -= kpdist[evalData.pawn_set[white][file]-rank];
	}
	else
	{
		ourscore -= 35;
	}
	return ourscore;
}

int blackpawncover(int file,int rank)
{
	int ourscore = 0;
	if(evalData.pawns[black][file] && rank < evalData.pawn_set[white][file]-rank)
	{
		ourscore -= kpdist[evalData.pawn_set[white][file]-rank];
	}
	else
	{
		ourscore -= 35;
	}
	return ourscore;	
}

void pawnstorm()
{
	int wkf = files[p.k[white]] + 1;
	int bkf = files[p.k[black]] + 1;
	
	evalData.score[white][beg] += wstorm[evalData.pawn_set[white][bkf-1]];
	evalData.score[white][beg] += wstorm[evalData.pawn_set[white][bkf]];
	evalData.score[white][beg] += wstorm[evalData.pawn_set[white][bkf+1]];
	
	evalData.score[black][beg] += bstorm[evalData.pawn_set[black][bkf-1]];
	evalData.score[black][beg] += bstorm[evalData.pawn_set[black][bkf]];
	evalData.score[black][beg] += bstorm[evalData.pawn_set[black][bkf+1]];
	
	if(evalData.pawns[black][wkf] == 0)
		evalData.score[black][beg] += 15;
	if(evalData.pawns[black][wkf-1] == 0)
		evalData.score[black][beg] += 12;
	if(evalData.pawns[black][wkf+1] == 0)
		evalData.score[black][beg] += 12;
		
	if(evalData.pawns[white][bkf] == 0)
		evalData.score[white][beg] += 15;
	if(evalData.pawns[white][bkf-1] == 0)
		evalData.score[white][beg] += 12;
	if(evalData.pawns[white][bkf+1] == 0)
		evalData.score[white][beg] += 12;
}

void whitepawnsstructure(int sq)
{
	int file = files[sq]+1;
	int rank = ranks[sq];
	int b = 0, i = 0;
	int escore = 0;
	int mscore = 0;
	
	if(evalData.pawns[white][file] > 1)
	{
		mscore -= 4;
		escore -= 8;
		evalData.defects[white]++;
	}
	
	if(evalData.pawn_set[white][file-1] > rank && evalData.pawn_set[white][file+1] > rank)
	{
		if(rank > 1)
		{
			mscore -= 10;
			escore -= 20;
		}
		evalData.defects[white]++;
		b = 1;
		if(evalData.pawns[white][file-1] == 0 && evalData.pawns[white][file+1] == 0)
		{
			if(rank > 1)
			{
				mscore -= 10;
				escore -= 20;
			}
			i = 1;			
		}
	}
	if(evalData.pawns[black][file] == 0)
	{
		if(b)
			mscore -= 10;
		if(i)
			mscore -= 10;		
	}
	if(evalData.pawn_set[black][file-1] <= rank && evalData.pawn_set[black][file] < rank
		&& evalData.pawn_set[black][file+1] <= rank)
	{
		wpp(sq);
	}
	evalData.score[white][beg] += (mscore * eo.pawnStructure) / 128;
	evalData.score[white][end] += (escore * eo.pawnStructure) / 128;
}

void blackpawnsstructure(int sq)
{
	int file = files[sq]+1;
	int rank = ranks[sq];
	int b = 0, i = 0;
	int escore = 0;
	int mscore = 0;
	
	if(evalData.pawns[black][file] > 1)
	{
		mscore -= 4;
		escore -= 8;
		evalData.defects[black]++;
	}
	
	if(evalData.pawn_set[black][file-1] < rank && evalData.pawn_set[black][file+1] < rank)
	{
		if(rank < 6)
		{
			mscore -= 10;
			escore -= 20;
		}
		evalData.defects[black]++;
		b = 1;
		if(evalData.pawns[black][file-1] == 0 && evalData.pawns[black][file+1] == 0)
		{
			if(rank < 6)
			{
				mscore -= 10;
				escore -= 20;
			}
			i = 1;			
		}
	}
	if(evalData.pawns[white][file] == 0)
	{
		if(b)
			mscore -= 10;
		if(i)
			mscore -= 10;		
	}
	if(evalData.pawn_set[white][file-1] >= rank && evalData.pawn_set[white][file] > rank
		&& evalData.pawn_set[white][file+1] >= rank)
	{
		bpp(sq);
	}
	evalData.score[black][beg] += (mscore * eo.pawnStructure) / 128;
	evalData.score[black][end] += (escore * eo.pawnStructure) / 128;	
}

void wpp(int sq)
{
	int rank = ranks[sq];
	int mscore = mppawn[white][rank];
	int escore = eppawn[white][rank];
	if(p.board[sq+12].typ != ety)
	{
		mscore >>= 1;
		escore >>= 1;
	}
	if(p.board[sq+1].typ == wP || p.board[sq-11].typ == wP)
	{
		mscore += mppawn[white][rank]>>2;
		mscore += eppawn[white][rank]>>1;
	}
	if(p.board[sq-1].typ == wP || p.board[sq-13].typ == wP)
	{
		mscore += mppawn[white][rank]>>2;
		mscore += eppawn[white][rank]>>1;		
	}
	mscore += kmdppawn[distancetable[p.k[white]][sq]] >> 2;
	mscore -= kmdppawn[distancetable[p.k[black]][sq]] >> 2;
	escore += kmdppawn[distancetable[p.k[white]][sq]] >> 2;
	escore -= kmdppawn[distancetable[p.k[black]][sq]] >> 2;
	if(evalData.bmajors == 0)
	{
		int psq = sq+(7-ranks[sq])*12;
		if(distancetable[p.k[black]][psq] > distancetable[sq][psq])
		{
			escore += 800;
		}
	}
	evalData.score[white][beg] += (mscore * eo.passedPawn) / 128;
	evalData.score[white][end] += (escore * eo.passedPawn) / 128;
}

void bpp(int sq)
{
	int rank = ranks[sq];
	int mscore = mppawn[black][rank];
	int escore = eppawn[black][rank];
	if(p.board[sq+12].typ != ety)
	{
		mscore >>= 1;
		escore >>= 1;
	}
	if(p.board[sq+1].typ == bP || p.board[sq+13].typ == bP)
	{
		mscore += mppawn[black][rank]>>2;
		mscore += eppawn[black][rank]>>1;
	}
	if(p.board[sq-1].typ == wP || p.board[sq-11].typ == wP)
	{
		mscore += mppawn[white][rank]>>2;
		mscore += eppawn[white][rank]>>1;		
	}
	mscore += kmdppawn[distancetable[p.k[black]][sq]] >> 2;
	mscore -= kmdppawn[distancetable[p.k[white]][sq]] >> 2;
	escore += kmdppawn[distancetable[p.k[black]][sq]] >> 2;
	escore -= kmdppawn[distancetable[p.k[white]][sq]] >> 2;
	if(evalData.wmajors == 0)
	{
		int psq = sq-(ranks[sq]*12);
		if(distancetable[p.k[white]][psq] > distancetable[sq][psq])
		{
			escore += 800;
		}
	}
	evalData.score[black][beg] += (mscore * eo.passedPawn) / 128;
	evalData.score[black][end] += (escore * eo.passedPawn) / 128;	
}

int wNsupport(int sq)
{
	int score = SupN[sq];
	if(score == 0)
		return score;
	if(evalData.pawn_set[black][files[sq+2]] <= ranks[sq] && evalData.pawn_set[black][files[sq]] <= ranks[sq])
	{
		if(evalData.bNc == 0)
		{
			if((evalData.bBc == 0) || (evalData.bBc == 1 && sqcol[evalData.bBsq] != sqcol[sq]))
			{
				return score;
			}
			else
			{
				return score >> 2;
			}
		}
	}
	return score;
}

int bNsupport(int sq)
{
	int score = SupN[opp[sq]];
	if(score == 0)
		return score;
	if(evalData.pawn_set[white][files[sq+2]] >= ranks[sq] && evalData.pawn_set[white][files[sq]] >= ranks[sq])
	{
		if(evalData.wNc == 0)
		{
			if((evalData.wBc == 0) || (evalData.wBc == 1 && sqcol[evalData.wBsq] != sqcol[sq]))
			{
				return score;
			}
			else
			{
				return score >> 2;
			}
		}
	}
	return score;
}

bool isdrawnp()
{
	if(!evalData.wRc && !evalData.bRc && !evalData.wQc && !evalData.bQc)
	{
		if(!evalData.bBc && !evalData.wBc)
		{
			if(evalData.wNc < 3 && evalData.bNc < 3)
			{
				return false;
			}
			else if (!evalData.wNc && !evalData.bNc)
			{
				if(abs(evalData.wBc - evalData.bBc)<2)
				{
					return false;
				}
			}
			else if((evalData.wNc<3 && !evalData.wBc) || (evalData.wBc == 1 && !evalData.wNc))
			{
				if((evalData.bNc < 3 && !evalData.bBc) || (evalData.bBc == 1 && !evalData.bNc))
				{
					return false;
				}
			}
		}
	}
	else if (!evalData.wQc && !evalData.bQc)
	{
		if(evalData.wRc == 1 && evalData.wRc == 1)
		{
			if((evalData.wNc+evalData.wBc)<2 && (evalData.bNc+evalData.bBc)<2)
			{
				return false;
			}
		}
		else if (evalData.wRc == 1 && !evalData.bRc)
		{
			if((evalData.wNc+evalData.wBc == 0) && (((evalData.bNc+evalData.bBc) == 1) || ((evalData.bNc+evalData.bBc) == 2)))
			{
				return false;
			}
		}
		else if (evalData.bRc == 1 && !evalData.wRc)
		{
			if((evalData.bNc+evalData.bBc == 0) && (((evalData.wNc+evalData.wBc) == 1) || ((evalData.wNc+evalData.wBc) == 2)))
			{
				return false;
			}
		}
	}
	return true;
}

void wbishopmob(int sq)
{
	int t, m = 0;
	for(t = sq+11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	evalData.score[white][beg] += m;
	evalData.score[white][end] += m*2;	
}

void bbishopmob(int sq)
{
	int t, m = 0;
	for(t = sq+11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	evalData.score[black][beg] += m;
	evalData.score[black][end] += m*2;		
}

void wrookmob(int sq)
{
	int t, m = 0;
	for(t = sq+1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	evalData.score[white][end] += m*2;	
}

void brookmob(int sq)
{
	int t, m = 0;
	for(t = sq+1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	evalData.score[black][end] += m*2;		
}

void wqueenmob(int sq)
{
	int t, m = 0;
	for(t = sq+1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	evalData.score[white][end] += m*2;
}

void bqueenmob(int sq)
{
	int t, m = 0;
	for(t = sq+1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq+13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-1;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-12;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-11;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	for(t = sq-13;; t+=1)
	{
		if(p.board[t].typ != ety)
			break;
		m++;
	}
	evalData.score[black][end] += m*2;	
}

void wknightmob(int sq)
{
	int m = 0;
	if(p.board[sq+25].typ == ety)
		m++;
	if(p.board[sq+14].typ == ety)
		m++;
	if(p.board[sq+10].typ == ety)
		m++;
	if(p.board[sq+23].typ == ety)
		m++;
	if(p.board[sq-25].typ == ety)
		m++;
	if(p.board[sq-14].typ == ety)
		m++;
	if(p.board[sq-10].typ == ety)
		m++;
	if(p.board[sq-23].typ == ety)
		m++;
	evalData.score[white][end] += m;
}

void bknightmob(int sq)
{
	int m = 0;
	if(p.board[sq+25].typ == ety)
		m++;
	if(p.board[sq+14].typ == ety)
		m++;
	if(p.board[sq+10].typ == ety)
		m++;
	if(p.board[sq+23].typ == ety)
		m++;
	if(p.board[sq-25].typ == ety)
		m++;
	if(p.board[sq-14].typ == ety)
		m++;
	if(p.board[sq-10].typ == ety)
		m++;
	if(p.board[sq-23].typ == ety)
		m++;
	evalData.score[black][beg] += m;	
}

void mymemset()
{
	evalData.score[0][0] = 0;
	evalData.score[1][0] = 0;
	evalData.score[0][1] = 0;
	evalData.score[1][1] = 0;
	
	evalData.pawn_set[0][0] = 0;
	evalData.pawn_set[0][1] = 0;
	evalData.pawn_set[0][2] = 0;
	evalData.pawn_set[0][3] = 0;
	evalData.pawn_set[0][4] = 0;
	evalData.pawn_set[0][5] = 0;
	evalData.pawn_set[0][6] = 0;
	evalData.pawn_set[0][7] = 0;
	evalData.pawn_set[0][8] = 0;
	evalData.pawn_set[0][9] = 0;
	evalData.pawn_set[1][0] = 7;
	evalData.pawn_set[1][1] = 7;
	evalData.pawn_set[1][2] = 7;
	evalData.pawn_set[1][3] = 7;
	evalData.pawn_set[1][4] = 7;
	evalData.pawn_set[1][5] = 7;
	evalData.pawn_set[1][6] = 7;
	evalData.pawn_set[1][7] = 7;
	evalData.pawn_set[1][8] = 7;
	evalData.pawn_set[1][9] = 7;
	
	evalData.pawns[0][0] = 0;
	evalData.pawns[0][1] = 0;
	evalData.pawns[0][2] = 0;
	evalData.pawns[0][3] = 0;
	evalData.pawns[0][4] = 0;
	evalData.pawns[0][5] = 0;
	evalData.pawns[0][6] = 0;
	evalData.pawns[0][7] = 0;
	evalData.pawns[0][8] = 0;
	evalData.pawns[0][9] = 0;
	evalData.pawns[1][0] = 0;
	evalData.pawns[1][1] = 0;
	evalData.pawns[1][2] = 0;
	evalData.pawns[1][3] = 0;
	evalData.pawns[1][4] = 0;
	evalData.pawns[1][5] = 0;
	evalData.pawns[1][6] = 0;
	evalData.pawns[1][7] = 0;
	evalData.pawns[1][8] = 0;
	evalData.pawns[1][9] = 0;
	
	evalData.pawnbits[0] = 0;
	evalData.pawnbits[1] = 0;
	
	evalData.defects[0] = 0;
	evalData.defects[1] = 0;
	
	evalData.wRc = 0;
	evalData.bRc = 0;
	evalData.wQc = 0;
	evalData.bQc = 0;
	evalData.wNc = 0;
	evalData.bNc = 0;
	evalData.wBc = 0;
	evalData.bBc = 0;
	evalData.wQf = 0;
	evalData.bQf = 0;
	evalData.wBsq = 0;
	evalData.bBsq = 0;
	evalData.wmajors = 0;
	evalData.bmajors = 0;
	evalData.wpawns = 0;
	evalData.bpawns = 0;
}