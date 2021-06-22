import std.math, std.stdio;
import data, defines, psqt, io;

const int beg = 0, end = 1;
const int[16] blockerbonus = [
	0, 0, 0, 15, 15, 12, 12, 7, 7, 2, 2, 0, 0, 0, 0, 0
];
const int[16] developpenalty = [
	0, 5, 8, 12, 18, 25, 35, 47, 68, 80, 105, 130, 130, 130, 130, 130
];
const int[32] bishoppairbonus = [
	20, 18, 17, 15, 12, 10, 6, 6, 6, 0, 0, 0, -5, -10, -15, -20, -20, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
];
const int[8] wstorm = [0, -5, 0, 5, 10, 15, 20, 0];
const int[8] bstorm = [0, 20, 15, 10, 5, 0, -5, 0];
const int[9] pdefect = [0, 0, 5, 10, 15, 20, 60, 60, 60];
const int[8] pbit = [1, 2, 4, 8, 16, 32, 64, 128];
const int[8][2] mppawn = [
	[0, 50, 30, 20, 10, 0, 0, 0], [0, 0, 0, 10, 20, 30, 50, 0]
];
const int[8][2] eppawn = [
	[0, 75, 60, 45, 30, 15, 5, 0], [0, 5, 15, 30, 45, 60, 75, 0]
];
const int[8] kmdppawn = [0, 150, 100, 50, 25, 10, 5, 0];
const int[8] kdeppawn = [0, 200, 150, 80, 40, 25, 10, 0];
const int[8] kpdist = [0, 0, 10, 20, 26, 31, 35, 38];
const int[8] ntrop = [0, 10, 7, 4, 2, 0, 0, 0];
const int[8] ptrop = [0, 15, 10, 6, 4, 0, 0, 0];
const int[8] rtrop = [0, 8, 5, 2, 1, 0, 0, 0];
const int[8] qtrop = [0, 6, 4, 2, 1, 0, 0, 0];

int[144][144] distancetable;

void initDistanceTable()
{
	for (int i = 0; i < 144; i++)
		for (int j = 0; j < 144; j++)
			distancetable[i][j] = 0;

	for (int i = 0; i < 144; i++)
	{
		int ri = ranks[i];
		int fi = files[i];
		for (int j = 0; j < 144; j++)
		{
			int rj = ranks[j];
			int fj = files[j];
			distancetable[i][j] = abs(ri - rj) > abs(fi - fj) ? abs(ri - rj) : abs(ri - rj);
		}
	}
}

void initEval()
{
	myMemset();
	for (int index = 1; index <= p.pceNum; index++)
	{
		if (p.pceNumToSq[index] == 0)
			continue;
		int sq = p.pceNumToSq[index];
		switch (p.board[sq])
		{
		case SquareType.wR:
			evalData.wRc++;
			evalData.wmajors++;
			break;
		case SquareType.wN:
			evalData.wNc++;
			evalData.wmajors++;
			break;
		case SquareType.wB:
			evalData.wBc++;
			evalData.wmajors++;
			evalData.wBsq = sq;
			break;
		case SquareType.wQ:
			evalData.wQc++;
			evalData.wmajors++;
			break;
		case SquareType.wK:
			break;
		case SquareType.wP:
			int f = files[sq] + 1;
			if (evalData.pawn_set[Side.White][f] > ranks[sq])
			{
				evalData.pawn_set[Side.White][f] = ranks[sq];
			}
			evalData.wpawns++;
			evalData.pawns[Side.White][f]++;
			evalData.pawnbits[Side.White] += pbit[ranks[sq]];
			break;
		case SquareType.bR:
			evalData.bRc++;
			evalData.bmajors++;
			break;
		case SquareType.bN:
			evalData.bNc++;
			evalData.bmajors++;
			break;
		case SquareType.bB:
			evalData.bBc++;
			evalData.bmajors++;
			evalData.bBsq = sq;
			break;
		case SquareType.bQ:
			evalData.bQc++;
			evalData.bmajors++;
			break;
		case SquareType.bK:
			break;
		case SquareType.bP:
			int f = files[sq] + 1;
			if (evalData.pawn_set[Side.Black][f] > ranks[sq])
			{
				evalData.pawn_set[Side.Black][f] = ranks[sq];
			}
			evalData.bpawns++;
			evalData.pawns[Side.Black][f]++;
			evalData.pawnbits[Side.Black] += pbit[ranks[sq]];
			break;
		default:
			break;
		}
	}
}

