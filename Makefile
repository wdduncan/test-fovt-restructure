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
	pylode -o $(DOCDIR)/FOVT.html fovtTEST.ttl
