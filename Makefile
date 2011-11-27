
TEMP_DIR:=$(shell mktemp -d -t /tmp)
PANDOC=pandoc
PREPROCESS=python _scripts/preprocess.py
BUILD_DIR=_build
ASSETS_DIR=_assets
MD_OUTPUT=documentation.md
HTML_OUTPUT=index.html

all: md2html build
	@echo '-- The documentation has been successfully generated.'

cprsrc:
	@echo -n '-- Copying the required assets into the temp folder...'
	@ditto 0*.md* $(TEMP_DIR)/
	@echo ' Done.'

concat: cprsrc
	@echo -n '-- Concatenating the Markdown files...'
	@cat $(TEMP_DIR)/0*.md > $(TEMP_DIR)/$(MD_OUTPUT)
	@echo ' Done.'

preprocess:
	@echo -n '-- Syntax-highlighting code blocks...'
	@$(PREPROCESS) $(TEMP_DIR)/$(MD_OUTPUT) $(TEMP_DIR)
	@echo ' Done.'

md2html: concat preprocess
	@echo -n '-- Converting the Markdown document to HTML...'
	@$(PANDOC)  --standalone \
				--html5 \
				--toc \
				--css=stylesheet.css \
				--template=$(ASSETS_DIR)/template.html \
				--include-before-body=_assets/header.html \
				-o $(BUILD_DIR)/$(HTML_OUTPUT) \
				$(TEMP_DIR)/$(MD_OUTPUT)
	@echo ' Done.'

build:
	@echo -n '-- Copying the required assets into the build folder...'
	@cp $(ASSETS_DIR)/stylesheet.css $(BUILD_DIR)/
	@cat $(TEMP_DIR)/highlight.css >> $(BUILD_DIR)/stylesheet.css
	@echo ' Done.'

clean:
	@rm -rf $(TEMP_DIR)

.PHONY: all
