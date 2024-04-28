void flip(char *buffer, int width, int height, int channels) {
    char t;
    int index = 0, opposite_index;
    for (int row = 0; row < height / 2; ++row) {
        for (int column = 0; column < width; ++column) {
            opposite_index = ((height - 1 - row) * width + column) * channels;
            for (int i = 0; i < channels; ++i) {
                t = buffer[index];
                buffer[index] = buffer[opposite_index];
                buffer[opposite_index] = t;
                ++index;
                ++opposite_index;
            }
        }
    }
}
