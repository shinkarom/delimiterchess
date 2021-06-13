import core.time, std.stdio;
import defines, data;

ulong allocateTime()
{
	if (searchParam.depth != -1)
	{
		return 128000000;
	}
	if (searchParam.timepermove > 0)
	{
		return searchParam.timepermove - 200;
	}
	if (searchParam.wtime == 0 || searchParam.btime == 0 || searchParam.inf)
	{
		return 128000000;
	}
	if (searchParam.movestogo[p.side] > 0)
	{
		if (p.side == black)
		{
			return ((searchParam.btime + (
					searchParam.binc * searchParam.movestogo[p.side])) / searchParam.movestogo[p.side]
					+ 1) - 1000;
		}
		else
		{
			return ((searchParam.wtime + (
					searchParam.winc * searchParam.movestogo[p.side])) / searchParam.movestogo[p.side]
					+ 1) - 1000;
		}
	}
	else
	{
		if (p.side == black)
		{
			return (searchParam.btime / 30 + searchParam.binc);
		}
		else
		{
			return (searchParam.wtime / 30 + searchParam.winc);
		}
	}
}

ulong ponderTime()
{
	if (searchParam.depth != -1)
	{
		return 128000000;
	}
	if (searchParam.timepermove > 0)
	{
		return 128000000;
	}
	if (searchParam.movestogo[p.side] > 0)
	{
		if (p.side == black)
		{
			return ((searchParam.btime + (
					searchParam.binc * searchParam.movestogo[p.side])) / searchParam.movestogo[p.side]
					+ 1) - 1000;
		}
		else
		{
			return ((searchParam.wtime + (
					searchParam.winc * searchParam.movestogo[p.side])) / searchParam.movestogo[p.side]
					+ 1) - 1000;
		}
	}
	else
	{
		if (p.side == black)
		{
			return (searchParam.btime / 30 + searchParam.binc);
		}
		else
		{
			return (searchParam.wtime / 30 + searchParam.winc);
		}
	}
}
