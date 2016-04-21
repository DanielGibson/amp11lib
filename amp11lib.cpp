// amp11lib - library interface layer and asynchronious player
// Copyright (c) 1999-2000 Alen Ladavac
// See COPYING (GNU Library General Public License 2) for license

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#if (defined(WIN32)||defined(DOS))&&!defined(_MSC_VER)
#include <dos.h>
#endif

#ifdef DOS
#include "binfplsb.h"
#endif

#ifdef WIN32
#include "binfplnt.h"
#include <process.h>
#include <mmsystem.h>
#endif

#ifdef LINUX
#include "binfile/binfpllx.h"
#endif

#ifdef UNIX
#include <glob.h>
#endif

#include "binfile/binfhttp.h"
#include "binfile/binfstd.h"
#include "binfile/binfarc.h"
#include "binfile/binfplwv.h"
#include "binfile/binfcon.h"
#include "ampdec.h"
#include "mpgsplit.h"

#include "amp11lib.h"

// ------------------------------------

// type of stream indentifier for each stream handle
enum StreamType {
  ST_INVALID=0,
  
  ST_BEFOREVALID, // low marker for valid values

  ST_UNUSED,
  ST_INPUT,
  ST_OUTPUT,
  ST_HTTP,
  ST_DECODER,
  ST_PLAYER,
  ST_SUBFILE,

  ST_AFTERVALID, // high marker for valid values
};

#define SLAVESPERSTREAM 2
#define SLAVE_REDIR           0     // base slave used for redirection
#define SLAVE_DECODERSOURCE   1     // mpeg decoder stream reads mpeg from another file

struct Stream {
  ALsint32 st_nReferences;                // reference counter
  StreamType st_stType;                   // type of the stream, or unused
  ALhandle st_ahSlaves[SLAVESPERSTREAM];  // slave streams referenced by this one
  float st_fBytesPerSec;        // bytes per second for decoder streams (used for seeking)
  union {     // holds pointer to the actual stream, NULL if unused
    binfile *st_binfile;
    sbinfile *st_sbinfile;
    httpbinfile *st_httpbinfile;
    ampegdecoder *st_ampegdecoder;
    //ntplaybinfile *st_ntplaybinfile;
    abinfile *st_abinfile;
  };
};

// stream structures are stored here
// stream number 0 is never used, so that handle 0 is used for errors
#define MAX_STREAMS 64
static struct Stream _astStreams[MAX_STREAMS];

#define MAX_REDIRTARGETS  8       // maximal number of different target streams
#define REDIR_BUFFERSIZE  256     // buffer for mixing of one target
// mixing buffers are here
static ALsint16 _aBuffers[MAX_REDIRTARGETS][REDIR_BUFFERSIZE];

// set between calls to alInitSystem() and alEndSystem()
static ALbool _bLibraryInitialized = ALfalse;

//------------------------------------

#ifdef WIN32
// we need only one critical section for access to all data from the two threads
CRITICAL_SECTION _cs;

// initialize critical section before using
void InitCS(void)
{
  InitializeCriticalSection(&_cs);
}
// cleanup critical section when not needed anymore
void EndCS(void)
{
  DeleteCriticalSection(&_cs);
}
// enter critical section (lock)
void EnterCS(void)
{
  EnterCriticalSection(&_cs);
}
// leave critical section (unlock)
void LeaveCS(void)
{
  LeaveCriticalSection(&_cs);
}
#else
//#error implement critical sections!
#endif

// wrapper class used for easy lock/unlock using critical sections
class CriticalSection {
private:
  int dummy;    // not to be zero sized
public:
  CriticalSection(void) {
    //EnterCS();
  }
  ~CriticalSection(void) {
    //LeaveCS();
  }
};


//------------------------------------

