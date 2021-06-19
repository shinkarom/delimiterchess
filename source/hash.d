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
		TTable[i].hashKey = 0;
		TTable[i].depth = 0;
		TTable[i].score = 0;
		TTable[i].flag = BookMoveType.None;
	}
}

void fullhashKey()
{
	p.hashKey = generateHashKey();
}

ulong generateHashKey()
{
	ulong hashKey = 0;
	for (int i = Square.A1; i <= Square.H8; i++)
	{
		if (p.board[i] == SquareType.Edge || p.board[i] == SquareType.Empty)
			continue;
		hashKey ^= hashPieces[64 * p.board[i] + 8 * ranks[i] + files[i]];
	}
	if (p.side == Side.White)
		hashKey ^= hashTurn;
	if (p.enPas != noEnPas)
	{
		int squareNum = 8 * ranks[p.enPas] + files[p.enPas];
		hashKey ^= hashEnPassant[files[p.enPas]];
	}
	//hashKey ^= hashCastleCombinations[p.castleFlags];
	if (p.castleFlags & WKC)
		hashKey ^= hashCastle[0];
	if (p.castleFlags & WQC)
		hashKey ^= hashCastle[1];
	if (p.castleFlags & BKC)
		hashKey ^= hashCastle[2];
	if (p.castleFlags & BQC)
		hashKey ^= hashCastle[3];
	return hashKey;
}

bool testhashKey()
{
	auto hashKey = generateHashKey();

	if (hashKey != p.hashKey)
	{
		writefln("corrupt key %X %X, difference %X", hashKey, p.hashKey, hashKey ^ p.hashKey);
		/+
		printboard();
		+/
		return false;
	}
	return true;
}

BookMoveType probe_hash_table(int depth, Move move, ref bool nul, ref int score, int beta)
{
	hashprobe++;
	HashElem probe2;
	auto flag = BookMoveType.None;
	probe2 = TTable[p.hashKey % numelem];
	if (probe2.hashKey == p.hashKey)
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
	return BookMoveType.None;
}

void store_hash(int depth, int score, BookMoveType flag, bool nul, Move move)
{
	auto index = p.hashKey % numelem;
	if (depth >= TTable[index].depth)
	{
		TTable[index].hashKey = p.hashKey;
		TTable[index].depth = depth;
		TTable[index].score = score;
		TTable[index].flag = flag;
		TTable[index].nul = nul;
		TTable[index].move = move.m;
	}
}
