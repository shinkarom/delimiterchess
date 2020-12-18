import core.stdc.stdio;

void unbufferStreams()
{
	setbuf(stdout, null);
	setbuf(stdin, null);
	setvbuf(stdout, null, _IONBF, 0);
	setvbuf(stdin, null, _IONBF, 0);
}