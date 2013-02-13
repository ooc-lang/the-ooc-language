
TEMP_DIR:=$(shell mktemp -d)
PANDOC=pandoc
PREPROCESS=python _scripts/preprocess.py
BUILD_DIR=_build
ASSETS_DIR=_assets
MD_OUTPUT=documentation.md
HTML_OUTPUT=index.html

all: init md2html build
	@echo '-- The documentation has been successfully generated.'

init:
	@mkdir -p $(BUILD_DIR)

cprsrc:
	@echo -n '-- Copying the required assets into the temp folder...'
	@cp 0*.md* $(TEMP_DIR)/
	@cp $(ASSETS_DIR)/stylesheet.css $(TEMP_DIR)/
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
				--section-divs \
				--title="The ooc language" \
				--css=stylesheet.css \
				--template=$(ASSETS_DIR)/template.html \
				--include-before-body=_assets/header.html \
				-o $(TEMP_DIR)/$(HTML_OUTPUT) \
				$(TEMP_DIR)/$(MD_OUTPUT)
	@echo ' Done.'

build:
	@echo -n '-- Copying the required assets into the build folder...'
	@cat $(TEMP_DIR)/highlight.css >> $(TEMP_DIR)/stylesheet.css
	@cp $(TEMP_DIR)/index.html $(BUILD_DIR)/
	@cp $(TEMP_DIR)/stylesheet.css $(BUILD_DIR)/
	@echo ' Done.'

publish:
	@git checkout gh-pages
	@rm -f stylesheet.css index.html
	@cp $(BUILD_DIR)/stylesheet.css ./
	@cp $(BUILD_DIR)/index.html ./
	@git add .
	@git commit -m "Update the documentation."
	@git push origin gh-pages
	@git checkout master

clean:
	@rm -rf $(TEMP_DIR) $(BUILD_DIR)

.PHONY: all
