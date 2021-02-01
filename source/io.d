import std.stdio, core.stdc.time;
import defines, data, board, doundo, movegen;

string returnsquare(int from)
{
	return ""~filetochar(files[from])~ranktochar(ranks[from]);
}

string returnmove(Move move)
{
	string result = "";
	result ~= filetochar(files[FROM(move.m)]);
	result ~= ranktochar(files[FROM(move.m)]);
	result ~= filetochar(files[TO(move.m)]);
	result ~= ranktochar(files[TO(move.m)]);
	int flag = FLAG(move.m);
	if(flag & mProm)
	{
		if(flag & oPQ)
			result ~= "q";
		else if(flag & oPR)
			result ~= "r";
		else if(flag & oPB)
			result ~= "b";
		else if(flag & oPN)
			result ~= "n";
		else
			result ~= "E";
	}
	return result;
}

int understandmove(string move, ref bool prom)
{
	int returnflag = -1;
	prom  = false;
	if((move[0]<'a'||move[0]>'h') || (move[1]<'1'||move[1]>'8') || (move[2]<'a'||move[2]>'h') || (move[3]<'1'||move[3]>'8'))
	{
		writeln("ILLEGAL PARSE : ",move);
		return -1;
	}
	int from = fileranktosquare(chartofile(move[0]), chartorank(move[1]));
	int to = fileranktosquare(chartofile(move[2]), chartorank(move[3]));
	
	/+
	movegen();
	+/
	int i;
	for(i = p.listc[p.ply]; i<p.listc[p.ply+1]; i++)
	{
		if(FROM(p.list[i].m)==from && TO(p.list[i].m)==to)
		{
			if(FLAG(p.list[i].m) & mProm)
			{
				if(move[4]=='q' && (p.list[i].m & oPQ))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else if(move[4]=='r' && (p.list[i].m & oPR))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else if(move[4]=='b' && (p.list[i].m & oPB))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else if(move[4]=='n' && (p.list[i].m & oPN))
				{
					returnflag = i;
					prom = true;
					break;
				}
				else continue;
			}
			returnflag = i;
			break;
		}
	}
	
	if(returnflag == -1)
	{
		return -1;
	}

	if(makemove(p.list[i]))
	{
		takemove();
		writeln("illegal move!");
		returnflag = -1;
		prom = false;
	}
	return returnflag;
}

void printpv(int score)
{
	if(searchParam.ucimode)
	{
		write("info depth ",itdepth);
		write(" score cp ",score);
		write(" time ",cast(double)(clock())-searchParam.starttime);
		write(" nodes ",nodes+qnodes);
		write(" depth ",itdepth," pv");
		for(int j = 0; j<pvindex[0]; j++)
		{
			write(" ",returnmove(pv[0][j]));
		}
		writeln();
	}
	else if(searchParam.post || searchParam.ics)
	{
		if(searchParam.post)
		{
			if(itdepth>7 && !searchParam.pon)
			{
				write("tellothers depth ",itdepth," score(cp) ",score);
				write(" time(s*100) ",cast(int)((cast(double)(clock))-searchParam.starttime)/10);
				write(" nodes ",nodes+qnodes," pv=");
				for(int j = 0; j<pvindex[0]; j++)
				{
					write(" ",returnmove(pv[0][j]));
				}
				writeln();
			}
			write(itdepth," ",score);
			write(" ",cast(int)((cast(double)(clock))-searchParam.starttime)/10);
			write(" ",nodes+qnodes);
			for(int j = 0; j<pvindex[0]; j++)
			{
				write(" ",returnmove(pv[0][j]));
			}
			writeln();
		}
	}
}

void stats()
{
	writeln("ordering = ",(fhf/fh)*100);
	writeln("null success = ",(nullcut/nulltry)*100);
	writeln("hashhit = ",(hashhit/hashprobe)*100);
	writeln("pvsf = ",(pvsh/pvs)*100);
	writeln("incheckext ",incheckext," wasincheck ",wasincheck," matethrt ",matethrt);
	writeln("pawnfifth ",pawnfifth," pawnsix ",pawnsix," prom ",prom," hisred ",reduct);
	writeln("single ",single," resethis ",resethis);
}

bool nopvmove(string move)
{
	if((move[0]<'a'||move[0]>'h') || (move[1]<'1'||move[1]>'8') || (move[2]<'a'||move[2]>'h') || (move[3]<'1'||move[3]>'8'))
		return true;
	return false;
}

string returncastle()
{
	string result;
	if(p.castleflags & 8)
		result ~= "K";
	else
		result ~= "-";
	if(p.castleflags & 4)
		result ~= "Q";
	else
		result ~= "-";
	if(p.castleflags & 2)
		result ~= "k";
	else
		result ~= "-";
	if(p.castleflags & 1)
		result ~= "Q";
	else
		result ~= "-";
	return result;
}

int myparse(string move)
{
	if((move[0]<'a'||move[0]>'h') || (move[1]<'1'||move[1]>'8') || (move[2]<'a'||move[2]>'h') || (move[3]<'1'||move[3]>'8'))
	{
		writeln("ILLEGAL PARSE : ",move);
		return -1;
	}
	int from = fileranktosquare(chartofile(move[0]), chartorank(move[1]));
	int to = fileranktosquare(chartofile(move[2]), chartorank(move[3]));
	
	moveGen();
	
	for(int i = p.listc[p.ply]; i<p.listc[p.ply+1]; i++)
	{
		if(FROM(p.list[i].m)==from && TO(p.list[i].m)==to)
		{
			return i;
		}
	}
	return -1;
}