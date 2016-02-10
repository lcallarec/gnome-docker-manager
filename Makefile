SHELL := /bin/bash

gtk_version := $(shell pkg-config --modversion gtk+-3.0 | cut -d'.' -f1,2)
vala_src_files := $(shell build/get_vala_src_files $(gtk_version))

EXEC=gnome-docker-file

all: $(EXEC)

gnome-docker-file:
	glib-compile-resources gnome-docker-manager.gresource.xml --target=resources.c --generate-source
	valac -g --save-temps \
        -X -lm \
        --pkg gtk+-3.0 --pkg libsoup-2.4 --pkg gio-2.0 \
        --pkg gio-unix-2.0 --pkg gee-0.8 --pkg json-glib-1.0 \
        $(vala_src_files) resources.c --gresources gnome-docker-manager.gresource.xml \
        -o gdocker
        
install:
	cp -f gdocker /usr/bin/gdocker
	$(MAKE) clean
	$(MAKE) install-desktop-entry

install-desktop-entry:
	rm -rf /usr/local/share/applications/docker-manager.desktop
	cp -f desktop/docker-manager.desktop /usr/local/share/applications/docker-manager.desktop
	chmod 0777 /usr/local/share/applications/docker-manager.desktop
	cp desktop/icons/docker-manager.svg /usr/share/icons/hicolor/scalable/apps/docker-manager.png
	cp desktop/icons/docker-managerx256.png /usr/share/icons/hicolor/256x256/apps/docker-manager.png
	cp desktop/icons/docker-managerx48.png /usr/share/icons/hicolor/48x48/apps/docker-manager.png
	gtk-update-icon-cache /usr/share/icons/hicolor
    
clean:
	find . -type f -name '*.c' -delete && rm gdocker