// check if a stream handle is valid
static ALbool IsStreamHandleValid(ALhandle hStream)
{
  // if library is not initialized
  if (!_bLibraryInitialized) {
    // no streams are valid
    assert(ALfalse);
    return ALfalse;
  }

  // if handle is out of range
  if (hStream<=0 || hStream>MAX_STREAMS) {
    assert(ALfalse);
    return ALfalse;
  }
  Stream &st = _astStreams[hStream];
  // if handle is not used or invalid type
  if (st.st_stType==ST_UNUSED||st.st_stType==ST_INVALID) {
    assert(ALfalse);
    return ALfalse;
  }

  // if bad pointer (paranoia check - this should not be external error)
  if (st.st_binfile==NULL) {
    assert(ALfalse);
    return ALfalse;
  }

  // reference count should be valid (paranoia check)
  if (st.st_nReferences<=0) {
    assert(ALfalse);
    return ALfalse;
  }

  return ALtrue;
}

// find an unused stream handle
static ALhandle FindFreeHandle(void)
{
  // for each stream (note that stream 0 is not used!)
  for(int ist=1; ist<MAX_STREAMS; ist++) {
    assert(
      _astStreams[ist].st_stType>ST_BEFOREVALID &&
      _astStreams[ist].st_stType<ST_AFTERVALID);
    // if unused
    if (_astStreams[ist].st_stType == ST_UNUSED) {
      // use that one
      return ist;
    }
  }
  // if not found, error
  return 0;
}

// add one reference to a stream
static ALbool AddStreamReference(ALhandle hStream)
{
  // if handle is invalid
  if (!IsStreamHandleValid(hStream)) {
    // it should not happen
    assert(ALfalse);
    // do nothing
    return ALfalse;
  }

  // this just increases the reference count
  _astStreams[hStream].st_nReferences++;
  return ALtrue;
}

// remove one reference from a stream - if no references, stream is closed
static void RemStreamReference(ALhandle hStream)
{
  // if handle is invalid
  if (!IsStreamHandleValid(hStream)) {
    // it should not happen
    assert(ALfalse);
    // do nothing
    return;
  }

  Stream &st = _astStreams[hStream];

  // decrease the reference count
  st.st_nReferences--;
  // if the stream is not used anymore
  if (st.st_nReferences<=0) {
    // delete the stream's binfile
    delete _astStreams[hStream].st_binfile;
    // mark as unused
    _astStreams[hStream].st_binfile = NULL;
    _astStreams[hStream].st_stType = ST_UNUSED;

    // for each possible slave stream
    for (int iSlave=0; iSlave<SLAVESPERSTREAM; iSlave++) {
      // if there is a slave
      if (_astStreams[hStream].st_ahSlaves[iSlave]!=0) {
        // remove reference from the slave stream
        RemStreamReference(_astStreams[hStream].st_ahSlaves[iSlave]);
        _astStreams[hStream].st_ahSlaves[iSlave] = 0;
      }
    }
  }
}

// add a slave stream to one stream
ALbool SetSlaveStream(ALhandle hStream, ALhandle hSlave, ALsint32 iSlave)
{
  assert(iSlave>=0 && iSlave<SLAVESPERSTREAM);

  // if handle is invalid
  if (!IsStreamHandleValid(hStream)) {
    // it should not happen
    assert(ALfalse);
    // do nothing
    return ALfalse;
  }

  Stream &st = _astStreams[hStream];

  // if already has that slave
  if (st.st_ahSlaves[iSlave]!=0) {
    // remove that reference
    RemStreamReference(st.st_ahSlaves[iSlave]);
    st.st_ahSlaves[iSlave] = 0;
  }

  // if setting slave to nothing
  if (hSlave==0) {
    // that's all
    return ALtrue;
  }

  // if handle is invalid
  if (!IsStreamHandleValid(hSlave)) {
    // it should not happen
    assert(ALfalse);
    // do nothing
    return ALfalse;
  }

  // add one reference to the slave
  if (!AddStreamReference(hSlave)) {
    return ALfalse;
  }

  // remember slave
  st.st_ahSlaves[iSlave] = hSlave;
  return ALtrue;
}

