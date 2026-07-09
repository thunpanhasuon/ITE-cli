ZIG ?= zig

TARGET := zig-out/bin/utils

all: $(TARGET)

$(TARGET): build.zig build.zig.zon main.cpp src/utils.zig
	$(ZIG) build

clean:
	rm -f *.o
	rm -rf build .zig-cache zig-out

run: all
	./$(TARGET)

.PHONY: all clean run
