import std.stdio;
import debugit, io, data, defines, attack, hash;

/// Make the move.
bool makeMove(Move m)
{
	int from = getFrom(m.m);
	int to = getTo(m.m);
	int flag = getFlag(m.m);
	bool r = false;

	hist[histply].data = m.m;
	hist[histply].enPas = p.en_pas;
	hist[histply].fifty = p.fifty;
	hist[histply].hashKey = p.hashkey;
	hist[histply].castleFlags = p.castleflags;
	hist[histply].captured = p.board[to];

	p.hashkey ^= hashTurn;

	auto diffCastleFlags = p.castleflags;

	if (p.en_pas != noenpas)
		p.hashkey ^= hashEnPassant[files[p.en_pas]];

	p.en_pas = noenpas;

	p.castleflags &= castleBits[to];
	p.castleflags &= castleBits[from];

	diffCastleFlags ^= p.castleflags;

	if (diffCastleFlags & WKC)
		p.hashkey ^= hashCastle[0];
	if (diffCastleFlags & WQC)
		p.hashkey ^= hashCastle[1];
	if (diffCastleFlags & BKC)
		p.hashkey ^= hashCastle[2];
	if (diffCastleFlags & BQC)
		p.hashkey ^= hashCastle[3];

	p.board[to] = p.board[from];
	p.board[from] = SquareType.Empty;

	hist[histply].pList = p.sqToPceNum[to];

	p.pceNumToSq[p.sqToPceNum[to]] = 0;
	p.pceNumToSq[p.sqToPceNum[from]] = to;

	p.sqToPceNum[to] = p.sqToPceNum[from];
	p.sqToPceNum[from] = 0;

	if (p.side == Side.White && p.board[to] == SquareType.wK)
	{
		p.k[Side.White] = to;
	}
	else if (p.side == Side.Black && p.board[to] == SquareType.bK)
	{
		p.k[Side.Black] = to;
	}

	p.hashkey ^= hashPieces[64 * p.board[to] + 8 * ranks[from] + files[from]];
	p.hashkey ^= hashPieces[64 * p.board[to] + 8 * ranks[to] + files[to]];

	p.fifty++;

	if (hist[histply].captured != SquareType.Empty)
	{
		if (hist[histply].captured > 2)
		{
			p.majors--;
		}
		p.material[p.side] -= vals[hist[histply].captured];
		p.hashkey ^= hashPieces[64 * hist[histply].captured + 8 * ranks[to] + files[to]];
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
				p.hashkey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.wQ + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bQ;
				p.material[Side.Black] += vQ - vP;
				p.hashkey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.bQ + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPR)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wR;
				p.material[Side.White] += vR - vP;
				p.hashkey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.wR + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bR;
				p.material[Side.Black] += vR - vP;
				p.hashkey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.bR + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPB)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wB;
				p.material[Side.White] += vB - vP;
				p.hashkey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.wB + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bB;
				p.material[Side.Black] += vB - vP;
				p.hashkey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.bB + 8 * ranks[to] + files[to]];
			}
		}
		else if (flag & oPN)
		{
			if (p.side == Side.White)
			{
				p.board[to] = SquareType.wN;
				p.material[Side.White] += vN - vP;
				p.hashkey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.wN + 8 * ranks[to] + files[to]];
			}
			else
			{
				p.board[to] = SquareType.bN;
				p.material[Side.Black] += vN - vP;
				p.hashkey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to] + files[to]];
				p.hashkey ^= hashPieces[64 * SquareType.bN + 8 * ranks[to] + files[to]];
			}
		}
	}
	else if (flag & mPST)
	{
		if (p.side == Side.White)
			p.en_pas = to - 12;
		else
			p.en_pas = to + 12;
	}
	else if (flag & mCA)
	{
		if (to == G1)
		{
			p.board[F1] = p.board[H1];
			p.board[H1] = SquareType.Empty;

			p.hashkey ^= hashPieces[64 * SquareType.wR + ranks[H1] + files[H1]];
			p.hashkey ^= hashPieces[64 * SquareType.wR + ranks[F1] + files[F1]];

			p.pceNumToSq[p.sqToPceNum[H1]] = F1;
			p.sqToPceNum[F1] = p.sqToPceNum[H1];
			p.sqToPceNum[H1] = 0;
		}
		else if (to == C1)
		{
			p.board[D1] = p.board[A1];
			p.board[A1] = SquareType.Empty;

			p.hashkey ^= hashPieces[64 * SquareType.wR + 8 * ranks[A1] + files[A1]];
			p.hashkey ^= hashPieces[64 * SquareType.wR + 8 * ranks[D1] + files[D1]];

			p.pceNumToSq[p.sqToPceNum[A1]] = D1;
			p.sqToPceNum[D1] = p.sqToPceNum[A1];
			p.sqToPceNum[A1] = 0;
		}
		else if (to == G8)
		{
			p.board[F8] = p.board[H8];
			p.board[H8] = SquareType.Empty;

			p.hashkey ^= hashPieces[64 * SquareType.bR + 8 * ranks[H8] + files[H8]];
			p.hashkey ^= hashPieces[64 * SquareType.bR + 8 * ranks[F8] + files[F8]];

			p.pceNumToSq[p.sqToPceNum[H8]] = F8;
			p.sqToPceNum[F8] = p.sqToPceNum[H8];
			p.sqToPceNum[H8] = 0;
		}
		else if (to == C8)
		{
			p.board[D8] = p.board[A8];
			p.board[A8] = SquareType.Empty;

			p.hashkey ^= hashPieces[64 * SquareType.bR + 8 * ranks[A8] + files[A8]];
			p.hashkey ^= hashPieces[64 * SquareType.bR + 8 * ranks[D8] + files[D8]];

			p.pceNumToSq[p.sqToPceNum[A8]] = D8;
			p.sqToPceNum[D8] = p.sqToPceNum[A8];
			p.sqToPceNum[A8] = 0;
		}
	}
	else if (flag & oPEP)
	{
		if (p.side == Side.White)
		{
			p.board[to - 12] = SquareType.Empty;

			p.hashkey ^= hashPieces[64 * SquareType.bP + 8 * ranks[to - 12] + files[to - 12]];
			p.material[Side.Black] -= vP;

			hist[histply].pList = p.sqToPceNum[to - 12];
			p.pceNumToSq[p.sqToPceNum[to - 12]] = 0;
			p.sqToPceNum[to - 12] = 0;
		}
		else
		{
			p.board[to + 12] = SquareType.Empty;

			p.hashkey ^= hashPieces[64 * SquareType.wP + 8 * ranks[to + 12] + files[to + 12]];
			p.material[Side.White] -= vP;

			hist[histply].pList = p.sqToPceNum[to + 12];
			p.pceNumToSq[p.sqToPceNum[to + 12]] = 0;
			p.sqToPceNum[to + 12] = 0;
		}
	}

	r = isAttacked(p.k[p.side], p.side ^ 1);

	p.ply++;
	p.side ^= 1;
	histply++;

	if (p.en_pas != noenpas)
		p.hashkey ^= hashEnPassant[files[p.en_pas]];

