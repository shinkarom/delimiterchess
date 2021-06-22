import std.stdio;
import debugit, io, data, defines, attack, hash;

/// Make the move.
bool makeMove(ref Position p, Move m)
{
	auto from = getFrom(m.m);
	auto to = getTo(m.m);
	immutable int flag = getFlag(m.m);
	bool r = false;

	hist[histply].data = m.m;
	hist[histply].enPas = p.enPas;
	hist[histply].fifty = p.fifty;
	hist[histply].hashKey = p.hashKey;
	hist[histply].castleFlags = p.castleFlags;
	hist[histply].captured = p.board[to];

	p.hashKey ^= hashTurn;

	auto diffCastleFlags = p.castleFlags;

	if (p.enPas != noEnPas)
		p.hashKey ^= hashEnPassant[files[p.enPas]];

	p.enPas = noEnPas;

	p.castleFlags &= castleBits[to];
	p.castleFlags &= castleBits[from];

	diffCastleFlags ^= p.castleFlags;

	if (diffCastleFlags & WKC)
		p.hashKey ^= hashCastle[0];
	if (diffCastleFlags & WQC)
		p.hashKey ^= hashCastle[1];
	if (diffCastleFlags & BKC)
		p.hashKey ^= hashCastle[2];
	if (diffCastleFlags & BQC)
		p.hashKey ^= hashCastle[3];

	p.board[to] = p.board[from];
	p.board[from] = SquareType.Empty;

	hist[histply].pList = p.sqToPceNum[to];

	p.pceNumToSq[p.sqToPceNum[to]] = 0;
	p.pceNumToSq[p.sqToPceNum[from]] = to;

	p.sqToPceNum[to] = p.sqToPceNum[from];
	p.sqToPceNum[from] = 0;

	if (p.side == Side.White && p.board[to] == SquareType.wK)
	{
		p.kingSquares[Side.White] = cast(Square)to;
	}
	else if (p.side == Side.Black && p.board[to] == SquareType.bK)
	{
		p.kingSquares[Side.Black] = cast(Square)to;
	}

	p.hashKey ^= hashPieces[64 * p.board[to] + 8 * ranks[from] + files[from]];
	p.hashKey ^= hashPieces[64 * p.board[to] + 8 * ranks[to] + files[to]];

	p.fifty++;

	if (hist[histply].captured != SquareType.Empty)
	{
		if (hist[histply].captured > 2)
		{
			p.majors--;
		}
		p.material[p.side] -= vals[hist[histply].captured];
		p.hashKey ^= hashPieces[64 * hist[histply].captured + 8 * ranks[to] + files[to]];
		p.fifty = 0;
	}

	if (p.board[to] < 3)
		p.fifty = 0;

	if (flag & mProm)
	{
		p.majors++;

		if (flag & oPQ)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wQ;
				p.material[Side.White] += vQ - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wQ + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bQ;
				p.material[Side.Black] += vQ - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bQ + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPR)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wR;
				p.material[Side.White] += vR - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bR;
				p.material[Side.Black] += vR - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPB)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wB;
				p.material[Side.White] += vB - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wB + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bB;
				p.material[Side.Black] += vB - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bB + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPN)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wN;
				p.material[Side.White] += vN - vP;
				p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.wN + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bN;
				p.material[Side.Black] += vN - vP;
				p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashKey ^= hashPieces[64 * SquareType.bN + 8 * ranks[to] + files[to]];
			}
		}
	}
	else if (flag & mPST)
	{
		if (p.side == Side.White)
			p.enPas = to - 12;
		else
			p.enPas = to + 12;
	}
	else if (flag & mCA)
	{
		if (to == Square.G1)
		{
			p.board[Square.F1] = p.board[Square.H1];
			p.board[Square.H1] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.wR + ranks[Square.H1] + files[Square.H1]];
			p.hashKey ^= hashPieces[64 * SquareType.wR + ranks[Square.F1] + files[Square.F1]];

			p.pceNumToSq[p.sqToPceNum[Square.H1]] = Square.F1;
			p.sqToPceNum[Square.F1] = p.sqToPceNum[Square.H1];
			p.sqToPceNum[Square.H1] = 0;
		}
		else if (to == Square.C1)
		{
			p.board[Square.D1] = p.board[Square.A1];
			p.board[Square.A1] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[Square.A1] + files[Square.A1]];
			p.hashKey ^= hashPieces[64 * SquareType.wR + 8 * ranks[Square.D1] + files[Square.D1]];

			p.pceNumToSq[p.sqToPceNum[Square.A1]] = Square.D1;
			p.sqToPceNum[Square.D1] = p.sqToPceNum[Square.A1];
			p.sqToPceNum[Square.A1] = 0;
		}
		else if (to == Square.G8)
		{
			p.board[Square.F8] = p.board[Square.H8];
			p.board[Square.H8] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.H8] + files[Square.H8]];
			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.F8] + files[Square.F8]];

			p.pceNumToSq[p.sqToPceNum[Square.H8]] = Square.F8;
			p.sqToPceNum[Square.F8] = p.sqToPceNum[Square.H8];
			p.sqToPceNum[Square.H8] = 0;
		}
		else if (to == Square.C8)
		{
			p.board[Square.D8] = p.board[Square.A8];
			p.board[Square.A8] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.A8] + files[Square.A8]];
			p.hashKey ^= hashPieces[64 * SquareType.bR + 8 * ranks[Square.D8] + files[Square.D8]];

			p.pceNumToSq[p.sqToPceNum[Square.A8]] = Square.D8;
			p.sqToPceNum[Square.D8] = p.sqToPceNum[Square.A8];
			p.sqToPceNum[Square.A8] = 0;
		}
	}
	else if (flag & oPEP)
	{
		if (p.side == Side.White)
		{
			p.board[to - 12] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to - 12] + files[to - 12]];
			p.material[Side.Black] -= vP;

			hist[histply].pList = p.sqToPceNum[to - 12];
			p.pceNumToSq[p.sqToPceNum[to - 12]] = 0;
			p.sqToPceNum[to - 12] = 0;
		}
		else
		{
			p.board[to + 12] = SquareType.Empty;

			p.hashKey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to + 12] + files[to + 12]];
			p.material[Side.White] -= vP;

			hist[histply].pList = p.sqToPceNum[to + 12];
			p.pceNumToSq[p.sqToPceNum[to + 12]] = 0;
			p.sqToPceNum[to + 12] = 0;
		}
	}

	r = p.isAttacked(p.kingSquares[p.side], p.side ^ 1);

	p.ply++;
	p.side ^= 1;
	histply++;

	if (p.enPas != noEnPas)
		p.hashKey ^= hashEnPassant[files[p.enPas]];

