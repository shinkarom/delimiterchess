import std.stdio, std.algorithm.sorting, std.file, std.bitmanip, std.random;
import defines, data, setboard, io, movegen;

void store(BinEntry[] full)
{
	writeln("\n\nNow in store, sorting to make binbook.bin");
	writeln("Old size = ",full.length);
	BinEntry bookentry;
	BinEntry[] t;
	for(int q = 0; q<full.length; q++)
	{
		bool notu = false;
		bookentry = full[q];
		for(int p = 0; p<t.length; p++)
		{
			if(t[p].m[0]==bookentry.m[0] &&
				t[p].m[1]==bookentry.m[1] &&
				t[p].m[2]==bookentry.m[2] &&
				t[p].m[3]==bookentry.m[3] &&
				t[p].k==bookentry.k)
			{
				notu = true;
				t[p].freq++;
			}
		}
		if(notu==0)
		{
			t ~= bookentry;
		}
		if(q % 500 == 0)
		{
			write(".");
			if(q % 10000 == 0)
			{
				writeln(" ",q," new size ",t.length);
			}
		}
	}
	
	t.sort!("a.k < b.k");
	
	writeln("final size ",t.length);
	
	for(auto c = 0; c<t.length; c++)
	{
		auto kb = nativeToLittleEndian(t[c].k);
		auto freqb = nativeToLittleEndian(t[c].k);
		bookfile.rawWrite([t[c]]);
	}
	
}

bool book_init()
{
	BinEntry move;
	if(!exists("binbook.bin"))
	{
		writeln("no binbook.bin!!");
		return false;
	}
	wbookfile = File("binbook.bin","rb");
	
	wbookfile.seek(0, SEEK_END);
	bookdata.whitelsize = wbookfile.tell();
	wbookfile.rewind();
	bookdata.whiteentries = bookdata.whitelsize/BinEntry.sizeof;
	
	for(int i = 0; i<bookdata.whiteentries; i++)
	{
		wbookfile.seek(BinEntry.sizeof, SEEK_SET);
		auto buf = wbookfile.rawRead(new BinEntry[1])[0];
		whitebook ~= buf;
	}
	writeln("white book size = ",bookdata.whitelsize," bytes, with ",whitebook.length," entries");
	
	return true;
}

void book_close()
{
	wbookfile.close();
}

void makehash()
{
	if(!exists("gamelines.txt"))
	{
		writeln("gamelines.txt!!");
		return;
	}
	book_file = File("gamelines.txt","r");
	writeln("beginning vector read...");
	foreach(line; book_file.byLine())
		vbooklines ~= line.idup;
	writeln("total lines = ",vbooklines.length);
	if(!exists("binbook.bin"))
	{
		writeln("no binbook.bin created to write to!!");
		book_file.close();
		return;
	}
	bookfile = File("binbook.bin","wb");
	movestotal = 0;
	writeln("beginning to fill vector with hash entries...");
	for(auto i = 0; i<vbooklines.length; i++)
	{
		if(i%100==0)
		{
			write(".");
			if(i%10000==0)
				write(" ",i);
		}
		parseopeningline(vbooklines[i]);
	}
	writeln("total moves,",movestotal);
	writeln("hash entry vector size = ",hashentries.length);
	
	store(hashentries);	
	
	bookfile.close();
	book_file.close();

	vbooklines.length = 0;
	hashentries.length = 0;
}

void parseopeningline(string str)
{
	string move_string;
	int ptr = 0;
	int ptrtwo;
	int movemade;
	bool t;
	
	setBoard(startfen);
	
	while(ptr < str.length)
	{
		movemade = 0;
		move_string = "";
		move_string ~= str[ptr++];
		move_string ~= str[ptr++];
		move_string ~= str[ptr++];
		move_string ~= str[ptr++];
		if(ptr == str.length || str[ptr]==' ' || str[ptr] == '+')
		{
			if(str[ptr]=='+')
				ptr++;
		}
		ulong oldkey = p.hashkey;
		auto flag = understandmove(move_string, t);
		if(!flag)
			return;
		binenter.k = oldkey;
		binenter.m = move_string;
		binenter.freq = 0;
		hashentries ~= binenter;
		while(str[ptr]==' ')
			ptr++;
		movemade++;
		movestotal++;
		if(movemade>20)
			return;
	}
}

int wfindhashbookmove()
{
	moveGen();
	int[2] f = [-1, -1];
	int[2] m = [-1, -1];
	foreach(it; whitebook)
	{
		if(it.k == p.hashkey)
		{
			auto match = myparse(it.m);
			if(match)
			{
				if(it.freq > f[0])
				{
					f[1] = f[0];
					m[1] = m[0];
					f[0] = it.freq;
					m[0] = match;
				}
				else if(it.freq > f[1])
				{
					f[1] = it.freq;
					m[1] = match;					
				}
			}
		}
	}
	if(m[0]==-1)
		return -1;
	int r = uniform(0, 1+1);
	writeln("book hit, freq ",f[r]," position ",r);
	return m[r];
}