import std.stdio, core.time;
import data, defines, attack, setboard, io, hash, doundo, utils, perftm, calcm, movegen, eval;

void iniFile()
{
	import std.file : exists;

	numelem = 16;

	if (!exists("delimiter.ini"))
		return;

	File ini = File("delimiter.ini", "r");
	int size;
	ini.readf("%d", size);
	numelem = size;
	writeln("numelem set to ", numelem);
	init_hash_tables();
}

void setTime(ulong t, ulong ot, int compside)
{
	if (compside == Side.White)
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
	for (int i = 0; i < histply; i++)
	{
		if (hist[i].hashKey == p.hashkey)
			rep++;
	}
	return rep;
}

bool drawMaterial()
{
	gameEval();
	if (evalData.wpawns || evalData.bpawns)
		return false;
	if (evalData.wRc || evalData.bRc || evalData.wQc || evalData.bQc)
		return false;
	if (evalData.wBc > 1 || evalData.bBc > 1)
		return false;
	if (evalData.wNc && evalData.wBc)
		return false;
	if (evalData.bNc && evalData.bBc)
		return false;
	return true;
}

bool checkResult()
{
	if (p.fifty > 100)
	{
		writeln("\n1/2-1/2 {fifty move rule}");
		return true;
	}
	if (repetition() >= 2)
	{
		writeln("\n1/2-1/2 {3-fold repetition}");
		return true;
	}

	moveGen();

	int played = 0;

	for (int i = p.listc[p.ply]; i < p.listc[p.ply + 1]; i++)
	{
		if (makeMove(p.list[i]))
		{
			takeMove();
			continue;
		}

		played++;
		takeMove();
	}
	if (played)
		return false;
	bool inc = isAttacked(p.k[p.side], p.side ^ 1);

	if (inc)
	{
		if (p.side == Side.White)
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
	if (nopvmove(m))
	{
		writeln("\nno pv move");
		return;
	}
	string move_string;
	bool prom;
	if (m.length == 4 || m[4] == ' ')
	{
		move_string = m[0 .. 4].idup;
	}
	else
	{
		move_string = m[0 .. 5].idup;
	}
	int flag = understandmove(move_string, prom);
	if (flag == -1)
	{
		writeln("\nnot understood", m);
		assert(flag != 0);
	}
}

void xThink()
{
	import alloctime, core.stdc.time;

	ulong allocatedtime;
	if (!searchParam.pon)
	{
		allocatedtime = allocateTime();
		if (allocatedtime < 0)
			allocatedtime = 200;
		searchParam.starttime = (MonoTime.currTime - MonoTime.zero()).total!"msecs";
		searchParam.stoptime = searchParam.starttime + allocatedtime;
	}
	else
	{
		allocatedtime = (ponderTime() * 4) / 3;
		searchParam.starttime = (MonoTime.currTime - MonoTime.zero()).total!"msecs";
		searchParam.pontime = searchParam.starttime + allocatedtime;
		searchParam.stoptime = searchParam.starttime + 128000000;
	}
	calc();

	if (!searchParam.pon)
	{
		makeMove(best);
		writeln("move=", returnmove(best));
		if (searchParam.movestogo[p.side ^ 1] != -1)
		{
			searchParam.movestogo[p.side ^ 1]--;
		}
		searchParam.ponfrom = deadsquare;
		searchParam.ponto = deadsquare;
	}
	else
	{
		searchParam.ponfrom = getFrom(best.m);
		searchParam.ponto = getTo(best.m);
	}
}

void xboardMode()
{
	import core.stdc.time, std.string, std.uni, std.format;

	immutable int noside = 2;

	int mps, base, inc;
	string command;

	iniFile();
	setBoard(startFEN);
	clearhash();
	int compside = noside;
	initSearchParam();
	searchParam.xbmode = true;
	searchParam.usebook = true;
	while (true)
	{
		if (drawMaterial)
		{
			writeln("\n1/2-1/2 (insufficient material)");
		}
		if (checkResult())
			compside = noside;
		if (compside == p.side)
		{
			if (searchParam.xtime != -1)
			{
				setTime(searchParam.xtime, searchParam.xotime, compside);
			}
			xThink();
			if (checkResult())
				compside = noside;
			if (searchParam.movestogo[p.side ^ 1] == 0)
				searchParam.movestogo[p.side ^ 1] = mps;
			if (searchParam.cpon)
			{
				searchParam.pon = true;
				searchParam.inf = true;
				xThink();
				if ((MonoTime.currTime() - MonoTime.zero()).total!"msecs" > searchParam.stoptime)
				{
					writeln("pondertime was exceeded!");
				}
				searchParam.inf = false;
				searchParam.pon = false;
			}
		}
		string line = readln().strip().toLower();
		if (line == "")
			continue;
		formattedRead(line, "%s", command);
		switch (command)
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
			formattedRead(line, "level %d %d %d", mps, base, inc);
			if (mps)
			{
				searchParam.movestogo[Side.White] = mps;
				searchParam.movestogo[Side.Black] = mps;
			}
			if (inc)
			{
				searchParam.winc = inc * 1000;
				searchParam.binc = inc * 1000;
			}
			searchParam.depth = -1;
			break;
		case "new":
			setBoard(startFEN);
			clearhash();
			compside = Side.Black;
			break;
		case "perft":
			setBoard(startFEN);
			clearhash();
			compside = Side.Black;
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
			formattedRead(line, "sd %d", d);
			searchParam.depth = d;
			break;
		case "st":
			int t;
			formattedRead(line, "st %d", t);
			searchParam.timepermove = t * 1000;
			searchParam.depth = -1;
			break;
		case "time":
			int t;
			formattedRead(line, "time %d", t);
			searchParam.xtime = t * 10;
			searchParam.depth = -1;
			break;
		case "otim":
			int t;
			formattedRead(line, "otim %d", t);
			searchParam.xotime = t * 10;
			searchParam.depth = -1;
			break;
		case "usermove":
			readInMove(line[9 .. $]);
			if (searchParam.movestogo[p.side ^ 1] != -1)
			{
				searchParam.movestogo[p.side ^ 1]--;
				if (searchParam.movestogo[p.side ^ 1] == 0)
					searchParam.movestogo[p.side ^ 1] = mps;
			}
			break;
		case "ping":
			int p;
			formattedRead(line, "ping %d", p);
			writeln("pong ", p);
			break;
		case "draw":
			if (isDrawnP() == 0)
				writeln("offer draw");
			break;
		case "setboard":
			setBoard(line[9 .. $]);
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
			compside = Side.White;
			break;
		case "black":
			compside = Side.Black;
			break;
		case "remove":
			if (histply > 0)
			{
				takeMove();
				if (histply > 0)
				{
					takeMove();
				}
			}
			break;
		case "undo":
			if (histply > 0)
			{
				takeMove();
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
