ENTRY(xeravend_start)

SECTIONS
{
	. = 2M;

	.boot :
	{
		KEEP(*(.xeravend_mutliboot_header))
	}

	.text :
	{
		*(.text)
	}

	.rodata :
	{
		*(.rodata)
	}

	.data :
	{
		*(.data)
	}

	.bss :
	{
		_bss_start = .;
		*(COMMON)
		*(.bss)
		_bss_end = .;
	}
}
