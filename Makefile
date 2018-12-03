
all: core homebrew gems

core:
	sh ./Corefile

homebrew:
	sh ./Brewfile

gems:
	sudo gem install bundle
	bundle install