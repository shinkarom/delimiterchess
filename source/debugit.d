import std.stdio;
import data, defines;

void debugSquareTypes()
{
	for(int i = 2; i<10;i++)
	{
		for(int j = 2; j<10; j++)
		{
			int k = i*12+j;
			write(piecetochar[p.board[k].typ]);
		}
		writeln();
	}
}