setup:
	git submodule init && git submodule update
	./mainte.sh
	./create_link.sh

maint:
	brew upgrade
	./mainte.sh
	zplug update
