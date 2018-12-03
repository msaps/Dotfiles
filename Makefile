
all: core homebrew gems

core:
	git submodule update --init --recursive
	sh ./Corefile

homebrew:
	sh ./Brewfile

gems:
	rbenv install 2.5.3
	rbenv global 2.5.3
	gem install bundler
	bundle install