import std.stdio;
import data, defines;

void init_hash_tables()
{
	initHashCastleCombinations();
	int elemSize = HashElem.sizeof;
	//writeln("elem size = ",elemSize);
	numelem *= 1000000;
	numelem /= elemSize;
	//writeln("numelem = ",numelem);
	TTable.length = 0;
	TTable.length = numelem;
	clearhash();
}

void initHashCastleCombinations()
{
	for (int kingK = 0; kingK <= 1; kingK++)
	{
		for (int kingQ = 0; kingQ <= 1; kingQ++)
		{
			for (int queenK = 0; queenK <= 1; queenK++)
			{
				for (int queenQ = 0; queenQ <= 1; queenQ++)
				{
					int index = (kingK << 3) | (kingQ << 2) | (queenK << 1) | (queenQ);
					ulong value = 0;
					if (kingK)
						value ^= hashCastle[0];
					if (kingQ)
						value ^= hashCastle[1];
					if (queenK)
						value ^= hashCastle[2];
					if (queenQ)
						value ^= hashCastle[3];
					hashCastleCombinations[index] = value;
				}
			}
		}
	}
}

void clearhash()
{
	for (int i = 0; i < numelem; i++)
	{
		TTable[i].hashkey = 0;
		TTable[i].depth = 0;
		TTable[i].score = 0;
		TTable[i].flag = 0;
	}
}

void fullhashkey()
{
	p.hashkey = generateHashKey();
}

ulong generateHashKey()
{
	ulong hashkey = 0;
	for (int i = A1; i <= H8; i++)
	{
		if (p.board[i].type == edge || p.board[i].type == empty)
			continue;
		hashkey ^= hashPieces[64 * p.board[i].type + 8 * ranks[i] + files[i]];
	}
	if (p.side == white)
		hashkey ^= hashTurn;
	if (p.en_pas != noenpas)
	{
		int squareNum = 8 * ranks[p.en_pas] + files[p.en_pas];
		hashkey ^= hashEnPassant[files[p.en_pas]];
	}
	//hashkey ^= hashCastleCombinations[p.castleflags];
	if (p.castleflags & WKC)
		hashkey ^= hashCastle[0];
	if (p.castleflags & WQC)
		hashkey ^= hashCastle[1];
	if (p.castleflags & BKC)
		hashkey ^= hashCastle[2];
	if (p.castleflags & BQC)
		hashkey ^= hashCastle[3];
	return hashkey;
}

bool testhashkey()
{
	auto hashkey = generateHashKey();

	if (hashkey != p.hashkey)
	{
		writefln("corrupt key %X %X, difference %X", hashkey, p.hashkey, hashkey ^ p.hashkey);
		/+
		printboard();
		+/
		return false;
	}
	return true;
}

int probe_hash_table(int depth, Move move, ref bool nul, ref int score, int beta)
{
	hashprobe++;
	HashElem probe2;
	int flag = NOFLAG;
	probe2 = TTable[p.hashkey % numelem];
	if (probe2.hashkey == p.hashkey)
	{
		move.m = probe2.move;
		hashhit++;
		score = probe2.score;

		if (probe2.depth >= depth)
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
	if (depth >= TTable[index].depth)
	{
		TTable[index].hashkey = p.hashkey;
		TTable[index].depth = depth;
		TTable[index].score = score;
		TTable[index].flag = flag;
		TTable[index].nul = nul;
		TTable[index].move = move.m;
	}
}
