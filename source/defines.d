import core.time;

immutable string engineName = "Delimiter";
immutable string engineVersion = "0.1.1";
immutable string engineAuthor = "Roman Shynkarenko";

enum SquareType { bP = 0, wP, bN, wN, bB, wB, bR, wR, bQ, wQ, bK, wK, Empty, Edge }
enum Side { Black, White, None }

immutable Side[14] SquareTypeColor = [Side.Black, Side.White, Side.Black, Side.White, Side.Black, Side.White, 
Side.Black, Side.White, Side.Black, Side.White, Side.Black, Side.White, Side. None, Side.None];

immutable int WKC = 8, WQC = 4, BKC = 2, BQC = 1;
immutable int NOFLAG = 0, LOWER = 1, UPPER = 2, EXACT = 3;
immutable int A1 = 26, B1 = 27, C1 = 28, D1 = 29, E1 = 30, F1 = 31, G1 = 32,
	H1 = 33, A2 = 38, B2 = 39, C2 = 40, D2 = 41, E2 = 42, F2 = 43, G2 = 44, H2 = 45,
	A3 = 50, B3 = 51, C3 = 52, D3 = 53, E3 = 54, F3 = 55, G3 = 56, H3 = 57, A4 = 62,
	B4 = 63, C4 = 64, D4 = 65, E4 = 66, F4 = 67, G4 = 68, H4 = 69, A5 = 74, B5 = 75,
	C5 = 76, D5 = 77, E5 = 78, F5 = 79, G5 = 80, H5 = 81, A6 = 86, B6 = 87, C6 = 88,
	D6 = 89, E6 = 90, F6 = 91, G6 = 92, H6 = 93, A7 = 98, B7 = 99, C7 = 100,
	D7 = 101, E7 = 102, F7 = 103, G7 = 104, H7 = 105, A8 = 110, B8 = 111, C8 = 112,
	D8 = 113, E8 = 114, F8 = 115, G8 = 116, H8 = 117;
immutable int noenpas = 200, nopiece = 0, deadsquare = 0;

immutable int vP = 90, vN = 325, vB = 325, vR = 500, vQ = 900, vK = 10000;

immutable string startFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

immutable int mCA = 0x20000, mPST = 0x40000, mPEP = 0x180000, mCAP = 0x100000,
	mPQ = 0x600000, mPR = 0xa00000, mPB = 0x1200000, mPN = 0x2200000,
	mNORM = 0x10000, mProm = 0x200000;

pure int getTo(int x)
{
	return x & 0xff;
}

pure int getFrom(int x)
{
	return (x & 0xff00) >> 8;
}

pure int getFlag(int x)
{
	return x & 0xfff0000;
}

immutable int MOVEBITS = 0xffff;

immutable int oPQ = 0x400000, oPR = 0x800000, oPB = 0x1000000, oPN = 0x2000000, oPEP = 0x80000;

immutable int PLY = 64;

struct Move
{
	int m;
	int score;
}

struct Hist
{
	int data;
	int enPas;
	ulong hashKey;
	SquareType captured;
	int castleFlags;
	int pListEp;
	int pList;
	int fifty;
}

struct EvalOptions
{
	int pawnStructure;
	int passedPawn;
	int kingSafety;
}

struct Position
{
	int[33] pceNumToSq;
	int[144] sqToPceNum;
	int pceNum;
	int majors;
	int castleflags;
	int fifty;
	Side side;
	int en_pas;
	int ply;
	int[2] material;
	ulong hashkey;
	Move[9600] list;
	int[512] listc;
	SquareType[144] board;
	int[2] k;
}

struct HashElem
{
	ulong hashkey;
	int depth;
	int flag;
	bool nul;
	int score;
	int move;
}

struct EvalData
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

struct Atab
{
	int[144][2] atttab;
}

struct SearchParam
{
	int depth;
	ulong wtime;
	ulong btime;
	ulong winc;
	ulong binc;
	ulong xtime;
	ulong xotime;
	int inf;
	uint[2] movestogo;
	ulong timepermove;
	ulong starttime;
	ulong stoptime;
	int pon;
	int cpon;
	int ponderhit;
	int xbmode;
	int ucimode;
	int post;
	int usebook;
	int ics;
	int ponfrom;
	int ponto;
	double pontime;
}

struct BookInfo
{
	ulong whitelsize;
	ulong whiteentries;
}

struct BinEntry
{
	ulong k;
	string m;
	int freq;
}
