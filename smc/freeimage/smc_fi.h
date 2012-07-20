/*
=============================================================================
 Copyright   : (c) 2008-2012 semantics GmbH. All Rights Reserved.
 Rep./File   : $URL$
 Date        : $Date$
 Author      : Christian Heimes, Dirk Rothe
 License     : FreeImage Public License (FIPL)
               GNU General Public License (GPL)
 Worker      : $Author$
 Revision    : $Rev$
 Purpose     : Hacks and tricks
=============================================================================

 COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT
 WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT
 LIMITATION, WARRANTIES THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE,
 FIT FOR A PARTICULAR PURPOSE OR NON-INFRINGING. THE ENTIRE RISK AS TO THE
 QUALITY AND PERFORMANCE OF THE COVERED CODE IS WITH YOU. SHOULD ANY COVERED
 CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT THE INITIAL DEVELOPER OR ANY
 OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY SERVICING, REPAIR OR
 CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF
 THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER
 THIS DISCLAIMER.
*/

#ifndef SMC_FI_CONST_H
#define SMC_FI_CONST_H

#include "FreeImage.h"
#include "Python.h"

#if PY_VERSION_HEX >= 0x03000000
#  define IS_PYTHON3 1
#else
#  define IS_PYTHON3 0
#endif

#if !defined(FREEIMAGE_TURBO) || !FREEIMAGE_TURBO
    #define FREEIMAGE_TURBO 0
#else
    #undef FREEIMAGE_TURBO
    #define FREEIMAGE_TURBO 1
#endif

typedef FIBITMAP* (DLL_CALLCONV *FI_ConvertFunction)(FIBITMAP *dib);

#if (CMS_USE_BIG_ENDIAN == 1) && !defined(FREEIMAGE_BIGENDIAN)
    #error "CMS_USE_BIG_ENDIAN / FREEIMAGE_BIGENDIAN mismatch"
#endif

#if (CMS_USE_BIG_ENDIAN == 1)
    #define SMC_FI_BIG_ENDIAN 1
#else
    #define SMC_FI_BIG_ENDIAN 0
#endif

// LCMS2 definitions
#ifndef _MSC_VER

#define LCMS_WIN_TYPES_ALREADY_DEFINED

//typedef unsigned char BYTE;
typedef unsigned char *LPBYTE;
//typedef unsigned short WORD;
typedef unsigned short *LPWORD;
//typedef unsigned long DWORD;
typedef unsigned long *LPDWORD;
typedef char *LPSTR;
typedef void *LPVOID;

#define ZeroMemory(p,l)     memset((p),0,(l))
#define CopyMemory(d,s,l)   memcpy((d),(s),(l))
#define FAR

#ifndef stricmp
#   define stricmp strcasecmp
#endif


#ifndef FALSE
#       define FALSE 0
#endif
#ifndef TRUE
#       define TRUE  1
#endif

#define LOWORD(l)    ((WORD)(l))
#define HIWORD(l)    ((WORD)((DWORD)(l) >> 16))

#ifndef MAX_PATH
#       define MAX_PATH     (256)
#endif

#define cdecl

#else /* Windows here */

#ifndef MAX_PATH
    #define MAX_PATH 4096
#endif

#endif/* _MSC_VER */


#endif
