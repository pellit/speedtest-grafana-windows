#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\Automatizacion werk\config.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
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
#include <WinHttp.au3>
#include <JSON.au3>

Opt("MustDeclareVars", 1)


Global $aSOFTinstall
Global $version = @ScriptDir & "\Produccion_v1.0"
Global $dir0 = @ProgramFilesDir & "\PELLIT"
Global $dir1 = $dir0 & "\Speedtest"
Const $sZipFile = $version & "\nssm-2.24.zip"
create_folder()
Global $sDestFolder = $dir1
ConsoleWrite("Produccion " & $version & @CRLF)
ConsoleWrite("Copia en " & $dir1 & @CRLF)
DirCopy($version ,$sDestFolder , $FC_OVERWRITE + $FC_CREATEPATH)
Global $file_copy = _FileListToArray($dir1, Default, Default, True)
_ArrayDisplay($dir1)
ConsoleWrite("Carpeta creada en " & $dir1 & @CRLF)
UnZip($sZipFile, $dir1)
Sleep(1000)
If @error Then Exit MsgBox ($MB_SYSTEMMODAL,"","Error al descomprimir archivo : " & @error)
Sleep(1000)
FileCopy($dir1 & "\nssm-2.24\win64\nssm.exe",$dir1)
set_ini()
telegram_ini()
DirRemove($dir1 & "\nssm-2.24",1)
FileDelete($sZipFile)



Func install_service_speedtest()
	Local $DOS
	$DOS = Run(@ComSpec & ' /c nssm install speedtest_pellit ', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
EndFunc

Func set_ini()
	Local $inifile = $dir1 & "\config.ini"
If Not FileExists($inifile) Then
	MsgBox(0, "Creación de archivo de configuracion", "El archivo ini no existe, creando...", 3) ; El mensaje está 3 segundos.
	Local $file = FileOpen($inifile)
	FileWriteLine($inifile , $dir1)
	FileWriteLine($file, $dir1)
	Local $ip1 = InputBox("PELLIT - speedtest configuration","Ingrese Ip a registrar","")
	FileWriteLine($inifile, $ip1)
	FileClose($file)
Else
	IniRead($inifile, "config", @MON & @MDAY, "")
EndIf
EndFunc

Func telegram_ini()
	Local $inifile = $dir1 & "\telegramBot.ini"
If Not FileExists($inifile) Then
	MsgBox(0, "Creación de archivo de configuracion", "El archivo ini no existe, creando...", 3) 
	Local $file = FileOpen($inifile)
	FileWriteLine($inifile , $dir1)
	FileWriteLine($file, $dir1)
	Local $Token = InputBox("PELLIT - speedtest configuration","Ingrese token de bot","")
	Local $ID = InputBox("PELLIT - speedtest configuration","Ingrese ID de chat","")
	FileWriteLine($inifile, $Token)
	FileWriteLine($inifile, $ID)
	FileClose($file)
Else
	IniRead($inifile, "telegramBot", @MON & @MDAY, "")
EndIf
EndFunc

Func create_folder()
If Not FileExists($dir0) Then
	DirCreate($dir0)
EndIf
If Not FileExists($dir1) Then
	DirCreate($dir0)
	ConsoleWrite("Carpeta creada en " & $dir1 & @CRLF)
EndIf
Sleep(1000)
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

