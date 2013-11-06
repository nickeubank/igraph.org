
all: nothing

HTML= index.html getstarted.html news.html \
      _layouts/default.html _layouts/newstemp.html _layouts/manual.html

CSS= css/affix.css css/manual.css css/other.css fonts/fonts.css

RMAN:= $(wildcard ../interfaces/R/igraph/man/*)

TMP:=$(shell mktemp -d /tmp/.XXXXX)

../doc/jekyll/stamp: ../doc/html/stamp
	cd ../doc && make jekyll

doc/c/stamp: ../doc/jekyll/stamp
	rm -rf doc/c
	mkdir -p doc
	cp -r ../doc/jekyll doc/c

doc/r/stamp: $(RMAN)
	cd ../interfaces/R && make && \
	R CMD INSTALL --html --no-inst --no-configure -l $(TMP) igraph
	rm -rf doc/r
	mkdir -p doc/r
	../tools/rhtml.sh $(TMP)/igraph/html doc/r
	ln -s 00Index.html doc/r/index.html
	touch doc/r/stamp

stamp: $(HTML) $(CSS) doc/c/stamp doc/r/stamp
	jekyll build
	touch stamp

deploy: stamp
	rsync -avz --delete _site/ igraph.org:www/

.PHONY: all deploy
