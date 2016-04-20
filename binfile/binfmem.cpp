// binfile - class library for files/streams - memory files
// Copyright (c) 1997-99 Niklas Beisert
// See COPYING (GNU Library General Public License 2) for license

#include <string.h>
#include <stdlib.h>
#include "binfmem.h"

mbinfile::mbinfile()
{
}

mbinfile::~mbinfile()
{
  close();
}

errstat mbinfile::open(void *buf, binfilepos len, intm type)
{
  close();
  filebuf=(uint1*)buf;
  rawpos=0;
  rawlen=len;
  openmode(moderead|modeseek|((type&openrw)?modewrite:0), rawpos, rawlen);
  trunc=0;
  freemem=type&openfree;
  return 0;
}

errstat mbinfile::opencs(void *&buf, binfilepos &len, intm inc)
{
  close();
  fbuf=&buf;
  flen=&len;
  fbuflen=*flen;
  fleninc=inc;
  filebuf=(uint1*)*fbuf;
  rawpos=0;
  rawlen=*flen;
  openmode(moderead|modewrite|modeseek|modeappend, rawpos, rawlen);
  trunc=0;
  return 0;
}

errstat mbinfile::rawclose()
{
  closemode();
  if (trunc)
    chsize(rawpos);
  if (mode&modeappend)
    *fbuf=realloc(*fbuf,*flen);
  else
    if (mode&&freemem)
      delete *fbuf;
  return 0;
}

binfilepos mbinfile::rawpeek(void *buf, binfilepos len)
{
  if ((rawpos+len)>rawlen)
    len=rawlen-rawpos;
  memcpy(buf, filebuf+rawpos, len);
  return len;
}

binfilepos mbinfile::rawread(void *buf, binfilepos len)
{
  if ((rawpos+len)>rawlen)
    len=rawlen-rawpos;
  memcpy(buf, filebuf+rawpos, len);
  rawpos+=len;
  return len;
}

binfilepos mbinfile::rawwrite(const void *buf, binfilepos len)
{
  if (len>(rawlen-rawpos))
  {
    chsize(rawpos+len);
    if (len>(rawlen-rawpos))
      len=rawlen-rawpos;
  }
  memcpy(filebuf+rawpos, buf, len);
  rawpos+=len;
  return len;
}

binfilepos mbinfile::rawseek(binfilepos pos)
{
  return rawpos=pos;
}

binfilepos mbinfile::chsize(binfilepos len)
{
  if (!(mode&modeappend))
    return rawlen;
  if (len<0)
    len=0;
  if (len<=fbuflen)
  {
    *flen=len;
    rawlen=*flen;
    return rawlen;
  }
  void *n=realloc(*fbuf,len+fleninc);
  if (!n)
    return rawlen;
  *fbuf=n;
  *flen=len;
  fbuflen=len+fleninc;
  filebuf=(uint1*)*fbuf;
  memset(filebuf+rawlen, 0, fbuflen-rawlen);
  rawlen=*flen;
  if (rawpos>rawlen)
    rawpos=rawlen;
  return rawlen;
}

binfilepos mbinfile::rawioctl(intm code, void *buf, binfilepos len)
{
  binfilepos ret;
  switch (code)
  {
  case ioctltrunc: ret=trunc; trunc=((mode&modeappend)&&len)?1:0; break;
  case ioctltruncget: ret=trunc; break;
  default: return binfile::rawioctl(code, buf, len);
  }
  return ret;
}
