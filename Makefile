
all: core homebrew gems

core:
	git submodule update --init --recursive
	sh ./Corefile

homebrew:
	sh ./Brewfile

gems:
	rbenv install 3.2.2
	rbenv global 3.2.2
	gem install bundler
	bundle install