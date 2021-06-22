import std.stdio, core.time;
import defines;

bool debugMode;

File book_file, bookfile, wbookfile;
string[] vbooklines;
BinEntry[] hashentries;
File hash_file;
BinEntry[] whitebook;

int movestotal, readtotal;

BinEntry binenter;
BookInfo bookdata;

File log_file;
bool logme;

//extern jmp_buf stopped;
int[48] check;
int[48] red;

Position p;
EvalOptions eo;

Move ponderMove;
HistoryEntry[1024] hist;

Move nomove;
Move best;

int[144] castleBits;

HashElem[] TTable;
int numelem;

string bookFile = "binbook.bin";

int[16] vals = [
   0, 100, 100, 300, 300, 300, 300, 500, 500, 900, 900, 10000, 10000, 0, 0, 0
];

EvalData evalData;

SearchParam searchParam;
bool stopsearch;
int itDepth;
Move[48][48] pv;
int[48] pvindex;
Move[48] killer1;
Move[48] killer2;
int[48] killerscore;
int[48] killerscore2;
Move[48] matekiller;
int[144][144] history;
int[MOVEBITS] his_table;
int[144][144][2] hisall;
int[144][144][2] hisfh;
int donull;
int nodes;
int qnodes;
bool followpv;
int histply;

float fhf;
float fh;
float nulltry;
float nullcut;
float hashprobe;
float hashhit;
float incheckext;
float wasincheck;
float matethrt;
float pawnfifth;
float pawnsix;
float prom;
float pvsh;
float pvs;
float reduct;
float single;
float resethis;

ulong[16] hashCastleCombinations;

void initSearchParam(ref SearchParam searchParam)
{
   searchParam.depth = -1;
   searchParam.winc = 0;
   searchParam.binc = 0;
   searchParam.wtime = 0;
   searchParam.btime = 0;
   searchParam.xtime = 0;
   searchParam.xotime = 0;
   searchParam.movestogo[Side.White] = 0;
   searchParam.movestogo[Side.Black] = 0;
   searchParam.timepermove = 0;
   searchParam.starttime = 0;
   searchParam.stoptime = 0;
   searchParam.inf = false;
   searchParam.pon = false;
   searchParam.ponderhit = false;
   searchParam.post = true;
}
