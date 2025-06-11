# really just some handy scripts...

KEXT      := NullEthernet.kext
DIST      := NullEthernet
BUILDDIR  := ./Build/Products

VERSION_ERA		:= $(shell ./print_version.sh)
VERSION_MODULE	:= $(shell ./print_module_version.sh)

ifeq ($(VERSION_ERA),10.10-)
  INSTDIR := /System/Library/Extensions
endif
ifeq ($(VERSION_ERA),10.11-10.15)
  INSTDIR := /Library/Extensions
endif

# on 11+ we stub out all install steps
ifeq ($(VERSION_ERA),11+)
.PHONY: install install_debug install_inject install_force update_kernelcache
install install_debug install_inject install_force update_kernelcache:
	@echo "Install/update skipped on macOS $(shell sw_vers -productVersion)"
else
# only for 10.10- through 10.15:
.PHONY: update_kernelcache install_debug install install_inject install_force

update_kernelcache:
	sudo touch /System/Library/Extensions
	sudo kextcache -update-volume /

install_debug:
	sudo cp -R $(BUILDDIR)/Debug/$(KEXT) $(INSTDIR)
	if [ "`which tag`" != "" ]; then sudo tag -a Purple $(INSTDIR)/$(KEXT); fi
	$(MAKE) update_kernelcache

install:
	sudo cp -R $(BUILDDIR)/Release/$(KEXT) $(INSTDIR)
	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(KEXT); fi
	$(MAKE) update_kernelcache

install_inject:
	sudo cp -R $(BUILDDIR)/Release/$(KEXT)                       $(INSTDIR)
	sudo cp -R $(BUILDDIR)/Release/NullEthernetInjector.kext      $(INSTDIR)
	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(KEXT); fi
	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/NullEthernetInjector.kext; fi
	$(MAKE) update_kernelcache

install_force:
	sudo cp -R $(BUILDDIR)/Release/$(KEXT)                       $(INSTDIR)
	sudo cp -R $(BUILDDIR)/Release/NullEthernetForce.kext         $(INSTDIR)
	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/$(KEXT); fi
	if [ "`which tag`" != "" ]; then sudo tag -a Blue $(INSTDIR)/NullEthernetForce.kext; fi
	$(MAKE) update_kernelcache
endif

# common bits below ----------------------------------------------------

ifeq ($(findstring 32,$(BITS)),32)
OPTIONS += -arch i386
endif

ifeq ($(findstring 64,$(BITS)),64)
OPTIONS += -arch x86_64
endif

OPTIONS += -scheme NullEthernet

.PHONY: all clean distribute

all: SSDT-RMNE.aml
	xcodebuild build $(OPTIONS) -configuration Debug
	xcodebuild build $(OPTIONS) -configuration Release

clean:
	xcodebuild clean $(OPTIONS) -configuration Debug
	xcodebuild clean $(OPTIONS) -configuration Release

distribute:
	if [ -e ./Distribute ]; then rm -r ./Distribute; fi
	mkdir ./Distribute
	cp -R $(BUILDDIR)/Debug    ./Distribute
	cp -R $(BUILDDIR)/Release  ./Distribute
	cp     patch.txt ./Distribute/Release
	cp     patch.txt ./Distribute/Debug
	cp     SSDT-RMNE.aml ./Distribute/Release
	cp     SSDT-RMNE.aml ./Distribute/Debug
	find ./Distribute -name '*.DS_Store' -delete
	find ./Distribute -name '*.dSYM' -prune -exec rm -r {} \;
	ditto -c -k --sequesterRsrc --zlibCompressionLevel 9 ./Distribute/Release ./Archive_Release.zip
	ditto -c -k --sequesterRsrc --zlibCompressionLevel 9 ./Distribute/Debug ./Archive_Debug.zip
	mv      ./Archive_Release.zip ./Distribute/$(DIST)-$(VERSION_MODULE)-RELEASE.zip
	mv      ./Archive_Debug.zip ./Distribute/$(DIST)-$(VERSION_MODULE)-DEBUG.zip

SSDT-RMNE.aml : SSDT-RMNE.dsl
	iasl -p $@ $^