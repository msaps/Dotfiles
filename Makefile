
all: core brew gems

core:
	git submodule update --init --recursive
	sh ./Corefile

brew:
	sh ./Brewfile

gems:
	rbenv install 3.2.2
	rbenv global 3.2.2
	gem install bundler
	bundle install
