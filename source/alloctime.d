import defines, data;

double allocatetime()
{
	if(searchparam.depth != -1)
	{
		return 128000000;
	}
	if(searchparam.timepermove > -1)
	{
		return searchparam.timepermove - 200;
	}
	if(searchparam.wtime < 0 || searchparam.btime <0 || searchparam.inf)
	{
		return 128000000;
	}
	if(searchparam.movestogo[p.side] > 0)
	{
		if(p.side==black)
		{
			return ((searchparam.btime + (searchparam.binc*searchparam.movestogo[p.side])) / searchparam.movestogo[p.side]+1)-1000;
		}
		else
		{
			return ((searchparam.wtime + (searchparam.winc*searchparam.movestogo[p.side])) / searchparam.movestogo[p.side]+1)-1000;			
		}
	}
	else
	{
		if(p.side == black)
		{
			return (searchparam.btime / 30 + searchparam.binc);
		}
		else
		{
			return (searchparam.wtime / 30 + searchparam.winc);			
		}
	}
}

double pondertime()
{
	if(searchparam.depth != -1)
	{
		return 128000000;
	}
	if(searchparam.timepermove > -1)
	{
		return 128000000;
	}
	if(searchparam.movestogo[p.side] > 0)
	{
		if(p.side==black)
		{
			return ((searchparam.btime + (searchparam.binc*searchparam.movestogo[p.side])) / searchparam.movestogo[p.side]+1)-1000;
		}
		else
		{
			return ((searchparam.wtime + (searchparam.winc*searchparam.movestogo[p.side])) / searchparam.movestogo[p.side]+1)-1000;			
		}
	}
	else
	{
		if(p.side == black)
		{
			return (searchparam.btime / 30 + searchparam.binc);
		}
		else
		{
			return (searchparam.wtime / 30 + searchparam.winc);			
		}
	}	
}