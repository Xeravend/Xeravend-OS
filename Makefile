#Main Xeravend Make Files

asm_src_files := $(shell find src -name '*.asm')
asm_obj_files := $(patsubst src/%.asm, _OUTPUT/_OBJ/%.o, $(asm_src_files))

$(asm_obj_files): _OUTPUT/_OBJ/%.o : src/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst _OUTPUT/_OBJ/%.o, src/%.asm, $@) -o $@

.PHONY: __BUILD_ALL __CLEAR_ALL __BUILD_COMPILE

#Build The Entire Operating System From All Makefiles
__BUILD_ALL: $(asm_obj_files)
	x86_64-elf-ld -n -o _OUTPUT/_BUILD/kernel.bin -T _TARGET/x86_64/linker.ld $(asm_obj_files)
	cp _OUTPUT/_BUILD/kernel.bin _TARGET/x86_64/iso/boot/kernel.bin
	grub-mkrescue -o _OUTPUT/_DIST/Xeravend.iso _TARGET/x86_64/iso

#Clear All Compile Output Files & Other Nesseary Files + Folders
__CLEAR_ALL:
	rm -r _OUTPUT 

#Build Compile Directory
__BUILD_COMPILE:
	mkdir -p _OUTPUT
#For Object Compile Files
	mkdir -p _OUTPUT/_OBJ 
#For Compiled Files Stored
	mkdir -p _OUTPUT/_BUILD
#Used For Distribution
	mkdir -p _OUTPUT/_DIST 