/+
	if (!testhashKey)
	{
		writeln("after making move ", returnmove(m));
		printBoard();
	}
+/
//	writeln("making move ", returnmove(m));
	return r;
}

/// Undo the move.
void takeMove(ref Position p)
{
	p.ply--;
	p.side ^= 1;
	histply--;

	p.castleFlags = hist[histply].castleFlags;
	p.enPas = hist[histply].enPas;
	p.hashKey = hist[histply].hashKey;
	p.fifty = hist[histply].fifty;

	auto from = getFrom(hist[histply].data);
	auto to = getTo(hist[histply].data);
	immutable int flag = getFlag(hist[histply].data);

	p.board[from] = p.board[to];
	p.board[to] = hist[histply].captured;

	p.sqToPceNum[from] = p.sqToPceNum[to];
	p.sqToPceNum[to] = hist[histply].pList;
	p.pceNumToSq[p.sqToPceNum[to]] = to;
	p.pceNumToSq[p.sqToPceNum[from]] = from;

	if (p.side == Side.White && p.board[from] == SquareType.wK)
	{
		p.kingSquares[Side.White] = cast(Square)from;
	}
	else if (p.side == Side.Black && p.board[from] == SquareType.bK)
	{
		p.kingSquares[Side.Black] = cast(Square)from;
	}

	if (hist[histply].captured != SquareType.Empty)
	{
		p.material[p.side] += vals[hist[histply].captured];
		if (hist[histply].captured > 2)
		{
			p.majors++;
		}
	}

	if (flag & mProm)
	{
		p.majors--;
		if (p.side == Side.White)
		{
			p.board[from] = SquareType.wP;
		}
		else
		{
			p.board[from] = SquareType.bP;
		}
		if (flag & oPQ)
			p.material[p.side] -= vQ - vP;
		else if (flag & oPR)
			p.material[p.side] -= vR - vP;
		else if (flag & oPB)
			p.material[p.side] -= vB - vP;
		else if (flag & oPN)
			p.material[p.side] -= vN - vP;
	}
	else if (flag & mCA)
	{
		if (to == Square.G1)
		{
			p.board[Square.H1] = p.board[Square.F1];
			p.board[Square.F1] = SquareType.Empty;

			p.sqToPceNum[Square.H1] = p.sqToPceNum[Square.F1];
			p.sqToPceNum[Square.F1] = 0;
			p.pceNumToSq[p.sqToPceNum[Square.H1]] = Square.H1;
		}
		else if (to == Square.C1)
		{
			p.board[Square.A1] = p.board[Square.D1];
			p.board[Square.D1] = SquareType.Empty;

			p.sqToPceNum[Square.A1] = p.sqToPceNum[Square.D1];
			p.sqToPceNum[Square.D1] = 0;
			p.pceNumToSq[p.sqToPceNum[Square.A1]] = Square.A1;
		}
		else if (to == Square.G8)
		{
			p.board[Square.H8] = p.board[Square.F8];
			p.board[Square.F8] = SquareType.Empty;

			p.sqToPceNum[Square.H8] = p.sqToPceNum[Square.F8];
			p.sqToPceNum[Square.F8] = 0;
			p.pceNumToSq[p.sqToPceNum[Square.H8]] = Square.H8;
		}
		else if (to == Square.C8)
		{
			p.board[Square.A8] = p.board[Square.D8];
			p.board[Square.D8] = SquareType.Empty;

			p.sqToPceNum[Square.A8] = p.sqToPceNum[Square.D8];
			p.sqToPceNum[Square.D8] = 0;
			p.pceNumToSq[p.sqToPceNum[Square.A8]] = Square.A8;
		}
	}
	else if (flag & oPEP)
	{
		if (p.side == Side.White)
		{
			p.board[to - 12] = SquareType.bP;
			p.material[Side.Black] += vP;

			p.sqToPceNum[to - 12] = hist[histply].pList;
			p.pceNumToSq[hist[histply].pList] = to - 12;
			p.sqToPceNum[to] = 0;
		}
		else
		{
			p.board[to + 12] = SquareType.wP;
			p.material[Side.White] += vP;

			p.sqToPceNum[to + 12] = hist[histply].pList;
			p.pceNumToSq[hist[histply].pList] = to + 12;
			p.sqToPceNum[to] = 0;
		}
	}
	//writeln("undoing move, ", p.ply);
}
