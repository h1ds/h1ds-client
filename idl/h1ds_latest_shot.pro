PRO h1ds_latest_shot

   oXMLDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME='http://h1svr.anu.edu.au/summary/latest_shot/?view=xml')
   
   oNodeList = oXMLDoc->getElementsByTagName('number')
   oNode = oNodeList->Item(0)
   oChild = oNode->getFirstChild()

   PRINT, oChild->getNodeValue()

   OBJ_DESTROY, oXMLDoc

END
