%module gridfunc
%{
  #include <iostream>
  #include <sstream>
  #include <fstream>
  #include <limits>
  #include <cmath>
  #include <cstring>
  #include <ctime>
  #include "iostream_typemap.hpp"    
  #include "fem/linearform.hpp"
  #include "fem/gridfunc.hpp"
  #include "pycoefficient.hpp"
  #include "numpy/arrayobject.h"      
%}

%init %{
import_array();
%}

%import "array.i"
%import "vector.i"
%import "coefficient.i"
%import "fespace.i"
%import "bilininteg.i"
%import "linearform.i"
%import "fespace.i"
%import "fe_coll.i"
%import "intrules.i"
%import "densemat.i"
%import "sparsemat.i"
%import "lininteg.i"
%import "eltrans.i"

%import "ostream_typemap.i"

%rename(Assign) mfem::GridFunction::operator=;

%feature("shadow") mfem::GridFunction::GetNodalValues%{
def GetNodalValues(self, *args):
    '''
    GetNodalValues(i)   ->   GetNodalValues(vector, vdim)
    GetNodalValues(i, array<dobule>, vdim)
    '''
    from .vector import Vector
    if len(args) == 1:
        vec = Vector()
        _gridfunc.GridFunction_GetNodalValues(self, vec, args[0])
        vec.thisown = 0
        return vec.GetDataArray()
    else:
        return _gridfunc.GridFunction_GetNodalValues(self, *args)
%}

%typemap(in) const mfem::IntegrationRule *irs[]{
  if (PyList_Check($input)) {
    int size = PyList_Size($input);
    int i = 0;
    $1 = (mfem::IntegrationRule **) malloc((size)*sizeof(mfem::IntegrationRule *));
    for (i = 0; i < size; i++) {
       PyObject *o = PyList_GetItem($input,i);
       void *temp;       
       if (SWIG_ConvertPtr(o, &temp,
	   $descriptor(mfem::IntegrationRule *),SWIG_POINTER_EXCEPTION) == -1){
           return NULL;
       }
       $1[i] = reinterpret_cast<mfem::IntegrationRule *>(temp);       
     }
  } else {
    PyErr_SetString(PyExc_TypeError,"not a list");
    return NULL;
  }
}
%typemap(typecheck) const mfem::IntegrationRule *irs[]{
   $1 = PyList_Check($input) ? 1 : 0;
}

%include "fem/gridfunc.hpp"

namespace mfem{
%extend GridFunction{
void SaveToFile(const char *gf_file, const int precision) const
   {
	std::ofstream mesh_ofs(gf_file);	
        mesh_ofs.precision(precision);
        self->Save(mesh_ofs);	
   }
GridFunction & iadd(GridFunction &c)
   {
      *self += c;
      return *self;
   }
GridFunction & isub(GridFunction &c)
   {
      *self -= c;
      return *self;
   }
GridFunction & isub(double c)
   {
      *self -= c;
      return *self;
   }
GridFunction & imul(double c)
  {
   (* self) *= c;
   return *self;
   }
GridFunction & idiv(double c)
   {
      * self /= c;
      return *self;
   }
  }
   
}

%pythoncode %{
def __iadd__(self, v):
    ret = _gridfunc.GridFunction_iadd(self, v)
    ret.thisown = self.thisown
    self.thisown = 0      
    return ret
def __isub__(self, v):
    ret = _gridfunc.GridFunction_isub(self, v)
    ret.thisown = self.thisown
    self.thisown = 0      
    return ret
def __idiv__(self, v):
    ret = _gridfunc.GridFunction_idiv(self, v)
    ret.thisown = self.thisown
    self.thisown = 0
    return ret
def __imul__(self, v):
    ret = _gridfunc.GridFunction_imul(self, v)
    ret.thisown = self.thisown
    self.thisown = 0
    return ret
      
GridFunction.__iadd__  = __iadd__
GridFunction.__idiv__  = __idiv__
GridFunction.__isub__  = __isub__
GridFunction.__imul__  = __imul__      
%} 



