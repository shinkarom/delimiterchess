import core.time;

immutable string engineName = "Delimiter";
immutable string engineVersion = "0.1.1";
immutable string engineAuthor = "Roman Shynkarenko";

immutable char[15] pieceToChar = "pPnNbBrRqQkK.";
immutable char[8] boardRanks = "12345678";
immutable char[8] boardFiles = "abcdefgh";

enum SquareType
{
	bP = 0,
	wP,
	bN,
	wN,
	bB,
	wB,
	bR,
	wR,
	bQ,
	wQ,
	bK,
	wK,
	Empty,
	Edge
}

enum Side
{
	Black,
	White,
	None
}

immutable Side[14] SquareTypeSide = [
	Side.Black, Side.White, Side.Black, Side.White, Side.Black, Side.White,
	Side.Black, Side.White, Side.Black, Side.White, Side.Black, Side.White,
	Side.None, Side.None
];

enum Square
{
	A1 = 26,
	B1,
	C1,
	D1,
	E1,
	F1,
	G1,
	H1,
	A2 = 38,
	B2,
	C2,
	D2,
	E2,
	F2,
	G2,
	H2,
	A3 = 50,
	B3,
	C3,
	D3,
	E3,
	F3,
	G3,
	H3,
	A4 = 62,
	B4,
	C4,
	D4,
	E4,
	F4,
	G4,
	H4,
	A5 = 74,
	B5,
	C5,
	D5,
	E5,
	F5,
	G5,
	H5,
	A6 = 86,
	B6,
	C6,
	D6,
	E6,
	F6,
	G6,
	H6,
	A7 = 98,
	B7,
	C7,
	D7,
	E7,
	F7,
	G7,
	H7,
	A8 = 110,
	B8,
	C8,
	D8,
	E8,
	F8,
	G8,
	H8
}

immutable int WKC = 8, WQC = 4, BKC = 2, BQC = 1;
enum BookMoveType { None, Lower, Upper, Exact }
immutable int noEnPas = 200, noPiece = 0, deadSquare = 0;

immutable int vP = 90, vN = 325, vB = 325, vR = 500, vQ = 900, vK = 10000;

immutable string startFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

immutable int mCA = 0x20000, mPST = 0x40000, mPEP = 0x180000, mCAP = 0x100000,
	mPQ = 0x600000, mPR = 0xa00000, mPB = 0x1200000, mPN = 0x2200000,
	mNORM = 0x10000, mProm = 0x200000;

immutable int HASH = 65536, M_KILLER = 65526, WIN_CAPT1 = 65516, WIN_CAPT2 = 65506,
	WIN_CAPT3 = 65496, Q_PROM_CAPT = 65486, Q_PROM = 65476, GCAP_QQ = 65466,
	GCAP_RR = 65456, GCAP_BB = 65446, GCAP_NN = 65436, GCAP_PP = 65426, SEECAP = 65416,
	KILLER1 = 65406, KILLER1_PLY = 65396, KILLER2 = 65376, KILLER2_PLY = 65366,
	OO = 65356, OOO = 65346, MINORPROM = 65366;

immutable int[16] equalcap = [
	0, GCAP_PP, GCAP_PP, GCAP_NN, GCAP_NN, GCAP_BB, GCAP_BB, GCAP_RR, GCAP_RR,
	GCAP_QQ, GCAP_QQ, 10000, 10000, 0, 0, 0
];

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

pure int fileRankToSquare(const int r, const int f)
{
	return (r + 2) * 12 + 2 + f;
}

pure int charToFile(const char file)
{
	assert(file >= 'a' && file <= 'h');
	return file - 'a';
}

pure int charToRank(const char rank)
{
	assert(rank >= '1' && rank <= '8');
	return rank - '1';
}

pure char rankToChar(int rank)
{
	return boardRanks[rank];
}

pure char fileToChar(int file)
{
	return boardFiles[file];
}

pure char piece(int piece)
{
	return pieceToChar[piece];
}

immutable int MOVEBITS = 0xffff;

immutable int oPQ = 0x400000, oPR = 0x800000, oPB = 0x1000000, oPN = 0x2000000, oPEP = 0x80000;

immutable int PLY = 64;

struct Move
{
	int m;
	int score;
}

struct HistoryEntry
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
	int castleFlags;
	int fifty;
	Side side;
	int enPas;
	int ply;
	int[2] material;
	ulong hashKey;
	Move[9600] list;
	int[512] listc;
	SquareType[144] board;
	int[2] k;
}

struct HashElem
{
	ulong hashKey;
	int depth;
	BookMoveType flag;
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