int gameEval()
{
	initEval();
	midgameEval();
	int phase = 24 - ((evalData.wQc + evalData.bQc) * 4 + (
			evalData.wRc + evalData.bRc) * 2 + (evalData.wBc + evalData.bBc) + (
			evalData.wNc + evalData.bNc));
	if (phase < 0)
		phase = 0;
	phase = (phase * 256 + (24 * 2)) / 24;
	int send = evalData.score[Side.White][end] - evalData.score[Side.Black][end];
	int sbeg = evalData.score[Side.White][beg] - evalData.score[Side.Black][beg];
	int score = ((sbeg * (256 - phase)) + (send * phase)) / 256;
	if (p.side == Side.White)
	{
		return score;
	}
	else
	{
		return -score;
	}
}

void midgameEval()
{
	if (evalData.wpawns + evalData.bpawns == 0)
	{
		if (!isDrawnP())
		{
			evalData.score[Side.White][beg] = 0;
			evalData.score[Side.White][end] = 0;
			evalData.score[Side.Black][beg] = 0;
			evalData.score[Side.Black][end] = 0;
		}
	}

	for (int index = 1; index <= p.pceNum; index++)
	{
		if (p.pceNumToSq[index] == 0)
			continue;

		int sq = p.pceNumToSq[index];

		switch (p.board[sq])
		{
		case SquareType.wP:
			evalData.score[Side.White][beg] += vP;
			evalData.score[Side.White][beg] += Pawn[sq];
			evalData.score[Side.White][end] += vP;
			whitePawnsStructure(sq);
			break;
		case SquareType.wN:
			evalData.score[Side.White][beg] += vN;
			evalData.score[Side.White][beg] += Knight[sq];
			evalData.score[Side.White][end] += vN;
			evalData.score[Side.White][end] += eKnight[sq];
			evalData.score[Side.White][beg] += wNSupport(sq);
			wKnightMob(sq);
			break;
		case SquareType.wB:
			evalData.score[Side.White][beg] += vB;
			evalData.score[Side.White][beg] += Bishop[sq];
			evalData.score[Side.White][end] += vB;
			evalData.score[Side.White][end] += eBishop[sq];
			wBishopMob(sq);
			break;
		case SquareType.wR:
			evalData.score[Side.White][beg] += vR;
			evalData.score[Side.White][beg] += Rook[sq];
			evalData.score[Side.White][end] += vR;
			wRookTrapped(sq);
			wRookMob(sq);
			if (evalData.pawns[Side.White][files[sq] + 1] == 0)
			{
				evalData.score[Side.White][beg] += 8;
				evalData.score[Side.White][end] += 15;
				if (evalData.pawns[Side.Black][files[sq] + 1] == 0)
				{
					evalData.score[Side.White][beg] += 5;
					evalData.score[Side.White][end] += 10;
				}
				if (abs(files[sq] - files[p.kingSquares[Side.Black]]) <= 1)
				{
					evalData.score[Side.White][beg] += 8;
					if (files[sq] == files[p.kingSquares[Side.Black]])
					{
						evalData.score[Side.White][beg] += 8;
					}
				}
			}
			if (ranks[sq] == 6 && wrSeven())
			{
				evalData.score[Side.White][beg] += 10;
				evalData.score[Side.White][end] += 20;
			}
			break;
		case SquareType.wQ:
			evalData.score[Side.White][beg] += vQ;
			evalData.score[Side.White][end] += vQ;
			wQueenMob(sq);
			if (ranks[sq] == 6 && wrSeven())
			{
				evalData.score[Side.White][beg] += 5;
				evalData.score[Side.White][end] += 10;
			}
			break;
		case SquareType.wK:
			evalData.score[Side.White][beg] += KingMid[sq];
			evalData.score[Side.White][end] += KingEnd[sq];
			if (doWks())
			{
				evalData.score[Side.White][beg] += whiteKingSafety(sq);
			}
			break;
		case SquareType.bP:
			evalData.score[Side.Black][beg] += vP;
			evalData.score[Side.Black][beg] += Pawn[opp[sq]];
			evalData.score[Side.Black][end] += vP;
			blackPawnsStructure(sq);
			break;
		case SquareType.bN:
			evalData.score[Side.Black][beg] += vN;
			evalData.score[Side.Black][beg] += Knight[opp[sq]];
			evalData.score[Side.Black][end] += vN;
			evalData.score[Side.Black][end] += eKnight[opp[sq]];
			evalData.score[Side.Black][beg] += bNSupport(sq);
			bKnightMob(sq);
			break;
		case SquareType.bB:
			evalData.score[Side.Black][beg] += vB;
			evalData.score[Side.Black][beg] += Bishop[opp[sq]];
			evalData.score[Side.Black][end] += vB;
			evalData.score[Side.Black][end] += eBishop[opp[sq]];
			bBishopMob(sq);
			break;
		case SquareType.bR:
			evalData.score[Side.Black][beg] += vR;
			evalData.score[Side.Black][beg] += Rook[opp[sq]];
			evalData.score[Side.Black][end] += vR;
			bRookTrapped(sq);
			bRookMob(sq);
			if (evalData.pawns[Side.Black][files[sq] + 1] == 0)
			{
				evalData.score[Side.Black][beg] += 8;
				evalData.score[Side.Black][end] += 15;
				if (evalData.pawns[Side.White][files[sq] + 1] == 0)
				{
					evalData.score[Side.Black][beg] += 5;
					evalData.score[Side.Black][end] += 10;
				}
				if (abs(files[sq] - files[p.kingSquares[Side.White]]) <= 1)
				{
					evalData.score[Side.Black][beg] += 8;
					if (files[sq] == files[p.kingSquares[Side.White]])
					{
						evalData.score[Side.Black][beg] += 8;
					}
				}
			}
			if (ranks[sq] == 1 && brSeven())
			{
				evalData.score[Side.Black][beg] += 10;
				evalData.score[Side.Black][end] += 20;
			}
			break;
		case SquareType.bQ:
			evalData.score[Side.Black][beg] += vQ;
			evalData.score[Side.Black][end] += vQ;
			bQueenMob(sq);
			if (ranks[sq] == 1 && brSeven())
			{
				evalData.score[Side.Black][beg] += 5;
				evalData.score[Side.Black][end] += 10;
			}
			break;
		case SquareType.bK:
			evalData.score[Side.Black][beg] += KingMid[opp[sq]];
			evalData.score[Side.Black][end] += KingEnd[opp[sq]];
			if (doBks())
			{
				evalData.score[Side.Black][beg] += blackKingSafety(sq);
			}
			break;
		default:
			break;
		}
	}
	development();
	blockedPawn();
	bishopPair();
	if (abs(files[p.kingSquares[Side.White]] - files[p.kingSquares[Side.Black]]) > 2)
	{
		pawnStorm();
	}
}

