
KICAD_PRO:=$(wildcard *.kicad_pro)
#PROJECTS=$(KICAD_PRO:%.kicad_pro=%)
PROJECTS=skedd6 skedd-jtag6

all: $(PROJECTS:%=%.all)

$(PROJECTS:%=%.all): %.all: out/%_gerber.zip out/%.rpt
	echo "$*" "$@" "$<"

.PHONY: $(PROJECTS:%=%.all) $(PROJECTS:%=%.drc)

$(PROJECTS:%=%.drc): %.drc: %.rpt
	! grep 'Found [^0]' $<

.PRECIOUS: out/%.rpt
out/%.rpt: %.kicad_pcb
	mkdir -p out
	kicad-cli pcb drc --exit-code-violations -o $@ $<

out/%_gerber.zip: %.kicad_pcb out/%.rpt
	mkdir -p out
	mkdir temp/
	kicad-cli pcb export gerbers --use-drill-file-origin --board-plot-params -o temp $<
	kicad-cli pcb export drill -o temp/ $<
	zip -j $@ temp/*
	rm -r temp

.PHONY: clean
clean:
	rm -rf out temp
