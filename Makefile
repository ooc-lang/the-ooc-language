
TEMP_DIR:=$(shell mktemp -d -t /tmp)
PANDOC=pandoc
BUILD_DIR=_build
MD_OUTPUT=documentation.md
HTML_OUTPUT=Documentation.html

all: convert build
	@echo '-- The documentation has been successfully generated.'

build:
	@echo -n '-- Copying the required assets into the build folder...'
	@cp _assets/stylesheet.css $(BUILD_DIR)/
	@cat $(TEMP_DIR)/highlight.css >> $(BUILD_DIR)/stylesheet.css
	@cat _assets/header.html $(TEMP_DIR)/$(HTML_OUTPUT) _assets/footer.html > _build/index.html
	@echo ' Done.'

cprsrc:
	@echo -n '-- Copying the required assets into the temp folder...'
	@ditto 0*.md* $(TEMP_DIR)/
	@echo ' Done.'

convert: md2html

concat: cprsrc
	@echo -n '-- Concatenating the Markdown files...'
	@cat $(TEMP_DIR)/0*.md > $(TEMP_DIR)/$(MD_OUTPUT)
	@echo ' Done.'

preprocess:
	@echo -n '-- Syntax-highlighting code blocks...'
	@python _scripts/preprocess.py $(TEMP_DIR)/$(MD_OUTPUT) $(TEMP_DIR)
	@echo ' Done.'

md2html: concat preprocess
	@echo -n '-- Converting the Markdown document to HTML...'
	@$(PANDOC) --html5 --toc -o $(TEMP_DIR)/$(HTML_OUTPUT) $(TEMP_DIR)/$(MD_OUTPUT)
	@echo ' Done.'

clean:
	@rm -rf $(TEMP_DIR)

.PHONY: all
