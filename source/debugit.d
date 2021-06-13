import std.stdio;
import data, defines, io, hash;

void printBoard()
{
	for (int i = 9; i > 1; i--)
	{
		for (int j = 2; j < 10; j++)
		{
			int k = i * 12 + j;
			write(piecetochar[p.board[k].type]);
		}
		write("\t");
		switch (i)
		{
		case 9:
			writef("Hash: %X", p.hashkey);
			break;
		case 8:
			writef("Fresh hash: %X", generateHashKey());
			break;
		case 7:
			write("Side to move: ", p.side == white ? "w" : "b");
			break;
		case 6:
			writef("Ply number: %d", p.ply);
			break;
		case 5:
			writef("Fifty: %d", p.fifty);
			break;
		case 4:
			write("Castling: ");
			if (p.castleflags & WKC)
				write("K");
			if (p.castleflags & WQC)
				write("Q");
			if (p.castleflags & BKC)
				write("k");
			if (p.castleflags & BQC)
				write("q");
			break;
		default:
			break;
		}
		writeln();
	}
}

void printMoveList()
{
	int num = 1;
	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		writefln("%d %s", num++, returnmove(p.list[i]));
	}
}

void debugPceNumToSq()
{
	write("Pieces: ");
	for (int index = 1; index <= p.pceNum; index++)
	{
		auto sq = p.pceNumToSq[index];
		writef("%s (%d) ", piecetochar[p.board[sq].type], sq);
	}
	writeln();
}