bool wrSeven()
{
	return (64 & evalData.pawnbits[Side.Black]) || (ranks[p.kingSquares[Side.Black]] == 7);
}

bool brSeven()
{
	return (2 & evalData.pawnbits[Side.White]) || (ranks[p.kingSquares[Side.White]] == 0);
}

void development()
{
	int wdev = 0, bdev = 0;
	if (p.board[Square.C1] == SquareType.wB)
		wdev++;
	if (p.board[Square.B1] == SquareType.wN)
		wdev++;
	if (p.board[Square.F1] == SquareType.wB)
		wdev++;
	if (p.board[Square.G1] == SquareType.wN)
		wdev++;
	if (p.board[Square.C8] == SquareType.bB)
		bdev++;
	if (p.board[Square.B8] == SquareType.bN)
		bdev++;
	if (p.board[Square.F8] == SquareType.bB)
		bdev++;
	if (p.board[Square.G8] == SquareType.bN)
		bdev++;

	evalData.score[Side.Black][beg] -= developpenalty[bdev];
	evalData.score[Side.White][beg] -= developpenalty[wdev];
}

bool doWks()
{
	return (evalData.bQc > 0) && (evalData.bRc + evalData.bBc + evalData.bNc > 1);
}

bool doBks()
{
	return (evalData.wQc > 0) && (evalData.wRc + evalData.wBc + evalData.wNc > 1);
}