// ------------------------------------
// actual interface functions
  
// open a standard file with given filename for reading
AMP11LIB_API ALhandle WINAPI alOpenInputFile(const char *strFileName)
{
  CriticalSection cs;

  // get new stream
  ALhandle hStream = FindFreeHandle();
  // if none available
  if (hStream==0) {
    // report error
    return 0;
  }
  Stream &st = _astStreams[hStream];

  // initialize it as binary input file
  st.st_stType = ST_INPUT;
  st.st_nReferences = 1;
  st.st_sbinfile = new sbinfile;

  // if cannot open it
  if (st.st_sbinfile->open(strFileName, sbinfile::openro) < 0) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if all fine, return the handle
  return hStream;
}

// open a standard file with given filename for writing
AMP11LIB_API ALhandle WINAPI alOpenOutputFile(const char *strFileName)
{
  CriticalSection cs;

  // get new stream
  ALhandle hStream = FindFreeHandle();
  // if none available
  if (hStream==0) {
    // report error
    return 0;
  }
  Stream &st = _astStreams[hStream];

  // initialize it as binary output file
  st.st_stType = ST_OUTPUT;
  st.st_nReferences = 1;
  st.st_sbinfile = new sbinfile;

  // if cannot open it
  if (st.st_sbinfile->open(strFileName, sbinfile::openrw|sbinfile::opentr) < 0) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if all fine, return the handle
  return hStream;
}

// open http file with given url, using proxy (proxy is optional)
AMP11LIB_API ALhandle WINAPI alOpenHttpFile(const char *strURL, const char *strProxy)
{
  CriticalSection cs;

  // get new stream
  ALhandle hStream = FindFreeHandle();
  // if none available
  if (hStream==0) {
    // report error
    return 0;
  }
  Stream &st = _astStreams[hStream];

  // initialize it as http input file
  st.st_stType = ST_HTTP;
  st.st_nReferences = 1;
  st.st_httpbinfile = new httpbinfile;

  // if cannot open it
  if (st.st_httpbinfile->open(strURL, strProxy, 0, 0) < 0) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if all fine, return the handle
  return hStream;
}

// open mpeg decoder that reads from a file of given handle
AMP11LIB_API ALhandle WINAPI alOpenDecoder(ALhandle hFile)
{
  CriticalSection cs;

  // if the given file handle is invalid
  if (!IsStreamHandleValid(hFile)) {
    // report error
    return 0;
  }
  // get the source stream
  Stream &stFile = _astStreams[hFile];
  // if it is not valid for input
  if (stFile.st_stType!=ST_INPUT && stFile.st_stType!=ST_HTTP && stFile.st_stType!=ST_SUBFILE) {
    // report error
    return 0;
  }

  // get new stream
  ALhandle hStream = FindFreeHandle();
  // if none available
  if (hStream==0) {
    // report error
    return 0;
  }
  Stream &st = _astStreams[hStream];

  // initialize it as decoder
  st.st_stType = ST_DECODER;
  st.st_nReferences = 1;
  st.st_ampegdecoder = new ampegdecoder;
  // if cannot reference the source stream
  if (!SetSlaveStream(hStream, hFile, SLAVE_DECODERSOURCE)) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if cannot open it
  int freq,stereo;
  if (st.st_ampegdecoder->open(*stFile.st_binfile, freq, stereo, 1, 0, 2) < 0) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // calculate stream bandwidth
  st.st_fBytesPerSec = (stereo?4:2)*freq;

  // if all fine, return the handle
  return hStream;
}

