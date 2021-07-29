#include <Constants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>

Opt("MustDeclareVars", 1)


Global $dir0 = @ProgramFilesDir & "\PELLIT"
Global $dir1 = $dir0 & "\Speedtest"
Const $sZipFile = @ScriptDir & "\nssm-2.24.zip"
Global $file_copy = _FileListToArray(@ScriptDir, Default, Default, True)
_ArrayDisplay($file_copy)
create_folder()
Global $sDestFolder = $dir1
UnZip($sZipFile, $sDestFolder)
If @error Then Exit MsgBox ($MB_SYSTEMMODAL,"","Error al descomprimir archivo : " & @error)
Func copy_file()
	For $i = 0 To UBound($file_copy) - 1
		DirCopy(@ScriptDir ,$dir1 , $FC_OVERWRITE + $FC_CREATEPATH)
	Next
EndFunc


Func set_ini()
	Local $inifile = @ScriptDir & "\config.ini"
If Not FileExists($inifile) Then
	MsgBox(0, "Creación de archivo de configuracion", "El archivo ini no existe, creando...", 3) ; El mensaje está 3 segundos.
	Local $file = FileOpen($inifile)
	FileWriteLine($inifile , $dir1)
	FileWriteLine($file, $dir1)
	Local $ip1 = InputBox("PELLIT - speedtest configuration","Ingrese Ip a registrar","")
	FileWriteLine($file, $ip1)
	FileClose($file)
Else
	IniRead($inifile, "config", @MON & @MDAY, "")
EndIf
;===============Example use .ini file=============================
;~ simplemente sepárelos con comas o algo así.
;~ [cumpleaños]
;~ 0713 = Helge, Thomas
;~ 0613 = Heidi
;~ 1212 = mamá
;~ Entonces, para verificar si hoy es el cumpleaños de alguien, puedes hacer algo como esto:
;~ IniRead ( "c: \ cumpleaños.ini" ,  "cumpleaños" ,  @MON  &  @MDAY ,  "" )
;=================================================================

EndFunc






Func create_folder()
;~ 	Global $dir0 = @ScriptDir & "\PELLIT"
If Not FileExists($dir0) Then
;~ 	MsgBox(0, "Creación de la carpeta", "La carpeta Asistencia_Imagenes no existe, creando...", 3) ; El mensaje está 3 segundos.
	DirCreate($dir0)
EndIf
;~ 	Global $dir1 = $dir0 & "\Speedtest"
If Not FileExists($dir1) Then
;~ 	MsgBox(0, "Creación de la carpeta", "La carpeta Asistencia_Imagenes no existe, creando...", 3) ; El mensaje está 3 segundos.
	DirCreate($dir0)
	ConsoleWrite("Carpeta creada en " & $dir1 & @CRLF)
EndIf
EndFunc



Func UnZip($sZipFile, $sDestFolder)
  If Not FileExists($sZipFile) Then Return SetError (1) ; source file does not exists
  If Not FileExists($sDestFolder) Then
    If Not DirCreate($sDestFolder) Then Return SetError (2) ; unable to create destination
  Else
    If Not StringInStr(FileGetAttrib($sDestFolder), "D") Then Return SetError (3) ; destination not folder
  EndIf
  Local $oShell = ObjCreate("shell.application")
  Local $oZip = $oShell.NameSpace($sZipFile)
  Local $iZipFileCount = $oZip.items.Count
  If Not $iZipFileCount Then Return SetError (4) ; zip file empty
  For $oFile In $oZip.items
    $oShell.NameSpace($sDestFolder).copyhere($ofile)
  Next
EndFunc   ;==>UnZip