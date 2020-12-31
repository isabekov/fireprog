# fireprog: a Xilinx Spartan 3 configuration software
Fireprog is a utility which can program Xilinx Spartan 3 FPGAs via FT232H-based USB-to-JTAG adapter.
It is based on *fpgaprog*, *Papilio-Prog*, *xc3sprog* to which support for Micron M25PE10 SPI flash was added.
Fireprog is used to configure Prometheus FPGA boards.

Copyleft (C) Altynbek Isabekov, Onurhan Öztürk

License:  GNU General Public License v2

![Prometheus FPGA](http://www.isabekov.pro/prometheus-fpga/static/img/Prometheus_FPGA_Board.jpg "Prometheus FPGA")

### Table of Contents

- [Usage](#usage)
- [Compilation on Linux](#compilation-on-linux)
- [Cross-compilation on Linux for Windows](#cross-compilation-on-linux-for-windows)
- [Cross-compilation on Linux for MacOS](#cross-compilation-on-linux-for-macos)
    - [using official libftd2xx library](#cross-compilation-on-linux-for-macos-using-official-libftd2xx-library)
    - [using libftdi and libusb libraries](#cross-compilation-on-linux-for-macos-using-libftdi-and-libusb-libraries)


## Usage

In order to program the Prometheus board, plug it in the USB port, Windows OS should recognize it as a USB-to-Serial (RS232) converter and associate it with the libftd2xx driver.
Now you can run "fireprog.exe" from the command line and supply the configuration bit-file.

Configuring FPGA with a bit-stream Circuit.bit:

    ./fireprog -v -f Circuit.bit

Configuring SPI Flash memory with a bit-stream Circuit.bit (mediator bscan_spi.bit is required):

    ./fireprog -v -f Circuit.bit -b bscan_spi.bit -r

The last switch "-r" triggers reconfiguration of the FPGA.

On Windows, command options are exactly the same:

![FPGA](Screenshots/fireprog_uploading_fpga.png "Configuring FPGA with a bit-stream")
![FLASH](Screenshots/fireprog_uploading_flash.png "Configuring SPI flash with a bit-stream")

## Compilation on Linux

To compile on Linux, install *libusb* and *libftdi* first and then run *make*:

	sudo pacman -S libusb libftdi
	make clean
	make

The resulting ELF binary "fireprog" will be linked with libusb and libftdi.

## Cross-compilation on Linux for Windows

In order to cross-compile on Linux for Windows, firstly install MinGW-w64 cross-compiler:

    sudo pacman -S mingw-w64-gcc mingw-w64-headers mingw-w64-binutils mingw-w64-winpthreads mingw-w64-crt


Then download the x64 version of the "CDM v2.12.24 WHQL Certified.zip" driver
from http://www.ftdichip.com/Drivers/D2XX.htm and unzip it into "libftd2xx" folder, which is at the same hierarchy level as "fireprog".

	├── fireprog
	│   ├── Makefile
	│   ├── ...
	│   ├── Makefile.MinGW64Static
	│   ├── README.md
	│   ├── Screenshots
	│   └── src
	│       ├── bitfile.cpp
	│       ├── bitfile.h
	│       ├── ...
	│       ├── tools.cpp
	│       └── tools.h
	│
	├── libftd2xx
	│   ├── amd64
	│   ├── ftd2xx.h
	│   ├── ftdibus.cat
	│   ├── ftdibus.inf
	│   ├── ftdiport.cat
	│   ├── ftdiport.inf
	│   ├── i386
	└── └── Static

The linker will use "../libftd2xx" folder (see the Make files). Modify the Make files to change the cross-compiler location (default is /usr/bin/i686-w64-mingw32-*).

After unzipping the libftd2xx driver, you can cross-compile on Linux for Windows (yields "fireprog.exe", which is a PE32 or PE32+ executable).
Depending on the architecture and linking type, one of the following commands should be executed:

	make -f Makefile.MinGW32Static clean
	make -f Makefile.MinGW32Static

	make -f Makefile.MinGW32Dynamic clean
	make -f Makefile.MinGW32Dynamic

	make -f Makefile.MinGW64Static clean
	make -f Makefile.MinGW64Static

	make -f Makefile.MinGW64Dynamic clean
	make -f Makefile.MinGW64Dynamic

Dynamically linked executables require some libraries from the MinGW cross-compiler. Putting these libraries in the same folder where "fireprog.exe" resides, allows execution without errors, e.g.:

	fireprog-win32-dynamic
	├── fireprog.exe
	├── libgcc_s_sjlj-1.dll
	├── libstdc++-6.dll
	└── libwinpthread-1.dll

	fireprog-win64-dynamic
	├── fireprog.exe
	├── libgcc_s_seh-1.dll
	├── libstdc++-6.dll
	└── libwinpthread-1.dll


## Cross-compilation on Linux for MacOS
Install OSXCross toolchain from source to an easily accessable directory (e.g. "/opt"):

    # Make the directory readable and writable to the user first
    sudo chown -R $(whoami):users /opt
    sudo chmod 755 $(whoami):users /opt
    cd /opt
    git clone https://github.com/tpoechtrager/osxcross

Pack the SDK on MacOS on a real Apple computer and put the packed achive "MacOSX10.11.sdk.tar.xz" to "/opt/osxcross/tarballs".
In this example, the MacOS cross-compiler is built for **OS X 10.11 El Capitan**, *Darwin version 15*.
Check compatibility between SDK versions and corresponding targets in:

    /opt/osxcross/tools/osxcross-macports

If *clang* compiler is already installed, there is no need to build it. If not, then proceed as described in

    /opt/osxcross/README.md

To build the cross toolchain (using *clang*), run:

    cd /opt/osxcross
    ./build.sh

Then build GCC:

    ./build_gcc.sh

Add OSXCross binary directory to the $PATH environment variable:

    export PATH=$PATH:/opt/osxcross/target/bin

Check the cross-compiler:

    x86_64-apple-darwin15-gcc -v
      Using built-in specs.
      COLLECT_GCC=x86_64-apple-darwin15-gcc
      COLLECT_LTO_WRAPPER=/opt/osxcross/target/bin/../libexec/gcc/x86_64-apple-darwin15/9.2.0/lto-wrapper
      Target: x86_64-apple-darwin15
      Configured with: ../configure --target=x86_64-apple-darwin15 --with-sysroot=/opt/osxcross/target/bin/../SDK/MacOSX10.11.sdk --disable-nls --enable-languages=c,c++,objc,obj-c++ --without-headers --enable-lto --enable-checking=release --disable-libstdcxx-pch --prefix=/opt/osxcross/target/bin/.. --with-system-zlib --with-ld=/opt/osxcross/target/bin/../bin/x86_64-apple-darwin15-ld --with-as=/opt/osxcross/target/bin/../bin/x86_64-apple-darwin15-as --with-multilib-list=m32,m64 --enable-multilib
      Thread model: posix
      gcc version 9.2.0 (GCC)

### Cross-compilation on Linux for MacOS using official libftd2xx library
Once the toolchain is ready, download and unpack FTD2XX drivers for MacOS:

    cd <path of the "fireprog" repository>
    # Change one directory up (important!)
    cd ..
    mkdir libftd2xx
    cd libftd2xx
    wget -vc https://www.ftdichip.com/Drivers/D2XX/MacOSX/D2XX1.4.16.dmg
    # Unpack archive using p7zip
    7z x D2XX1.4.16.dmg release/D2XX
    mv release/D2XX .

Rename the shared library file so that its name does not start with "lib":

    mv D2XX/libftd2xx.1.4.16.dylib D2XX/backup_libftd2xx.1.4.16.dylib
    cd ..

This is needed to **enforce static linking**, so that static library *libftd2xx.a* instead of *libftd2xx.1.4.16.dylib* is used by the linker.

The hierarchy of the folders should look like this:

	├── fireprog
	│   ├── Makefile
	│   ├── ...
	│   ├── Makefile.MinGW64Static
	│   ├── README.md
	│   ├── Screenshots
	│   └── src
	│       ├── bitfile.cpp
	│       ├── bitfile.h
	│       ├── ...
	│       ├── tools.cpp
	│       └── tools.h
	│
	├── libftd2xx
	│   ├── D2XX
	│   │   ├── ftd2xx.cfg
	│   │   ├── ftd2xx.h
	│   │   ├── backup_libftd2xx.1.4.16.dylib
	│   │   ├── libftd2xx.a
	│   │   ├── libusb
	│   │   ├── Object
	│   │   ├── Samples
	│   │   └── WinTypes.h
	└── └── D2XX1.4.16.dmg

The corresponding Makefile is written according to this directory structure.

Now compile the "fireprog":

    cd <path of the fireprog repository>
    make -f Makefile.MacOS_libftd2xx

Check the output binary:

    file fireprog
      fireprog: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|WEAK_DEFINES|BINDS_TO_WEAK|PIE>

The output executable should be statically linked with no dynamic dependencies such as FT2XX:

    x86_64-apple-darwin15-otool -L fireprog
	fireprog:
		/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
		/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit (compatibility version 1.0.0, current version 275.0.0)
		/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1253.0.0)
		/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1225.1.1)

### Cross-compilation on Linux for MacOS using libftdi and libusb libraries
Download and unpack *libusb* library:

    cd <path of the "fireprog" repository>
    # Change one directory up (important!)
    cd ..
    wget -vc https://github.com/libusb/libusb/releases/download/v1.0.23/libusb-1.0.23.tar.bz2
     # Unpack archive
    tar -xvf libusb-1.0.23.tar.bz2

Create a local installation directory:

    cd libusb-1.0.23
    mkdir prefix
    cd ..

Configure the build environment, compile and install the library locally:

    ./configure --host=x86_64-apple-darwin15 --prefix="$(pwd)/prefix" CC=x86_64-apple-darwin15-clang
    make
    make install

Check for newly created library files:

    tree ./prefix/
    ./prefix
    ├── include
    │   └── libusb-1.0
    │       └── libusb.h
    └── lib
        ├── libusb-1.0.0.dylib
        ├── libusb-1.0.a
        ├── libusb-1.0.dylib -> libusb-1.0.0.dylib
        ├── libusb-1.0.la
        └── pkgconfig
            └── libusb-1.0.pc

Rename the shared library files so that their names do not start with "lib":

    mv ./prefix/lib/libusb-1.0.0.dylib ./prefix/lib/backup_libusb-1.0.0.dylib
    mv ./prefix/lib/libusb-1.0.dylib ./prefix/lib/backup_libusb-1.0.dylib

This is needed to **enforce static linking**, so that static library *libusb-1.0.a* instead of *libusb-1.0.dylib* is used by the linker.

Download and unpack *libftdi* library:

    cd <path of the "fireprog" repository>
    # Change one directory up (important!)
    cd ..
    wget -vc https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.5.tar.bz2
     # Unpack archive
    tar -xvf libftdi1-1.5.tar.bz2
    cd libftdi1-1.5

There are only two files which need to be compiled, configuring CMake to support cross-compilation is more difficult than compiling these two files.

In order to create header *ftdi_version_i.h* from template *ftdi_version_i.h.in* manually, one needs to learn the versions of the library:

    MAJOR_VERSION=`grep -P -o "(?<=set\(MAJOR_VERSION)\s*\d+(?=\))" CMakeLists.txt`
    echo ${MAJOR_VERSION}
      1

    MINOR_VERSION=`grep -P -o "(?<=set\(MINOR_VERSION)\s*\d+(?=\))" CMakeLists.txt`
    echo ${MINOR_VERSION}
      5

    grep -P -o "(?<=set\(VERSION_STRING)\s*.+(?=\))" CMakeLists.txt
       ${MAJOR_VERSION}.${MINOR_VERSION}

    VERSION_STRING_TEMPLATE=`grep -P -o "(?<=set\(VERSION_STRING)\s*.+(?=\))" CMakeLists.txt`
    VERSION_STRING=$(eval echo ${VERSION_STRING_TEMPLATE}|sed "s/\s//g")
    echo $VERSION_STRING
     1.5

After setting MAJOR_VERSION, MINOR_VERSION, VERSION_STRING environment variables, create *ftdi_version_i.h* from the template:

    cd src
    sed "s/@MAJOR_VERSION@/${MAJOR_VERSION}/g" ftdi_version_i.h.in > ftdi_version_i.h
    sed -i "s/@MINOR_VERSION@/${MINOR_VERSION}/g" ftdi_version_i.h
    sed -i "s/@VERSION_STRING@/${VERSION_STRING}/g" ftdi_version_i.h
    sed -i "s/@SNAPSHOT_VERSION@/unknown/g" ftdi_version_i.h

Compile files:

    x86_64-apple-darwin15-g++ -c ftdi.c -o ftdi.o -I ../../libusb-1.0.23/libusb/ -I .
    x86_64-apple-darwin15-g++ -c ftdi_stream.c -o ftdi_stream.o -I ../../libusb-1.0.23/libusb/ -I . -Wno-narrowing -fpermissive

Bind object files into a static library:

    x86_64-apple-darwin15-libtool -static ftdi.o ftdi_stream.o -o libftdi1.a

The corresponding Makefile is written according to this directory structure:

	├── fireprog
	├── libftdi1-1.5
	└── libusb-1.0.23

Now compile the "fireprog":

    cd <path of the fireprog repository>
    make -f Makefile.MacOS_libftdi

Check the output binary:

    file fireprog
      fireprog: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|WEAK_DEFINES|BINDS_TO_WEAK|PIE>

The output executable should be statically linked with no dynamic dependencies such as libftdi or libusb:

    x86_64-apple-darwin15-otool -L fireprog
	fireprog:
		/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
		/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit (compatibility version 1.0.0, current version 275.0.0)
		/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1253.0.0)
		/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1225.1.1)
