HDL_LEXER	:= hdl_lex.cpp
HDL_GRAMMAR	:= hdl.cpp
HDL_TOKENS	:= tokens.h

PRJ_TREE_SRC	:= hdl_tree.cpp
PRJ_TREE_HDR	:= hdl_tree.h

TARGET  := hdl
SRCS    := ${PRJ_TREE_SRC} ${HDL_GRAMMAR} ${HDL_LEXER} main.cpp
OBJS    := ${SRCS:.cpp=.o}

CCFLAGS = -g
LDFLAGS = 
LIBS    = 

.PHONY: all clean

all:: ${TARGET} 

${TARGET}: ${OBJS} 
	${CXX} ${LDFLAGS} -o $@ $^ ${LIBS} 

${OBJS}: %.o: %.cpp
	${CXX} ${CCFLAGS} -o $@ -c $<

${PRJ_TREE_SRC} ${PRJ_TREE_HDR}: hdl.tc
	treecc -o ${PRJ_TREE_SRC} -h ${PRJ_TREE_HDR} $<

${HDL_LEXER}: hdl.l
	flex -o $@ $<

${HDL_GRAMMAR} ${HDL_TOKENS}: hdl.y
	bison --defines=${HDL_TOKENS} -r all -o ${HDL_GRAMMAR} $<

clean:: 
	-rm -f *~ *.o ${TARGET} ${PRJ_TREE_SRC} ${PRJ_TREE_HDR} ${HDL_LEXER} ${HDL_GRAMMAR} ${HDL_TOKENS} *.output
