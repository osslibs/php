PROJECT_NAME=osslibs/php
PROJECT_LICENSE=MIT

PHP=php
PHPUNIT=vendor/bin/phpunit

COMPOSER_PHAR=composer.phar
COMPOSER_JSON=composer.json

PACKAGES:=$(shell find osslibs/* -maxdepth 0 -type d)
PACKAGES_SRC:=$(addsufix /src, $(shell find osslibs/* -maxdepth 0 -type d))
PACKAGES_TESTS:=$(addsufix /tests, $(shell find osslibs/* -maxdepth 0 -type d))

VENDOR=vendor

.PHONY: test
test: $(PACKAGES)

.PHONY: clean
clean:
	rm --preserve-root -rf ./$(COMPOSER_PHAR) ./$(VENDOR)

.PHONY: $(PACKAGES)
$(PACKAGES): $(PACKAGES_TESTS) $(PHPUNIT)
	$(PHPUNIT) $@/tests

$(PACKAGES_TESTS):
	git submodule init
	git submodule update

$(PHPUNIT) $(VENDOR):
	make $(COMPOSER_JSON)
	$(PHP) $(COMPOSER_PHAR) install --dev

$(COMPOSER_JSON):
	make $(COMPOSER_PHAR)
	$(PHP) $(COMPOSER_PHAR) init \
		--no-interaction \
		--name $(PROJECT_NAME) \
		--license $(PROJECT_LICENSE) \
		$(foreach PACKAGE, $(PACKAGES), --repository '{"type": "path","url":"$(PACKAGE)","options":{"symlink":true}}') \
		$(foreach PACKAGE, $(PACKAGES), --require '$(PACKAGE):dev-main') \
		--require-dev 'mockery/mockery:*' \
		--require-dev 'phpunit/phpunit:*'


$(COMPOSER_PHAR):
	$(PHP) -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	$(PHP) -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	$(PHP) composer-setup.php
	$(PHP) -r "unlink('composer-setup.php');"
