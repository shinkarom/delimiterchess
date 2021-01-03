import std.stdio, std.string;
import utils, defines, data, psqt, log, board, sort, interrupt, xboard;

void main()
{
	unbufferStreams();
	numelem = 32;
	init_castlebits();
	/+
	init_distancetable();
	init_hash_tables();
	+/
	logme = false;
	openlog();
	eo.passedpawn = 176;
	eo.kingsafety = 128;
	eo.pawnstructure = 96;
	searchparam.xbmode = false;
	searchparam.ucimode = false;
	searchparam.ics = false;
	searchparam.cpon = false;
	/+
	book_init();
	+/	
	string command;
	while(true)
	{
		command = readln().strip();
		if(command=="uci")
		{
			/+
			uci_mode();
			+/
			break;
		}
		else if (command=="xboard")
		{
			xboard_mode();
			break;
		}
		else if(command=="quit")
		{
			break;
		}
		else
		{
			writeln("\nunknown command ",command);
			writeln("use 'uci' or 'quit'");
		}
	}
	
		closelog();
}
