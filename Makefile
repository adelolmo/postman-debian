MAKEFLAGS += --silent

BIN_DIR=/opt/Postman
BUILD_DIR=build-debian
TMP_DIR=$(BUILD_DIR)/tmp
RELEASE_DIR := $(realpath $(CURDIR)/..)

VERSION=9.31.0

.PHONY: all
all: $(BUILD_DIR) $(BUILD_DIR)/linux64_$(VERSION) $(BUILD_DIR)/Postman/Postman

.PHONY: debian
debian: clean $(TMP_DIR) $(BUILD_DIR)/DEBIAN
	@echo Building package...
	chmod --quiet 0555 $(TMP_DIR)/DEBIAN/p* || true
	fakeroot dpkg-deb -b -z9 $(TMP_DIR) $(RELEASE_DIR)

.PHONY: clean
clean:
	@echo Clean...
	rm -rf $(TMP_DIR)

$(BUILD_DIR)/DEBIAN: $(TMP_DIR)
	@echo Prapare package...
	cp -R deb/DEBIAN $(TMP_DIR)
	$(MAKE) install DESTDIR=$(TMP_DIR)
	$(eval SIZE := $(shell du -sbk $(TMP_DIR) | grep -o '[0-9]*'))
	@sed -i "s/{{version}}/$(VERSION)/g;s/{{size}}/$(SIZE)/g" "$(TMP_DIR)/DEBIAN/control"

$(BUILD_DIR)/linux64_$(VERSION):
	@echo Download postman $(VERSION)...
	wget --quiet -O $(BUILD_DIR)/linux64_$(VERSION) -P $(BUILD_DIR) https://dl.pstmn.io/download/version/$(VERSION)/linux64

$(BUILD_DIR)/Postman/Postman:
	@echo Extract tar ball...
	tar -xf $(BUILD_DIR)/linux64_$(VERSION) -C $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TMP_DIR):
	mkdir -p $(TMP_DIR)$(BIN_DIR)

.PHONY: install
install:
	install -Dm644 postman.desktop $(DESTDIR)/usr/share/applications/postman.desktop
	cp -r $(BUILD_DIR)/Postman/* $(DESTDIR)$(BIN_DIR)
	@echo $(VERSION) > $(DESTDIR)/opt/Postman/VERSION

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)/usr/share/applications/postman.desktop
	rm -rf $(DESTDIR)$(BIN_DIR)