/+
	if (!testhashkey)
	{
		writeln("after making move ", returnmove(m));
		printBoard();
	}
+/
//	writeln("making move ", returnmove(m));
	return r;
}

/// Undo the move.
void takeMove()
{
	p.ply--;
	p.side ^= 1;
	histply--;

	p.castleflags = hist[histply].castleFlags;
	p.en_pas = hist[histply].enPas;
	p.hashkey = hist[histply].hashKey;
	p.fifty = hist[histply].fifty;

	int from = getFrom(hist[histply].data);
	int to = getTo(hist[histply].data);
	int flag = getFlag(hist[histply].data);

	p.board[from] = p.board[to];
	p.board[to] = hist[histply].captured;

	p.sqToPceNum[from] = p.sqToPceNum[to];
	p.sqToPceNum[to] = hist[histply].pList;
	p.pceNumToSq[p.sqToPceNum[to]] = to;
	p.pceNumToSq[p.sqToPceNum[from]] = from;

	if (p.side == Side.White && p.board[from] == SquareType.wK)
	{
		p.k[Side.White] = from;
	}
	else if (p.side == Side.Black && p.board[from] == SquareType.bK)
	{
		p.k[Side.Black] = from;
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
		if (to == G1)
		{
			p.board[H1] = p.board[F1];
			p.board[F1] = SquareType.Empty;

			p.sqToPceNum[H1] = p.sqToPceNum[F1];
			p.sqToPceNum[F1] = 0;
			p.pceNumToSq[p.sqToPceNum[H1]] = H1;
		}
		else if (to == C1)
		{
			p.board[A1] = p.board[D1];
			p.board[D1] = SquareType.Empty;

			p.sqToPceNum[A1] = p.sqToPceNum[D1];
			p.sqToPceNum[D1] = 0;
			p.pceNumToSq[p.sqToPceNum[A1]] = A1;
		}
		else if (to == G8)
		{
			p.board[H8] = p.board[F8];
			p.board[F8] = SquareType.Empty;

			p.sqToPceNum[H8] = p.sqToPceNum[F8];
			p.sqToPceNum[F8] = 0;
			p.pceNumToSq[p.sqToPceNum[H8]] = H8;
		}
		else if (to == C8)
		{
			p.board[A8] = p.board[D8];
			p.board[D8] = SquareType.Empty;

			p.sqToPceNum[A8] = p.sqToPceNum[D8];
			p.sqToPceNum[D8] = 0;
			p.pceNumToSq[p.sqToPceNum[A8]] = A8;
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
