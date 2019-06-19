#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"

function setup() {
  # check vim, git, ruby and rake first
  if [[ ! -x $(which git) ]]; then
    echo Error: git currently not installed
    exit 1
  fi
  if [[ ! -x $(which ruby) ]]; then
    echo Error: ruby not installed
    exit 1
  fi
  if [[ ! -x $(which rake) ]]; then
    echo Error: rake not installed
    exit 1
  fi
  if [[ ! -x $(which go) ]]; then
    echo Error: Go not installed
    exit 1
  fi
  if [[ ! -x $(which nvim) ]] || [[ ! -x $(which vim) ]]; then
    echo Error: vim/nvim not installed
    exit 1
  fi

  # golangci_lint
  echo '  -> Installing golangci_lint'
  go get -u github.com/golangci/golangci-lint/cmd/golangci-lint
  echo '  -> golangci_lint installed'

  # install z.sh
  echo '  -> Installing z.sh'
  mkdir -p ~/.bin
  git clone https://github.com/rupa/z/ ~/.bin/z
  echo '  -> z installed!'

  # install janus
  echo '  -> Installing janus'
  curl -L https://bit.ly/janus-bootstrap | bash
  echo '  -> Creating link for neovim'
  ln -s ~/.vim ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim
  echo '  -> janus installed'

  # save dotfiles dir
  dotfiles_folder=$(pwd)
  # create ~/.janus folder and install plugins
  echo '  -> Installing vim plugins from vim-plugins.txt'
  mkdir -p ~/.janus
  cd ~/.janus
  for repo in `cat "$dotfiles_folder"/vim-plugins.txt`
  do
    git clone $repo
  done
  echo '  -> plugins installed'
  cd $dotfiles_folder

  # COC.nvim setup/install
  if [[ -x ~/.janus/coc.nvim/install.sh ]]; then
    echo '  -> running coc.nvim start.sh script'
    cd ~/.janus/coc.nvim/
    if [[ ! -x $(which yarn) ]]; then
      curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
    fi
    yarn install --frozen-lockfile
    echo '  -> coc.nvim done'
    if [[ ! -f "$dotfiles_folder"/coc-settings.json ]]; then
      touch "$dotfiles_folder"/coc-settings.json
    fi
    echo '{' > "$dotfiles_folder"/coc-settings.json
    echo '  "languageserver": {' >> "$dotfiles_folder"/coc-settings.json

    # Gopls for COC
    if [[ -x $(which go) ]] && [[ $(go version | grep 1.12) ]]; then
      echo '  -> setting up gopls for coc'
      go get -u golang.org/x/tools/cmd/gopls
      if [[ -x $(which gopls) ]]; then
        echo '  -> gopls installed'
        echo '     "golang": {' >> "$dotfiles_folder"/coc-settings.json
        echo '       "command": "gopls",' >> "$dotfiles_folder"/coc-settings.json
        echo '       "args": [],' >> "$dotfiles_folder"/coc-settings.json
        echo '       "rootPatterns": ["go.mod", ".vim/", ".git/", ".hg/"],' >> "$dotfiles_folder"/coc-settings.json
        echo '       "filetypes": ["go"]' >> "$dotfiles_folder"/coc-settings.json
        echo -n '     }' >> "$dotfiles_folder"/coc-settings.json
      fi
      rm -rf /tmp/tools
      cd $godoc_files
    fi

    # Flow for COC (javascript completion shit)
    if [[ -x $(which npm) ]]; then
      echo ' -> setting up flow for coc'
      npm install -g flow-bin
      if [[ -x $(which flow)  ]]; then
        echo ' -> flow installed'
        echo ',' >> "$dotfiles_folder"/coc-settings.json
        echo '     "flow": {' >> "$dotfiles_folder"/coc-settings.json
        echo '       "command": "flow",' >> "$dotfiles_folder"/coc-settings.json
        echo '       "args": ["lsp"],' >> "$dotfiles_folder"/coc-settings.json
        echo '       "initializationOptions": {},' >> "$dotfiles_folder"/coc-settings.json
        echo '       "settings": {},' >> "$dotfiles_folder"/coc-settings.json
        echo '       "requireRootPattern": true,' >> "$dotfiles_folder"/coc-settings.json
        echo '       "rootPatterns": [".flowconfig"],' >> "$dotfiles_folder"/coc-settings.json
        echo '       "filetypes": ["javascript", "javascriptreact"]' >> "$dotfiles_folder"/coc-settings.json
        echo -n '     }' >> "$dotfiles_folder"/coc-settings.json
      fi
    fi

    echo '' >> "$dotfiles_folder"/coc-settings.json
    echo '  }' >> "$dotfiles_folder"/coc-settings.json
    echo '}' >> "$dotfiles_folder"/coc-settings.json

    echo ' -> moving config file to .vim folder'
    mv "$dotfiles_folder"/coc-settings.json ~/.vim/coc-settings.json
    echo ' -> done'
  fi
}

function doIt() {
  rsync --exclude ".git/" --exclude ".DS_Store" --exclude "start.sh" \
    --exclude "setup.sh" --exclude "fonts" --exclude "vim-plugins.txt" \
    --exclude "README.txt" --exclude "LICENSE-MIT.txt" -av --no-perms . ~
  source ~/.bash_profile
}

if [ "$1" == "--setup" -o "$1" == "-s" ] || [ "$2" == "--setup" -o "$2" == "-s" ]; then
  setup
fi

if [ "$1" == "--force" -o "$1" == "-f" ] || [ "$2" == "--force" -o "$2" == "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi

unset setup
unset doIt
