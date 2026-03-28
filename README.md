# yad IDE

**Disclaimer:** I am not a programmer by trade. use my software at your own risk. MIT License Applies 2026. Development is still Alpha Design but, usable. Just make more buttons and associated snippet files, very east.

 I am not the author of yad, here is his page on Github -- https://github.com/v1cont/yad.
            
**yad DnD IDE** - Alpha but, only one being created in the world where its purely yad & bash.

yad-ide-V1.0j is Alpha Framework only utilizing bash (heavily) and yad gui --dnd & yad --notebook.

**Pre-use considerations:**
Please Understand that no one has ever been able to develop a Drag & Drop from yad --html to yad --dnd before now. 

This is alpha example coding with only frame work designed with several included pre-configured buttons in png format and associated yad code snippet files. To test this code You need at least ver 10.x or higher yad gui which is compatible with GTK3 Desktop Environment. Or, use the yad-13.AppImage which is 72MB. ysd compiled executable is only 10MB.

**Design and files overview:**
Contained in the yad-IDE-Ver1.0a file are two separate scripts. The top script is a yad --notebook (very small) left dialog and bottom script is for yad --dnd (very large) right dialog. 

The images and snippet files have same exact name. images are png format (required) and snippet files have no extension. 

Screen Resolution Detection is used to size the right yad --dnd dialog to 450px and remaining left screen area is occupied by the yad --notebook dialog.

**Installing Script, images / snippet files:**
yad-ide-Ver1.0x can be located anywhere on your computer and must be executable.

Associated snippet files are located in:
/production/yad

Associated button image files go in:
/production/yad/buttons

yad gui 10.x+ is recommended to be compiled to your computer because of yad duplicates that are needed in this Alpha version. Desktop must be  GTK3+ system. Additionally, you need 3 copies of the yad executable, yad yad2 yad3 locaded in /usr/local/bin directory. 

/usr/local/bin/yad
/usr/local/bin/yad2
/usr/local/bin/yad3

The duplicate copies of yad executable allow enhanced dialog window closing in the Alpha Version. 

**To do**
link to yad source
Debian compiling instructions 
link to yad-13-AppImage
