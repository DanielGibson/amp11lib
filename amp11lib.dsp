# Microsoft Developer Studio Project File - Name="amp11lib" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=amp11lib - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "amp11lib.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "amp11lib.mak" CFG="amp11lib - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "amp11lib - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "amp11lib - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Porting/amp11lib", KVCAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "amp11lib - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "AMP11LIB_EXPORTS" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O2 /I "binfile" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "AMP11LIB_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386
# Begin Custom Build - Copying amp11lib.dll to the test directory
InputPath=.\Release\amp11lib.dll
SOURCE="$(InputPath)"

"..\test\release\amp11lib.dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	copy    release\amp11lib.dll    ..\test\release\ 

# End Custom Build
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=copy release\amp11lib.dll test\release
# End Special Build Tool

!ELSEIF  "$(CFG)" == "amp11lib - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "AMP11LIB_EXPORTS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "binfile" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "AMP11LIB_EXPORTS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# Begin Custom Build - Copying amp11lib.dll to the test directory
InputPath=.\Debug\amp11lib.dll
SOURCE="$(InputPath)"

"..\test\debug\amp11lib.dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	copy    debug\amp11lib.dll    ..\test\debug\ 

# End Custom Build
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=copy debug\amp11lib.dll test\debug
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "amp11lib - Win32 Release"
# Name "amp11lib - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "binfile sources"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\binfile\binfarc.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfcon.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfhttp.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfile.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfilef.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfmem.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfplnt.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfplwv.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binfstd.cpp
# End Source File
# Begin Source File

SOURCE=.\binfile\binftcp.cpp
# End Source File
# End Group
# Begin Source File

SOURCE=.\amp11lib.cpp
# End Source File
# Begin Source File

SOURCE=.\amp1dec.cpp
# End Source File
# Begin Source File

SOURCE=.\amp2dec.cpp
# End Source File
# Begin Source File

SOURCE=.\amp3dec.cpp
# End Source File
# Begin Source File

SOURCE=.\ampdec.cpp
# End Source File
# Begin Source File

SOURCE=.\ampsynth.cpp
# End Source File
# Begin Source File

SOURCE=.\mpgsplit.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Group "binfile headers"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\binfile\binfarc.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfcon.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfhttp.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfile.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfmem.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfpllx.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfplnt.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfplsb.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfplwv.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binfstd.h
# End Source File
# Begin Source File

SOURCE=.\binfile\binftcp.h
# End Source File
# Begin Source File

SOURCE=.\binfile\ptypes.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\amp11lib.bas
# End Source File
# Begin Source File

SOURCE=.\amp11lib.h
# End Source File
# Begin Source File

SOURCE=.\ampdec.h
# End Source File
# Begin Source File

SOURCE=.\mpgsplit.h
# End Source File
# Begin Source File

SOURCE=.\timer.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
