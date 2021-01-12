import std.stdio, std.format, std.string, std.algorithm.searching, std.array, std.conv, core.stdc.time;
import data, defines, utils, log, alloctime, setboard, io;

const string[] uciStrings = [
	"id name Delimiter",
	"id author Roman Shynkarenko",
	"option name Hash type spin default 16 min 4 max 512",
	"option name OwnBook type check default false",
	"option name PawnStructure type spin default 128 min 12 max 256",
	"option name KingSafety type spin default 128 min 12 max 256",
	"option name PassedPawn type spin default 128 min 12 max 256",
	"option name Ponder type check default true",
	"uciok"
];

void uciMode()
{
	searchParam.cpon = true;
	searchParam.ucimode = true;
	searchParam.usebook = false;
	foreach(s; uciStrings)
		writeln(s);
	uciLoop();
}

void uciLoop()
{
	while(true)
	{
		string line = readln().strip();
		if(line.length==0)
			continue;
		string command;
		formattedRead(line,"%s",command);	
		switch(command)
		{
			case "isready":
				writeln("readyok");
				break;
			case "position":
				parsePosition(line[9..$]);
				break;
			case "setoption":
				parseOption(line[10..$]);
				break;
			case "ucinewgame":
				/+
				setboard(startfen);
				clearhash();
				+/
				break;
			case "go":
				parseGo(line[3..$]);
				break;
			case "setboard":
				break;
			case "quit":
				exitAll();
				break;
			case "uci":
				foreach(s; uciStrings)
					writeln(s);
				break;
			default:
				writeln("unknown command");
				break;
		}
	}
}

void parsePosition(string str)
{
	if(logme)
	{
		writestring("parsing position...\n");
		writestring(str~"\n");
	}
	string fen = str.find("fen ")[4..$];
	string moves = str.find("moves ")[6..$];
	if(fen != "")
	{
		setBoard(fen);
	}
	else
	{
		setBoard(startfen);
	}
	//now, if we have moves, parse and make them
	string moveString;
	bool prom;
	if(moves != "")
	{
		while(moves.length >=4)
		{
			if(moves.length >= 5 && moves[4]!=' ')
			{
				moveString = moves[0..5];
				moves = moves[5..$];
			}
			else
			{
				moveString = moves[0..4];
				moves = moves[4..$];
			}
			int flag = understandmove(moveString, prom);
			if(flag == -1)
			{
				writestring("not understood "~moveString);
				assert(flag != 0);
			}
			moves = moves[moveString.length..$];
			while(moves.length>0 && moves[0]==' ')
			{
				moves = moves[1..$];
			}
		}
	}
}

void parseGo(string str)
{
	if(logme)
	{
		writestring("parsing go\n");
		writestring(str);
	}
	
	initSearchParam();
	auto arr = str.split()[1..$];
	
	for(int i = 0; i<arr.length; i++)
	{
		switch(arr[i])
		{
			case "infinite":
				searchParam.inf = true;
				break;
			case "binc":
				i++;
				searchParam.binc = to!double(arr[i]);
				break;
			case "btime":
				i++;
				searchParam.btime = to!double(arr[i]);
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
				searchParam.timepermove = to!double(arr[i]);
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
				searchParam.winc = to!double(arr[i]);
				break;
			case "wtime":
				i++;
				searchParam.wtime = to!double(arr[i]);
				break;
			default:
				break;
		}
	}
	
	think();
}

void think()
{
	double allocatedtime = allocatetime();
	writeln("allocated ",allocatedtime);
	if(allocatedtime<0)
		allocatedtime = 200;
	searchParam.starttime = cast(double)(clock());
	searchParam.stoptime = searchParam.starttime+allocatedtime;
	if(logme)
	{
		writestring("Calling calc(), allocatedtime = "~to!string(allocatedtime));
		writeboard();
	}
	/+
	calc();
	+/
	if(logme)
	{
		writestring("Returned from calc()");
		writeboard();		
	}
	searchParam.inf = false;
	/+
	writeln("bestmove ",returnmove(best)," ponder ",returnmove(pondermove));
	+/
}

void parseOption(string str)
{
	auto arr = str.split();
	if(arr[0]!="name" || arr[2]!="value")
	{
		writeln("erroneous command");
		return;
	}
	string value = arr[3];
	switch(arr[1])
	{
		case "Hash":
			int val = to!int(value);
			if(val<4)
				val = 4;
			numelem = val;
			/+
			init_hash_tables();
			+/
			break;
		case "OwnBook":
			if(value=="true")
				searchParam.usebook = true;
			else if (value=="false")
				searchParam.usebook = false;
			break;
		case "KingSafety":
			eo.kingsafety = to!int(value);
			writestring("King Safety adjusted to ");
			writeint(eo.kingsafety);
			break;
		case "PassedPawn":
			eo.passedpawn = to!int(value);
			writestring("Passed Pawn adjusted to ");
			writeint(eo.passedpawn);
			break;
		case "PawnStructure":
			eo.pawnstructure = to!int(value);
			writestring("Pawn Structure adjusted to ");
			writeint(eo.pawnstructure);
			break;
		case "Ponder":
			break;
		default:
			break;
	}
}