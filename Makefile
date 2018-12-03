
all: homebrew gems core

homebrew:
	sh ./Brewfile

gems:
	rbenv install 2.5.3
	rbenv global 2.5.3
	gem install bundler
	bundle install

core:
	sh ./Corefile