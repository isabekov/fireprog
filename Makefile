GCC           = gcc -I.
DEFINES       =
CPPFLAGS      = -g -Wall -O2
INCPATH       = 
LINK          = g++ -static
LFLAGS        = -g -O2
LIBS          = -L. -lftdi -lusb

fpgaprog: butterfly.o jtag.o iobase.o ioftdi.o bitfile.o tools.o devicedb.o progalgspi.o progalgxc3s.o
	$(LINK) $^ -o $@ $(LIBS)

butterfly.o: butterfly.cpp io_exception.h jtag.h ioftdi.h devicedb.h progalgxc3s.h progalgspi.h bitfile.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o butterfly.o butterfly.cpp
  
bitfile.o: bitfile.cpp bitfile.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o bitfile.o bitfile.cpp

ioftdi.o: ioftdi.cpp ioftdi.h io_exception.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o ioftdi.o ioftdi.cpp

jtag.o: jtag.cpp jtag.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o jtag.o jtag.cpp

iobase.o: iobase.cpp iobase.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o iobase.o iobase.cpp

devicedb.o: devicedb.cpp devicedb.h devlist.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o devicedb.o devicedb.cpp

tools.o: tools.cpp tools.h config.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o tools.o tools.cpp

progalgxc3s.o: progalgxc3s.cpp progalgxc3s.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o progalgxc3s.o progalgxc3s.cpp

progalgspi.o: progalgspi.cpp progalgspi.h config.h
	$(GCC) -c $(CPPFLAGS) $(INCPATH) -o progalgspi.o progalgspi.cpp

clean:
	rm -rf *.o *.exe
