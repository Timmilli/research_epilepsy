FILE_NAME = main

default: pdf clean

pdf:
	pdflatex $(FILE_NAME).tex
	pdflatex $(FILE_NAME).tex

clean:
	rm -f *.aux *.log *.out *.synctex.gz *.toc

deepClean: clean
	rm -f *.pdf

all: pdf
