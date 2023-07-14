# install for various dependencies
# homebrew
echo "check homebrew"
if ! command -v brew 
then /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# makefile
if ! command -v makefile 
then brew install make
fi
# docker cli
if ! command -v makefile 
then brew install docker
fi

if ! command -v jq
then brew install jq
fi 
