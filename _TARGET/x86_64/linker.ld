ENTRY(xeravend_start)

SECTIONS
{
	. = 1M;

	.boot :
	{
		KEEP(*(.xeravend_mutliboot_header))
	}

	.text :
	{
		*(.text)
	}
}