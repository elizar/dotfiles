[OVERVIEW]

  This is a stripped down version of my old dotfiles. I've only included the
  essential stuff here. Mostly for `Go` and `Javascript` development.

  Platforms that I've used this setup on are:

    MacOS and ArchLinux



[PREREQUISITES]

  Inside the `fonts/` folder, there are 3 patched nerd fonts that
  will enable dev-icons vim plugin.

  Install them and choose one as your terminal font.



[REQUIREMENTS]

  › Ruby with Rake (pre-installed on MacOS)
  › Python (also comes pre-installed with MacOS)
  › Go (1.12 abover is recommended)
  › Node with Yarn
  › Vim / NeoVim (the latter is better)
  › Git
  › Gpg
  › Ack or Ag (https://github.com/ggreer/the_silver_searcher)

  Note: Make sure you have everything listed above before continuing.



[SETUP]

  Run the script with:

    $ ./start.sh

    Optional flags:
    --setup Force initial setup.
         -s
    --force Force sync. Will override existing files.
         -f



[CUSTOMIZATION]

  You add your own PATH and EXPORTS without touching the `.exports` file by
  creating `.exports.after` file in your home dir.

  For `.vimrc`. Just create a `.vimrc.extra` file in your home dir and add
  all your custom vim configs there.



Cheers,

Elizar
