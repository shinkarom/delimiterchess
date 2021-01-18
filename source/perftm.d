import core.stdc.time, std.stdio, std.algorithm.searching, std.format;
import data, defines, doundo, hash, io, setboard;

long pnodes, actnodes, pdepth;
bool target;
long[100] rootnodes;

void perft(int depth)
{
	pnodes = 0;
	actnodes = 0;
	p.ply = 0;
	auto s = cast(double)(clock());
	rootnodes = 0;
	goroot(depth);
	auto f = cast(double)(clock());
	writeln("pnodes = ",pnodes);
	writeln("actnodes = ",actnodes);
	writeln("time = ",(f-s)/1000);
}

void go(int depth)
{
	if(depth == 0)
		return;
	/+
	movegen
	+/
	for(int i  = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		if(makemove(p.list[i]))
		{
			takemove();
			continue;
		}
		testhashkey();
		pnodes++;
		if(pdepth == p.ply)
			actnodes++;
			
		go(depth-1);
		takemove();
	}
	return;
}

void goshow(int depth)
{
	if(depth == 0)
		return;
	/+
	movegen
	+/
	for(int i  = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		if(makemove(p.list[i]))
		{
			takemove();
			continue;
		}
		writeln("making ",returnmove(p.list[i]));
		testhashkey();
		pnodes++;
		if(pdepth == p.ply)
			actnodes++;
			
		go(depth-1);
		takemove();
	}
	return;	
}

void goroot(int depth)
{
	if(depth == 0)
		return;
	/+
	movegen
	+/
	long oldnodes = 0;
	for(int i  = p.listc[p.ply]; i < p.listc[p.ply+1]; i++)
	{
		if(makemove(p.list[i]))
		{
			takemove();
			continue;
		}
		testhashkey();
		pnodes++;
		if(pdepth == p.ply)
			actnodes++;
			
		go(depth-1);
		takemove();
		
		rootnodes[i] = actnodes - oldnodes;
		writeln(returnmove(p.list[i])," ",rootnodes[i]);
		oldnodes = actnodes;
	}
	return;	
}

void perftfile()
{
	long[] myscore;
	long[] targetscore;
	long x;
	int tests = 0;
	
	writeln("This function will always test to depth 6!!");
	writeln("the perft file must have the target number of nodes at the end of");
	writeln("the fen in the following format:  'D6 1888900'. The program looks for 'D6'");
	
	writeln();
	writeln();
	
	writeln("Enter filename...");
	string filename = readln();
	
	File testfile = File(filename,"r");
	
	foreach(fileline; testfile.byLine())
	{
		setBoard(fileline.idup);
		auto finddepth = fileline.find("D6 ");
		if(finddepth == "")
			continue;
		finddepth = finddepth[3..$];
		formattedRead(finddepth, "%d", x);
		targetscore ~= x;
		perft(6);
		myscore ~= actnodes;
		writeln("position ",tests+1, " target ",x," actual ",actnodes);
	}
	writeln("\n\nTest compete.");
	for(int i = 0; i<tests;i++)
	{
		write("Position ",i+1,"\t",targetscore[i],"\t",myscore[i]," ");
		if(targetscore[i] == myscore[i])
		{
			write("PASS");
		}
		else
		{
			write("FAIL");
		}
		writeln();
	}
}