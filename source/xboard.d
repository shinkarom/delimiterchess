import std.stdio;
import data, defines, attack, setboard, io, hash, doundo, utils, perftm;

void iniFile()
{
	import std.file: exists;
	
	numelem = 16;
	
	if(!exists("delimiter.ini"))
		return;
	
	File ini = File("delimiter.ini","r");
	int size;
	ini.readf("%d",size);
	numelem = size;
	writeln("numelem set to ",numelem);
	init_hash_tables();
}

void setTime(double t, double ot, int compside)
{
	if(compside==white)
	{
		searchParam.wtime = t;
		searchParam.btime = ot;
	}
	else
	{
		searchParam.btime = t;
		searchParam.wtime = ot;		
	}
}

int repetition()
{
	int rep = 0;
	for(int i = 0; i<histply; i++)
	{
		if(hist[i].hashkey == p.hashkey)
			rep++;
	}
	return rep;
}

bool drawMaterial()
{
	//gameeval();
	if(eval.wpawns || eval.bpawns) return false;
	if(eval.wRc || eval.wRc || eval.wQc || eval.bQc) return false;
	if(eval.wBc>1 || eval.bBc>1) return false;
	if(eval.wNc && eval.wBc) return false;
	if(eval.bNc && eval.bBc) return false;
	return true;
}

bool checkResult()
{
	if(p.fifty>100)
	{
		writeln("\n1/2-1/2 {fifty move rule}");
		return true;
	}
	if(repetition()>=2)
	{
		writeln("\n1/2-1/2 {3-fold repetition}");
		return true;
	}
	
	//movegen();
	
	int played = 0;
	
	for(int i = p.listc[p.ply]; i<p.listc[p.ply+1]; i++)
	{
		if(makemove(p.list[i]))
		{
			takemove();
			continue;
		}
		
		played++;
		takemove();
	}
	if(played) return false;
	bool inc = isattacked(p.k[p.side], p.side^1);
	
	if(inc)
	{
		if(p.side==white)
		{
			writeln("\n0-1 {black mates}");
			return true;
		}
		else
		{
			writeln("\n1-0 {white mates}");
			return true;
		}
	}
	else
	{
		writeln("\n1/2-1/2 {stalemate}");
		return true;
	}
}

void readInMove(string m)
{
	if(nopvmove(m))
	{
		writeln("\nno pv move");
		return;
	}
	string move_string;
	bool prom;
	if(m.length==4 || m[4]==' ')
	{
		move_string = m[0..4].idup;
	}
	else
	{
		move_string = m[0..5].idup;
	}
	int flag = understandmove(move_string, prom);
	if(flag == -1)
	{
		writeln("\nnot understood",m);
		assert(flag != 0);
	}
}

void xThink()
{
	import alloctime, core.stdc.time;
	
	double allocatedtime;
	if(!searchParam.pon)
	{
		allocatedtime = allocatetime();
		if(allocatedtime < 0) allocatedtime = 200;
		searchParam.starttime = cast(double)clock();
		searchParam.stoptime = searchParam.starttime + allocatedtime;
	}
	else
	{
		allocatedtime = (pondertime()*4)/3;
		searchParam.starttime = cast(double)clock();
		searchParam.pontime = searchParam.starttime + allocatedtime;
		searchParam.stoptime = searchParam.starttime + 128000000;
	}
	/+
		calc();
	+/
	
	if(!searchParam.pon)
	{
		makemove(best);
		writeln("move=",returnmove(best));
		if(searchParam.movestogo[p.side^1] != -1)
		{
			searchParam.movestogo[p.side^1]--;
		}
		searchParam.ponfrom = deadsquare;
		searchParam.ponto = deadsquare;
	}
	else
	{
		searchParam.ponfrom = FROM(best.m);
		searchParam.ponto = TO(best.m);
	}
}

