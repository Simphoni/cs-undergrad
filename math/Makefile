obj := $(patsubst %.tex, %.pdf, $(wildcard *.tex))

.PHONY: all clean
all: $(obj)

$(obj): %.pdf : %.tex
	xelatex -synctex=1 -interaction=nonstopmode --shell-escape $<
clean:
	rm -f $(obj)
