import data, defines;

bool isattacked(int sq, int side)
{
	int tsq;
	if(side==black)
	{
		//black pawns
		if(p.board[sq+13].typ == bP) return true;
		if(p.board[sq+11].typ == bP) return true;
		//black knights
		if(p.board[sq+14].typ == bN) return true;
		if(p.board[sq+10].typ == bN) return true;
		if(p.board[sq+25].typ == bN) return true;
		if(p.board[sq+23].typ == bN) return true;
		if(p.board[sq-14].typ == bN) return true;
		if(p.board[sq-10].typ == bN) return true;
		if(p.board[sq-25].typ == bN) return true;
		if(p.board[sq-23].typ == bN) return true;
		//rooks and queens and king
		tsq = sq+1;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bR || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=1;
		}
		
		tsq = sq-1;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bR || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=1;
		}
		
		tsq = sq+12;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bR || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=12;
		}
		
		tsq = sq-12;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bR || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=12;
		}
		//bishops and queens
		tsq = sq+13;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bB || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=13;
		}
		
		tsq = sq-13;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bB || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=13;
		}	

		tsq = sq+11;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bB || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=11;
		}
		
		tsq = sq-11;
		if(p.board[tsq].typ == bK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==bB || p.board[tsq].typ==bQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=11;
		}		
	}
	else
	{
		//white pawns
		if(p.board[sq-13].typ == wP) return true;
		if(p.board[sq-11].typ == wP) return true;
		//black knights
		if(p.board[sq+14].typ == wN) return true;
		if(p.board[sq+10].typ == wN) return true;
		if(p.board[sq+25].typ == wN) return true;
		if(p.board[sq+23].typ == wN) return true;
		if(p.board[sq-14].typ == wN) return true;
		if(p.board[sq-10].typ == wN) return true;
		if(p.board[sq-25].typ == wN) return true;
		if(p.board[sq-23].typ == wN) return true;
		//rooks and queens and king
		tsq = sq+1;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wR || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=1;
		}
		
		tsq = sq-1;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wR || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=1;
		}
		
		tsq = sq+12;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wR || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=12;
		}
		
		tsq = sq-12;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wR || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=12;
		}
		//bishops and queens
		tsq = sq+13;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wB || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=13;
		}
		
		tsq = sq-13;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wB || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=13;
		}	

		tsq = sq+11;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wB || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq+=11;
		}
		
		tsq = sq-11;
		if(p.board[tsq].typ == wK) return true;
		while(p.board[sq].typ != edge)
		{
			if(p.board[tsq].typ==wB || p.board[tsq].typ==wQ) return true;
			if(p.board[tsq].col!=npco) break;
			tsq-=11;
		}			
	}
	return false;
}