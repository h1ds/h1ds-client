
PRO data_from_mds, data, tree, path, shot

  query = '?shot='+STRING(shot, FORMAT='(I5)')+'&mds-tree='+tree+'&mds-path='+path

  url = 'http://h1svr.anu.edu.au/data/_/request_url'+query

  oXMLDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME=url)
  oData = oXMLDoc->getFirstChild()

  oNodeList = oData->getElementsByTagName('mds_url')      
  oElement = oNodeList->Item(0)
  oElementText = oElement->getFirstChild()
  mds_url_path = oElementText->getNodeValue()

  mds_url = STRJOIN(['http://h1svr.anu.edu.au', mds_url_path])



  OBJ_DESTROY, oNodeList
  OBJ_DESTROY, oElement
  OBJ_DESTROY, oElementText
  OBJ_DESTROY, oData
  OBJ_DESTROY, oXMLDoc

  data_from_url, data, mds_url

END

