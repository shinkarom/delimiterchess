import std.stdio;
import debugit, io, data, defines, attack, hash;

bool makemove(Move m)
{	
	int from = FROM(m.m);
	int to = TO(m.m);
	int flag = FLAG(m.m);
	bool r = false;
	
	hist[histply].data = m.m;
	hist[histply].enPas = p.en_pas;
	hist[histply].fifty = p.fifty;
	hist[histply].hashKey = p.hashkey;
	hist[histply].castleFlags = p.castleflags;
	hist[histply].captured = p.board[to];
	
	p.hashkey ^= hashTurn;
	
	auto diffCastleFlags = p.castleflags;
	
	if(p.en_pas != noenpas)
		p.hashkey ^= hashEnPassant[files[p.en_pas]];
	
	p.en_pas = noenpas;
	
	p.castleflags &= castleBits[to];
	p.castleflags &= castleBits[from];
	
	diffCastleFlags ^= p.castleflags;
	
	if(diffCastleFlags & WKC)
		p.hashkey ^= hashCastle[0];
	if(diffCastleFlags & WQC)
		p.hashkey ^= hashCastle[1];
	if(diffCastleFlags & BKC)
		p.hashkey ^= hashCastle[2];
	if(diffCastleFlags & BQC)
		p.hashkey ^= hashCastle[3];
	
	p.board[to] = p.board[from];	
	p.board[from].type = empty;	
	p.board[from].color = npco;	
	
	hist[histply].pList = p.sqToPceNum[to];	
	
	p.pceNumToSq[p.sqToPceNum[to]] = 0;	
	p.pceNumToSq[p.sqToPceNum[from]] = to;	
	
	p.sqToPceNum[to] = p.sqToPceNum[from];	
	p.sqToPceNum[from] = 0;
	
	if(p.side==white && p.board[to].type == wK)
	{
		p.k[white] = to;
	}
	else if (p.side==black && p.board[to].type == bK)
	{
		p.k[black] = to;
	}
	
	p.hashkey ^= hashPieces[64*p.board[to].type+8*ranks[from]+files[from]];
	p.hashkey ^= hashPieces[64*p.board[to].type+8*ranks[to]+files[to]];
	
	p.fifty++;
	
	if(hist[histply].captured.type != empty)
	{
		if(hist[histply].captured.type > 2)
		{
			p.majors--;
		}
		p.material[p.side] -= vals[hist[histply].captured.type];
		p.hashkey ^= hashPieces[64*hist[histply].captured.type+8*ranks[to]+files[to]];
		p.fifty = 0;
	}
	
	if(p.board[to].type < 3)
		p.fifty = 0;
		
	if(flag & mProm)
	{
		p.majors++;
		
		if(flag & oPQ)
		{
			if(p.side == white)
			{
				p.board[to].type = wQ;
				p.material[white] += vQ-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wQ+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bQ;
				p.material[black] += vQ-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bQ+8*ranks[to]+files[to]];				
			}
		}
		else if (flag & oPR)
		{
			if(p.side == white)
			{
				p.board[to].type = wR;
				p.material[white] += vR-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wR+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bR;
				p.material[black] += vR-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bR+8*ranks[to]+files[to]];				
			}			
		}
		else if (flag & oPB)
		{
			if(p.side == white)
			{
				p.board[to].type = wB;
				p.material[white] += vB-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wB+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bB;
				p.material[black] += vB-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bB+8*ranks[to]+files[to]];			
			}			
		}
		else if (flag & oPN)
		{
			if(p.side == white)
			{
				p.board[to].type = wN;
				p.material[white] += vN-vP;
				p.hashkey ^= hashPieces[64*wP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*wN+8*ranks[to]+files[to]];
			}
			else
			{
				p.board[to].type = bN;
				p.material[black] += vN-vP;
				p.hashkey ^= hashPieces[64*bP+8*ranks[to]+files[to]];
				p.hashkey ^= hashPieces[64*bN+8*ranks[to]+files[to]];				
			}			
		}
	}
	else if(flag & mPST)	
	{
		if(p.side == white)
			p.en_pas = to - 12;
		else
			p.en_pas = to + 12;
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[F1].type = p.board[H1].type;
			p.board[H1].type = empty;
			p.board[F1].color = p.board[H1].color;
			p.board[H1].color = empty;
			
			p.hashkey ^= hashPieces[64*wR+ranks[H1]+files[H1]];
			p.hashkey ^= hashPieces[64*wR+ranks[F1]+files[F1]];
			
			p.pceNumToSq[p.sqToPceNum[H1]] = F1;
			p.sqToPceNum[F1] = p.sqToPceNum[H1];
			p.sqToPceNum[H1] = 0;
		}
		else if(to == C1)
		{
			p.board[D1].type = p.board[A1].type;
			p.board[A1].type = empty;
			p.board[D1].color = p.board[A1].color;
			p.board[A1].color = empty;
			
			p.hashkey ^= hashPieces[64*wR+8*ranks[A1]+files[A1]];
			p.hashkey ^= hashPieces[64*wR+8*ranks[D1]+files[D1]];
			
			p.pceNumToSq[p.sqToPceNum[A1]] = D1;
			p.sqToPceNum[D1] = p.sqToPceNum[A1];
			p.sqToPceNum[A1] = 0;
		}
		else if(to == G8)
		{
			p.board[F8].type = p.board[H8].type;
			p.board[H8].type = empty;
			p.board[F8].color = p.board[H8].color;
			p.board[H8].color = empty;
			
			p.hashkey ^= hashPieces[64*bR+8*ranks[H8]+files[H8]];
			p.hashkey ^= hashPieces[64*bR+8*ranks[F8]+files[F8]];
			
			p.pceNumToSq[p.sqToPceNum[H8]] = F8;
			p.sqToPceNum[F8] = p.sqToPceNum[H8];
			p.sqToPceNum[H8] = 0;
		}
		else if(to == C8)
		{
			p.board[D8].type = p.board[A8].type;
			p.board[A8].type = empty;
			p.board[D8].color = p.board[A8].color;
			p.board[A8].color = empty;
			
			p.hashkey ^= hashPieces[64*bR+8*ranks[A8]+files[A8]];
			p.hashkey ^= hashPieces[64*bR+8*ranks[D8]+files[D8]];
			
			p.pceNumToSq[p.sqToPceNum[A8]] = D8;
			p.sqToPceNum[D8] = p.sqToPceNum[A8];
			p.sqToPceNum[A8] = 0;
		}
	}
	else if (flag & oPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].type = empty;
			p.board[to-12].color = npco;
			
			p.hashkey ^= hashPieces[64*bP+8*ranks[to-12]+files[to-12]];
			p.material[black] -= vP;
			
			hist[histply].pList = p.sqToPceNum[to-12];
			p.pceNumToSq[p.sqToPceNum[to-12]] = 0;
			p.sqToPceNum[to-12] = 0;
		}
		else
		{
			p.board[to+12].type = empty;
			p.board[to+12].color = npco;
			
			p.hashkey ^= hashPieces[64*wP+8*ranks[to+12]+files[to+12]];
			p.material[white] -= vP;
			
			hist[histply].pList = p.sqToPceNum[to+12];
			p.pceNumToSq[p.sqToPceNum[to+12]] = 0;
			p.sqToPceNum[to+12] = 0;			
		}
	}
	
	r = isattacked(p.k[p.side], p.side^1);
	
	p.ply++;
	p.side ^= 1;
	histply++;
	
	
	if(p.en_pas!= noenpas)
		p.hashkey ^= hashEnPassant[files[p.en_pas]];
		
	if(!testhashkey)
		writeln("after making move ",returnmove(m));
		
	return r;
}

