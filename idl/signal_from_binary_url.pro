;-----------------------------------------------------------------
FUNCTION Url_Callback, status, progress, data
  
   ; return 1 to continue, return 0 to cancel
   RETURN, 1
END

;-----------------------------------------------------------------
PRO signal_from_binary_url, dim, signal, units, url


   ; If the url object throws an error it will be caught here
   CATCH, errorStatus 
   IF (errorStatus NE 0) THEN BEGIN
      CATCH, /CANCEL

      ; Display the error msg in a dialog and in the IDL output log
      r = DIALOG_MESSAGE(!ERROR_STATE.msg, TITLE='URL Error', $
                         /ERROR)
      PRINT, !ERROR_STATE.msg

      ; Get the properties that will tell us more about the error.
      oUrl->GetProperty, RESPONSE_CODE=rspCode, $
         RESPONSE_HEADER=rspHdr, RESPONSE_FILENAME=rspFn
      PRINT, 'rspCode = ', rspCode
      PRINT, 'rspHdr= ', rspHdr
      PRINT, 'rspFn= ', rspFn

      ; Destroy the url object
      OBJ_DESTROY, oUrl
      RETURN
   ENDIF

   url_info = PARSE_URL(url)

   ; create a new IDLnetURL object 
   oUrl = OBJ_NEW('IDLnetUrl')

   ; Specify the callback function
   oUrl->SetProperty, CALLBACK_FUNCTION ='Url_Callback'

   ; Set verbose to 1 to see more info on the transacton
   oUrl->SetProperty, VERBOSE = 0

   ; Set the transfer protocol as ftp
   oUrl->SetProperty, url_scheme = url_info.scheme

   ; The ITT VIS FTP server
   oUrl->SetProperty, URL_HOST = url_info.host

   ; The FTP server path of the file to download
   oUrl->SetProperty, URL_PATH = STRJOIN([url_info.path, $
                                          url_info.query], '?')

   ; Retrieve the binary data to a buffer
   tmp_buffer = oUrl->Get( /BUFFER )
   ; This should be a unique filename, so we don't overwrite anyone's files..
   temp_filename = 'tempMDSq8te63c.dat'
   openw, 1, FILEPATH(temp_filename, /TMP)
   writeu, 1, tmp_buffer
   close, 1
   ; Read the file back in as binary
   openr, 1, FILEPATH(temp_filename, /TMP), /DELETE
   tmp_output = read_binary(1, data_type=2)
   close, 1
   ;;;;;;;;;;; read HTTP headers for calibration and dim (e.g. timebase)

   oUrl->GetProperty, RESPONSE_HEADER = headers

   header_strings = ['X-H1DS-signal-min: ',    $ 
                     'X-H1DS-signal-delta: ',  $
                     'X-H1DS-dim-t0: ',   $
                     'X-H1DS-dim-delta: ',$
                     'X-H1DS-dim-length: ',$
                     'X-H1DS-dim-units: ',   $
                     'X-H1DS-signal-units: ']
   header_data = ['','','','','','','']
   
   ;;; Use regex to find the headers
   FOR head_i=0,4 DO BEGIN

      h_str = header_strings[head_i]
      pos = STREGEX(headers, STRJOIN([h_str, '[e0-9.-]+']), length=len)
      header_data[head_i] = STRMID(headers, pos+STRLEN(h_str), len-STRLEN(h_str))
      
   ENDFOR

   FOR head_i=5,6 DO BEGIN

      h_str = header_strings[head_i]
      pos = STREGEX(headers, STRJOIN([h_str, '[a-zA-Z]+']), length=len)
      header_data[head_i] = STRMID(headers, pos+STRLEN(h_str), len-STRLEN(h_str))
      
   ENDFOR


   signal = FLOAT(header_data[1])*tmp_output + FLOAT(header_data[0])
   dim = FLOAT(header_data[3])*FINDGEN(FLOAT(header_data[4])) + FLOAT(header_data[2])
   units = [header_data[5], header_data[6]]

   ; Destroy the url object
   OBJ_DESTROY, oUrl

END
