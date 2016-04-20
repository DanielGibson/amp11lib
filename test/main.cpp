#include <stdio.h>
#include <math.h>
#include <conio.h>
#include "../amp11lib.h"

#ifndef NDEBUG
  #pragma comment(lib,"../debug/amp11lib.lib")
#else
  #pragma comment(lib,"../release/amp11lib.lib")
#endif

int main(int argc, char *argv[])
{
  if (argc<1+2+1) {
    puts("usage: test.exe <bufferlen(sec)> <timerfreq(sec)> <mp3-1> [<mp3-2> <mp3-3>...]\n");
    return 1;
  }

  int iDevice = -1;

  float fBufferLen = (float)atof(argv[1]);
  float fTimerFreq = (float)atof(argv[2]);
  printf("bufferlen=%gs\n", fBufferLen);
  printf("timerfreq=%gs\n", fTimerFreq);

  alInitLibrary();

  ALhandle hPlayer = alOpenPlayer(iDevice, 44100, ALtrue, fBufferLen);
  if (hPlayer==0) {
    puts("cannot open wave output (do you have winamp running? :) )");
    return 1;
  }
  char strDevice[256];
  alDescribePlayerDevice(iDevice, strDevice, sizeof(strDevice));
  printf("opened output device: %s\n", strDevice);

  alEnableRedirection(fTimerFreq);

  ALhandle hFile;
  ALhandle hDecoder;
  for (int iarg=3; iarg<argc; iarg++) {
    hFile = alOpenInputFile(argv[iarg]);
    hDecoder = alOpenDecoder(hFile);
    if (hFile==0 || hDecoder==0) {
      printf("cannot open file %s\n", argv[iarg]);
      return 1;
    }
    alSetRedirection(hDecoder, hPlayer);
  }

  puts("playing... press 'p' to pause, 'r' to rewind, 'q' to quit");
  // just for testing latency
  int c;
  do {
    c = getch();
    if (c=='p') {
      if (alGetRedirection(hDecoder)==0) {
        alSetRedirection(hDecoder, hPlayer);
      } else {
        alSetRedirection(hDecoder, 0);
      }
    }
    if (c=='r') {
      alDecSeekAbs(hDecoder, 0.0f);
    }
  } while (c!='q');

  /*
  // this is an example of how to decode mp3s to raw files
  ALhandle hOut = alOpenOutputFile("out.raw");
  ALhandle hIn = alOpenInputFile(argv[3]);
  ALhandle hDecoder = alOpenDecoder(hIn);

  ALuint8 buffer[1024];
  ALsint32 slSize;
  do {
    slSize = alRead(hDecoder, buffer, 1024);
    alWrite(hOut, buffer, slSize);
  } while(slSize>0);
  */

  alEndLibrary();

  return 0;
}