void takemove()
{
	p.ply--;
	p.side ^= 1;
	histply--;
	
	p.castleflags = hist[histply].castleFlags;
	p.en_pas = hist[histply].enPas;
	p.hashkey = hist[histply].hashKey;
	p.fifty = hist[histply].fifty;
	
	int from = FROM(hist[histply].data);
	int to = TO(hist[histply].data);
	int flag = FLAG(hist[histply].data);
	
	p.board[from] = p.board[to];
	p.board[to] = hist[histply].captured;
	
	p.sqToPceNum[from] = p.sqToPceNum[to];
	p.sqToPceNum[to] = hist[histply].pList;
	p.pceNumToSq[p.sqToPceNum[to]] = to;
	p.pceNumToSq[p.sqToPceNum[from]] = from;
	
	if(p.side == white && p.board[from].type == wK)
	{
		p.k[white] = from;
	}
	else if (p.side == black && p.board[from].type == bK)
	{
		p.k[black] = from;
	}
	
	if(hist[histply].captured.type != empty)
	{
		p.material[p.side] += vals[hist[histply].captured.type];
		if(hist[histply].captured.type > 2)
		{
			p.majors++;
		}
	}
	
	if(flag & mProm)
	{
		p.majors--;
		if(p.side == white)
		{
			p.board[from].type = wP;
		}
		else
		{
			p.board[from].type = bP;
		}
		if(flag & oPQ)
			p.material[p.side] -= vQ - vP;
		else if(flag & oPR)
			p.material[p.side] -= vR - vP;
		else if(flag & oPB)
			p.material[p.side] -= vB - vP;
		else if(flag & oPN)
			p.material[p.side] -= vN - vP;
	}
	else if(flag & mCA)
	{
		if(to == G1)
		{
			p.board[H1].type = p.board[F1].type;
			p.board[F1].type = empty;
			p.board[H1].color = p.board[F1].color;
			p.board[F1].color = npco;
			
			p.sqToPceNum[H1] = p.sqToPceNum[F1];
			p.sqToPceNum[F1] = 0;
			p.pceNumToSq[p.sqToPceNum[H1]] = H1;
		}
		else if(to == C1)
		{
			p.board[A1].type = p.board[D1].type;
			p.board[D1].type = empty;
			p.board[A1].color = p.board[D1].color;
			p.board[D1].color = npco;
			
			p.sqToPceNum[A1] = p.sqToPceNum[D1];
			p.sqToPceNum[D1] = 0;
			p.pceNumToSq[p.sqToPceNum[A1]] = A1;			
		}
		else if(to == G8)
		{
			p.board[H8].type = p.board[F8].type;
			p.board[F8].type = empty;
			p.board[H8].color = p.board[F8].color;
			p.board[F8].color = npco;
			
			p.sqToPceNum[H8] = p.sqToPceNum[F8];
			p.sqToPceNum[F8] = 0;
			p.pceNumToSq[p.sqToPceNum[H8]] = H8;
		}
		else if(to == C8)
		{
			p.board[A8].type = p.board[D8].type;
			p.board[D8].type = empty;
			p.board[A8].color = p.board[D8].color;
			p.board[D8].color = npco;
			
			p.sqToPceNum[A8] = p.sqToPceNum[D8];
			p.sqToPceNum[D8] = 0;
			p.pceNumToSq[p.sqToPceNum[A8]] = A8;			
		}
	}
	else if(flag & oPEP)
	{
		if(p.side == white)
		{
			p.board[to-12].type = bP;
			p.board[to-12].color = bpco;
			p.material[black] += vP;
			
			p.sqToPceNum[to-12] = hist[histply].pList;
			p.pceNumToSq[hist[histply].pList] = to-12;
			p.sqToPceNum[to] = 0;
		}
		else
		{
			p.board[to+12].type = wP;
			p.board[to+12].color = wpco;
			p.material[white] += vP;
			
			p.sqToPceNum[to+12] = hist[histply].pList;
			p.pceNumToSq[hist[histply].pList] = to+12;
			p.sqToPceNum[to] = 0;			
		}
	}
}