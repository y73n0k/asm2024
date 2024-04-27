#define STBI_ONLY_PNG
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb/stb_image_write.h>

#include <time.h>

extern void flip(char *buffer, int width, int height, int channels);

int main(int argc, char *argv[]) {

    int width, height, channels;
    unsigned char *img;
    int res = 0;

    if (argc != 3) {
        printf("Usage: %s <input_file> <output_file>\n", argv[0]);
        return 1;
    }

    img = stbi_load(argv[1], &width, &height, &channels, 0);
    if (img == NULL) {
        printf("Error while reading from file %s\n", argv[1]);
        return 2;
    }

    clock_t begin = clock();
    flip(img, width, height, channels);
    clock_t end = clock();
    printf("time: %lf\n", (double)(end - begin) / CLOCKS_PER_SEC);

    if (!stbi_write_png(argv[2], width, height, channels, img, width * channels)) {
        printf("Error while writing to file %s", argv[2]);
        res = 3;
    }

    stbi_image_free(img);
    return res;
}
