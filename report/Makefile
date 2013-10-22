all:
	@echo "<<<<<<<<<<<<<<<<<<Running 1. PDF Latex>>>>>>>>>>>>>>>>>>>>>>>>"
	pdflatex thesis.tex

bib:
	@echo "<<<<<<<<<<<<<<<<<<Running BibTex>>>>>>>>>>>>>>>>>>>>>>>>"
	bibtex thesis
	@echo "<<<<<<<<<<<<<<<<<<Running 2. PDF Latex>>>>>>>>>>>>>>>>>>>>>>>>"
	pdflatex thesis.tex
	@echo "<<<<<<<<<<<<<<<<<<Running 3. PDF Latex>>>>>>>>>>>>>>>>>>>>>>>>"
	pdflatex thesis.tex
	@echo "<<<<<<<<<<<<<<<<<<END Running PDF Latex>>>>>>>>>>>>>>>>>>>>>>>>"

test:
	@echo "Makeing Test..."

