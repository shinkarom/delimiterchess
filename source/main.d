import std.stdio, std.string, std.conv;
import utils, defines, data, psqt, log, board, sort, interrupt, xboard, root, uci, hash, book, eval, perftm, debugit, movegen, setboard, io, doundo;

void main()
{
	scope(exit)
	{
		closelog();
	}

	debugMode = false;
	unbufferStreams();
	numelem = 32;
	initCastleBits();
	init_distancetable();
	init_hash_tables();	
	logme = false;
	openlog();
	
	eo.passedPawn = 176;
	eo.kingSafety = 128;
	eo.pawnStructure = 96;
	
	searchParam.xbmode = false;
	searchParam.ucimode = false;
	searchParam.ics = false;
	searchParam.cpon = false;
	
	book_init();
	
	setBoard(startFEN);
	//printBoard();
	if(debugMode)
	{
		//setBoard("7K/7p/7k/8/8/8/8/8 w - - 1 1 "); //should have some moves
		//printBoard();
		//perftfile(2);
		uciMode();
	}
	while(true)
	{
		string line = readln().strip().idup();
		string[] tokens = line.split(" ");
		string command = tokens[0];
		switch(command)
		{
			case "uci":
				uciMode();
				break;			
			case "xboard":
				xboardMode();
				break;	
			case "moves":
				moveGen();
				printMoveList();
				break;
			case "suite":
				perftfile(to!int(tokens[1]));
				break;
			case "perft":
				int d = to!int(tokens[1]);
				perft(d);
				break;
			case "undo":
				takemove();
				printBoard();
				break;
			case "print":
				printBoard();
				break;
			case "quit":			
				exitAll();
				break;
			default:
				bool prom;
				auto flag = understandmove(command, prom);
				if(flag != -1)
				{
					printBoard();
				}
				else 
				{
					writeln("\nunknown command ",command);
					writeln("use 'uci' or 'quit'");
				}
				break;
		}
	}	
}
