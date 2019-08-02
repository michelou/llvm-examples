CXX=g++
PROGRAM_NAME = program

all: build

build:
	$(CXX) -g -O3 main.cpp `llvm-config --cxxflags --ldflags --system-libs --libs core` -o main

executable: build
	./main
	llc -filetype=obj $(PROGRAM_NAME).ll -o $(PROGRAM_NAME).o
	gcc $(PROGRAM_NAME).o -o $(PROGRAM_NAME)
	echo "'$(PROGRAM_NAME)' created!"

run: executable
	./$(PROGRAM_NAME)

clean:
	rm -f main
	rm -rf main.dSYM
	rm -f $(PROGRAM_NAME).ll
	rm -f $(PROGRAM_NAME).o
	rm -f $(PROGRAM_NAME) 