// open a sub-file inside an archive file
AMP11LIB_API ALhandle WINAPI alOpenSubFile(ALhandle hFile, ALsize sOffset, ALsize sSize)
{
  CriticalSection cs;

  // if the given file handle is invalid
  if (!IsStreamHandleValid(hFile)) {
    // report error
    return 0;
  }
  // get the source stream
  Stream &stFile = _astStreams[hFile];
  // if it is not valid for input
  if (stFile.st_stType!=ST_INPUT && stFile.st_stType!=ST_HTTP && stFile.st_stType!=ST_SUBFILE) {
    // report error
    return 0;
  }

  // get new stream
  ALhandle hStream = FindFreeHandle();
  // if none available
  if (hStream==0) {
    // report error
    return 0;
  }
  Stream &st = _astStreams[hStream];

  // initialize it as subfile
  st.st_stType = ST_SUBFILE;
  st.st_nReferences = 1;
  st.st_abinfile = new abinfile;
  // if cannot reference the source stream
  if (!SetSlaveStream(hStream, hFile, SLAVE_DECODERSOURCE)) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if cannot open it
  if (st.st_abinfile->open(*stFile.st_binfile, sOffset, sSize) < 0) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if all fine, return the handle
  return hStream;
}

// get file header of mpx file from a file of given handle
AMP11LIB_API ALbool WINAPI alGetMPXHeader(ALhandle hFile, ALsint32 *piLayer, 
  ALsint32 *piVersion, ALsint32 *piFrequency, ALbool *pbStereo, ALsint32 *piRate)
{
  CriticalSection cs;

  // if the given file handle is invalid
  if (!IsStreamHandleValid(hFile)) {
    // report error
    return 0;
  }
  // get the source stream
  Stream &stFile = _astStreams[hFile];
  // if it is not valid for input
  if (stFile.st_stType!=ST_INPUT && stFile.st_stType!=ST_HTTP && stFile.st_stType!=ST_SUBFILE) {
    // report error
    return 0;
  }

  // get the header
  return ampegdecoder::getheader(*stFile.st_binfile, 
    *piLayer, *piVersion, *piFrequency, *pbStereo, *piRate);
}

#if 0
// get descriptive name of a given player device
AMP11LIB_API ALsize WINAPI alDescribePlayerDevice(ALsint32 iDevice,
    char *strNameBuffer, ALsize sizeNameBuffer)
{
  return ntplaybinfile::getdevicename(iDevice, strNameBuffer, sizeNameBuffer);
}

// open sound output with given settings (frequency is in Hz)
AMP11LIB_API ALhandle WINAPI alOpenPlayer(ALsint32 iDevice, ALsint32 iFreq, ALbool bStereo, 
  ALfloat fPrebuffer)
{
  CriticalSection cs;

  // get new stream
  ALhandle hStream = FindFreeHandle();
  // if none available
  if (hStream==0) {
    // report error
    return 0;
  }
  Stream &st = _astStreams[hStream];

  // initialize it as player
  st.st_stType = ST_PLAYER;
  st.st_nReferences = 1;
  st.st_ntplaybinfile = new ntplaybinfile;

  // prepare buffer size so that it is given time long
  ALsint32 slBufferSize = 1024/2/(bStereo?2:1);
  ALsint32 ctBuffers = (ALsint32)ceil(fPrebuffer*iFreq/slBufferSize);

  // if cannot open it
  if (st.st_ntplaybinfile->open(iFreq, bStereo, 1, slBufferSize, ctBuffers, iDevice) < 0) {
    // close it
    alClose(hStream);
    // report error
    return 0;
  }

  // if all fine, return the handle
  return hStream;
}
#endif

// close any open amp11 stream
AMP11LIB_API void WINAPI alClose(ALhandle hStream)
{
  CriticalSection cs;

  // just remove one reference from it - it will free it if not used anymore
  RemStreamReference(hStream);
}

// read a chunk of bytes from given stream
AMP11LIB_API ALsize WINAPI alRead(ALhandle hStream, void *pvBuffer, ALsize size)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hStream)) {
    // do nothing
    return 0;
  }

  return _astStreams[hStream].st_binfile->read(pvBuffer, size);
}

