# Compiler
CC = gcc
NVCC = nvcc
LINKER = nvcc
SYSTEM_GXX := $(shell which g++)

SRC_DIR = ./cupdlpx
BUILD_DIR = ./build

# CFLAGS for C compiler (gcc)
CFLAGS = -I. -I$(CUDA_HOME)/include -O3 -Wall -Wextra -g

# NVCCFLAGS for CUDA compiler (nvcc)
NVCCFLAGS = -I. -I$(CUDA_HOME)/include -O3 -g -gencode arch=compute_90,code=sm_90 -gencode arch=compute_80,code=sm_80 -Xcompiler -gdwarf-4 -ccbin $(SYSTEM_GXX)

# LDFLAGS for the linker
LDFLAGS = -L$(CONDA_PREFIX)/lib -L$(CUDA_HOME)/lib64 -lcudart -lcusparse -lcublas -lz -lm

C_SOURCES = $(filter-out $(SRC_DIR)/cupdlpx.c, $(wildcard $(SRC_DIR)/*.c))
CU_SOURCES = $(wildcard $(SRC_DIR)/*.cu)

C_OBJECTS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SOURCES))
CU_OBJECTS = $(patsubst $(SRC_DIR)/%.cu, $(BUILD_DIR)/%.o, $(CU_SOURCES))
OBJECTS = $(C_OBJECTS) $(CU_OBJECTS)

TARGET_LIB = $(BUILD_DIR)/libcupdlpx.a

DEBUG_SRC = $(SRC_DIR)/cupdlpx.c
DEBUG_EXEC = $(BUILD_DIR)/cupdlpx

.PHONY: all clean build

all: $(TARGET_LIB)

$(TARGET_LIB): $(OBJECTS)
	@echo "Archiving objects into $(TARGET_LIB)..."
	@ar rcs $@ $^

build: $(DEBUG_EXEC)
$(DEBUG_EXEC): $(DEBUG_SRC) $(TARGET_LIB)
	@echo "Building debug executable..."
	@$(LINKER) $(NVCCFLAGS) $(DEBUG_SRC) -o $(DEBUG_EXEC) $(TARGET_LIB) $(LDFLAGS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling $< -> $@..."
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cu
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling $< -> $@..."
	@$(NVCC) $(NVCCFLAGS) -c $< -o $@

clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR) $(TARGET_LIB) $(DEBUG_EXEC)