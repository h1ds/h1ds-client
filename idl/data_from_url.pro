
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
   
   oData = oXMLDoc->getFirstChild()
   
   ; The simple (non-data) elements
   element_name_list = ['shot_number', 'shot_time', 'mds_tree', 'mds_path']
   element_list = ['','','','']
   
   ; Extract the non-data elements from the XML document.
   FOR i=0, N_ELEMENTS(element_list)-1 DO BEGIN
      oNodeList = oData->getElementsByTagName(element_name_list[i])      
      oElement = oNodeList->Item(0)
      oElementText = oElement->getFirstChild()
      element_list[i] = oElementText->getNodeValue()
   ENDFOR

   ; Get the data type
   oNodeList = oData->getElementsByTagName('data')      
   oElement = oNodeList->Item(0)
   oAttrList = oElement->getAttributes()
   oType = oAttrList->getNamedItem('type')
   data_type = oType->getNodeValue()

   data = OBJ_NEW('h1mdsdata', LONG(element_list[0]), element_list[1], element_list[2], element_list[3])
   
   CASE data_type OF
      'signal': BEGIN
         oElementText = oElement->getFirstChild()
         signal_url = oElementText->getNodeValue()
         signal_from_binary_url, dim, signal, units, signal_url
         signal_struct = CREATE_STRUCT('dim', dim, 'signal', signal, 'dim_units', units[0], 'signal_units', units[1])
         data->setdata, signal_struct
      END
      'scalar': BEGIN
         oElementText = oElement->getFirstChild()
         d = oElementText->getNodeValue()
         data->setdata, d         
      END
      'text': BEGIN
         oElementText = oElement->getFirstChild()
         d = oElementText->getNodeValue()
         data->setdata, d         
      END
   ENDCASE

   OBJ_DESTROY, oNodeList
   OBJ_DESTROY, oElement
   OBJ_DESTROY, oElementText

   OBJ_DESTROY, oXMLDoc

END

