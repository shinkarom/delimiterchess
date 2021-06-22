import std.stdio;
import data, defines, board, io;

void openlog()
{
	log_file = File("log.txt", "a");
}

void closelog()
{
	if(log_file.isOpen())
		log_file.close();
}

void writeply(int ply)
{
	log_file.writef(" ply %d;",ply);
}

void writemove(Move our)
{
	string move = returnmove(our);
	log_file.writef(" move %s", move);
}

void writesq(int our)
{
	string sq = returnsquare(our);
	log_file.write(sq);
}

void writescore(int score)
{
	log_file.writef(" score %d;",score);
}

void writefpv(bool fpv)
{
	if(fpv)
	{
		log_file.write(" following pv ");
	}
	else
	{
		log_file.write(" not pv ");
	}
}
void writegamehist()
{
	log_file.write(" \ngame history ");
	for(int i = 0;i<histply-1; i++)
	{
		log_file.write(" move %d %s ", i, returnmove(Move(hist[i].data,0)));
	}
	log_file.write("\n");
}

void writestring(string s)
{
	log_file.write(s);
}

void writeint(int i)
{
	log_file.write(i);
}

void writedouble(double i)
{
	log_file.writef("%f",i);
}

void writespace()
{
	log_file.write(" ");
}

void writenewline()
{
	log_file.writeln();
}

void writeboard()
{
	log_file.write("\nprinting board...\n\n");
	for(int r = 7; r>=0; r--)
	{
		log_file.writeln();
		for(int f = 0; f<8; f++)
		{
			if(p.board[fileRankToSquare(f,r)] != SquareType.Empty)
			{
				log_file.writef(" %c ",pieceToChar[p.board[fileRankToSquare(f,r)]]);
			}
			else
			{
				log_file.write(" . ");
			}
		}
	}
	
	log_file.writef(" \n side = %d", p.side);
	writestring("\n Castle Flags ");
	writestring(returncastle());
	writesq(p.enPas);
	log_file.writef("\n hashKey %X", p.hashKey);
	log_file.writef("\n side = %d", colours[p.side]);
	log_file.writef("\n majors = %d", p.majors);
	log_file.writef("\n ply = %d", p.ply);
	log_file.write("\n wk ");
	writesq(p.kingSquares[Side.White]);
	log_file.write("\n bk ");
	writesq(p.kingSquares[Side.Black]);
	log_file.writef("\n white material = %d", p.material[Side.White]);
	log_file.writef("\n black material = %d", p.material[Side.Black]);
	log_file.writef("\n fifty = %d", p.fifty);
	log_file.write("\n\n");
}