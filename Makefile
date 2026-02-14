.PHONY: all

all: clean ramdisk.dmg

jb.dylib:
	xcrun -sdk iphoneos clang -arch arm64 -shared src/jb.c -o jb.dylib
	ldid -S jb.dylib

jbinit:
	xcrun -sdk iphoneos clang -e__dyld_start -Wl,-dylinker -Wl,-dylinker_install_name,/usr/lib/dyld -nostdlib -static -Wl,-fatal_warnings -Wl,-dead_strip -Wl,-Z --target=arm64-apple-ios12.0 -std=gnu17 -flto -ffreestanding -U__nonnull -nostdlibinc -fno-stack-protector src/jbinit.c src/printf.c -o jbinit
	mv jbinit com.apple.dyld
	ldid -Sents/generic.plist com.apple.dyld
	mv com.apple.dyld jbinit
	chmod +rwx jbinit

jbloader:
	xcrun -sdk iphoneos clang -arch arm64 src/jbloader.m -o jbloader -fobjc-arc -framework Foundation
	ldid -Sents/launchd.plist jbloader
	chmod +rwx jbloader

ramdisk.dmg: jb.dylib jbinit jbloader
	mkdir -p ramdisk/{dev,bin,sbin,usr/lib,private/{etc,var/tmp}}
	# ln -s ramdisk/private/etc ramdisk/etc
	# ln -s ramdisk/private/var ramdisk/var
	# ln -s ramdisk/private/var/tmp ramdisk/tmp
	cp jbloader ramdisk/sbin/launchd
	cp jbinit ramdisk/usr/lib/dyld
	cp jb.dylib ramdisk/jb.dylib
	cp gestaltpatcher ramdisk/gestaltpatcher
	hdiutil create -size 28m -layout NONE -format UDRW -srcfolder ./ramdisk -fs HFS+ ./ramdisk.dmg

clean:
	rm -rf jb.dylib jbinit jbloader ramdisk.dmg ramdisk