void xboardMode()
{
	import core.stdc.time, std.string, std.uni, std.format;
	immutable int noside = 2;

	int mps, base, inc;
	string command;

	iniFile();
	setBoard(startfen);
	clearhash();
	int compside = noside;
	initSearchParam();
	searchParam.xbmode = true;
	searchParam.usebook = true;
	while(true)
	{
		if(drawMaterial)
		{
			writeln("\n1/2-1/2 (insufficient material)");
		}
		if(checkResult()) compside = noside;
		if(compside == p.side)
		{
			if(searchParam.xtime != -1)
			{
				setTime(searchParam.xtime, searchParam.xotime, compside);
			}
			xThink();
			if(checkResult()) compside = noside;
			if(searchParam.movestogo[p.side^1]==0) searchParam.movestogo[p.side^1] = mps;
			if(searchParam.cpon)
			{
				searchParam.pon = true;
				searchParam.inf = true;
				xThink();
				if(cast(double)(clock())> searchParam.stoptime)
				{
					writeln("pondertime was exceeded!");
				}
				searchParam.inf = false;
				searchParam.pon = false;
			}
		}
		string line = readln().strip().toLower();
		if(line=="")
			continue;
		formattedRead(line, "%s", command);
		switch(command)
		{
			case "xboard":
				break;
			case "protover":
				writeln("feature usermove=1");
				writeln("feature ping=1");
				writeln("feature setboard=1");
				writeln("feature reuse=1");
				writeln("feature colors=0");
				writeln("feature name=0");
				writeln("feature done=1");
				writeln("feature ics=1");
				break;
			case "level":
				initSearchParam();
				formattedRead(line, "level %d %d %d",mps, base, inc);
				if(mps)
				{
					searchParam.movestogo[white] = mps;
					searchParam.movestogo[black] = mps;
				}
				if(inc)
				{
					searchParam.winc = inc*1000;
					searchParam.binc = inc*1000;
				}
				searchParam.depth = -1;
				break;
			case "new":
				setBoard(startfen);
				clearhash();
				compside = black;
				break;
			case "perft":				
				setBoard(startfen);
				clearhash();
				compside = black;
				perft(6);
				break;	
			case "quit":
				exitAll();
				return;
			case "force":
				compside = noside;
				break;
			case "go":
				compside = p.side;
				break;
			case "pr":
				/+
				printboard();
				+/
				break;
			case "sd":
				int d;
				formattedRead(line,"sd %d",d);
				searchParam.depth = d;
				break;
			case "st":
				int t;
				formattedRead(line,"st %d",t);
				searchParam.timepermove = t*1000;
				searchParam.depth = -1;
				break;
			case "time":
				int t;
				formattedRead(line,"time %d",t);
				searchParam.xtime = t*10;
				searchParam.depth = -1;
				break;	
			case "otim":
				int t;
				formattedRead(line,"otim %d",t);
				searchParam.xotime = t*10;
				searchParam.depth = -1;
				break;	
			case "usermove":
				readInMove(line[9..$]);
				if(searchParam.movestogo[p.side^1]!=-1)
				{
					searchParam.movestogo[p.side^1]--;
					if(searchParam.movestogo[p.side^1]==0)
						searchParam.movestogo[p.side^1]=mps;
				}
				break;
			case "ping":
				int p;
				formattedRead(line,"ping %d",p);
				writeln("pong ",p);
				break;
			case "draw":
				/+
				if(isdrawnp()==0)
					writeln("offer draw");
				+/
				break;
			case "setboard":				
				setBoard(line[9..$]);
				/+
				printboard();
				+/
				break;
			case "ics":
				searchParam.ics = (line[4] != '-');
				break;
			case "hint":
				break;
			case "result":
				break;
			case "bk":
				break;
			case "white":
				compside = white;
				break;
			case "black":
				compside = black;
				break;
			case "remove":
				if(histply>0)
				{
					takemove();
					if(histply>0)
					{
						takemove();
					}
				}
				break;
			case "undo":
				if(histply>0)
				{
					takemove();
				}
				break;
			case "hard":
				searchParam.cpon = true;
				break;
			case "easy":
				searchParam.cpon = false;
				break;
			case "post":
				searchParam.post = true;
				break;
			case "nopost":
				searchParam.post = false;
				break;
			case "name":
				break;
			case "computer":
				break;
			case "random":
				break;
			default:
				writeln("\nerror");
				break;
		}
	}
}