
all: homebrew gems system

homebrew:
	sh ./Brewfile

gems:
	sudo gem install bundle
	bundle install

system:
	sh ./install