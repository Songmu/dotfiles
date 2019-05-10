setup:
	git submodule init && git submodule update
	./mainte.sh
	./create_link.sh

