OBOBASE=                    http://purl.obolibrary.org/obo
URIBASE=                    http://purl.obolibrary.org/obo
ONT=                        fovtTEST
ONTBASE=                    http://purl.obolibrary.org/obo/fovtTEST
EDIT_FORMAT=                owl
SRC =                       $(ONT)-edit.$(EDIT_FORMAT)
MAKE_FAST=                  $(MAKE) IMP=false PAT=false COMP=false MIR=false
CATALOG=                    catalog-v001.xml
ROBOT=                      robot --catalog $(CATALOG)

OWLTOOLS=                   owltools --use-catalog
RELEASEDIR=                 ../..
REPORTDIR=                  reports
TEMPLATEDIR=                ../templates
TMPDIR=                     tmp
MIRRORDIR=                  mirror
IMPORTDIR=                  imports

TODAY ?=                    $(shell date +%Y-%m-%d)
OBODATE ?=                  $(shell date +'%d:%m:%Y %H:%M')
VERSION=                    $(TODAY)
ANNOTATE_ONTOLOGY_VERSION = annotate -V $(ONTBASE)/releases/$(VERSION)/$@ --annotation owl:versionInfo $(VERSION)
OTHER_SRC =                 
ONTOLOGYTERMS =             $(TMPDIR)/ontologyterms.txt

FORMATS = $(sort  owl owl)
FORMATS_INCL_TSV = $(sort $(FORMATS) tsv)
RELEASE_ARTEFACTS = $(sort $(ONT)-base $(ONT)-full $(ONT)-simple $(ONT)-non-classified $(ONT)-base $(ONT)-full)

# ----------------------------------------
# Import modules
# ----------------------------------------
IMPORTS =  omo uberon fovt

IMPORT_ROOTS = $(patsubst %, $(IMPORTDIR)/%_import, $(IMPORTS))
IMPORT_OWL_FILES = $(foreach n,$(IMPORT_ROOTS), $(n).owl)
IMPORT_FILES = $(IMPORT_OWL_FILES)

IMP=true # Global parameter to bypass import generation
MIR=true # Global parameter to bypass mirror generation
IMP_LARGE=true # Global parameter to bypass handling of large imports

.PRECIOUS: $(IMPORTDIR)/%_import.owl

.PHONY: all_imports
all_imports: $(IMPORT_FILES)

.PHONY: refresh-imports
refresh-imports:
	$(MAKE) IMP=true MIR=true PAT=false IMP_LARGE=true all_imports -B

.PHONY: no-mirror-refresh-imports
no-mirror-refresh-imports:
	$(MAKE) IMP=true MIR=false PAT=false IMP_LARGE=true all_imports -B

.PHONY: refresh-imports-excluding-large
refresh-imports-excluding-large:
	$(MAKE) IMP=true MIR=true PAT=false IMP_LARGE=false all_imports -B

.PHONY: refresh-%
refresh-%:
	$(MAKE) IMP=true IMP_LARGE=true MIR=true PAT=false $(IMPORTDIR)/$*_import.owl -B

.PHONY: no-mirror-refresh-%
no-mirror-refresh-%:
	$(MAKE) IMP=true IMP_LARGE=true MIR=false PAT=false $(IMPORTDIR)/$*_import.owl -B

## OMO
$(IMPORTDIR)/omo_import.owl: $(MIRRORDIR)/omo.owl
	$(ROBOT) \
	  remove \
		--input $< \
		--select "owl:deprecated='true'^^xsd:boolean" \
	  remove \
		--select classes \
	  annotate \
		--annotate-defined-by true \
		--ontology-iri $(URIBASE)/$(ONT)/$@ \
		--version-iri $(URIBASE)/$(ONT)/$@ \
	  convert --format ofn \
	  --output $@.tmp.owl && mv $@.tmp.owl $@

## UBERON
$(IMPORTDIR)/uberon_import.owl: $(MIRRORDIR)/uberon.owl $(IMPORTDIR)/uberon_terms.txt
	$(ROBOT) \
		filter \
			--input $< \
			--term-file $(word 2, $^) \
			--select "annotations self ancestors" \
			--axioms logical \
			--signature true \
			--trim true \
		remove \
			--select "owl:deprecated='true'^^xsd:boolean" \
		remove \
			--select "<http://purl.obolibrary.org/obo/NCBITaxon_*>" \
		annotate \
			--annotate-defined-by true \
			--ontology-iri $(URIBASE)/$(ONT)/$@ \
			--version-iri $(URIBASE)/$(ONT)/$@ \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

###### UBERON TESTING #######
uberon_mireot.owl: $(MIRRORDIR)/uberon.owl $(IMPORTDIR)/uberon_terms.txt
	$(ROBOT) \
		filter \
			--input $< \
			--term-file $(word 2, $^) \
			--select "annotations self ancestors" \
			--axioms logical \
			--signature true \
			--trim true \
		remove \
			--select "owl:deprecated='true'^^xsd:boolean" \
		remove \
			--select "<http://purl.obolibrary.org/obo/NCBITaxon_*>" \
		extract --method MIREOT \
			--branch-from-term "obo:UBERON_0001062" \
		annotate \
			--annotate-defined-by true \
			--ontology-iri $(URIBASE)/$(ONT)/$@ \
			--version-iri $(URIBASE)/$(ONT)/$@ \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

uberon_subset.owl: $(MIRRORDIR)/uberon.owl $(IMPORTDIR)/uberon_terms.txt
	$(ROBOT) \
		filter \
			--input $< \
			--term-file $(word 2, $^) \
			--select "annotations self ancestors" \
			--axioms logical \
			--signature true \
			--trim true \
		remove \
			--select "owl:deprecated='true'^^xsd:boolean" \
		remove \
			--select "<http://purl.obolibrary.org/obo/NCBITaxon_*>" \
		extract --method subset \
			--term-file $(word 2, $^) \
		annotate \
			--annotate-defined-by true \
			--ontology-iri $(URIBASE)/$(ONT)/$@ \
			--version-iri $(URIBASE)/$(ONT)/$@ \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

uberon_merge.owl: uberon_mireot.owl uberon_subset.owl
	$(ROBOT) \
		merge \
			--input $(word 1, $^) \
			--input $(word 2, $^) \
			--include-annotations true \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

# ----------------------------------------
# Mirroring upstream ontologies
# ----------------------------------------

.PHONY: mirror-%
mirror-%: | $(TMPDIR)
	@echo "*** mirroring $* ***"
	if [ $(MIR) = true ] && [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then \
		curl -L $(OBOBASE)/$*.owl \
			--create-dirs -o $(MIRRORDIR)/$(notdir $*).temp.owl --retry 4 --max-time 200 && \
		$(ROBOT) convert \
			--input $(MIRRORDIR)/$(notdir $*).temp.owl \
			--output $(MIRRORDIR)/$(notdir $*).owl && \
		rm  $(MIRRORDIR)/$*.temp.owl; fi

.PRECIOUS: $(MIRRORDIR)/%.owl
$(MIRRORDIR)/%.owl: 
	if [ $(MIR) = true ] && [ $(IMP) = true ] && [ $(IMP_LARGE) = true ]; then \
		$(MAKE) mirror-$*; fi