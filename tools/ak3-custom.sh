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

check_vendor_hals() {
  grep -q "/vendor " /proc/mounts || mount /vendor;
  if [ $? -eq 0 ]; then
    if grep -qs is_miuicamera_app /vendor/lib/hw/audio.primary.*.so; then
      ui_print " " "Stock Audio HAL detected.";
      fdtput $AKHOME/dtb /soc/qcom,msm-audio-apr/qcom,q6core-audio/sound qcom,aw88261-model -d;
      fdtput $AKHOME/dtb /soc/qcom,msm-audio-apr/qcom,q6core-audio/sound qcom,fs1962-model -d;
      dtb_patched=1;
    fi;
    if grep -qs displayfeature /vendor/bin/hw/vendor.qti.hardware.display.composer-service; then
      ui_print " " "Stock Display HAL detected.";
      fdtput $AKHOME/dtb /soc/qcom,mdss_mdp@5e00000/qcom,mdss_dsi_k6s_38_0c_0a_fhdp_dsc_vid qcom,mdss-pan-physical-width-dimension 695;
      fdtput $AKHOME/dtb /soc/qcom,mdss_mdp@5e00000/qcom,mdss_dsi_k6s_38_0c_0a_fhdp_dsc_vid qcom,mdss-pan-physical-height-dimension 1546;
      dtb_patched=1;
    fi;
    if [ -e /vendor/lib64/hw/consumerir.default.so -o -e /vendor/lib64/hw/consumerir.holi.so ]; then
      ui_print " " "Stock IR HAL detected.";
      fdtput $AKHOME/dtb /soc/spi@4c84000/irled@0 compatible ir-spi-xiaomi -t s;
      dtb_patched=1;
    fi;
    if [ "$dtb_patched" -eq 1 ]; then
      ui_print " " "Using patched dtb...";
    fi;
  else
      ui_print " " "Failed to mount /vendor. Using default dtb...";
  fi;
}

erase_dtbo() {
  dd if=/dev/zero of=/dev/block/by-name/dtbo$SLOT conv=fsync count=1 bs=$(blockdev --getsize64 /dev/block/by-name/dtbo$SLOT);
}
