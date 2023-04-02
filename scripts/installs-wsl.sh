#!/bin/bash

# Installs workspace directories
# WSL updates and install packages
# Install Oh My Zsh
# Install Node
# Install pyenv and python 3.11
# Install VS Code Extensions

clear

# Set up workspace directory
FOLDER=$HOME/workspace
if [ ! -d "$FOLDER" ]; then    
  echo -e "\n\nCreating some directories that you will need..."
  mkdir -p $HOME/workspace
  mkdir -p $HOME/.ssh
  mkdir -p $HOME/.config
  mkdir -p $HOME/.npm-packages
else
  echo "Skipping directory creation"
fi
echo -e "\n\n"

# WSL Specific: Get latest updates and install packages - May take awhile but needs to run first
echo -e "\n\nUpdating the Ubuntu operating system..."
sudo apt-get update && sudo apt-get dist-upgrade -y
sudo apt install -y curl file build-essential libssl-dev libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb zsh git fonts-powerline
echo -e "\n\n"

# Switch to Zsh
ZSH_FOLDER=$HOME/.oh-my-zsh
if [ ! -d "$ZSH_FOLDER" ]; then
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed"
fi
echo -e "\n\n"

current_shell=$(echo $SHELL)
if [ $current_shell == "/bin/bash" ];
then
    echo -e "\n\n\n\n"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo "@@                                                        @@"
    echo "@@   Change Needed: Switch to zsh                         @@"
    echo "@@   This change might require your computer password.    @@"
    echo "@@                                                        @@"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    ZSH_PATH=$(which zsh) 
    chsh -s $ZSH_PATH

    new_shell=$(echo $SHELL)
    if [ $new_shell != "$ZSH_PATH" ]; then
      # The rest of the installs will not work if zsh is not the default shell
      echo "Shell did not change to zsh. Reach out to an instructor before continuing"
      exit
    fi
else
    echo "Already using zsh as default shell"
fi
echo -e "\n\n"

# Install Node - Needs to run after zsh setup
if ! command -v nvm &> /dev/null; then
  echo -e "Installing Node Version Manager..."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  source ~/.zshrc &>zsh-reload.log
fi
echo -e "\n\n"

nvm install --lts
nvm use --lts

echo -e "\n\nInstalling a web server and a simple API server..."
npm config set prefix $HOME/.npm-packages
echo 'export PATH="$PATH:$HOME/.npm-packages/bin"' >> ~/.zshrc
source ~/.zshrc &>zsh-reload.log
npm i -g serve json-server cypress
# End Node Set up
echo -e "\n\n"


PYTHON_VERSION=3.11

echo "Update Ubuntu and install required packages"
sudo apt update
sudo apt install -y gcc make build-essential openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev zlib1g-dev libncursesw5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libffi-dev python3 python3-pip wget liblzma-dev curl xz-utils libncurses5-dev python3-openssl llvm sqlite
echo -e "\n\n"

echo "Install pyenv"
curl https://pyenv.run | bash

if [ $(cat ~/.zshrc | grep -c 'Configure pyenv') != 1 ];
then
  echo Adding Pyenv Configuration
  echo -e '\n\n# Configure pyenv\n
  export PYENV_ROOT="$HOME/.pyenv"\n
  export PIPENV_DIR="$HOME/.local"\n
  export PATH="$PIPENV_DIR/bin:$PYENV_ROOT/bin:$PATH"\n

  if command -v pyenv 1>/dev/null 2>&1; then\n
    \texport PATH=$(pyenv root)/shims:$PATH\n
    \teval "$(pyenv init -)"\n
  fi\n' >> ~/.zshrc
  source ~/.zshrc
else
  echo Skipping Pyenv Configuration
fi



echo "Install pyenv"
if [ $(pyenv versions | grep -c $PYTHON_VERSION) != 1 ];
then
  echo Installing Python version $PYTHON_VERSION
  pyenv install ${PYTHON_VERSION}:latest
else
  echo Skipping $PYTHON_VERSION install
fi

INSTALLED_PYTHON_VERSION=$(pyenv versions | grep -o ${PYTHON_VERSION}'.*[0-9]' | tail -1)
pyenv global $INSTALLED_PYTHON_VERSION


if [ $(python3 --version | grep -c $INSTALLED_PYTHON_VERSION) != 1 ];
then
    echo "Could not set the global python version let an instructor know"
    return 0
fi

if [ $(python3 -m pip list | grep -c pipenv) != 1 ];
then 
  echo Install pipenv, black and pylint
  python3 -m pip install pipenv black pylint
else
  echo Skipping pipenv, black and pylint install
fi

if [[ $(which pipenv) == "pipenv not found" ]];
then
    echo "Could not find pipenv"
    return 0
fi
echo -e "\n\n"


echo "Installing VS Code Extensions"
code --install-extension ms-python.python --force \
--install-extension ms-python.vscode-pylance --force \
--install-extension ms-python.pylint --force \
--install-extension njpwerner.autodocstring --force \
--install-extension alexcvzz.vscode-sqlite --force \
--install-extension streetsidesoftware.code-spell-checker --force \
--install-extension ms-vscode-remote.remote-wsl --force \
--install-extension formulahendry.auto-rename-tag --force \
--install-extension formulahendry.code-runner --force \
--install-extension mikoz.black-py --force \
--install-extension aeschli.vscode-css-formatter --force \
--install-extension batisteo.vscode-django --force \
--install-extension janisdd.vscode-edit-csv --force \
--install-extension eamodio.gitlens --force \
--install-extension oderwat.indent-rainbow --force \
--install-extension christian-kohler.path-intellisense --force \
--install-extension timonwong.shellcheck --force \
--install-extension meganrogge.template-string-converter --force \
--install-extension samuelcolvin.jinjahtml --force

echo -e "\n\n"

echo "Setting up aliases"
echo 'alias gs="git status"' >> ~/.zshrc
echo 'alias gaa="git add --all"' >> ~/.zshrc
echo 'alias gcm="git commit -m"' >> ~/.zshrc
echo 'alias gcnb="git checkout -b"' >> ~/.zshrc
echo 'alias gc="git checkout"' >> ~/.zshrc
echo 'alias gpo="git push origin"' >> ~/.zshrc
echo 'alias gplo="git pull origin"' >> ~/.zshrc
echo 'alias gdb="git branch -d"' >> ~/.zshrc
echo 'alias pes="pipenv shell"' >> ~/.zshrc
echo 'alias prs="python manage.py runserver"' >> ~/.zshrc
echo 'alias psp="python manage.py shell_plus"' >> ~/.zshrc



echo -e "\n\n\n\n"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@                                                             @@"
echo "@@                   S U C C E S S !!!                         @@"
echo "@@                                                             @@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
