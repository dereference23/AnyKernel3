### AnyKernel custom methods
## dereference23@github.com

check_cmdline() {
  if [ -f $AKHOME/cmdline ]; then
    sed -i '/^cmdline/d' $SPLITIMG/header;
    echo cmdline=$(tr '\n' ' ' < $AKHOME/cmdline) >> $SPLITIMG/header;
  fi;
}

check_ksu() {
  if [ -e $AKHOME/KSU_UNLOCK -a -f $AKHOME/ksu.bdf ]; then
    ui_print " " "Flashing KernelSU version...";
    ui_print "This is not secure!";
    bspatch $AKHOME/Image $AKHOME/Image_KSU $AKHOME/ksu.bdf;
    mv -f $AKHOME/Image_KSU $AKHOME/Image;
  fi;
}

check_twrp() {
  if [ -e $AKHOME/TWRP_LOCK ]; then
    ui_print " " "TWRP will be disabled.";
    sed -i '$ s/$/ ignore_builtin_recovery/' $SPLITIMG/header;
  fi;
}
