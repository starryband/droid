# Compilers and Tools
CC = x86_64-elf-gcc
AS = nasm
LD = x86_64-elf-ld
GRUB_MKRESCUE = grub-mkrescue

# Directories
SRC_DIR = src
KERNEL_DIR = $(SRC_DIR)/kernel
BIN_DIR = bin
BUILD_DIR = build
ISO_DIR = $(BUILD_DIR)/isofiles

# Files
BOOT_SRC = $(SRC_DIR)/boot.asm
LINKER_SCRIPT = linker.ld
KERNEL_BIN = $(BIN_DIR)/droid_os.bin
ISO_OUT = $(BIN_DIR)/droid_os.iso

# Flags
ASFLAGS = -f elf64
CFLAGS = -ffreestanding -mcmodel=kernel -mno-red-zone -m64 -g -nostdlib -I$(SRC_DIR)/include
LDFLAGS = -T $(LINKER_SCRIPT) -m elf_x86_64

# Automatically find all C sources in kernel/
C_SRCS := $(wildcard $(KERNEL_DIR)/*.c)
C_OBJS := $(patsubst $(KERNEL_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SRCS))

# Default target
.PHONY: all clean run
all: $(ISO_OUT)

# 1. Compile Assembly
$(BUILD_DIR)/boot.o: $(BOOT_SRC)
	@mkdir -p $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@

# 2. Compile all C sources
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# 3. Link Kernel Binary
$(KERNEL_BIN): $(BUILD_DIR)/boot.o $(C_OBJS)
	@mkdir -p $(BIN_DIR)
	$(LD) $(LDFLAGS) -o $@ $^

# 4. Create Bootable ISO
$(ISO_OUT): $(KERNEL_BIN)
	@mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_BIN) $(ISO_DIR)/boot/
	@echo 'set timeout=0' > $(ISO_DIR)/boot/grub/grub.cfg
	@echo 'set default=0' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo 'menuentry "Droid OS" {' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '  multiboot2 /boot/droid_os.bin' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '  boot' >> $(ISO_DIR)/boot/grub/grub.cfg
	@echo '}' >> $(ISO_DIR)/boot/grub/grub.cfg
	$(GRUB_MKRESCUE) -o $(ISO_OUT) $(ISO_DIR)

# Utility: Run in QEMU
run: $(ISO_OUT)
	qemu-system-x86_64 -cdrom $(ISO_OUT)

# Clean build
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
