# AVR Makefile with libs support
# Usage: make PROJECT=folder_name [FLASH=1] [BAUD=115200] [PORT=/dev/tty.usbmodem101] [FILENAME=main.c]

# Default parameters
PROJECT ?=
BAUD ?= 115200
PORT ?= /dev/tty.usbmodem101
FLASH ?= 0
MCU = atmega2560
ENTRY_POINT = main.c

# Validate required PROJECT parameter
ifndef PROJECT
$(error PROJECT parameter is required. Usage: make PROJECT=folder_name)
endif

# Directories
SRC_DIR = $(PROJECT)
LIBS_DIR = libs
BUILD_DIR = build/$(PROJECT)
TARGET_NAME = main

# Files
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
LIB_FILES = $(wildcard $(LIBS_DIR)/*.c)
ALL_SRC_FILES = $(SRC_FILES) $(LIB_FILES)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC_FILES)) \
            $(patsubst $(LIBS_DIR)/%.c,$(BUILD_DIR)/lib_%.o,$(LIB_FILES))
ELF_FILE = $(BUILD_DIR)/$(TARGET_NAME).elf
HEX_FILE = $(BUILD_DIR)/$(TARGET_NAME).hex

# Validate entry point exists
ENTRY_POINT_FILE = $(SRC_DIR)/$(ENTRY_POINT)
ifeq ($(wildcard $(ENTRY_POINT_FILE)),)
$(error Entry point $(ENTRY_POINT_FILE) not found!)
endif

# Compiler settings
CC = avr-gcc
OBJCOPY = avr-objcopy
SIZE = avr-size
PROGRAMMER = avrdude
CFLAGS  = -g -Os -mmcu=$(MCU) -I$(LIBS_DIR) -DF_CPU=16000000L --std=c2x
LDFLAGS = -g -mmcu=$(MCU) -Wl,-u,vfprintf -lprintf_flt -lm
OBJCOPY_FLAGS = -j .text -j .data -O ihex
SIZE_FLAGS = --format=avr --mcu=$(MCU)
AVRDUDE_FLAGS = -v -p $(MCU) -c wiring -P $(PORT) -b $(BAUD) -D

# Default target
.PHONY: all clean flash help
all: $(HEX_FILE) size
ifeq ($(FLASH),1)
	@$(MAKE) flash
endif

# Show discovered source files
.PHONY: list-sources
list-sources:
	@echo "Found source files in $(SRC_DIR):"
	@echo "$(SRC_FILES)"
	@echo "Found library files in $(LIBS_DIR):"
	@echo "$(LIB_FILES)"
	@echo "Object files to build:"
	@echo "$(OBJ_FILES)"

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Compile project source files to objects
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@
	@echo ""

# Compile library source files to objects (with lib_ prefix to avoid conflicts)
$(BUILD_DIR)/lib_%.o: $(LIBS_DIR)/%.c | $(BUILD_DIR)
	@echo "Compiling library $<..."
	$(CC) $(CFLAGS) -c $< -o $@
	@echo ""


# Link all objects to ELF
$(ELF_FILE): $(OBJ_FILES)
	@echo "Linking $(ELF_FILE) with $(words $(OBJ_FILES)) object file(s)..."
	$(CC) $(LDFLAGS) -o $@ $^
	@echo ""


# Convert ELF to HEX
$(HEX_FILE): $(ELF_FILE)
	@echo "Creating hex file $(HEX_FILE)..."
	$(OBJCOPY) $(OBJCOPY_FLAGS) $< $@
	@echo ""


# Show size information
.PHONY: size
size: $(ELF_FILE)
	@echo "Size information:"
	$(SIZE) $(SIZE_FLAGS) $<

# Flash the microcontroller
.PHONY: flash
flash: $(HEX_FILE)
	@echo "Flashing $(HEX_FILE) to $(MCU) via $(PORT) at $(BAUD) baud..."
	$(PROGRAMMER) $(AVRDUDE_FLAGS) -U flash:w:$<:i

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts for $(PROJECT)..."
	@rm -rf $(BUILD_DIR)

# Clean all build artifacts
clean-all:
	@echo "Cleaning all build artifacts..."
	@rm -rf build/

# Help
help:
	@echo "AVR Makefile Usage:"
	@echo ""
	@echo "Required parameters:"
	@echo "  PROJECT=folder_name    - Specify the project folder to build"
	@echo ""
	@echo "Optional parameters:"
	@echo "  FLASH=1               - Flash after building (default: 0)"
	@echo "  BAUD=rate             - Baud rate for flashing (default: 115200)"
	@echo "  PORT=device           - USB modem device (default: /dev/tty.usbmodem101)"
	@echo ""
	@echo "Project Structure:"
	@echo "  - All .c files in PROJECT/ folder will be compiled and linked"
	@echo "  - All .c files in libs/ folder will be compiled and linked"
	@echo "  - libs/ directory headers are automatically included (-I libs)"
	@echo "  - main.c must exist as the entry point in PROJECT/ folder"
	@echo "  - Build artifacts stored in build/PROJECT/"
	@echo ""
	@echo "Examples:"
	@echo "  make PROJECT=my_project"
	@echo "  make PROJECT=my_project FLASH=1"
	@echo "  make PROJECT=my_project flash"
	@echo "  make PROJECT=my_project BAUD=57600 PORT=/dev/ttyUSB0 flash"
	@echo ""
	@echo "Targets:"
	@echo "  all           - Build the project (default)"
	@echo "  flash         - Flash the hex file to microcontroller"
	@echo "  monitor       - Start an interactive serial monitor"
	@echo "  size          - Show size information"
	@echo "  list-sources  - Show discovered source files"
	@echo "  clean         - Clean build artifacts for current project"
	@echo "  clean-all     - Clean all build artifacts"
	@echo "  help          - Show this help"

# Ensure source files exist
$(SRC_FILES):
	@if [ ! -f "$@" ]; then \
		echo "Error: Source file $@ not found!"; \
		exit 1; \
	fi

.PHONY: monitor
monitor:
	tio $(PORT) -b $(BAUD)
