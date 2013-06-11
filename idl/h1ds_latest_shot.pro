PRO h1ds_latest_shot

   oXMLDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME='http://h1svr.anu.edu.au/data/_/latest_shot/?format=xml')
   
   oNodeList = oXMLDoc->getElementsByTagName('shot_number')
   oNode = oNodeList->Item(0)
   oChild = oNode->getFirstChild()

   PRINT, oChild->getNodeValue()

   OBJ_DESTROY, oXMLDoc

END
