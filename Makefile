CXX           = g++
CXXFLAGS      = -c -g -Wall -O2 -Wnarrowing  -std=c++11
LINK          = g++
LFLAGS        = -g -O2 -v
LIBS          = -lftdi
VPATH         = src
SRC_FILES     = butterfly.c jtag.c iobase.c ioftdi.c bitfile.c tools.c devicedb.c progalgspi.c progalgxc3s.c
OBJ_FILES     = $(patsubst %.c, %.o, $(addprefix $(VPATH)/, $(SRC_FILES)))
DEP_FILES     = $(OBJ_FILES:.o=.d)

fireprog: $(OBJ_FILES)
	$(LINK) $(LFLAGS) $(LIBS) $^ -o $@

$(OBJ_FILES): %.o: %.cpp
	$(CXX) $(CXXFLAGS) -MMD -MF $(patsubst %.o,%.d,$@) -o $@ $<

clean:
	rm -f $(DEP_FILES) $(OBJ_FILES) fireprog