void blockedPawn()
{
	if (p.board[Square.D2] == SquareType.wP && p.board[Square.D3] != SquareType.Empty)
	{
		evalData.score[Side.White][beg] -= 40;
	}
	if (p.board[Square.E2] == SquareType.wP && p.board[Square.E3] != SquareType.Empty)
	{
		evalData.score[Side.White][beg] -= 40;
	}
	if (p.board[Square.D7] == SquareType.bP && p.board[Square.D6] != SquareType.Empty)
	{
		evalData.score[Side.Black][beg] -= 40;
	}
	if (p.board[Square.E7] == SquareType.bP && p.board[Square.E6] != SquareType.Empty)
	{
		evalData.score[Side.Black][beg] -= 40;
	}
}

void wRookTrapped(int sq)
{
	if (sq == Square.H1 || sq == Square.G1)
	{
		if (p.kingSquares[Side.White] == Square.F1 || p.kingSquares[Side.White] == Square.G1)
		{
			evalData.score[Side.White][beg] -= 70;
		}
	}
	else if (sq == Square.A1 || sq == Square.B1)
	{
		if (p.kingSquares[Side.White] == Square.C1 || p.kingSquares[Side.White] == Square.B1)
		{
			evalData.score[Side.White][beg] -= 70;
		}
	}
}

void bRookTrapped(int sq)
{
	if (sq == Square.H8 || sq == Square.G8)
	{
		if (p.kingSquares[Side.Black] == Square.F8 || p.kingSquares[Side.Black] == Square.G8)
		{
			evalData.score[Side.Black][beg] -= 70;
		}
	}
	else if (sq == Square.A8 || sq == Square.B8)
	{
		if (p.kingSquares[Side.Black] == Square.C8 || p.kingSquares[Side.Black] == Square.B8)
		{
			evalData.score[Side.Black][beg] -= 70;
		}
	}
}

void bishopPair()
{
	if (evalData.wBc == 2)
	{
		evalData.score[Side.White][beg] += 50;
		evalData.score[Side.White][end] += 50;
	}
	if (evalData.bBc == 2)
	{
		evalData.score[Side.Black][beg] += 50;
		evalData.score[Side.Black][end] += 50;
	}
}

