#Main Xeravend Make Files

.PHONY: __BUILD_ALL __CLEAR_ALL

#Build The Entire Operating System From All Makefiles
__BUILD_ALL:

#Clear All Compile Output Files & Other Nesseary Files + Folders
__CLEAR_ALL:



#x86_64_asm_source_files := $(shell find src/kernel/ -name '*.asm')
#x86_64_asm_object_files := $(patsubst src/kernel/%.asm, _OUTPUT/%.o, $(x86_64_asm_source_files))

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