// write a chunk of bytes to given stream
AMP11LIB_API ALsize WINAPI alWrite(ALhandle hStream, void *pvBuffer, ALsize size)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hStream)) {
    // do nothing
    return 0;
  }

  return _astStreams[hStream].st_binfile->write(pvBuffer, size);
}

// do one pass of redirection loop - return false if nothing to do
ALbool DoRedirection(void)
{
  CriticalSection cs;

  int aiTargets[MAX_STREAMS];
  // mark all streams as not being targets
  {for (int is=1; is<MAX_STREAMS; is++) {
    aiTargets[is] = -1;
  }}

  // -- find which are targets    
  // for each stream
  int nTargets = 0;
  {for (int is=1; is<MAX_STREAMS; is++) {
    // if there is redirection target
    int isTarget = _astStreams[is].st_ahSlaves[SLAVE_REDIR];
    if (isTarget != 0) {
      // if the target is not yet marked, 
      // and has enough free space in the buffer
      if (aiTargets[isTarget] == -1
        &&_astStreams[isTarget].st_binfile->ioctl(binfile::ioctlwmax) 
          >= REDIR_BUFFERSIZE*sizeof(ALsint16)) {
        // mark it
        aiTargets[isTarget] = nTargets;
        nTargets++;
      }
    }
  }}

  // if there are none, or too many
  if (nTargets==0 || nTargets>MAX_REDIRTARGETS) {
    // nothing to do
    return ALfalse;
  }
  
  // clear all buffers that will be used for mixing
  memset(_aBuffers, 0, nTargets*REDIR_BUFFERSIZE*sizeof(ALsint16));

  // for each stream that has a target
  {for (int is=1; is<MAX_STREAMS; is++) {
    Stream &st = _astStreams[is];
    if (st.st_ahSlaves[SLAVE_REDIR]==0) {
      continue;
    }
    // get the target buffer
    int iTarget = aiTargets[_astStreams[is].st_ahSlaves[SLAVE_REDIR]];
    if (iTarget<0) {
      continue;
    }
    // read from stream to it
    ALsint16 buffer[REDIR_BUFFERSIZE];
    ALsize sRead = alRead(is, buffer, REDIR_BUFFERSIZE*sizeof(ALsint16));
    assert(sRead<=REDIR_BUFFERSIZE*sizeof(ALsint16));
    assert(iTarget>=0 && iTarget<MAX_REDIRTARGETS);
    // mix to target buffer
    {for(ALsize i=0; i<sRead/(ALsize)sizeof(ALsint16); i++) {
      _aBuffers[iTarget][i]+=buffer[i];
    }}
    // if end of stream
    if (sRead<REDIR_BUFFERSIZE*sizeof(ALsint16)) {
      // end redirection
      //alSetRedirection(is, 0); // FIXME DG: I had to compile this out, is it useful?
    }
  }}

  // for each target stream
  {for (int is=1; is<MAX_STREAMS; is++) {
    int iTarget = aiTargets[is];
    if (iTarget==-1) {
      continue;
    }
    Stream &st = _astStreams[is];

    // if still valid stream
    if (st.st_stType!=ST_UNUSED) {
      // write its buffer out
      alWrite(is, _aBuffers[iTarget], REDIR_BUFFERSIZE*sizeof(ALsint16));
    }
  }}

  // done something
  return ALtrue;
}

#if 0
// timer id for the multimedia timer
UINT uiTimerID = 0;
ALbool _bRedirEnabled = ALfalse;

void CALLBACK TimerFunction(UINT uTimerID, UINT uMsg, DWORD dwUser, DWORD dw1, DWORD dw2)
{
  // do the redirection
  ALbool bDoneSomething = TRUE;
  while (bDoneSomething && _bRedirEnabled) {
    bDoneSomething = DoRedirection();
  };
}

