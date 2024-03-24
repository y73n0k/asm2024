AS = /usr/bin/nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

BUILD_DIR = build
SRCS = lab.s
OBJS = $(BUILD_DIR)/$(SRCS:.s=.o)

EXE = $(BUILD_DIR)/lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(BUILD_DIR)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(OBJS):
	mkdir build
	$(AS) $(ASFLAGS) $(SRCS) -o $@