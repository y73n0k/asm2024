void flip(char *buffer, int width, int height, int channels, char *new_iamge) {
    int index = 0, opposite_index;
    for (int row = 0; row < height / 2 + 1; ++row) {
        for (int column = 0; column < width; ++column) {
            opposite_index = ((height - 1 - row) * width + column) * channels;
            for (int i = 0; i < channels; ++i) {
                new_iamge[opposite_index] = buffer[index];
                new_iamge[index] = buffer[opposite_index];
                ++index;
                ++opposite_index;
            }
        }
    }
}
