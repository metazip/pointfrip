## Getting Started
If you use windows, the exe-files start without an additional program. \
But if you are using Linux and **don't** have wine, then install wine: \
Open the terminal-window and type for **Debian 11:**

    sudo dpkg --add-architecture i386
    
    sudo apt-get update && sudo apt install wine32 wine64 -y
For **Linux Mint 20.3** open the terminal-window and type:

    sudo apt-get update
    
    sudo apt-get install wine
Unfortunately, I have no experience with other Linux versions.

Then go to the [installer directory](https://github.com/metazip/pointfrip/tree/main/installer) and choose the installer version for an installation of Pointfrip and download it \
**or** choose the portable version for download, which is extracted with an unzipper and can then be used easily.

In the directory of Pointfrip is the file pointfrip.exe, which can be started by double-clicking and then a window with an event-controlled \
read-eval-print-loop will appear. Function expressions can be entered here and started with return or the triangle button in the toolbar. \ 
If you only want to start a part, you should select the area.

## Some examples
If you want a list of increasing numbers, use the **iota** function with an operator **°** and a real number. Like this:

    iota ° 10
    
    --> (1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ;)

Then you can use the apply-to-all combinator **aa** to square the individual values of the list with **id * id**.

    ((id * id) aa) ° iota ° 10
 
 
