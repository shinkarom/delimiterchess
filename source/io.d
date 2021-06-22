import std.stdio, core.time;
import defines, data, board, doundo, movegen;

string returnsquare(int from)
{
	return "" ~ fileToChar(files[from]) ~ rankToChar(ranks[from]);
}

string returnmove(Move move)
{
	string result = "";
	result ~= fileToChar(files[getFrom(move.m)]);
	result ~= rankToChar(ranks[getFrom(move.m)]);
	result ~= fileToChar(files[getTo(move.m)]);
	result ~= rankToChar(ranks[getTo(move.m)]);
	int flag = getFlag(move.m);
	if (flag & mProm)
	{
		if (flag & oPQ)
			result ~= "q";
		else if (flag & oPR)
			result ~= "r";
		else if (flag & oPB)
			result ~= "b";
		else if (flag & oPN)
			result ~= "n";
		else
			result ~= "E";
	}
	return result;
}

int understandmove(string move, ref bool prom)
{
	int returnflag = -1;
	prom = false;
	if ((move[0] < 'a' || move[0] > 'h') || (move[1] < '1' || move[1] > '8')
			|| (move[2] < 'a' || move[2] > 'h') || (move[3] < '1' || move[3] > '8'))
	{
		writeln("ILLEGAL PARSE : ", move);
		return -1;
	}
	Square from = fileRankToSquare(charToRank(move[1]), charToFile(move[0]));
	Square to = fileRankToSquare(charToRank(move[3]), charToFile(move[2]));

	moveGen();

	int i;
	for (i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		if (getFrom(p.list[i].m) == from && getTo(p.list[i].m) == to)
		{
			if (getFlag(p.list[i].m) & mProm)
			{
				if (move[4] == 'q' && (p.list[i].m & oPQ))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else if (move[4] == 'r' && (p.list[i].m & oPR))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else if (move[4] == 'b' && (p.list[i].m & oPB))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else if (move[4] == 'n' && (p.list[i].m & oPN))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else
					continue;
			}
			returnflag = i;
			break;
		}
	}

	if (returnflag == -1)
	{
		return -1;
	}

	if (p.makeMove(p.list[i]))
	{
		p.takeMove();
		writeln("illegal move!");
		returnflag = -1;
		prom = false;
	}
	return returnflag;
}

void printpv(int score)
{
	if (searchParam.ucimode)
	{
		write("info depth ", itDepth);
		write(" score cp ", score);
		write(" time ", (MonoTime.currTime() - MonoTime.zero())
				.total!"msecs" - searchParam.starttime);
		write(" nodes ", nodes + qnodes);
		write(" depth ", itDepth, " pv");
		for (int j = 0; j < pvindex[0]; j++)
		{
			write(" ", returnmove(pv[0][j]));
		}
		writeln();
	}
	else if (searchParam.post || searchParam.ics)
	{
		if (searchParam.post)
		{
			if (itDepth > 7 && !searchParam.pon)
			{
				write("tellothers depth ", itDepth, " score(cp) ", score);
				write(" time(s*100) ", cast(int)((MonoTime.currTime() - MonoTime.zero())
						.total!"msecs" - searchParam.starttime) / 10);
				write(" nodes ", nodes + qnodes, " pv=");
				for (int j = 0; j < pvindex[0]; j++)
				{
					write(" ", returnmove(pv[0][j]));
				}
				writeln();
			}
			write(itDepth, " ", score);
			write(" ", ((MonoTime.currTime() - MonoTime.zero())
					.total!"msecs" - searchParam.starttime) / 10);
			write(" ", nodes + qnodes);
			for (int j = 0; j < pvindex[0]; j++)
			{
				write(" ", returnmove(pv[0][j]));
			}
			writeln();
		}
	}
}

void stats()
{
	writeln("ordering = ", (fhf / fh) * 100);
	writeln("null success = ", (nullcut / nulltry) * 100);
	writeln("hashhit = ", (hashhit / hashprobe) * 100);
	writeln("pvsf = ", (pvsh / pvs) * 100);
	writeln("incheckext ", incheckext, " wasincheck ", wasincheck, " matethrt ", matethrt);
	writeln("pawnfifth ", pawnfifth, " pawnsix ", pawnsix, " prom ", prom, " hisred ", reduct);
	writeln("single ", single, " resethis ", resethis);
}

bool nopvmove(string move)
{
	if ((move[0] < 'a' || move[0] > 'h') || (move[1] < '1' || move[1] > '8')
			|| (move[2] < 'a' || move[2] > 'h') || (move[3] < '1' || move[3] > '8'))
		return true;
	return false;
}

string returncastle()
{
	string result;
	if (p.castleFlags & 8)
		result ~= "K";
	else
		result ~= "-";
	if (p.castleFlags & 4)
		result ~= "Q";
	else
		result ~= "-";
	if (p.castleFlags & 2)
		result ~= "k";
	else
		result ~= "-";
	if (p.castleFlags & 1)
		result ~= "Q";
	else
		result ~= "-";
	return result;
}

int myparse(string move)
{
	if ((move[0] < 'a' || move[0] > 'h') || (move[1] < '1' || move[1] > '8')
			|| (move[2] < 'a' || move[2] > 'h') || (move[3] < '1' || move[3] > '8'))
	{
		writeln("ILLEGAL PARSE : ", move);
		return -1;
	}
	Square from = fileRankToSquare(charToFile(move[0]), charToRank(move[1]));
	Square to = fileRankToSquare(charToFile(move[2]), charToRank(move[3]));

	moveGen();

	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		if (getFrom(p.list[i].m) == from && getTo(p.list[i].m) == to)
		{
			return i;
		}
	}
	return -1;
}
