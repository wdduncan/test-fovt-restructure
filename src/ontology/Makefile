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
IMPORTS =  omo ro uberon uberon_filter uberon_mireot uberon_subset fovt organism bspo

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

## RO
$(IMPORTDIR)/ro_import.owl: $(MIRRORDIR)/ro.owl
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

## ORGANSM (extacted from FOVT)
$(IMPORTDIR)/organism_import.owl: $(MIRRORDIR)/fovt.owl
	$(ROBOT) \
	  extract --method MIREOT \
		--input $< \
		--branch-from-term OBI:0100026 \
		--copy-ontology-annotations true \
	  remove \
		--select "owl:deprecated='true'^^xsd:boolean" \
	  annotate \
		--annotate-defined-by true \
		--ontology-iri $(URIBASE)/$(ONT)/$@ \
		--version-iri $(URIBASE)/$(ONT)/$@ \
	  convert --format ofn \
	  --output $@.tmp.owl && mv $@.tmp.owl $@

## BSPO
# - BSPO:0000051 'anatomical gradient'
# - CARO:0000003 'connected anatomical structure'
# - CARO:0000010 'anatomical boundary'
# - CARO:0000008 'anatomical line'

# extract --method TOP \
# 	--input $< \
# 	--term BSPO:0000051 \
# 	--term CARO:0000003 \
# 	--term CARO:0000010 \
# 	--term CARO:0000008 \

# extract --method MIREOT \
# 	--input $< \
# 	--branch-from-term BSPO:0000051 \
# 	--branch-from-term CARO:0000003 \
# 	--branch-from-term CARO:0000010 \
# 	--branch-from-term CARO:0000008 \
# 	--copy-ontology-annotations true \

$(IMPORTDIR)/bspo_import.owl: $(MIRRORDIR)/bspo.owl $(IMPORTDIR)/bspo_terms.txt
	$(ROBOT) \
	    filter \
			--input $< \
			--term-file $(word 2, $^) \
			--select "annotations self descendants" \
			--axioms logical \
			--signature true \
			--trim true \
		remove \
			--select "owl:deprecated='true'^^xsd:boolean" \
	    annotate \
			--annotate-defined-by true \
			--ontology-iri $(URIBASE)/$(ONT)/$@ \
			--version-iri $(URIBASE)/$(ONT)/$@ \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

### UBERON ###
# This is a multistep process
# - robot filter to create base ontology used for mireot and subset
# - robot mireot to extract the anatomical entity branch; this doesn't extract axioms
# - robot subset is used to get the axioms
# - merge the meriot and subset ontologies

## UBERON import ontology created by merging mireot and subset
$(IMPORTDIR)/uberon_import.owl: $(IMPORTDIR)/uberon_mireot.owl $(IMPORTDIR)/uberon_subset.owl
	@echo "*** building $@ ***"
	$(ROBOT) \
		merge \
			--input $(word 1, $^) \
			--input $(word 2, $^) \
			--include-annotations true \
		remove \
			--select "owl:deprecated='true'^^xsd:boolean" \
			--select "<http://purl.obolibrary.org/obo/NCBITaxon_*>" \
		annotate \
			--annotate-defined-by true \
			--ontology-iri $(URIBASE)/$(ONT)/$@ \
			--version-iri $(URIBASE)/$(ONT)/$@ \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

## UBERON filtered ontology
$(IMPORTDIR)/uberon_filter_import.owl: $(MIRRORDIR)/uberon.owl $(IMPORTDIR)/uberon_terms.txt
	@echo "*** building $@ ***"
	$(ROBOT) \
		filter \
			--input $< \
			--term-file $(word 2, $^) \
			--select "annotations self ancestors" \
			--axioms logical \
			--signature true \
			--trim true \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

## UBERON mireot ontology
$(IMPORTDIR)/uberon_mireot.owl: $(IMPORTDIR)/uberon_filter_import.owl
	@echo "*** building $@ ***"
	$(ROBOT) \
		extract \
			--method MIREOT \
			--input $< \
			--branch-from-term "obo:UBERON_0001062" \
			--copy-ontology-annotations true \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@

## UBERON subset ontology
$(IMPORTDIR)/uberon_subset.owl: $(IMPORTDIR)/uberon_filter_import.owl $(IMPORTDIR)/uberon_terms.txt
	@echo "*** building $@ ***"
	$(ROBOT) \
		extract --method subset \
			--input $< \
			--term-file $(word 2, $^) \
		remove \
			--axioms annotation \
		convert --format ofn \
		--output $@.tmp.owl && mv $@.tmp.owl $@
### END UBERON ###

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

# ----------------------------------------
# Queries
# ----------------------------------------
.PHONY: bspo_caro_terms
# used to help retrieve the terms list for bspo_terms.txt
bspo_caro_terms:
	$(ROBOT) \
		query \
		--input imports/bspo_import.owl \
		--query ../sparql/bspo_caro_terms.sparql tmp/out.tsv 