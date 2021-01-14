import std.stdio;
import data, defines;

void init_hash_tables()
{
	int elemSize = Hashelem.sizeof;
	writeln("elem size = ",elemSize);
	numelem *= 1000000;
	numelem /= elemSize;
	writeln("numelem = ",numelem);
	TTable.length = 0;
	TTable.length = numelem;
	clearhash();
}

void clearhash()
{
	for(int i = 0; i<numelem; i++)
	{
		TTable[i].hashkey = 0;
		TTable[i].depth = 0;
		TTable[i].score = 0;
		TTable[i].flag = 0;
	}
}

void fullhashkey()
{
	p.hashkey = 0;
	for(int i= 0; i<144;i++)
	{
		if(p.board[i].typ == edge || p.board[i].typ == ety)
			continue;
		p.hashkey ^= hash_p[p.board[i].typ][i];
	}
	
	p.hashkey ^= hash_s[p.side];
	p.hashkey ^= hash_enp[p.en_pas];
	p.hashkey ^= hash_ca[p.castleflags];
}

void testhashkey()
{
	ulong hashkey = 0;
		for(int i= 0; i<144;i++)
	{
		if(p.board[i].typ == edge || p.board[i].typ == ety)
			continue;
		hashkey ^= hash_p[p.board[i].typ][i];
	}
	
	hashkey ^= hash_s[p.side];
	hashkey ^= hash_enp[p.en_pas];
	hashkey ^= hash_ca[p.castleflags];
	
	if(hashkey != p.hashkey)
	{
		writeln("corrupt key, board = ",p.hashkey,", should be ",hashkey);
		/+
		printboard();
		+/
	}
}

int probe_hash_table(int depth, Move move, ref int nul, ref int score, int beta)
{
	hashprobe++;
	Hashelem probe2;
	int flag = NOFLAG;
	probe2 = TTable[p.hashkey % numelem];
	if(probe2.hashkey == p.hashkey)
	{
		move.m = probe2.move;
		hashhit++;
		score = probe2.score;
		
		if(probe2.depth >= depth)
		{
			flag = probe2.flag;
			nul = probe2.nul;
			return flag;
		}
		return flag;
	}
	return 0;
}

void store_hash(int depth, int score, int flag, bool nul, Move move)
{
	auto index = p.hashkey % numelem;
	if(depth >= TTable[index].depth)
	{
		TTable[index].hashkey = p.hashkey;
		TTable[index].depth = depth;
		TTable[index].score = score;
		TTable[index].flag = flag;
		TTable[index].nul = nul;
		TTable[index].move = move.m;
	}
}