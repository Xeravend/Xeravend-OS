//Xeravend Main C Kernel Enrty Point

//Kernel Main Start Function
void xkmain() {
    char* video_memory = (char*) 0xb8000;
    *video_memory = 'X';
}