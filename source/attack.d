import data, defines;

bool isAttacked(ref Position p, int sq, int side)
{
	int tsq;
	if (side == Side.Black)
	{
		//black pawns
		if (p.board[sq + 13] == SquareType.bP)
			return true;
		if (p.board[sq + 11] == SquareType.bP)
			return true;
		//black knights
		if (p.board[sq + 14] == SquareType.bN)
			return true;
		if (p.board[sq + 10] == SquareType.bN)
			return true;
		if (p.board[sq + 25] == SquareType.bN)
			return true;
		if (p.board[sq + 23] == SquareType.bN)
			return true;
		if (p.board[sq - 14] == SquareType.bN)
			return true;
		if (p.board[sq - 10] == SquareType.bN)
			return true;
		if (p.board[sq - 25] == SquareType.bN)
			return true;
		if (p.board[sq - 23] == SquareType.bN)
			return true;
		//rooks and queens and king
		tsq = sq + 1;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bR || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 1;
		}

		tsq = sq - 1;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bR || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 1;
		}

		tsq = sq + 12;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bR || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 12;
		}

		tsq = sq - 12;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bR || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 12;
		}
		//bishops and queens
		tsq = sq + 13;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bB || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 13;
		}

		tsq = sq - 13;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bB || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 13;
		}

		tsq = sq + 11;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bB || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 11;
		}

		tsq = sq - 11;
		if (p.board[tsq] == SquareType.bK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.bB || p.board[tsq] == SquareType.bQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 11;
		}
	}
	else
	{
		//white pawns
		if (p.board[sq - 13] == SquareType.wP)
			return true;
		if (p.board[sq - 11] == SquareType.wP)
			return true;
		//black knights
		if (p.board[sq + 14] == SquareType.wN)
			return true;
		if (p.board[sq + 10] == SquareType.wN)
			return true;
		if (p.board[sq + 25] == SquareType.wN)
			return true;
		if (p.board[sq + 23] == SquareType.wN)
			return true;
		if (p.board[sq - 14] == SquareType.wN)
			return true;
		if (p.board[sq - 10] == SquareType.wN)
			return true;
		if (p.board[sq - 25] == SquareType.wN)
			return true;
		if (p.board[sq - 23] == SquareType.wN)
			return true;
		//rooks and queens and king
		tsq = sq + 1;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wR || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 1;
		}

		tsq = sq - 1;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wR || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 1;
		}

		tsq = sq + 12;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wR || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 12;
		}

		tsq = sq - 12;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wR || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 12;
		}
		//bishops and queens
		tsq = sq + 13;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wB || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 13;
		}

		tsq = sq - 13;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wB || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 13;
		}

		tsq = sq + 11;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wB || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq += 11;
		}

		tsq = sq - 11;
		if (p.board[tsq] == SquareType.wK)
			return true;
		while (p.board[tsq] != SquareType.Edge)
		{
			if (p.board[tsq] == SquareType.wB || p.board[tsq] == SquareType.wQ)
				return true;
			if (SquareTypeSide[p.board[tsq]] != Side.None)
				break;
			tsq -= 11;
		}
	}
	return false;
}
