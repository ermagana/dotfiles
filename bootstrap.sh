#!/usr/bin/env bash
curdir=$(dirname $0)
home=~

if [ "$curdir" == "." ]
  then
    curdir=$PWD
  else
    curdir="$PWD/$curdir"
fi

echo $home
echo $curdir

# Add depencies first
source $curdir/install-deps.sh

case "`uname -s`" in
  MINGW*)
    cmdslash="//"
    ;;

  Linux*)
    cmdslash="/"
    ;;

  CYGW*)
    cmdslash="/"
    ;;

  *)
    echo "This script should only be run under Linux, MSYS or Cygwin."
    exit 1
    ;;
esac

mklink=`bash "$curdir/testmklink.sh"`

if [ $? -eq 2 ]; then
    mklink="ln -s"
elif [ -z "$mklink" ]; then
    echo "Won't be able to make symbolic links"
    exit 1
fi

# Convert to windows style slashing
wpath() # posix
{
  # TODO: Use cygpath under Cygwin.  
  cmd ${cmdslash}c echo "$1" | sed 's/\//\\/g'
}

symlink() # target, link
{
  target=$1
  link=$2
  
  if [ "$mklink" = "ln -s" ]; then
    $mklink $target $link 
  elif [ -d "$target" ]; then
    $mklink ${cmdslash}d "`wpath $link`" "`wpath $target`"
  else
    #echo "`wpath $link`" "`wpath $target`"
    echo "$mklink `wpath $link` `wpath $target`"
    $mklink "`wpath $link`" "`wpath $target`"
  fi
}

for file in `ls $curdir -A --ignore="*.md" --ignore="*.txt" --ignore="*.sh" --ignore=".git*" --ignore="sublimetext3"`
do
  if ! [ -e ~/$file ]
    then
    symlink "$curdir/$file" "$home/$file"
    # cmd link
  fi
done

# manually set the .git folder :(
# symlink "$curdir/.gitignore" "$home/.gitignore"
if ! [ -e $home/.gitconfig ]
  then
  symlink "$curdir/.gitconfig" "$home/.gitconfig"
fi

curdir="$curdir/sublimetext3"
home="$APPDATA\Sublime Text 3\Packages\User"

if ! [ -d "$home" ]
  then
  mkdir -p "$home"
fi

IFS=$(echo -en "\n\b")

for file in `ls $curdir -A`
do
  #echo "file to be tested is $file"
  if ! [ -e "$home/$file" ]
    then
    symlink "$curdir/$file" "$home/$file"
    # cmd link
  else
    echo "file exists $home/$file"
  fi
done

IFS=$SAVEIFS

unset link
unset file

source ~/.bash_profile
