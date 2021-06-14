import std.stdio, std.format, std.string, std.algorithm.searching, std.array, std.conv, core.time;
import data, defines, utils, log, alloctime, setboard, io, hash, calcm;

const string[] uciStrings = [
	"id name " ~ engineName ~ " " ~ engineVersion, "id author " ~ engineAuthor,
	"option name Hash type spin default 16 min 4 max 512",
	"option name OwnBook type check default false",
	"option name BookFile type string default binbook.bin",
	"option name PawnStructure type spin default 128 min 12 max 256",
	"option name KingSafety type spin default 128 min 12 max 256",
	"option name PassedPawn type spin default 128 min 12 max 256",
	"option name Ponder type check default true", "uciok"
];

string[] autorunLines = ["position startpos", "go wtime 60000 btime 60000 winc 1000 binc 1000", "quit"];

void uciMode()
{
	searchParam.cpon = true;
	searchParam.ucimode = true;
	searchParam.usebook = false;
	foreach (s; uciStrings)
		writeln(s);
	uciLoop();
}

void uciLoop()
{
	if (debugMode)
		foreach (l; autorunLines)
			parseLine(l);
	while (true)
	{
		string line = readln().strip();
		if (line.length == 0)
			continue;
		else
			parseLine(line);
	}
}

void parseLine(string str)
{
	string command;
	int spaceIndex = 0;
	while ((spaceIndex < str.length) && (str[spaceIndex] != ' '))
		spaceIndex++;
	if (spaceIndex != str.length)
		command = str[0 .. spaceIndex];
	else
		command = str;
	switch (command)
	{
	case "isready":
		writeln("readyok");
		break;
	case "position":
		parsePosition(str[9 .. $]);
		break;
	case "setoption":
		parseOption(str[10 .. $]);
		break;
	case "ucinewgame":
		setBoard(startFEN);
		clearhash();
		break;
	case "go":
		parseGo(str[3 .. $]);
		break;
	case "setboard":
		break;
	case "quit":
		exitAll();
		break;
	case "uci":
		foreach (s; uciStrings)
			writeln(s);
		break;
	default:
		writeln("unknown command");
		break;
	}
}

void parsePosition(string str)
{
	if (logme)
	{
		writestring("parsing position...\n");
		writestring(str ~ "\n");
	}
	string fen = str.find("fen ");
	string moves = str.find("moves ");
	if (fen != "")
	{
		fen = fen[4 .. $];
		setBoard(fen);
	}
	else
	{
		setBoard(startFEN);
	}

	bool prom;
	if (moves != "")
	{
		string[] moveArray = moves.split(" ")[1 .. $];
		foreach (m; moveArray)
		{
			immutable flag = understandmove(m, prom);
			if (flag == -1)
			{
				writestring("not understood " ~ m);
				assert(flag != 0);
			}
		}
	}
}

void parseGo(string str)
{
	if (logme)
	{
		writestring("parsing go\n");
		writestring(str);
	}

	initSearchParam();
	auto arr = str.split(' ');
	for (int i = 0; i < arr.length; i++)
	{
		switch (arr[i])
		{
		case "infinite":
			searchParam.inf = true;
			break;
		case "binc":
			i++;
			searchParam.binc = to!ulong(arr[i]);
			break;
		case "btime":
			i++;
			searchParam.btime = to!ulong(arr[i]);
			break;
		case "depth":
			i++;
			searchParam.depth = to!int(arr[i]);
			break;
		case "mate":
			break;
		case "movestogo":
			i++;
			searchParam.movestogo[p.side] = to!int(arr[i]);
			break;
		case "movetime":
			i++;
			searchParam.timepermove = to!ulong(arr[i]);
			break;
		case "nodes":
			break;
		case "ponder":
			searchParam.pon = true;
			searchParam.inf = true;
			break;
		case "searchmoves":
			break;
		case "winc":
			i++;
			searchParam.winc = to!ulong(arr[i]);
			break;
		case "wtime":
			i++;
			searchParam.wtime = to!ulong(arr[i]);
			break;
		default:
			break;
		}
	}

	think();
}

void think()
{
	ulong allocatedtime = allocateTime();
	if (allocatedtime == 0)
		allocatedtime = 200;
	//writeln("allocated ",allocatedtime);
	searchParam.starttime = (MonoTime.currTime() - MonoTime.zero()).total!"msecs";
	searchParam.stoptime = searchParam.starttime + allocatedtime;
	if (logme)
	{
		writestring("Calling calc(), allocatedtime = " ~ to!string(allocatedtime));
		writeboard();
	}
	calc();
	if (logme)
	{
		writestring("Returned from calc()");
		writeboard();
	}
	searchParam.inf = false;
	if (ponderMove.m)
		writeln("bestmove ", returnmove(best), " ponder ", returnmove(ponderMove));
	else
		writeln("bestmove ", returnmove(best));
}

void parseOption(string str)
{
	auto arr = str.split();
	if (arr[0] != "name" || arr[2] != "value")
	{
		writeln("erroneous command");
		return;
	}
	string value = arr[3];
	switch (arr[1])
	{
	case "Hash":
		int val = to!int(value);
		if (val < 4)
			val = 4;
		numelem = val;
		init_hash_tables();
		break;
	case "OwnBook":
		if (value == "true")
			searchParam.usebook = true;
		else if (value == "false")
			searchParam.usebook = false;
		break;
	case "BookFile":
		if (value == "")
			bookFile = "binbook.bin";
		else
			bookFile = value;
		break;
	case "KingSafety":
		eo.kingSafety = to!int(value);
		writestring("King Safety adjusted to ");
		writeint(eo.kingSafety);
		break;
	case "PassedPawn":
		eo.passedPawn = to!int(value);
		writestring("Passed Pawn adjusted to ");
		writeint(eo.passedPawn);
		break;
	case "PawnStructure":
		eo.pawnStructure = to!int(value);
		writestring("Pawn Structure adjusted to ");
		writeint(eo.pawnStructure);
		break;
	case "Ponder":
		break;
	default:
		break;
	}
}
