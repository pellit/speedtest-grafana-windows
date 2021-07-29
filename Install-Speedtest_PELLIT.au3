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
install_service_speedtest()
install_software()
;~ xampp_install()
set_ini()
DirRemove($dir1 & "\nssm-2.24",1)
FileDelete($sZipFile)



Func install_service_speedtest()
	Local $DOS
	$DOS = Run(@ComSpec & ' /c nssm install speedtest_pellit ', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
EndFunc

Func xampp_install()
	Local $iIndex = _ArraySearch($aSOFTinstall, "XAMPP", 0, 0, 0, 0, 1, 1)
;~ 	MsgBox($MB_SYSTEMMODAL, "Found '#32'", "Column 2 on Row " & $iIndex)
	If $iIndex = -1 Then
		Run($dir1 & "\xampp-windows-x64-7.3.29-1-VC15-installer.exe")
		WinActive("Setup")
		WinWaitActive("Setup")
		Send("{TAB}")
		Sleep(100)
		Send("{ENTER}")
		Sleep(100)
		Send("{ENTER}")
		Sleep(100)
		Send("{ENTER}")
		WinWaitClose("Setup")
	EndIf
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


Func install_software()
;~ :Listar programas instalados
;~ BlockInput($BI_DISABLE)
Local $name=@ComputerName
Global $file = @ScriptDir & "\Software-" & @ComputerName & "_" & @UserName & "-" & @MDAY & "_" & @MON & "_" & @YEAR & ".txt"
Local $output = "C:\misprogramas.txt"
Local $output1 = "C:\CPU.txt"
Local $output2 = "C:\ALL.txt"
Local $output3 = "C:\system.txt"
Local $CMD_win7 = "wmic /output:" & $output & " product get name, version"
;~ Local $sysinfo = "WMIC /Output:" & $output1 & " CPU get /all /format:LIST"
;~ Local $sysinfo2 = "WMIC /Output:" & $output2 & " OS get /all /format:LIST"
;~ Local $sysinfo3 = "WMIC /Output:" & $output3 & " COMPUTERSYSTEM get /all /format:LIST"
;~ wmic /output:[C:/misprogramas.txt] product get name, version
Local $CMD = "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize > " & $file
RunWait(@ComSpec & " /c " & $CMD_win7, "", @SW_SHOW)
;~ RunWait(@ComSpec & " /c " & $sysinfo, "", @SW_SHOW)
;~ RunWait(@ComSpec & " /c " & $sysinfo2, "", @SW_SHOW)
;~ RunWait(@ComSpec & " /c " & $sysinfo3, "", @SW_SHOW)
_FileReadToArray($output, $aSOFTinstall)
;~ _ArrayDisplay( $aSOFTinstall,"Software instalado")
_FileWriteFromArray($file, $aSOFTinstall, Default, Default, ",")
Sleep(1000)
FileDelete($output)
;~ FileDelete($output1)
;~ FileDelete($output2)
;~ FileDelete($output3)
;~ FileDelete($file)
;~ BlockInput($BI_ENABLE)
EndFunc