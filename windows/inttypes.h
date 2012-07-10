/* partly copied from lcms2.h */

#include <limits.h>
#include <stddef.h>

typedef unsigned char uint8_t;
typedef signed char int8_t;

#if (USHRT_MAX == 65535U)
 typedef unsigned short uint16_t;
#elif (UINT_MAX == 65535U)
 typedef unsigned int uint16_t;
#else
#  error "Unable to find 16 bits unsigned type, unsupported compiler"
#endif

#if (UINT_MAX == 4294967295U)
 typedef unsigned int uint32_t;
#elif (ULONG_MAX == 4294967295U)
 typedef unsigned long uint32_t;
#else
#  error "Unable to find 32 bit unsigned type, unsupported compiler"
#endif

#if (INT_MAX == +2147483647)
 typedef int int32_t;
#elif (LONG_MAX == +2147483647)
 typedef long int32_t;
#else
#  error "Unable to find 32 bit signed type, unsupported compiler"
#endif