// enable stream redirection
AMP11LIB_API ALbool WINAPI alEnableRedirection(ALfloat fInterval)
{
  // if library is not initialized
  if (!_bLibraryInitialized) {
    // no redirection
    assert(ALfalse);
    return ALfalse;
  }

  CriticalSection cs;

  // if already on
  if (_bRedirEnabled) {
    // do nothing
    return ALfalse;
  }

  // if timer already started
  if (uiTimerID!=0) {
    // this should not happen
    assert(ALfalse);
    return ALfalse;
  }

  // setup multimedia timer
  uiTimerID = timeSetEvent(
    int(fInterval*1000.0f), // milliseconds
    0,  // precision - 0=best possible
    TimerFunction, 
    0,  // user
    TIME_PERIODIC);

  // if cannot add timer
  if (uiTimerID==NULL) {
    // error
    return ALfalse;
  }

  // mark that the redirection is enabled
  _bRedirEnabled = ALtrue;

  return ALtrue;
}

// disable stream redirection
AMP11LIB_API void WINAPI alDisableRedirection(void)
{
  // if library is not initialized
  if (!_bLibraryInitialized) {
    // no redirection
    assert(ALfalse);
    return;
  }

  // must not lock the critical section here,
  // or we won't be able to kill the timer!
  //CriticalSection cs;

  // if not on
  if (!_bRedirEnabled) {
    // do nothing
    return;
  }

  // if timer not started
  if (uiTimerID==0) {
    // this should not happen
    assert(ALfalse);
    return;
  }

  // first disable redirection - so that the thread will stop looping
  _bRedirEnabled = ALfalse;

  // stop the timer
  MMRESULT mmres = timeKillEvent(uiTimerID);
  // must succeed
  assert(mmres==TIMERR_NOERROR);

  // mark the timer as off
  uiTimerID = 0;
}

// redirect source stream to the target stream
AMP11LIB_API ALbool WINAPI alSetRedirection(ALhandle hSource, ALhandle hTarget)
{
  CriticalSection cs;

  // if cannot reference the target stream
  if (!SetSlaveStream(hSource, hTarget, SLAVE_REDIR)) {
    // report error
    return ALfalse;
  }
  return ALtrue;
}

// get target stream for given source stream
AMP11LIB_API ALhandle WINAPI alGetRedirection(ALhandle hSource)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hSource)) {
    // do nothing
    return 0;
  }

  return _astStreams[hSource].st_ahSlaves[SLAVE_REDIR];
}
#endif

// decoder control functions
AMP11LIB_API void WINAPI alDecSetVolume(ALhandle hDecoder, ALfloat fVolume)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hDecoder)) {
    // do nothing
    return;
  }

  Stream &st = _astStreams[hDecoder];

  // if not a decoder
  if (st.st_stType != ST_DECODER) {
    // do nothing
    return;
  }

  // set volume
  st.st_ampegdecoder->ioctl(st.st_ampegdecoder->ioctlsetvol, &fVolume, 0);
}

AMP11LIB_API void WINAPI alDecSeekAbs(ALhandle hDecoder, ALfloat fSeconds)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hDecoder)) {
    // do nothing
    return;
  }

  Stream &st = _astStreams[hDecoder];

  // if not a decoder
  if (st.st_stType != ST_DECODER) {
    // do nothing
    return;
  }

  // set position
  st.st_ampegdecoder->seek(int(st.st_fBytesPerSec*fSeconds));
}

AMP11LIB_API void WINAPI alDecSeekRel(ALhandle hDecoder, ALfloat fSecondsDelta)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hDecoder)) {
    // do nothing
    return;
  }

  Stream &st = _astStreams[hDecoder];

  // if not a decoder
  if (st.st_stType != ST_DECODER) {
    // do nothing
    return;
  }

  // change position
  st.st_ampegdecoder->seekcur(int(st.st_fBytesPerSec*fSecondsDelta));
}

