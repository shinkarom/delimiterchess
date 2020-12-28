void unbufferStreams()
{
	import std.stdio;
	stdout.setvbuf(0, _IONBF);
	stdin.setvbuf(0, _IONBF);
}

void exitAll()
{
	import core.stdc.stdlib, core.runtime;
	Runtime.terminate();
	exit(0);
}