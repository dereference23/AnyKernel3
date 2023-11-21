### AnyKernel custom methods
## dereference23@github.com

check_cmdline() {
  if [ -f $AKHOME/cmdline ]; then
    sed -i '/^cmdline/d' $SPLITIMG/header;
    echo cmdline=$(tr '\n' ' ' < $AKHOME/cmdline) >> $SPLITIMG/header;
  fi;
}
