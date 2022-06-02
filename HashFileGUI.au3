#NoTrayIcon
#include <ComboConstants.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>
#include <WinAPIEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

Main()

Func Main()
	Local $iAlgorithm = $CALG_SHA_256

	Local $hGUI = GUICreate("Hash Digest Tool - ALBANESE Research Lab " & Chr(169) & " 2018-2022", 670, 100)
	GUISetFont(9, 400, 1, "Consolas")
	Local $idInput = GUICtrlCreateInput("Select file...", 10, 15, 465, 20)
	Local $idBrowse = GUICtrlCreateButton("...", 480, 15, 35, 20)
	Local $idCombo = GUICtrlCreateCombo("", 520, 15, 140, 20, $CBS_DROPDOWNLIST)
	GUICtrlSetData($idCombo, "CRC32 (32bit)|MD2 (128bit)|MD4 (128bit)|MD5 (128bit)|SHA1 (160bit)|SHA_256 (256bit)|SHA_384 (384bit)|SHA_512 (512bit)", "SHA_256 (256bit)")
	Local $idCalculate = GUICtrlCreateButton("Calculate", 585, 40, 77, 22)
	Local $hButton = GUICtrlCreateButton("Clipboard", 585, 65, 77, 22)
	Local $idHashLabel = GUICtrlCreateEdit("Hash Digest", 10, 45, 570, 40, $ES_AUTOVSCROLL + $WS_VSCROLL)
	GUISetState(@SW_SHOW, $hGUI)

	_Crypt_Startup()

	Local $dHash = 0, _
			$sRead = ""
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idBrowse
				Local $sFilePath = FileOpenDialog("Open a file", "", "All files (*.*)")
				If @error Then
					ContinueLoop
				EndIf
				GUICtrlSetData($idInput, $sFilePath)
				GUICtrlSetData($idHashLabel, "Hash Digest")

			Case $idCombo
				Switch GUICtrlRead($idCombo)
					Case "CRC32 (32bit)"
						$iAlgorithm = "CRC32"
					Case "MD2 (128bit)"
						$iAlgorithm = $CALG_MD2
					Case "MD4 (128bit)"
						$iAlgorithm = $CALG_MD4
					Case "MD5 (128bit)"
						$iAlgorithm = $CALG_MD5
					Case "SHA1 (160bit)"
						$iAlgorithm = $CALG_SHA1
					Case "SHA_256 (256bit)"
						$iAlgorithm = $CALG_SHA_256
					Case "SHA_384 (384bit)"
						$iAlgorithm = $CALG_SHA_384
					Case "SHA_512 (512bit)"
						$iAlgorithm = $CALG_SHA_512

				EndSwitch
			Case $hButton
				ClipPut(GUICtrlRead($idHashLabel))
			Case $idCalculate
				$sRead = GUICtrlRead($idInput)
				Global $aRead = GUICtrlRead($idInput)
				If $iAlgorithm = "CRC32" Then
					$dHash = StringLower(_CRC32($sRead))
					GUICtrlSetData($idHashLabel, $dHash)
				Else
					If StringStripWS($sRead, $STR_STRIPALL) <> "" And FileExists($sRead) Then ; Check there is a file available to find the hash digest
						$dHash = StringLower(StringReplace(_Crypt_HashFile($sRead, $iAlgorithm), "0x", ""))
						GUICtrlSetData($idHashLabel, $dHash) 
					EndIf
				EndIf
		EndSwitch
	WEnd

	GUIDelete($hGUI) 
	_Crypt_Shutdown() 
EndFunc   ;==>Main

Func _CRC32($sFilePath) 
	Local $bData = $aRead
	Local $iLength = BinaryLen($bData), $tData

	If $iLength = 0 Then
		Return SetError(2, 0, 0)
	EndIf
	$tData = DllStructCreate('byte[' & $iLength & ']')
	DllStructSetData($tData, 1, $bData)
	Return Hex(_WinAPI_ComputeCrc32(DllStructGetPtr($tData), $iLength), 8)
EndFunc   ;==>_CRC32
