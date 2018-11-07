
all: homebrew gems

homebrew:
	sh ./Brewfile

gems:
	sudo gem install bundle
	bundle install