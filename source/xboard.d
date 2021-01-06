import std.stdio, utils;
import data, defines, attack;

void inifile()
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
	//init_hash_tables();
}

void settime(double t, double ot, int compside)
{
	if(compside==white)
	{
		searchparam.wtime = t;
		searchparam.btime = ot;
	}
	else
	{
		searchparam.btime = t;
		searchparam.wtime = ot;		
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

bool drawmaterial()
{
	//gameeval();
	if(eval.wpawns || eval.bpawns) return false;
	if(eval.wRc || eval.wRc || eval.wQc || eval.bQc) return false;
	if(eval.wBc>1 || eval.bBc>1) return false;
	if(eval.wNc && eval.wBc) return false;
	if(eval.bNc && eval.bBc) return false;
	return true;
}

bool checkresult()
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
	
	/+
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
	+/
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

void readinmove(string m)
{
	/+
	if(nopvmove(m))
	{
		writeln("\nno pv move");
		return;
	}
	+/
	string move_string;
	int prom;
	if(m.length==4 || m[4]==' ')
	{
		move_string = m[0..4].idup;
	}
	else
	{
		move_string = m[0..5].idup;
	}
	/+
	int flag = understandmove(move_string, prom);
	if(flag == -1)
	{
		writeln("\nnot understood",m);
		assert(flag != 0);
	}
	+/
}

void xthink()
{
	import alloctime, core.stdc.time;
	
	double allocatedtime;
	if(!searchparam.pon)
	{
		allocatedtime = allocatetime();
		if(allocatedtime < 0) allocatedtime = 200;
		searchparam.starttime = cast(double)clock();
		searchparam.stoptime = searchparam.starttime + allocatedtime;
	}
	else
	{
		allocatedtime = (pondertime()*4)/3;
		searchparam.starttime = cast(double)clock();
		searchparam.pontime = searchparam.starttime + allocatedtime;
		searchparam.stoptime = searchparam.starttime + 128000000;
	}
	/+
		calc();
	+/
	
	if(!searchparam.pon)
	{
		//makemove(best);
		//writeln("move=",returnmove(best));
		if(searchparam.movestogo[p.side^1] != -1)
		{
			searchparam.movestogo[p.side^1]--;
		}
		searchparam.ponfrom = deadsquare;
		searchparam.ponto = deadsquare;
	}
	else
	{
		searchparam.ponfrom = FROM(best.m);
		searchparam.ponto = TO(best.m);
	}
}

void xboard_mode()
{
	import core.stdc.time, std.string, std.uni, std.format;
	immutable int noside = 2;

	int mps, base, inc;
	string command;

	inifile();
	/+
	setboard(startfen);
	clearhash();
	+/
	int compside = noside;
	/+
	initsearchparam();
	+/
	searchparam.xbmode = true;
	searchparam.usebook = true;
	while(true)
	{
		if(drawmaterial)
		{
			writeln("\n1/2-1/2 (insufficient material)");
		}
		if(checkresult()) compside = noside;
		if(compside == p.side)
		{
			if(searchparam.xtime != -1)
			{
				settime(searchparam.xtime, searchparam.xotime, compside);
			}
			xthink();
			if(checkresult()) compside = noside;
			if(searchparam.movestogo[p.side^1]==0) searchparam.movestogo[p.side^1] = mps;
			if(searchparam.cpon)
			{
				searchparam.pon = true;
				searchparam.inf = true;
				xthink();
				if(cast(double)(clock())> searchparam.stoptime)
				{
					writeln("pondertime was exceeded!");
				}
				searchparam.inf = false;
				searchparam.pon = false;
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
				/+
				initsearchparam();
				+/
				formattedRead(line, "level %d %d %d",mps, base, inc);
				if(mps)
				{
					searchparam.movestogo[white] = mps;
					searchparam.movestogo[black] = mps;
				}
				if(inc)
				{
					searchparam.winc = inc*1000;
					searchparam.binc = inc*1000;
				}
				searchparam.depth = -1;
				break;
			case "new":
				/+
				setboard(startfen);
				clearhash();
				+/
				compside = black;
				break;
			case "perft":
				/+
				setboard(startfen);
				clearhash();
				+/
				compside = black;
				/+
				perft(6);
				+/
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
				searchparam.depth = d;
				break;
			case "st":
				int t;
				formattedRead(line,"st %d",t);
				searchparam.timepermove = t*1000;
				searchparam.depth = -1;
				break;
			case "time":
				int t;
				formattedRead(line,"time %d",t);
				searchparam.xtime = t*10;
				searchparam.depth = -1;
				break;	
			case "otim":
				int t;
				formattedRead(line,"otim %d",t);
				searchparam.xotime = t*10;
				searchparam.depth = -1;
				break;	
			case "usermove":
				readinmove(line[9..$]);
				if(searchparam.movestogo[p.side^1]!=-1)
				{
					searchparam.movestogo[p.side^1]--;
					if(searchparam.movestogo[p.side^1]==0)
						searchparam.movestogo[p.side^1]=mps;
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
				/+
				setboard(line[9..$]);
				printboard();
				+/
				break;
			case "ics":
				searchparam.ics = (line[4] != '-');
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
				/+
				if(histply>0)
				{
					takemove();
					if(histply>0)
					{
						takemove();
					}
				}
				+/
				break;
			case "undo":
				/+
				if(histply>0)
				{
					takemove();
				}
				+/
				break;
			case "hard":
				searchparam.cpon = true;
				break;
			case "easy":
				searchparam.cpon = false;
				break;
			case "post":
				searchparam.post = true;
				break;
			case "nopost":
				searchparam.post = false;
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