AMP11LIB_API ALfloat WINAPI alDecGetPos(ALhandle hDecoder)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hDecoder)) {
    // do nothing
    return 0.0f;
  }

  Stream &st = _astStreams[hDecoder];

  // if not a decoder
  if (st.st_stType != ST_DECODER) {
    // do nothing
    return 0.0f;
  }

  // read position
  return st.st_ampegdecoder->tell()/st.st_fBytesPerSec;
}

AMP11LIB_API ALfloat WINAPI alDecGetLen(ALhandle hDecoder)
{
  CriticalSection cs;

  // if handle is invalid
  if (!IsStreamHandleValid(hDecoder)) {
    // do nothing
    return 0.0f;
  }

  Stream &st = _astStreams[hDecoder];

  // if not a decoder
  if (st.st_stType != ST_DECODER) {
    // do nothing
    return 0.0f;
  }

  // read length
  return st.st_ampegdecoder->length()/st.st_fBytesPerSec;
}

//----------------------------------------------

// initialize amp11lib before calling any of its functions
AMP11LIB_API void WINAPI alInitLibrary(void)
{
  // if already initialized
  if (_bLibraryInitialized) {
    // do nothing
    return;
  }
  // set all streams to unused
  for(int ist=0; ist<MAX_STREAMS; ist++) {
    _astStreams[ist].st_stType      = ST_UNUSED;
    _astStreams[ist].st_nReferences = 0;
    _astStreams[ist].st_binfile     = NULL;
    for (int iSlave=0; iSlave<SLAVESPERSTREAM; iSlave++) {
      _astStreams[ist].st_ahSlaves[iSlave] = 0;
    }
  }
  // mark as initialized
  _bLibraryInitialized = ALtrue;

  // initialize critical section
  //InitCS();
}

// cleanup amp11lib when not needed anymore
// NOTE: do not try to call this using atexit(). it just won't work
// because all threads are force-killed _before_ any at-exit function
// is called. sigh.
AMP11LIB_API void WINAPI alEndLibrary(void)
{
  // if not initialized
  if (!_bLibraryInitialized) {
    // do nothing
    return;
  }

  // disable possible redirection if on
  //alDisableRedirection(); // FIXME DG: I had to compile this out, is it useful?

  // free all streams that are not freed
  for(int ist=0; ist<MAX_STREAMS; ist++) {
    if (_astStreams[ist].st_stType != ST_UNUSED) {
      alClose(ist);
    }
  }

  // check that reference counting did its job fine
#ifndef NDEBUG
  {for(int ist=0; ist<MAX_STREAMS; ist++) {
    assert(_astStreams[ist].st_stType       == ST_UNUSED);
    assert(_astStreams[ist].st_nReferences  == 0);
    assert(_astStreams[ist].st_binfile      == NULL);
    for (int iSlave=0; iSlave<SLAVESPERSTREAM; iSlave++) {
      assert(_astStreams[ist].st_ahSlaves[iSlave] == 0);
    }
  }}
#endif

  // cleanup critical section
  //EndCS();

  // mark as not initialized
  _bLibraryInitialized = ALfalse;
}

#if 0
// standard dll entry/exit point
BOOL WINAPI DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{

  // NOTES:
  // in a perfect world, we should do init/cleanup here.
  // but if redirection is on, its thread is killed before process_detach is called.
  // it is much safer do make application programmer call init/end.
  switch (ul_reason_for_call)
	{
    // when dll is loaded
		case DLL_PROCESS_ATTACH:
			break;

    // when dll is unloaded
		case DLL_PROCESS_DETACH:
			break;

    // when a new thread is created
    case DLL_THREAD_ATTACH:
			break;
    // when a thread exits
		case DLL_THREAD_DETACH:
			break;
  }

  return TRUE;
}
#endif
