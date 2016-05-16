LDLIBS=-ll -ly

hoc-reverse-polish-notation:	hoc-reverse-polish-notation.y
	yacc -d hoc-reverse-polish-notation.y
	mv -f y.tab.c hoc-reverse-polish-notation.c
	mv -f y.tab.h hoc-reverse-polish-notation.h
	cc -o hoc-reverse-polish-notation hoc-reverse-polish-notation.c  $(LDLIBS)
