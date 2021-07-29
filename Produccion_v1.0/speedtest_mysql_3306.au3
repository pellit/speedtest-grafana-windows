#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=speed.ico
#AutoIt3Wrapper_Compile_Both=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <GuiEdit.au3>
#include <GUIConstantsEx.au3>
#include <FileConstants.au3>
;~ #include <CSV.au3>
#include <EzMySql.au3>
#include <StringConstants.au3>


;~ Control my sql shell
;~ cd c:\xampp\mysql\bin
;~ mysql.exe -u root --password
;~ XAMPP Shell
;~ mysql -h localhost -u root -p


Global $deltaTime = 900;segundos
Global $port = "3306"
Global $dimBack = Number(($deltaTime*1000+60000)/1000)
Global $Intervalo = $deltaTime*1000
Global $dim_data = 15
Global $array[3][$dim_data]
;~ Global $aBack[$dimBack*24][10]
Global $aBack[1][$dim_data]
Global $fil
Global $sortString
Global $filterString
Global $cerrar
Global $FileCount = 1
Global $text
Global $speedDB = "speedtest_db"
Global $speedTable = "medicion"
Global $dim_data = 9
Global $Name_col[$dim_data] = ["In,Latencia,Descarga,Carga,Hora,Fecha,google,github,SERVER"]
Global $aData
Global $sock = ""
Global $aIni
;~ Global $sIPAddress = "186.138.164.250"
Global $index
FileCreateShortcut ( @ScriptFullPath ,  @StartupDir  & "\ speedtest_mysql_3306.lnk" )
Global $ini = @ScriptDir & "\config.ini"
;~ Global $xampp = Run("C:\xampp\xampp_start.exe", "", , @SW_HIDE)

$aIni = FileReadToArray($ini)
$aIni[1] = StringSplit($aIni[1], " ")[1]
;~ _ArrayDisplay($aIni)

