TARGET = thesis
LATEX  = xelatex -interaction=nonstopmode -file-line-error
BIB    = biber

.PHONY: all clean view

all: $(TARGET).pdf

$(TARGET).pdf: $(TARGET).tex
	$(LATEX) $(TARGET)
	$(BIB) $(TARGET)
	$(LATEX) $(TARGET)
	$(LATEX) $(TARGET)
	@echo "=== 检查引用 ==="
	@grep -c "??" $(TARGET).aux 2>/dev/null || echo "无 aux 文件"
	@echo "=== Overfull 检查 ==="
	@grep -c "Overfull" $(TARGET).log 2>/dev/null || echo "无 overfull"

clean:
	rm -f *.aux *.log *.out *.bbl *.bcf *.blg *.run.xml *.synctex.gz *.toc *.lof *.lot
	rm -f chapters/*.aux

view: $(TARGET).pdf
	@echo "打开 $(TARGET).pdf"
	cmd /c start $(TARGET).pdf
