import std.stdio, core.stdc.time;
import defines, data, utils, alloctime;

version (Posix)
{
	import core.sys.posix.posix;
	
	bool bioskey()
	{
		fd_set readfs;
		timeval timeout;
		
		FD_ZERO(&readfs);
		FD_SET(fileno(stdin), &readfs);
		
		timeout.tv_sec = 0;
		timeout.tv_usec = 0;
		select(16, &readfs, 0, 0, &timeout);
		
		return FD_ISSET(fileno(stdin), &readfs);
	}
	
}
version (Windows)
{
	import core.sys.windows.windows;
	
	bool bioskey()
	{
		int init = 0, pipe;
		HANDLE inh;
		DWORD dw;
		if(!init)
		{
			init = 1;
			inh = GetStdHandle(STD_INPUT_HANDLE);
			pipe = !GetConsoleMode(inh, &dw);
			if(!pipe)
			{
				SetConsoleMode(inh, dw & ~(ENABLE_MOUSE_INPUT|ENABLE_WINDOW_INPUT));
				FlushConsoleInputBuffer(inh);
			}
		}
		if(pipe)
		{
			if(!PeekNamedPipe(inh, null, 0, null, &dw, null))
				return true;
			return dw>0;
		}
		else
		{
			GetNumberOfConsoleInputEvents(inh, &dw);
			return dw > 1;
		}
	}
	
}

bool checkinput()
{
	int bytes;
	char[] input;
	
	if(bioskey())
	{
		if(searchparam.xbmode)
		{
			stopsearch = true;
			searchparam.force = true;
			return true;
		}
		do
		{
			input = stdin.rawRead(new char[256]);
		} while(input.length == 0);
		
		if(input[$-1]=='\n')
			input = input[0 .. $-1];
			
		if(input.length > 0)
		{
			import std.uni;
			if(input[0..4].toLower=="quit")
			{
				exitAll();
				return true;
			}
			else if(input[0..4].toLower=="stop")
			{
				stopsearch = true;
				searchparam.force = true;
				return true;
			}
			else if(input[0..9].toLower=="ponderhit")
			{				
				searchparam.ponderhit = true;
				searchparam.pon = false;
				searchparam.inf = false;
				double alloctime = allocatetime();
				if(alloctime<0) alloctime = 200;
				searchparam.starttime = cast(double)(clock())+500;
				searchparam.stoptime = searchparam.starttime + alloctime;
				return true;
			}
			else
			{
				stopsearch = true;
				return true;
			}			
		}
	}	
	return false;
}

void checkup()
{
	checkinput();
	if(cast(double)(clock()) >= searchparam.stoptime)
	{
		stopsearch = true;
	}
}