Do
create_folder()
Global $array[3][10]
$i = 0
$v = 0
$index += 1
$DOS = Run(@ComSpec & ' /c speedtest_gp ', "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
; Wait until the process has closed using the PID returned by Run.
ProcessWaitClose($DOS)
; Read the Stdout stream of the PID returned by Run. This can also be done in a while loop. Look at the example for StderrRead.
$Message = StdoutRead($DOS)
$fil1 = StringSplit($Message, ",")
$fil1[1] = Number($fil1[1])
ReDim $fil1[$dim_data]
$fil1[0] = $index
$fil1[4] = @HOUR & ":" & @MIN & ":" & @SEC
$fil1[5] = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
$fil1[6] = Ping("www.google.com", 5000)
$fil1[7] = Ping("github.com", 5000)
$fil1[8] = ping_port($aIni[1], 5000);PingPort($aIni[1], 5000)
;~ $fil1[9] = PingPort("190.151.167.108", "8000")
;~ _ArrayDisplay($fil1)
For $i = 0 To (UBound($fil1)-1)
	$array[1][$i] = $fil1[$i]
Next
;~ _ArrayDisplay($array,"Test sin limpiar")
For $v = UBound($array, 1) - 1 To 0 Step -1 ; elimina celdas en cero
	If $array[$v][1] = "" or $array[$v][1] = 0 Then
		_ArrayDelete($array, $v)
	EndIf
Next

;~ _ArrayDisplay($array,"Test limpio")
;~ ConsoleWrite($Text & @CRLF & $FileCount & @CRLF)
log_test($array)

mysql_database()

If ($fil1[2] < 1) and ($fil1[1] > 5000) Then
	$msT = "Internet caido, controlar conexión"
	telegram_msg($msT)
EndIf
Sleep($Intervalo)

Until $cerrar =  ProcessExists("explorer.exe")
;~ ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $Message = ' & $Message & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console


Func create_folder()
	Global $dir = @ScriptDir & "\Speedtest_" & @MDAY & "_" & @MON & "_" & @YEAR
If Not FileExists($dir) Then
;~ 	MsgBox(0, "Creación de la carpeta", "La carpeta Asistencia_Imagenes no existe, creando...", 3) ; El mensaje está 3 segundos.
	DirCreate($dir)
EndIf
EndFunc

Func log_test($Edit1)
	_ArrayAdd($aBack, $Edit1)
	Local $sFilePath = $dir & "\Speedtest_" & @MDAY & "_" & @MON & "_" & @YEAR & ".csv"
;~ 	$aResult = _ParseCSV($sFilePath, "\", '$', 4)
;~ 	_ArrayDisplay($aBack)
;~ 	_WriteCSV($sFilePath, $aBack, ',', '', 5)

;~ 	FileWriteLine($sFilePath, $FileCount)
;~ 	$FileCount += 1
;~ 	_GUICtrlEdit_AppendText($Edit1, $sFilePath & "" & @CRLF)
;~ 	Sleep(50)

; Write array to a file by passing the file name.
_FileWriteFromArray($sFilePath, $aBack, 1,Default,",")
EndFunc

Func telegram_msg($PROMPT)

; Nos pregunta el texto a enviar
$TEXT = $PROMPT

; Token que nos da @BotFather al crear nuestro bot
$TOKEN = "1740847768:AAHh5iaK816mdtEonCSV4SVGj1dD32g3MVo"

; ID del chat dónde queremos las notificaciones
$CHATID = "1447276563"

; Llamamos a la API con una URL
$OUTPUT1 = InetRead("https://api.telegram.org/bot" & $TOKEN & "/sendMessage?chat_id=" & $CHATID & "&text=" & $TEXT)
; Capturamos la salida y la pasamos de Binario a String
$OUTPUT2 = BinaryToString($OUTPUT1)

; Mensaje de confirmación (no necesario, se peude comentar), formato JSON
;~ MsgBox(64, $TITLE, $OUTPUT2)
EndFunc


Func mysql_database()

	If Not _EzMySql_Startup() Then
	MsgBox(0, "1-Error al iniciar MySql", "Error: "& @error & @CR & "Error string: " & _EzMySql_ErrMsg())
	Exit
	EndIf

	$Pass = ""

	If Not _EzMySql_Open("", "root", $Pass, "", $port) Then
		MsgBox(0, "2-Error al abrir la base de datos", "Error: "& @error & @CR & "Cadena de error: " & _EzMySql_ErrMsg())
		Exit
	EndIf

	If Not _EzMySql_Exec("CREATE DATABASE IF NOT EXISTS " & $speedDB) Then
		MsgBox(0, "3-Error al abrir la base de datos", "Error: "& @error & @CR & "Cadena de error: " & _EzMySql_ErrMsg())
		Exit
	EndIf
	;~ ConsoleWrite(_EzMySql_SelectDB($speedDB) & @CRLF)
	If Not _EzMySql_SelectDB($speedDB) Then
		MsgBox(0, "4-Error al configurar la base de datos para usar", "Error: "& @error & @CR & "Cadena de error: " & _EzMySql_ErrMsg())
		Exit
	EndIf

	$sMySqlStatement = "CREATE TABLE IF NOT EXISTS " & $speedTable & "(" & _
					   "RowID INT NOT NULL AUTO_INCREMENT," & _
					   "Latencia INT NOT NULL ," & _
					   "Descarga FLOAT NOT NULL ," & _
					   "Carga FLOAT NOT NULL ," & _
					   "Hora TIME NOT NULL ," & _
					   "Fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP ," & _
					   "google FLOAT NOT NULL ," & _
					   "github FLOAT NOT NULL ," & _
					   "SERVER FLOAT NOT NULL ," & _
					   "PRIMARY KEY (`RowID`) ," & _
					   "UNIQUE INDEX RowID_UNIQUE (`RowID` ASC) );"

	If Not _EzMySql_Exec($sMySqlStatement) Then
		MsgBox(0, "5-Error al crear la tabla de la base de datos", "Error: "& @error & @CR & "Cadena de error: " & _EzMySql_ErrMsg())
		Exit
	EndIf
;~ 							"'" & $array[$z][5] & "'," & _
	Local $sMySqlStatement = ""
	Local $z = UBound($array, 1) - 1
		$sMySqlStatement &= "INSERT INTO " & $speedTable & "(Latencia,Descarga,Carga,Hora,google,github,SERVER) VALUES (" & _
							"'" & $array[$z][1] & "'," & _
							"'" & $array[$z][2] & "'," & _
							"'" & $array[$z][3] & "'," & _
							"'" & $array[$z][4] & "'," & _
							"'" & $array[$z][6] & "'," & _
							"'" & $array[$z][7] & "'," & _
							"'" & $array[$z][8] & "');"

	If Not _EzMySql_Exec($sMySqlStatement) Then
		MsgBox(0, "6-Error al insertar datos en la tabla", "Error: "& @error & @CR & "Cadena de error: " & _EzMySql_ErrMsg())
		Exit
	EndIf
;~ 	MsgBox(0, "7-Última AUTO_INCREMENT columnID2", _EzMySql_InsertID())
	$aOk = _EzMySql_GetTable2d("SELECT Latencia,Descarga,Carga,Hora,Fecha,google,github,SERVER FROM " & $speedTable)
	$error = @error
	If Not IsArray($aOk) Then MsgBox(0, $sMySqlStatement & " error", $error)
;~ 	ConsoleWrite("Latencia " & $aOk[$z][1] & " - Descarga " & $aOk[$z][2] & " - Carga " & $aOk[$z][3] & @CRLF)
;~ 	_ArrayDisplay($aOk, "2d Array mostrar tabla")
;~ 	_EzMySql_Exec("DROP TABLE TestTable")
	_EzMySql_Close()
	_EzMySql_ShutDown()
EndFunc



Func PingPort($ip, $port)
	Local $Result
	Local $Stop = 0
;~     $ip = TCPNameToIP($ip)
    Sleep(1000)
    $start = TimerInit()
    $sock = TCPConnect($ip, $port)
    If @error = 1 Then
;~         MsgBox(0, "Error", "Invalid IP entered!")
		ConsoleWrite("Error, Invalid IP entered!" & @CRLF)
    ElseIf @error = 2 Then
;~         MsgBox(0, "Error", "Invalid/closed Port entered!")
		ConsoleWrite("Error, Invalid/closed Port entered!" & @CRLF)
    ElseIf $sock = -1 Then
		$Result = ConsoleWrite( "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] OFFLINE, " & $ip & ":" & $port & @CRLF)
    Else
        $Stop = Round(TimerDiff($start), 2)
        TCPCloseSocket($sock)
		$Result = ConsoleWrite("[" & @HOUR & ":" & @MIN & ":" & @SEC & "] ONLINE, " & $ip & ":" & $port & " ms:" & $Stop & @CRLF)
    EndIf
	Return $Stop
EndFunc   ;==>PingPort

Func ping_port($sIPAddress, $iPort)
    TCPStartup() ; Start the TCP service.

    ; Register OnAutoItExit to be called when the script is closed.
    OnAutoItExitRegister("OnAutoItExit")

    ; Assign Local variables the loopback IP Address and the Port.
;~     Local $sIPAddress = "186.138.164.250" ; This IP Address only works for testing on your own computer.
;~     Local $iPort = 5000 ; Port used for the connection.
	$start = TimerInit()
    ; Assign a Local variable the socket and connect to a Listening socket with the IP Address and Port specified.
    Local $iSocket = TCPConnect($sIPAddress, $iPort)

    ; If an error occurred display the error code and return False.
    If @error Then
        ; The server is probably offline/port is not opened on the server.
        Local $iError = @error
;~         MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Could not connect, Error code: " & $iError)
		ConsoleWrite("Could not connect, Error code: " & $iError & @CRLF)
		$Stop = 15000
        Return $Stop
    Else
		$Stop = Round(TimerDiff($start), 2)
;~         MsgBox($MB_SYSTEMMODAL, "", "Connection successful " &  & $Stop & "ms")
		ConsoleWrite( "Connection successful " & $Stop & "ms" & @CRLF)
		Return $Stop

    EndIf

    ; Close the socket.
    TCPCloseSocket($iSocket)
EndFunc   ;==>Example

Func OnAutoItExit()
    TCPShutdown() ; Close the TCP service.
EndFunc   ;==>OnAutoItExit