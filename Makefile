CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++20

SRC_DIR := src
BUILD_DIR := build

SRC := $(wildcard $(SRC_DIR)/*.cpp)
OBJ := $(patsubst $(SRC_DIR)/%.cpp,%.o,$(SRC))

TARGET := $(BUILD_DIR)/app

all: $(TARGET)

$(TARGET): $(OBJ)
	mkdir -p $(BUILD_DIR)
	$(CXX) $(OBJ) -o $@

%.o: $(SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f *.o
	rm -rf $(BUILD_DIR)

run: all
	./$(TARGET)

.PHONY: all clean run
