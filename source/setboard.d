import std.stdio;
import data, defines, board, utils, hash;

int[64] index = [
	110, 111, 112, 113, 114, 115, 116, 117, 98, 99, 100, 101, 102, 103, 104,
	105, 86, 87, 88, 89, 90, 91, 92, 93, 74, 75, 76, 77, 78, 79, 80, 81, 62,
	63, 64, 65, 66, 67, 68, 69, 50, 51, 52, 53, 54, 55, 56, 57, 38, 39, 40,
	41, 42, 43, 44, 45, 26, 27, 28, 29, 30, 31, 32, 33
];

void setBoard(string str)
{
	clearBoard();
	int WK = 0, BK = 0, WP = 0, BP = 0;
	int sq = 0;
	int ptr = 0;
	bool shouldBreak = false;
	while (sq < 64)
	{
		switch (str[ptr])
		{
		case 'K':
			p.board[index[sq]].type = wK;
			p.board[index[sq]].color = PieceColor.White;
			p.k[white] = index[sq];
			WK++;
			sq++;
			break;
		case 'Q':
			p.board[index[sq]].type = wQ;
			p.board[index[sq]].color = PieceColor.White;
			p.material[white] += vQ;
			sq++;
			break;
		case 'R':
			p.board[index[sq]].type = wR;
			p.board[index[sq]].color = PieceColor.White;
			p.material[white] += vR;
			sq++;
			break;
		case 'B':
			p.board[index[sq]].type = wB;
			p.board[index[sq]].color = PieceColor.White;
			p.material[white] += vB;
			sq++;
			break;
		case 'N':
			p.board[index[sq]].type = wN;
			p.board[index[sq]].color = PieceColor.White;
			p.material[white] += vN;
			sq++;
			break;
		case 'P':
			p.board[index[sq]].type = wP;
			p.board[index[sq]].color = PieceColor.White;
			p.material[white] += vP;
			sq++;
			WP++;
			break;
		case 'k':
			p.board[index[sq]].type = bK;
			p.board[index[sq]].color = PieceColor.Black;
			p.k[black] = index[sq];
			BK++;
			sq++;
			break;
		case 'q':
			p.board[index[sq]].type = bQ;
			p.board[index[sq]].color = PieceColor.Black;
			p.material[black] += vQ;
			sq++;
			break;
		case 'r':
			p.board[index[sq]].type = bR;
			p.board[index[sq]].color = PieceColor.Black;
			p.material[black] += vR;
			sq++;
			break;
		case 'b':
			p.board[index[sq]].type = bB;
			p.board[index[sq]].color = PieceColor.Black;
			p.material[black] += vB;
			sq++;
			break;
		case 'n':
			p.board[index[sq]].type = bN;
			p.board[index[sq]].color = PieceColor.Black;
			p.material[black] += vN;
			sq++;
			break;
		case 'p':
			p.board[index[sq]].type = bP;
			p.board[index[sq]].color = PieceColor.Black;
			p.material[black] += vP;
			sq++;
			BP++;
			break;
		case '1':
			sq += 1;
			break;
		case '2':
			sq += 2;
			break;
		case '3':
			sq += 3;
			break;
		case '4':
			sq += 4;
			break;
		case '5':
			sq += 5;
			break;
		case '6':
			sq += 6;
			break;
		case '7':
			sq += 7;
			break;
		case '8':
			sq += 8;
			break;
		case ' ':
			break;
		default:
			break;
		}
		ptr++;
	}

	if (WK != 1 || BK != 1 || WP > 8 || BP > 8)
	{
		writeln("FEN ILLEGAL NUM");
		writeln(str);
		writeln(WK, " ", BK, " ", WP, " ", BP);
		exitAll();
	}

	while (str[ptr] == ' ')
		ptr++;
	if (str[ptr] == 'w')
		p.side = white;
	else if (str[ptr] == 'b')
		p.side = black;

	ptr++;
	while (str[ptr] == ' ')
		ptr++;

	p.castleflags = 0;
	while (str[ptr] != ' ')
	{
		if (str[ptr] == '-')
			break;
		else if (str[ptr] == 'K')
			p.castleflags |= 8;
		else if (str[ptr] == 'Q')
			p.castleflags |= 4;
		else if (str[ptr] == 'k')
			p.castleflags |= 2;
		else if (str[ptr] == 'q')
			p.castleflags |= 1;
		ptr++;
	}
	ptr++;
	while (str[ptr] == ' ')
		ptr++;

	if (str[ptr] == '-')
	{
		p.en_pas = noenpas;
	}
	else
	{
		int file = charToFile(str[ptr]);
		ptr++;
		int rank = charToRank(str[ptr]);
		p.en_pas = fileRankToSquare(file, rank);
	}
	if (p.en_pas < A4 || p.en_pas > H6)
		p.en_pas = noenpas;

	ptr++;
	while (str[ptr] == ' ')
		ptr++;

	p.fifty = (str[ptr] - '0') * 10;
	ptr++;
	p.fifty += str[ptr] - '0';
	if (p.fifty < 0 || p.fifty > 49)
		p.fifty = 0;
	p.fifty *= 2;

	initPieceLists();
	fullhashkey();
	p.ply = 0;
	histply = 0;
	p.listc[0] = 0;
}
