#include <stdio.h>
#include <time.h>
#include <FreeImage.h>

#define TEST_TIFF "test.tif"
#define LOOPS 100

#ifndef LIB
    #define LIB freeimage
#endif

#define QUOTEME_(x) #x
#define QUOTEME(x) QUOTEME_(x)

int main(void) {
    FIBITMAP *tiff;
    char filename[50];
    struct timespec start, stop;
    double runtime = 0;
    
    tiff = FreeImage_Load(FIF_TIFF, TEST_TIFF, TIFF_DEFAULT);
    if (tiff == NULL) {
        printf("Failed to load test.tif\n");
        return 1;
    }
    printf("TIFF image with h:%i, w:%i, bpp:%i\n", FreeImage_GetHeight(tiff), 
           FreeImage_GetWidth(tiff), FreeImage_GetBPP(tiff));

    if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start) != 0) {
        printf("Can't get clock\n");
        return 1;
    }

    for (int i = 0; i < LOOPS; i++) {
        sprintf(filename, "test_%s_%03d.jpg", QUOTEME(LIB), i);
        FreeImage_Save(FIF_JPEG, tiff, filename, 95);
        printf("."); fflush(stdout);
    }

    if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &stop) != 0) {
        printf("Can't get clock\n");
        return 1;
    }

    runtime = (stop.tv_sec * 1000 + stop.tv_nsec / 1000000.) - (start.tv_sec * 1000 + start.tv_nsec / 1000000.);

    printf("\ntime: %0.3f msec for %i loops with %s\n", runtime, LOOPS, QUOTEME(LIB));
    return 0;
}
