'***** BASIC OPEN/CLOSE FUNCTIONS *****
'open a standard file with given filename for reading
Declare Function alOpenInputFile Lib "amp11lib.dll" Alias "_alOpenInputFile@4" _
    (ByVal strFileName As String) As Long
'open mpeg decoder that reads from a file of given handle
Declare Function alOpenDecoder Lib "amp11lib.dll" Alias "_alOpenDecoder@4" _
    (ByVal hFile As Long) As Long
' open sound output with given settings (frequency is in Hz, prebuffer time in seconds,
' use device=-1 for default audio output device)
Declare Function alOpenPlayer Lib "amp11lib.dll" Alias "_alOpenPlayer@16" _
    (ByVal iDevice, ByVal iFreq As Long, ByVal ALbool As Long, _
	ByVal fPreBuffer As Single) As Long
'close any open amp11 stream
Declare Sub alClose Lib "amp11lib.dll" Alias "_alClose@4" _
    (ByVal hStream As Long)


'***** STREAM REDIRECTION FUNCTIONS *****
'enable stream redirection with given timer interval (in seconds)
Declare Sub alEnableRedirection Lib "amp11lib.dll" Alias "_alEnableRedirection@4" 
    (ByVal fInterval As Single)
'disable stream redirection
Declare Sub alDisableRedirection Lib "amp11lib.dll" Alias "_alDisableRedirection@0" ()
'redirect source stream to the target stream
Declare Function alSetRedirection Lib "amp11lib.dll" Alias "_alSetRedirection@8" _
    (ByVal hSource As Long, ByVal hTarget As Long) As Long
'get target stream for given source stream
Declare Function alGetRedirection Lib "amp11lib.dll" Alias "_alGetRedirection@4" _
    (ByVal hSource As Long) As Long


'***** DECODER CONTROL FUNCTIONS *****
'set output volume(0-1)
Declare Sub alDecSetVolume Lib "amp11lib.dll" Alias "_alDecSetVolume@8" _
    (ByVal hDecoder As Long, ByVal fVolume As Single)
'seek absolute/relative (in seconds)
Declare Sub alDecSeekAbs Lib "amp11lib.dll" Alias "_alDecSeekAbs@8" _
    (ByVal hDecoder As Long, ByVal fSeconds As Single)
Declare Sub alDecSeekRel Lib "amp11lib.dll" Alias "_alDecSeekRel@8" _
    (ByVal hDecoder As Long, ByVal fSecondsDelta As Single)
'get current position (in seconds)
Declare Function alDecGetPos Lib "amp11lib.dll" Alias "_alDecGetPos@4" _
    (ByVal hDecoder As Long) As Single
'get total stream length (in seconds)
Declare Function alDecGetLen Lib "amp11lib.dll" Alias "_alDecGetLen@4" _
    (ByVal hDecoder As Long) As Single


'***** LIBRARY INIT/END FUNCTIONS *****
'initialize amp11lib before calling any of its functions
Declare Sub alInitLibrary Lib "amp11lib.dll" Alias "_alInitLibrary@0" ()
'cleanup amp11lib when not needed anymore
Declare Sub alEndLibrary Lib "amp11lib.dll" Alias "_alEndLibrary@0" ()
