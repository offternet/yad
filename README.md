# yad IDE

**Disclaimer:** I am not a programmer by trade. use my software at your own risk. MIT License Applies 2026. Development is still Alpha Design but, usable. I need to make more buttons and associated snippet files, very easy but, there are lot to make. 

 I am not the author of yad, here is his page on Github -- https://github.com/v1cont/yad
            
**yad DnD IDE** - Alpha but, most like the only one being created in the world where its purely yad & bash.

yad-ide-V1.0n is Alpha Framework only utilizing bash (heavily). Using  [yad --notebook (yad --html)] --> DnD --> yad gui --dnd

**Pre-use considerations:**
Please Understand that no one has ever been able to develop a Drag & Drop from yad --html to yad --dnd before now. 

This is alpha example coding with only frame work designed with many included pre-configured buttons in png format and associated yad code snippet files. To test this code You need at least ver 10.x or higher yad gui compiled and installed to your GTK3.22+ machine.

yad compiled executable is only 10MB. yad 10.x+ source: https://github.com/v1cont/yad
Instructions to Compile and Install yad gui: https://github.com/offternet/yad/blob/main/yad-related/compile-yad.txt

Or, use the self contained yad-13.AppImage which (73MB) --> https://github.com/sonic2kk/steamtinkerlaunch-tweaks/releases
Simply copy it to your system  and make yad-13 AppImage executable. chmod +x ./filename.extenstion

**Design and files overview:**
Contained inside the yad-IDE-Ver1.0n file are two scripts. The top script is a yad --dnd (very very large) left dialog and bottom script is for yad --note (very small) right dialog with 12 tabs.

The images and snippet files must have same exact name. images are png format (required) and snippet files have no extension. 

Screen Resolution Detection is used to size the left yad --dnd dialog to 450px and remaining right screen area is occupied by the yad --notebook dialog.

**Installing Script, images / snippet files:**
yad-ide-Ver1.0x can be located anywhere on your computer and must be executable.

create 2 directories: /production  & /production/yad
Give both directories user permissions (not root:root)  cd / | sudo mkdir production | sudo chown -r user:group ./production | cd production | mkdir yad | cd yad

Download v1.02n release: wget -O https://github.com/offternet/yad/releases/download/yad-ide-v1.0n/yad-ide-v1.0n.zip
                         unzip https://github.com/offternet/yad/releases/download/yad-ide-v1.0n/yad-ide-v1.0n.zip
                         
Associated snippet files are located in:
/production/yad/snippets

Associated button image files go in:
/production/yad/buttons

Associated webpages are in:
/production/yad/html

yad gui 10.x+ is recommended to be compiled to your computer because of yad duplicates that are needed in this Alpha version. Desktop must be  GTK3+ system. Additionally, you need 2 copies of the yad executable, yad yad2 yad3 locaded in /usr/local/bin directory. 
The duplicate copies of yad executable allow enhanced dialog window closing in the Alpha Version. 

After installing yad 10.x+ to your machine:  sudo cp /usr/local/bin/yad /usr/local/bin/yad2

---------------------------------
Version 1.0n updates:
As you can see from above, files are now located in different directories for better usability.
Added a Screen Resolution Detection and input form to fine adjust layout to your liking.
Added additional buttons: Author / Help / Screen Config / License / About.
Only the Help button pulls a document from the web, this was done to allow most up to date help.

Code went from 500 to 985 lines in 2 days. 

Screen Resoluton Detection and Manual Adjustment:
Auto Detection will get it close (but depends on your desktop enviroment).
Then you open Screen Config utility from main program and adjust the posx of both windows & bottom of both windows & right window right margin.
When its referred to as "Margin", you add a higher number to compress the windows up. Or, the right Window compressed from right to left making it smaller. 

If you have questons, concerns, suggestions or want to make images and yad option snippet files. Use my contact form here: https://LinDnD.com 

Thanks for taking the time to review my yad IDE project.
RC
