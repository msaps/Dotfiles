
all: homebrew gems core

homebrew:
	sh ./Brewfile

gems:
	rbenv install 2.5.3
	sudo gem install bundle
	bundle install

core:
	sh ./Corefile