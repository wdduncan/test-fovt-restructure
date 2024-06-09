DOCDIR = docs
SRC = src
SOURCE_SCHEMA_DIR = src/schema

## generate documentation
gendoc: $(DOCDIR)
# copy existing files if they exist 
# note: there is no space after the ',' in ($(wildcard src/docs/*.md),)
# condition is the true if the wildcard returns non-empty content (i.e, not equal)
ifneq ($(wildcard src/docs/*.md),)
	cp src/docs/*.md docs/
endif
ifneq ($(wildcard src/docs/images/*.*),)
	cp src/docs/images/*.* docs/images 
endif
# generate documentation
# for pyLODE to show the definitions replace obo:obo:IAO_0000115 "..." with skos:definition "..."
# and similarlyt replace elucidations (IAO_0000600) with skos:definition
	mkdir -p tmp
	sed 's@obo:IAO_0000115 \"@skos:definition \"@g' fovtTEST.ttl | \
	sed 's@obo:IAO_0000600 \"@skos:definition \"@g' > tmp/temp.ttl
	pylode -o $(DOCDIR)/index.html tmp/temp.ttl
