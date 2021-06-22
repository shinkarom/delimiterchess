import core.stdc.time, std.stdio, std.algorithm.searching, std.format, std.conv, std.string, core.time;
import data, defines, doundo, hash, io, setboard, movegen;

long actNodes;
bool target;
long[100] rootNodes;

long perft(int depth, bool silent = false)
{
	p.ply = 0;
	auto s = cast(double)(clock());
	rootNodes = 0;
	long nodes = goRoot(depth);
	auto f = cast(double)(clock());
	if(!silent)
		writeln(nodes,", actnodes ",actNodes, " time ",(f-s)/1000);
	return nodes;
}

long go(int depth)
{	
	if(depth == 0)
		return 1;
	long nodes = 0;	
	moveGen();
	for(int i  = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		//writeln(returnmove(p.list[i])," there is on depth ",depth);
		if(p.makeMove(p.list[i]))
		{
			//writeln("move ",returnmove(p.list[i])," depth ",depth," unavailable");
			p.takeMove();
			continue;
		}
		//writeln("move ",returnmove(p.list[i])," depth ",depth);
		testhashKey();
			
		nodes += go(depth-1);
		p.takeMove();
	}
	return nodes;
}

long goShow(int depth)
{
	if(depth == 0)
		return 1;
	long nodes = 0;
	moveGen();
	for(int i  = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		if(p.makeMove(p.list[i]))
		{
			p.takeMove();
			continue;
		}
		//writeln("making ",returnmove(p.list[i]));
		testhashKey();
			
		nodes += go(depth-1);
		p.takeMove();
	}
	return nodes;	
}

long goRoot(int depth)
{
	if(depth == 0)
		return 1;
	long nodes = 0;
	moveGen();

	//long oldnodes = 0;
	for(int i  = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		if(p.makeMove(p.list[i]))
		{
			//writeln("root move ",returnmove(p.list[i])," depth ",depth," unavailable");
			p.takeMove();
			continue;
		}
		//writeln("root move ",returnmove(p.list[i]));
		testhashKey();
			
		nodes += go(depth-1);
		p.takeMove();
		
		//rootnodes[i] = actnodes - oldnodes;
		//writeln(returnmove(p.list[i])," ",rootnodes[i]);
		//oldnodes = actnodes;
	}
	return nodes;	
}

void perftFile(int depth)
{
	long targetScore;
	
	File testfile = File("perftsuite.epd","r");
	
	foreach(fileline; testfile.byLine())
	{
		p.setBoard(fileline.idup);
		auto finddepth = fileline.find("D"~to!string(depth)~" ");
		if(finddepth == "")
			continue;
		finddepth = finddepth[3..$];
		formattedRead(finddepth, "%d", targetScore);
		long perftResult = perft(depth, true);		
		if(targetScore != perftResult)
		{
			writeln(fileline.idup.split(' ')[0..5].join(' ') ," | ",targetScore," ",perftResult," ");
		}
	}
	writeln("\n\nTest complete.");
	testfile.close();
}