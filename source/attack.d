import data, defines;

bool isAttacked(int sq, int side)
{
	int tsq;
	if (side == black)
	{
		//black pawns
		if (p.board[sq + 13].type == bP)
			return true;
		if (p.board[sq + 11].type == bP)
			return true;
		//black knights
		if (p.board[sq + 14].type == bN)
			return true;
		if (p.board[sq + 10].type == bN)
			return true;
		if (p.board[sq + 25].type == bN)
			return true;
		if (p.board[sq + 23].type == bN)
			return true;
		if (p.board[sq - 14].type == bN)
			return true;
		if (p.board[sq - 10].type == bN)
			return true;
		if (p.board[sq - 25].type == bN)
			return true;
		if (p.board[sq - 23].type == bN)
			return true;
		//rooks and queens and king
		tsq = sq + 1;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bR || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 1;
		}

		tsq = sq - 1;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bR || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 1;
		}

		tsq = sq + 12;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bR || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 12;
		}

		tsq = sq - 12;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bR || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 12;
		}
		//bishops and queens
		tsq = sq + 13;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bB || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 13;
		}

		tsq = sq - 13;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bB || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 13;
		}

		tsq = sq + 11;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bB || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 11;
		}

		tsq = sq - 11;
		if (p.board[tsq].type == bK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == bB || p.board[tsq].type == bQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 11;
		}
	}
	else
	{
		//white pawns
		if (p.board[sq - 13].type == wP)
			return true;
		if (p.board[sq - 11].type == wP)
			return true;
		//black knights
		if (p.board[sq + 14].type == wN)
			return true;
		if (p.board[sq + 10].type == wN)
			return true;
		if (p.board[sq + 25].type == wN)
			return true;
		if (p.board[sq + 23].type == wN)
			return true;
		if (p.board[sq - 14].type == wN)
			return true;
		if (p.board[sq - 10].type == wN)
			return true;
		if (p.board[sq - 25].type == wN)
			return true;
		if (p.board[sq - 23].type == wN)
			return true;
		//rooks and queens and king
		tsq = sq + 1;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wR || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 1;
		}

		tsq = sq - 1;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wR || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 1;
		}

		tsq = sq + 12;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wR || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 12;
		}

		tsq = sq - 12;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wR || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 12;
		}
		//bishops and queens
		tsq = sq + 13;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wB || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 13;
		}

		tsq = sq - 13;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wB || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 13;
		}

		tsq = sq + 11;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wB || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq += 11;
		}

		tsq = sq - 11;
		if (p.board[tsq].type == wK)
			return true;
		while (p.board[tsq].type != edge)
		{
			if (p.board[tsq].type == wB || p.board[tsq].type == wQ)
				return true;
			if (p.board[tsq].color != PieceColor.None)
				break;
			tsq -= 11;
		}
	}
	return false;
}
