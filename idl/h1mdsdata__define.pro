FUNCTION h1mdsdata::init, shot, tree, path
  self.shot = shot
  self.tree = tree
  self.path = path
  self.ptr=PTR_NEW(/ALLOCATE)
  RETURN, 1
END

FUNCTION h1mdsdata::getshot
  RETURN, self.shot
END

FUNCTION h1mdsdata::gettree
  RETURN, self.tree
END

FUNCTION h1mdsdata::getpath
  RETURN, self.path
END

PRO h1mdsdata::setdata, value
  IF N_ELEMENTS(value) NE 0 THEN *(self.ptr)=value
  RETURN
END

FUNCTION h1mdsdata::getdata, value
  IF N_ELEMENTS(*(self.ptr)) NE 0 THEN value=*(self.ptr)
  RETURN, value
END

FUNCTION h1mdsdata::cleanup
; free memory allocated to pointer when destroying object

  PTR_FREE,self.ptr
  RETURN, 1
END

PRO h1mdsdata::plot
  IF N_ELEMENTS(*(self.ptr)) NE 0 THEN BEGIN
     ; For now, assume signal structure...
     ; TODO check data type, don't break if we don't have signal struct
     signal_struc = *(self.ptr)
     title = STRJOIN([STRING(self.shot), ' ', self.path])
     ; plot, signal_struc.dim, signal_struc.signal, TITLE=title, XTITLE=signal_struc.dim_units, YTITLE=signal_struc.signal_units
     plot, signal_struc.dim, signal_struc.signal, TITLE=title
  ENDIF
  
  RETURN
END

PRO h1mdsdata__define
  void={h1mdsdata,    $
        shot:0L,      $
        tree:'',      $
        path:'',      $
        ptr:ptr_new() $
       }
  RETURN
END