int whiteKingSafety(int sq)
{
	int file = files[sq] + 1;
	int rank = ranks[sq];
	int fpen = 0;
	fpen += whitePawnCover(file, rank);
	if (file > 1)
		fpen += whitePawnCover(file - 1, rank);
	if (file < 8)
		fpen += whitePawnCover(file + 1, rank);
	int ourscore = 0;
	if (p.castleFlags & 12)
	{
		if (fpen < 21)
			ourscore -= 25;
		if (evalData.pawns[Side.White][file] == 0)
		{
			ourscore -= 10;
		}
		if (evalData.pawns[Side.Black][file] == 0)
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

int blackKingSafety(int sq)
{
	int file = files[sq] + 1;
	int rank = ranks[sq];
	int fpen = 0;
	fpen += whitePawnCover(file, rank);
	if (file > 1)
		fpen += whitePawnCover(file - 1, rank);
	if (file < 8)
		fpen += whitePawnCover(file + 1, rank);
	int ourscore = 0;
	if (p.castleFlags & 3)
	{
		if (fpen < 21)
			ourscore -= 25;
		if (evalData.pawns[Side.White][file] == 0)
		{
			ourscore -= 10;
		}
		if (evalData.pawns[Side.Black][file] == 0)
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

int whitePawnCover(int file, int rank)
{
	int ourscore = 0;
	if (evalData.pawns[Side.White][file] && rank < evalData.pawn_set[Side.White][file] - rank)
	{
		ourscore -= kpdist[evalData.pawn_set[Side.White][file] - rank];
	}
	else
	{
		ourscore -= 35;
	}
	return ourscore;
}

int blackPawnCover(int file, int rank)
{
	int ourscore = 0;
	if (evalData.pawns[Side.Black][file] && rank < evalData.pawn_set[Side.White][file] - rank)
	{
		ourscore -= kpdist[evalData.pawn_set[Side.White][file] - rank];
	}
	else
	{
		ourscore -= 35;
	}
	return ourscore;
}

void pawnStorm()
{
	int wkf = files[p.kingSquares[Side.White]] + 1;
	int bkf = files[p.kingSquares[Side.Black]] + 1;

	evalData.score[Side.White][beg] += wstorm[evalData.pawn_set[Side.White][bkf - 1]];
	evalData.score[Side.White][beg] += wstorm[evalData.pawn_set[Side.White][bkf]];
	evalData.score[Side.White][beg] += wstorm[evalData.pawn_set[Side.White][bkf + 1]];

	evalData.score[Side.Black][beg] += bstorm[evalData.pawn_set[Side.Black][bkf - 1]];
	evalData.score[Side.Black][beg] += bstorm[evalData.pawn_set[Side.Black][bkf]];
	evalData.score[Side.Black][beg] += bstorm[evalData.pawn_set[Side.Black][bkf + 1]];

	if (evalData.pawns[Side.Black][wkf] == 0)
		evalData.score[Side.Black][beg] += 15;
	if (evalData.pawns[Side.Black][wkf - 1] == 0)
		evalData.score[Side.Black][beg] += 12;
	if (evalData.pawns[Side.Black][wkf + 1] == 0)
		evalData.score[Side.Black][beg] += 12;

	if (evalData.pawns[Side.White][bkf] == 0)
		evalData.score[Side.White][beg] += 15;
	if (evalData.pawns[Side.White][bkf - 1] == 0)
		evalData.score[Side.White][beg] += 12;
	if (evalData.pawns[Side.White][bkf + 1] == 0)
		evalData.score[Side.White][beg] += 12;
}

void whitePawnsStructure(int sq)
{
	int file = files[sq] + 1;
	int rank = ranks[sq];
	int b = 0, i = 0;
	int escore = 0;
	int mscore = 0;

	if (evalData.pawns[Side.White][file] > 1)
	{
		mscore -= 4;
		escore -= 8;
		evalData.defects[Side.White]++;
	}

	if (evalData.pawn_set[Side.White][file - 1] > rank && evalData.pawn_set[Side.White][file + 1] > rank)
	{
		if (rank > 1)
		{
			mscore -= 10;
			escore -= 20;
		}
		evalData.defects[Side.White]++;
		b = 1;
		if (evalData.pawns[Side.White][file - 1] == 0 && evalData.pawns[Side.White][file + 1] == 0)
		{
			if (rank > 1)
			{
				mscore -= 10;
				escore -= 20;
			}
			i = 1;
		}
	}
	if (evalData.pawns[Side.Black][file] == 0)
	{
		if (b)
			mscore -= 10;
		if (i)
			mscore -= 10;
	}
	if (evalData.pawn_set[Side.Black][file - 1] <= rank
			&& evalData.pawn_set[Side.Black][file] < rank && evalData.pawn_set[Side.Black][file + 1] <= rank)
	{
		wpp(sq);
	}
	evalData.score[Side.White][beg] += (mscore * eo.pawnStructure) / 128;
	evalData.score[Side.White][end] += (escore * eo.pawnStructure) / 128;
}

void blackPawnsStructure(int sq)
{
	int file = files[sq] + 1;
	int rank = ranks[sq];
	int b = 0, i = 0;
	int escore = 0;
	int mscore = 0;

	if (evalData.pawns[Side.Black][file] > 1)
	{
		mscore -= 4;
		escore -= 8;
		evalData.defects[Side.Black]++;
	}

	if (evalData.pawn_set[Side.Black][file - 1] < rank && evalData.pawn_set[Side.Black][file + 1] < rank)
	{
		if (rank < 6)
		{
			mscore -= 10;
			escore -= 20;
		}
		evalData.defects[Side.Black]++;
		b = 1;
		if (evalData.pawns[Side.Black][file - 1] == 0 && evalData.pawns[Side.Black][file + 1] == 0)
		{
			if (rank < 6)
			{
				mscore -= 10;
				escore -= 20;
			}
			i = 1;
		}
	}
	if (evalData.pawns[Side.White][file] == 0)
	{
		if (b)
			mscore -= 10;
		if (i)
			mscore -= 10;
	}
	if (evalData.pawn_set[Side.White][file - 1] >= rank
			&& evalData.pawn_set[Side.White][file] > rank && evalData.pawn_set[Side.White][file + 1] >= rank)
	{
		bpp(sq);
	}
	evalData.score[Side.Black][beg] += (mscore * eo.pawnStructure) / 128;
	evalData.score[Side.Black][end] += (escore * eo.pawnStructure) / 128;
}

void wpp(int sq)
{
	int rank = ranks[sq];
	int mscore = mppawn[Side.White][rank];
	int escore = eppawn[Side.White][rank];
	if (p.board[sq + 12] != SquareType.Empty)
	{
		mscore >>= 1;
		escore >>= 1;
	}
	if (p.board[sq + 1] == SquareType.wP || p.board[sq - 11] == SquareType.wP)
	{
		mscore += mppawn[Side.White][rank] >> 2;
		mscore += eppawn[Side.White][rank] >> 1;
	}
	if (p.board[sq - 1] == SquareType.wP || p.board[sq - 13] == SquareType.wP)
	{
		mscore += mppawn[Side.White][rank] >> 2;
		mscore += eppawn[Side.White][rank] >> 1;
	}
	mscore += kmdppawn[distancetable[p.kingSquares[Side.White]][sq]] >> 2;
	mscore -= kmdppawn[distancetable[p.kingSquares[Side.Black]][sq]] >> 2;
	escore += kmdppawn[distancetable[p.kingSquares[Side.White]][sq]] >> 2;
	escore -= kmdppawn[distancetable[p.kingSquares[Side.Black]][sq]] >> 2;
	if (evalData.bmajors == 0)
	{
		int psq = sq + (7 - ranks[sq]) * 12;
		if (distancetable[p.kingSquares[Side.Black]][psq] > distancetable[sq][psq])
		{
			escore += 800;
		}
	}
	evalData.score[Side.White][beg] += (mscore * eo.passedPawn) / 128;
	evalData.score[Side.White][end] += (escore * eo.passedPawn) / 128;
}

void bpp(int sq)
{
	int rank = ranks[sq];
	int mscore = mppawn[Side.Black][rank];
	int escore = eppawn[Side.Black][rank];
	if (p.board[sq + 12] != SquareType.Empty)
	{
		mscore >>= 1;
		escore >>= 1;
	}
	if (p.board[sq + 1] == SquareType.bP || p.board[sq + 13] == SquareType.bP)
	{
		mscore += mppawn[Side.Black][rank] >> 2;
		mscore += eppawn[Side.Black][rank] >> 1;
	}
	if (p.board[sq - 1] == SquareType.wP || p.board[sq - 11] == SquareType.wP)
	{
		mscore += mppawn[Side.White][rank] >> 2;
		mscore += eppawn[Side.White][rank] >> 1;
	}
	mscore += kmdppawn[distancetable[p.kingSquares[Side.Black]][sq]] >> 2;
	mscore -= kmdppawn[distancetable[p.kingSquares[Side.White]][sq]] >> 2;
	escore += kmdppawn[distancetable[p.kingSquares[Side.Black]][sq]] >> 2;
	escore -= kmdppawn[distancetable[p.kingSquares[Side.White]][sq]] >> 2;
	if (evalData.wmajors == 0)
	{
		int psq = sq - (ranks[sq] * 12);
		if (distancetable[p.kingSquares[Side.White]][psq] > distancetable[sq][psq])
		{
			escore += 800;
		}
	}
	evalData.score[Side.Black][beg] += (mscore * eo.passedPawn) / 128;
	evalData.score[Side.Black][end] += (escore * eo.passedPawn) / 128;
}

int wNSupport(int sq)
{
	int score = SupN[sq];
	if (score == 0)
		return score;
	if (evalData.pawn_set[Side.Black][files[sq] + 2] <= ranks[sq]
			&& evalData.pawn_set[Side.Black][files[sq]] <= ranks[sq])
	{
		if (evalData.bNc == 0)
		{
			if ((evalData.bBc == 0) || (evalData.bBc == 1 && sqcol[evalData.bBsq] != sqcol[sq]))
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

int bNSupport(int sq)
{
	int score = SupN[opp[sq]];
	if (score == 0)
		return score;
	if (evalData.pawn_set[Side.White][files[sq] + 2] >= ranks[sq]
			&& evalData.pawn_set[Side.White][files[sq]] >= ranks[sq])
	{
		if (evalData.wNc == 0)
		{
			if ((evalData.wBc == 0) || (evalData.wBc == 1 && sqcol[evalData.wBsq] != sqcol[sq]))
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

bool isDrawnP()
{
	if (!evalData.wRc && !evalData.bRc && !evalData.wQc && !evalData.bQc)
	{
		if (!evalData.bBc && !evalData.wBc)
		{
			if (evalData.wNc < 3 && evalData.bNc < 3)
			{
				return false;
			}
			else if (!evalData.wNc && !evalData.bNc)
			{
				if (abs(evalData.wBc - evalData.bBc) < 2)
				{
					return false;
				}
			}
			else if ((evalData.wNc < 3 && !evalData.wBc) || (evalData.wBc == 1 && !evalData.wNc))
			{
				if ((evalData.bNc < 3 && !evalData.bBc) || (evalData.bBc == 1 && !evalData.bNc))
				{
					return false;
				}
			}
		}
	}
	else if (!evalData.wQc && !evalData.bQc)
	{
		if (evalData.wRc == 1 && (evalData.bRc == 1))
		{
			if ((evalData.wNc + evalData.wBc) < 2 && (evalData.bNc + evalData.bBc) < 2)
			{
				return false;
			}
		}
		else if ((evalData.wRc == 1) && !evalData.bRc)
		{
			if ((evalData.wNc + evalData.wBc == 0)
					&& (((evalData.bNc + evalData.bBc) == 1) || ((evalData.bNc + evalData.bBc) == 2)))
			{
				return false;
			}
		}
		else if (evalData.bRc == 1 && !evalData.wRc)
		{
			if ((evalData.bNc + evalData.bBc == 0)
					&& (((evalData.wNc + evalData.wBc) == 1) || ((evalData.wNc + evalData.wBc) == 2)))
			{
				return false;
			}
		}
	}
	return true;
}

void wBishopMob(int sq)
{
	int t, m = 0;
	for (t = sq + 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	evalData.score[Side.White][beg] += m;
	evalData.score[Side.White][end] += m * 2;
}

void bBishopMob(int sq)
{
	int t, m = 0;
	for (t = sq + 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	evalData.score[Side.Black][beg] += m;
	evalData.score[Side.Black][end] += m * 2;
}

void wRookMob(int sq)
{
	int t, m = 0;
	for (t = sq + 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	evalData.score[Side.White][end] += m * 2;
}

void bRookMob(int sq)
{
	int t, m = 0;
	for (t = sq + 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	evalData.score[Side.Black][end] += m * 2;
}

void wQueenMob(int sq)
{
	int t, m = 0;
	for (t = sq + 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	evalData.score[Side.White][end] += m * 2;
}

void bQueenMob(int sq)
{
	int t, m = 0;
	for (t = sq + 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq + 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 1;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 12;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 11;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	for (t = sq - 13;; t += 1)
	{
		if (p.board[t] != SquareType.Empty)
			break;
		m++;
	}
	evalData.score[Side.Black][end] += m * 2;
}

void wKnightMob(int sq)
{
	int m = 0;
	if (p.board[sq + 25] == SquareType.Empty)
		m++;
	if (p.board[sq + 14] == SquareType.Empty)
		m++;
	if (p.board[sq + 10] == SquareType.Empty)
		m++;
	if (p.board[sq + 23] == SquareType.Empty)
		m++;
	if (p.board[sq - 25] == SquareType.Empty)
		m++;
	if (p.board[sq - 14] == SquareType.Empty)
		m++;
	if (p.board[sq - 10] == SquareType.Empty)
		m++;
	if (p.board[sq - 23] == SquareType.Empty)
		m++;
	evalData.score[Side.White][end] += m;
}

void bKnightMob(int sq)
{
	int m = 0;
	if (p.board[sq + 25] == SquareType.Empty)
		m++;
	if (p.board[sq + 14] == SquareType.Empty)
		m++;
	if (p.board[sq + 10] == SquareType.Empty)
		m++;
	if (p.board[sq + 23] == SquareType.Empty)
		m++;
	if (p.board[sq - 25] == SquareType.Empty)
		m++;
	if (p.board[sq - 14] == SquareType.Empty)
		m++;
	if (p.board[sq - 10] == SquareType.Empty)
		m++;
	if (p.board[sq - 23] == SquareType.Empty)
		m++;
	evalData.score[Side.Black][beg] += m;
}

void myMemset()
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
