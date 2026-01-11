# Purdue ECET 179 Makefile and Build System

ECET 179 at Purdue University gives instruction for using AVR Studio, a Windows
only IDE for AVR Microcontrollers. Because of this I created a custom Makefile
that is tailored to having a few shared libraries with new weekly projects.
Created in Fall 2025 semester.

> Note: This will require terminal understanding and some tinkering. If you do
> not want to do this and cannot use AVR Studio on your personal computer,
> please use AVR Studio on the lab computers. I am not responsible for any work
> that doesn't get done because of this Makefile. Use at your own risk.

## Contact

While I am not responsible for any issues that occur, I would still be very
willing to help debug and fix any issues people find. I am able to be reached by
email at `yoder177@purdue.edu` or on discord at `qyvo`. Shoot me a message and I
would love to help!

## Installing Prerequisites

This Makefile depends on some AVR tools that need to be installed

On MacOS, make sure you have [homebrew](https://brew.sh/) installed and then run
the following:

```sh
brew tap osx-cross/avr
brew install avr-gcc avr-binutils avrdude tio
```

On Linux, install `avr-gcc`, `acr-binutils`, `avrdude`, and `tio` (optional:
only needed if you want serial monitor) on your distribution of choice.

## Usage

### Folder Structure

This Makefile expects a folder structure with libraries used in multiple labs in
the `libs` folder and then each lab having its own folder with a `main.c` file
in it which contains an `int main()` function. Here is an
example folder structure:

```
├── lab0
│   └── main.c
├── lab1
│   └── main.c
├── libs
│   ├── library_a.c
│   ├── library_a.h
│   ├── library_b.c
│   └── library_b.h
└── Makefile
```

> Note: Libraries in class were provided as a single c file. This means that you
> must split these files up yourself. See the section titled "Splitting Into C
> and H Files"

### Parameters

When using the Makefile, you will need to provide the upload port of the device.
This will in all likelihood be in `/dev`. On MacOS it will look like
`/dev/tty.usbmodem101` where the number might be different. On Linux it will
likely look like `/dev/ttyACM0`. Run `ls /dev/tty*` and look for something
similar. You will also need to provide the folder that you have code in. In
these examples, it is named `lab0` but the folder could be named anything. An
example command on a MacOS machine where you want to build the code in `lab0`
would look like this:

```sh
make PROJECT=lab0 PORT=/dev/tty.usbmodem101
```

> Tip: You can change the default port by editing the Makefile. You will then
> not need to specify a port when running commands

### Flashing/Uploading

To upload to the board, you append `flash` to the end of your command. This will
upload it to the board immediately running your code. Example:

```sh
make PROJECT=lab0 PORT=/dev/tty.usbmodem101 flash
```

### Serial Monitoring

Any Serial Monitor will work to monitor. This means you can use the Arduino
Serial Monitor, the VSCode Serial Monitor, `pio device monitor`, or anything
else you want. However, if you just want to be able to monitor using the
makefile, that is an option. Just replace `flash` with `monitor` and it will use
`tio` to monitor in your terminal. To quit, press **Ctrl-T** then press **Q**.
and it will go back to the terminal.

```sh
make PROJECT=lab0 PORT=/dev/tty.usbmodem101 monitor
```

> Note: In order to see your `printf` statements in the serial monitor, you will
> need to use the serial library provided in class.

### Help

You are able to run the command with `help` in order to view terminal help.


```sh
make PROJECT=lab0 PORT=/dev/tty.usbmodem101 help
```

## Misc

### Splitting Into C and H Files

Because class provided libraries are in single c files, you will need to take
that file and split it into an c file and a header/h file.

```c
// Included Libraries
#include <stdint.h>
#include <avr/io.h>

// Define Statements
#define COOL_NUMBER 6

// Function Declarations (where we tell it that the function exists)
uint32_t add_cool_number(uint32_t num);

// Function Definitions (where we tell it what the function does)
uint32_t add_cool_number(uint32_t num) {
    uint32_t new_num = num + COOL_NUMBER;
    return new_num;
}
```

Given the following c file, we can split this up pretty easily. We are able to
make a c file with the include statements (adding an include of `library_a.h`) and
the function definition. In the h file we will put the included libraries, the
define statements, and the function declarations.

**`library_a.c`:**

```c
// Included Libraries
#include <stdint.h>
#include <avr/io.h>

// NEW LINE
#include "library_a.h"

// Function Definitions (where we tell it what the function does)
uint32_t add_cool_number(uint32_t num) {
    uint32_t new_num = num + COOL_NUMBER;
    return new_num;
}
```

**`library_a.h`:**

```c
#ifndef LIBRARY_A_H
#define LIBRARY_A_H

// Included Libraries
#include <stdint.h>
#include <avr/io.h>

// Define Statements
#define COOL_NUMBER 6

// Function Declarations (where we tell it that the function exists)
uint32_t add_cool_number(uint32_t num);

#endif
```

If you notice the top 2 and bottom lines in the h file are new. This is a header
guard. Make sure you include this in your h file and change the name on the
first two lines to be the name of the file in all uppercase with no periods. If
you are confused, I recommend watching [this
video](https://www.youtube.com/watch?v=tOQZlD-0Scc).

### The `.clangd` File

I do my editing in Neovim and use `clangd` as my lsp. In order to get it to
work, I created a `.clangd` file to give it the includes it needs. I just gave
it a hard path to where my `avr-gcc` files were so this will need to be edited
to fit your machine. I don't know if this is required for editors like VSCode
but I suspect it is.

