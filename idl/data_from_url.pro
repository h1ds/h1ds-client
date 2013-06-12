
PRO data_from_url, data, url

  ; Let's add the format=xml HTTP GET query to make sure we get XML
                                ; it doesn't matter if another
                                ; format is requested, if there
                                ; are multiple GET queries then the
                                ; last one is used.
  url_parts = PARSE_URL(url)

  ; if there are no GET queries
  IF STRLEN(url_parts.query) EQ 0 THEN BEGIN
                                ; IDL is crashing if we don't
                                ; have a trailing slash before
                                ; the query...
     IF STRPOS(url_parts.path, '/', /REVERSE_SEARCH) NE STRLEN(url_parts.path)-1 THEN BEGIN
        url = STRJOIN([url, '/'])
     ENDIF
     url = STRJOIN([url, 'format=xml'], '?')
  ENDIF ELSE BEGIN  ; if there are already some queries...
     url = STRJOIN([url, 'format=xml'], '&')
  ENDELSE

   oXMLDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME=url)
   
   oContent = oXMLDoc->getFirstChild()
   
   ; The simple (non-data) elements
   element_name_list = ['shot', 'tree', 'path']
   element_list = ['','','']
   
   ; Extract the non-data elements from the XML document.
   FOR i=0, N_ELEMENTS(element_list)-1 DO BEGIN
      oNodeList = oContent->getElementsByTagName(element_name_list[i])
      oElement = oNodeList->Item(0)
      oElementText = oElement->getFirstChild()
      element_list[i] = oElementText->getNodeValue()
   ENDFOR

   ; Get data
   oData = (oContent->getElementsByTagName('data'))->Item(0)
   oElementList = oData->getElementsByTagName('*')
   data_length = oElementList->GetLength()
   data_arr = MAKE_ARRAY(data_length, /FLOAT)

   FOR I=0,(data_length-1) DO BEGIN
      data_arr[I] = ((oElementList->Item(I))->getFirstChild())->getNodeValue()
   ENDFOR

   ; Get dim
   oDim = (oContent->getElementsByTagName('dim'))->Item(0)
   oElementList = oDim->getElementsByTagName('*')
   dim_length = oElementList->GetLength()
   dim_arr = MAKE_ARRAY(dim_length, /FLOAT)

   FOR I=0,(dim_length-1) DO BEGIN
      dim_arr[I] = ((oElementList->Item(I))->getFirstChild())->getNodeValue()
   ENDFOR

   signal_struct = CREATE_STRUCT('dim', dim_arr, 'signal', data_arr)
   data = OBJ_NEW('h1mdsdata', LONG(element_list[0]), element_list[1], element_list[2])
   data->setdata, signal_struct

   OBJ_DESTROY, oXMLDoc

END

