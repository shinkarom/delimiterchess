public import psqt;

enum : int { wP = 1, bP, wN, bN, wB, bB, wR, bR, wQ, bQ, wK, bK, ety };
enum : int { WKC = 8, BKC = 4, WQC = 2, BQC = 1 };
enum : int { NOFLAG, LOWER, UPPER, EXACT };
enum : int {	A1 = 26, B1, C1, D1, E1, F1, G1, H1, 
				A2 = 38, B2, C2, D2, E2, F2, G2, H2, 
				A3 = 50, B3, C3, D3, E3, F3, G3, H3, 
				A4 = 62, B4, C4, D4, E4, F4, G4, H4, 
				A5 = 74, B5, C5, D5, E5, F5, G5, H5, 
				A6 = 86, B6, C6, D6, E6, F6, G6, H6, 
				A7 = 98, B7, C7, D7, E7, F7, G7, H7, 
				A8 = 110, B8, C8, D8, E8, F8, G8, H8 
			};
immutable int noenpas = 0, nopiece = 0, deadsquare = 0, edge = 0;

enum : int { black, white };

immutable int wpco = 1, bpco = 1, npco = 13;

enum : int { vP = 90, vN = 325, vB = 325, vR = 500, vQ = 900, vK = 10000 };

immutable string startfen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

enum : int { mCA = 0x20000, mPST = 0x40000, mPEP = 0x180000, mCAP = 0x100000, mPQ = 0x600000, mPR = 0xa00000, mPB = 0x1200000, mPN = 0x2200000, mNORM = 0x10000, mProm = 0x200000 };

pure int TO(int x) { return x&0xff; };
pure int FROM(int x) { return (x&0xff00)>>8; };
pure int FLAG(int x) { return x&0xfff0000; };

enum : int { oPQ = 0x400000, oPR = 0x800000, oPB = 0x1000000, oPN = 0x2000000, oPEP = 0x80000 };

immutable int PLY = 64;

struct s_Move
{
	int m;
	int score;
}

struct s_Pce
{
	int col;
	int typ;
}

struct s_Hist
{
	int data;
	int en_pas;
	ulong hashkey;
	s_Pce captured;
	int castleflags;
	int plistep;
	int plist;
	int fifty;
}

struct s_EvalOptions
{
	int pawnstructure;
	int passedpawn;
	int kingsafety;
}

struct s_Position
{
	int[17] pcenumtosq;
	int[144] sqtopcenum;
	int pcenum;
	int majors;
	int castleflags;
	int fifty;
	int side;
	int en_pas;
	int ply;
	int[2] material;
	ulong hashkey;
	s_Move[9600] list;
	int[512] listc;
	s_Pce[144] board;
	int[2] k;
}

struct s_Hashelem
{
	ulong hashkey;
	short depth;
	short flag;
	short Null;
	int move;
}

struct s_EvalData
{
	int wRc;
	int bRc;
	int wQf;
	int bQf;
	int wNc;
	int bNc;
	int wBc;
	int bBc;
	int wQc;
	int bQc;
	int wBsq;
	int bBsq;
	int bmajors;
	int wmajors;
	int bpawns;
	int wpawns;
	int[10][2] pawn_set;
	int[10][2] pawns;
	int[2] pawnbits;
	int[2][2] score;
	int[2] defects;
}

struct s_Atab
{
	int[144][2] atttab;
}

struct s_SearchParam
{
	int depth;
	double wtime;
	double btime;
	double winc;
	double binc;
	double xtime;
	double xotime;
	int inf;
	double movestogo;
	double timepermove;
	double starttime;
	double stoptime;
	int pon;
	int cpon;
	int ponderhit;
	int xbmode;
	int ucimode;
	int post;
	int force;
	int usebook;
}

