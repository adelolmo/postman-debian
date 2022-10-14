MAKEFLAGS += --silent

BIN_DIR = /opt/Postman
BUILD_DIR = build-debian
TMP_DIR = $(BUILD_DIR)/tmp
PKG_DIR = $(BUILD_DIR)/package
RELEASE_DIR := $(realpath $(CURDIR)/..)

VERSION = 9.31.0

.PHONY: all
all: $(TMP_DIR) $(BUILD_DIR)/linux64_$(VERSION) $(TMP_DIR)/Postman

.PHONY: debian
debian: $(PKG_DIR) $(PKG_DIR)/DEBIAN
	@echo Building package...
	chmod --quiet 0555 $(PKG_DIR)/DEBIAN/p* || true
	fakeroot dpkg-deb -b -z9 $(PKG_DIR) $(RELEASE_DIR)

.PHONY: clean
clean:
	@echo Clean...
	rm -rf $(PKG_DIR)
	rm -rf $(TMP_DIR)

$(PKG_DIR)/DEBIAN:
	@echo Prapare package...
	cp -R deb/DEBIAN $(PKG_DIR)
	$(MAKE) install DESTDIR=$(PKG_DIR)
	$(eval SIZE := $(shell du -sbk $(PKG_DIR) | grep -o '[0-9]*'))
	@sed -i "s/{{version}}/$(VERSION)/g;s/{{size}}/$(SIZE)/g" "$(PKG_DIR)/DEBIAN/control"

$(BUILD_DIR)/linux64_$(VERSION):
	@echo Download postman $(VERSION)...
	wget --quiet -O $(BUILD_DIR)/linux64_$(VERSION) https://dl.pstmn.io/download/version/$(VERSION)/linux64

$(TMP_DIR)/Postman:
	@echo Extract tar ball...
	tar -xf $(BUILD_DIR)/linux64_$(VERSION) --strip-components 2 -C $(TMP_DIR)

$(BUILD_DIR):
	echo Create directory $(BUILD_DIR)...
	mkdir -p $(BUILD_DIR)

$(TMP_DIR):
	echo Create directory $(TMP_DIR)...
	mkdir -p $(TMP_DIR)

$(PKG_DIR):
	echo Create directory $(PKG_DIR)...
	mkdir -p $(PKG_DIR)$(BIN_DIR)

.PHONY: install
install:
	install -Dm644 postman.desktop $(DESTDIR)/usr/share/applications/postman.desktop
	cp -r $(TMP_DIR)/* $(DESTDIR)$(BIN_DIR)
	@echo $(VERSION) > $(DESTDIR)/VERSION

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)/usr/share/applications/postman.desktop
	rm -rf $(DESTDIR)$(BIN_DIR)
