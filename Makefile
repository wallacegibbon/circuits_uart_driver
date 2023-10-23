BUILD_DIR = build
TARGET = circuits_uart

C_SOURCE_FILES += $(wildcard ./*.c)
C_SOURCE_FILES += $(wildcard ./ei_copy/*.c)
OBJECTS += $(addprefix $(BUILD_DIR)/, $(notdir $(C_SOURCE_FILES:.c=.c.o)))

C_INCLUDES += ./ ./ei_copy

C_FLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
C_FLAGS += -std=c99 -D_GNU_SOURCE
C_FLAGS += $(addprefix -I, $(C_INCLUDES)) -MMD -MP -MF"$(@:%.o=%.d)"
#C_FLAGS += -DDEBUG

LD_FLAGS +=
ifeq ($(OS),Windows_NT)
C_FLAGS += -DUNICODE
LD_FLAGS += -lSetupapi -lCfgmgr32 -static
endif

CC = gcc

vpath %.c $(sort $(dir $(C_SOURCE_FILES)))

.PHONY: all clean

all: $(BUILD_DIR)/$(TARGET)

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)
	$(CC) -o $@ -c $< $(C_FLAGS)

$(BUILD_DIR)/$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^ $(LD_FLAGS)

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf build

-include $(OBJECTS:.o=.d)
