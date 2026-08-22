#Xeravend Kernel Makefile

#DEFINE FOLDER & FILE PATHS
_OUTPUT_DIR := /_OUTPUT

x86_64_asm_source_files := $(shell find -name '*.asm')
x86_64_asm_object_files := $(patsubst src/Kernel/%.asm, _OUTPUT/%.o, $(x86_64_asm_source_files))

_OUTPUT/%.o: src/Kernel/%.asm
	mkdir -p $(dir $@)
	nasm -f elf64 $< -o $@

.PHONY: __BUILD_Kernel __CLEAR_Kernel __DEBUG_Makefile

#Build Xeravend Kernel
__BUILD_Kernel:  $(x86_64_asm_object_files)
	mkdir -p dist/x86_64
	x86_64-elf-ld -n -o dist/x86_64/kernel.bin \
		-T ../../_TARGET/x86_64/linker.ld \
		build/x86_64/boot/main.o \
		$(filter-out build/x86_64/boot/main.o,$(x86_64_asm_object_files))
	cp dist/x86_64/kernel.bin Targets/x86_64/iso/boot/kernel.bin
	grub-mkrescue -o dist/x86_64/kernel.iso Targets/x86_64/iso

#Clear All Compile Output Files & Other Nesseary Files + Folders
__CLEAR_Kernel:

#Used To Do Testing Makefile Configs
__DEBUG_Makefile:
	@echo "The full path is: $(_OUTPUT_DIR)"

#build/x86_64/%.o: src/kernel/x86_64/%.asm
#	mkdir -p $(dir $@)
#	nasm -f elf64 $< -o $@
#
#.PHONY: build-x86_64
#build-x86_64: $(x86_64_asm_object_files)
#	mkdir -p dist/x86_64
#	x86_64-elf-ld -n -o dist/x86_64/kernel.bin \
#		-T targets/x86_64/linker.ld \
#		build/x86_64/boot/main.o \
#		$(filter-out build/x86_64/boot/main.o,$(x86_64_asm_object_files))
#	cp dist/x86_64/kernel.bin Targets/x86_64/iso/boot/kernel.bin
#	grub-mkrescue -o dist/x86_64/kernel.iso Targets/x86_64/iso