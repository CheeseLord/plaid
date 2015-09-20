.PHONY: all clean docs test code

all: code docs
code:
	dub build
docs: 
	dub build --build=docs 
test:
	dub test
clean:
	dub clean
	rm -rf docs plaid
