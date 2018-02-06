patch_mixer_toplevel() {
 if [ "$1" != "updateonly" ] && [ "$(grep "<ctl name=\"$1\" value=\".*\" />" $MODPATH/$NAME)" ]; then
   sed -i "0,/<ctl name=\"$1\" value=\".*\" \/>/ s/\(<ctl name=\"$1\" value=\"\).*\(\" \/>\)/\1$2\2/" $MODPATH/$NAME
 elif [ "$1" != "updateonly" ]; then
   sed -i "/<mixer>/ a\    <ctl name=\"$1\" value=\"$2\" \/>" $MODPATH/$NAME
 else
   sed -i "/<mixer>/ a\    <ctl name=\"$2\" value=\"$3\" \/>" $MODPATH/$NAME
 fi
}
QCP=
AP=
FMAS=
SHB=
OAP=
ASP=
TMSM=
QCNEW=
QCOLD=
BIT=
IMPEDANCE=
RESAMPLE=
BTRESAMPLE=
AX7=
LX3=
X9=
Z9=
Z9M=
Z11=
V20=
V30=
G6=
QC8996=
QC8998=
APTX=
M8=
M9=
M10=
COMP=
for FILE in ${FILES}; do
  NAME=$(echo "$FILE" | sed "s|$MOD|system|")
  case $NAME in
  *audio_effects*) $ASP && patch_cfgs $MODPATH/$NAME audiosphere audiosphere $LIBDIR/libasphere.so 184e62ab-2d19-4364-9d1b-c0a40733866c
                   $SHB && patch_cfgs $MODPATH/$NAME shoebox shoebox $LIBDIR/libshoebox.so 1eab784c-1a36-4b2a-b7fc-e34c44cab89e 
                   $FMAS || break
                   case $NAME in
                     "system/etc"*) ;;
                     *) patch_cfgs $MODPATH/$NAME libraryonly fmas $LIBDIR/libfmas.so
                        case $FILE in
                          *.conf) [ ! "$(sed -n "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ {/uuid 36103c50-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  virtualizer {/,/^  }/ s/library bundle.*/library fmas/; s/uuid 1d4033c0-8557-11df-9f2d-0002a5d5c51b.*/uuid 36103c50-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME
                                  [ ! "$(sed -n "/^effects {/,/^}/ {/^  downmix {/,/^  }/ {/uuid 36103c50-8514-11e2-9e96-0800200c9a66/p}}" $MODPATH/$NAME)" ] && sed -i "/^effects {/,/^}/ {/^  downmix {/,/^  }/ s/library downmix.*/library fmas/; s/uuid 93f04452-e4fe-41cc-91f9-e475b6d1d69f.*/uuid 36103c51-8514-11e2-9e96-0800200c9a66/}" $MODPATH/$NAME;;
                          *) [ ! "$(sed -n "/<effects>/,/<\/effects>/ {/<effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/p}" $MODPATH/$NAME)" ] && sed -i "/<effects>/ s/<effect name=\"virtualizer\".*/>/<effect name=\"virtualizer\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/" $MODPATH/$NAME
                             [ ! "$(sed -n "/<effects>/,/<\/effects>/ {/<effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/p}" $MODPATH/$NAME)" ] && sed -i "/<effects>/ s/<effect name=\"downmix\".*/>/<effect name=\"downmix\" library=\"fmas\" uuid=\"36103c50-8514-11e2-9e96-0800200c9a66\"\/>/" $MODPATH/$NAME;;
                        esac;;
                   esac;;
  "system/etc/audio_policy.conf") $AP || break
                                  for AUD in "direct_pcm" "direct" "raw" "multichannel" "compress_offload" "high_res_audio"; do
                                    if [ "$AUD" != "compress_offload" ]; then
                                      sed -i "/$AUD {/,/}/ s/formats.*/formats AUDIO_FORMAT_PCM_8_24_BIT/g" $MODPATH/system/etc/audio_policy.conf
                                    fi
                                    if [ "$AUD" == "direct_pcm" ] || [ "$AUD" == "direct" ] || [ "$AUD" == "raw" ]; then
                                      sed -i "/$AUD {/,/}/ s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $MODPATH/system/etc/audio_policy.conf
                                    fi
                                    sed -i "/$AUD {/,/}/ s/sampling_rates.*/sampling_rates 8000\|11025\|16000\|22050\|32000\|44100\|48000\|64000\|88200\|96000\|176400\|192000\|352800\|384000/g" $MODPATH/system/etc/audio_policy.conf
                                  done;;
  "system/vendor/etc/audio_policy.conf") $OAP || break
                                         for AUD in "default" "direct" "proaudio" "direct_pcm" "direct_pcm_24" "raw" "compress_offload_16" "compress_offload_24" "compress_offload_HD"; do
                                           if [[ "$AUD" != "compress_offload"* ]]; then
                                             sed -i "/$AUD {/,/}/ s/formats.*/formats AUDIO_FORMAT_PCM_16_BIT\|AUDIO_FORMAT_PCM_24_BIT_PACKED\|AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_32_BIT/g" $MODPATH/system/vendor/etc/audio_output_policy.conf
                                           fi
                                           if [ "$AUD" == "direct" ]; then
                                             if [ "$(grep "compress_offload" /system/vendor/etc/audio_output_policy.conf)" ]; then
                                               sed -i "/$AUD {/,/}/ s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM\|AUDIO_OUTPUT_FLAG_COMPRESS_OFFLOAD\|AUDIO_OUTPUT_FLAG_NON_BLOCKING/g" $MODPATH/system/vendor/etc/audio_output_policy.conf
                                             else
                                               sed -i "/$AUD {/,/}/ s/flags.*/flags AUDIO_OUTPUT_FLAG_DIRECT\|AUDIO_OUTPUT_FLAG_DIRECT_PCM/g" $MODPATH/system/vendor/etc/audio_output_policy.conf
                                             fi
                                           fi
                                           sed -i "/$AUD {/,/}/ s/sampling_rates.*/sampling_rates 44100\|48000\|96000\|176400\|192000\|352800\|384000/g" $MODPATH/system/vendor/etc/audio_output_policy.conf
                                           [ -z $BIT ] || sed -i "/$AUD {/,/}/ s/bit_width.*/bit_width $BIT/g" $MODPATH/system/vendor/etc/audio_output_policy.conf
                                         done;;            
  "system/etc/audio_policy_configuration.xml") $AP || break
                                               sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"primary output\"/,/ ^*<\/mixPort>/ {s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"48000,96000,192000\"\1/}}" $MODPATH/system/etc/audio_policy_configuration.xml
                                               sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"raw\"/,/<\/mixPort>/ s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/}" $MODPATH/system/etc/audio_policy_configuration.xml
                                               sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"deep_buffer\"/,/<\/mixPort>/ {s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"192000\"\1/}}" $MODPATH/system/etc/audio_policy_configuration.xml
                                               sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"multichannel\"/,/<\/mixPort>/ {s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"44100,48000,64000,88200,96000,128000,176400,192000\"\1/}}" $MODPATH/system/etc/audio_policy_configuration.xml
                                               sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"direct_pcm\"/,/<\/mixPort>/ {s/format=\".*\"\(.*\)/format=\"AUDIO_FORMAT_PCM_8_24_BIT\|AUDIO_FORMAT_PCM_16_BIT\"\1/; s/samplingRates=\".*\"\(.*\)/samplingRates=\"48000,96000,192000\"\1/}}" $MODPATH/system/etc/audio_policy_configuration.xml
                                               sed -i "/<module name=\"primary\"/,/<\/module>/ {/<mixPort name=\"compress_offload\"/,/<\/mixPort>/ s/channelMasks=\".*\"\(.*\)/channelMasks=\"AUDIO_CHANNEL_OUT_PENTA\|AUDIO_CHANNEL_OUT_5POINT1\|AUDIO_CHANNEL_OUT_6POINT1\|AUDIO_CHANNEL_OUT_7POINT1\"\1/}" $MODPATH/system/etc/audio_policy_configuration.xml;;
  *mixer_paths*.xml) if [ "$QCP" ]; then
                       if [ "$BIT" ]; then
                         patch_mixer_toplevel "SLIM_0_RX Format" "$BIT" $MODPATH/$NAME
                         patch_mixer_toplevel "SLIM_5_RX Format" "$BIT" $MODPATH/$NAME
                         [ ! -z $QC8996 -o ! -z $QC8998 ] && patch_mixer_toplevel "SLIM_6_RX Format" "$BIT" $MODPATH/$NAME
                         patch_mixer_toplevel "USB_AUDIO_RX Format" "$BIT" $MODPATH/$NAME
                         patch_mixer_toplevel "HDMI_RX Bit Format" "$BIT" $MODPATH/$NAME
                       fi
                       if [ "$IMPEDANCE" ]; then
                         patch_mixer_toplevel "HPHR Impedance" "$IMPEDANCE" $MODPATH/$NAME
                         patch_mixer_toplevel "HPHL Impedance" "$IMPEDANCE" $MODPATH/$NAME
                       fi
                       if [ "$RESAMPLE" ]; then
                         patch_mixer_toplevel "SLIM_0_RX SampleRate" "$RESAMPLE" $MODPATH/$NAME
                         patch_mixer_toplevel "SLIM_5_RX SampleRate" "$RESAMPLE" $MODPATH/$NAME
                         [ ! -z $QC8996 -o ! -z $QC8998 ] && patch_mixer_toplevel "SLIM_6_RX SampleRate" "$RESAMPLE" $MODPATH/$NAME
                         patch_mixer_toplevel "USB_AUDIO_RX SampleRate" "$RESAMPLE" $MODPATH/$NAME
                         patch_mixer_toplevel "HDMI_RX SampleRate" "$RESAMPLE" $MODPATH/$NAME  
                       fi
                       if [ "$BTRESAMPLE" ]; then
                         patch_mixer_toplevel "BT SampleRate" "$BTRESAMPLE" $MODPATH/$NAME
                       fi
                       if [ "$AX7" ]; then
                         patch_mixer_toplevel "AKM HIFI Switch Sel" "ak4490" $MODPATH/$NAME "updateonly"
                         patch_mixer_toplevel "Smart PA Init Switch" "On" $MODPATH/$NAME 
                         patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $MODPATH/$NAME 
                         patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $MODPATH/$NAME 
                       fi
                       if [ "$LX3" ]; then
                         patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $MODPATH/$NAME
                         patch_mixer_toplevel "ESS_HEADPHONE Off" "On" $MODPATH/$NAME
                       fi
                       if [ "$X9" ]; then
                         patch_mixer_toplevel "Es9018 CLK Divider" "DIV4" $MODPATH/$NAME
                         patch_mixer_toplevel "Es9018 Hifi Switch" "1" $MODPATH/$NAME
                       fi   
                       if [ "$Z9" ] || [ "$Z9M" ]; then
                         patch_mixer_toplevel "HP Out Volume" "22" $MODPATH/$NAME
                         patch_mixer_toplevel "ADC1 Digital Filter" "sharp_roll_off_88" $MODPATH/$NAME
                         patch_mixer_toplevel "ADC2 Digital Filter" "sharp_roll_off_88" $MODPATH/$NAME
                       fi
                       if [ "$Z11" ]; then
                         patch_mixer_toplevel "AK4376 DAC Digital Filter Mode" "Slow Roll-Off" $MODPATH/$NAME
                         patch_mixer_toplevel "AK4376 HPL Power-down Resistor" "Hi-Z" $MODPATH/$NAME
                         patch_mixer_toplevel "AK4376 HPR Power-down Resistor" "Hi-Z" $MODPATH/$NAME
                         patch_mixer_toplevel "AK4376 HP-Amp Analog Volume" "15" $MODPATH/$NAME
                       fi
                       if [ "$V20" ] || [ "$V30" ] || [ "$G6" ]; then
                         patch_mixer_toplevel "Es9018 AVC Volume" "14" $MODPATH/$NAME
                         patch_mixer_toplevel "Es9018 HEADSET TYPE" "1" $MODPATH/$NAME
                         patch_mixer_toplevel "Es9018 State" "Hifi" $MODPATH/$NAME
                         patch_mixer_toplevel "HIFI Custom Filter" "6" $MODPATH/$NAME
                       fi  
                       if [ -f "/system/etc/TAS2557_A.ftcfg" ]; then 
                         patch_mixer_toplevel "HTC_AS20_VOL Index" "Eleven" $MODPATH/$NAME
                       fi 
                       if [ "$QC8996" ] || [ "$QC8998" ]; then 
                         patch_mixer_toplevel "VBoost Ctrl" "AlwaysOn" $MODPATH/$NAME
                         patch_mixer_toplevel "VBoost Volt" "8.6V" $MODPATH/$NAME
                       fi
                       patch_mixer_toplevel "Set Custom Stereo OnOff" "Off" $MODPATH/$NAME
                       if $APTX; then  
                         patch_mixer_toplevel "APTX Dec License" "21" $MODPATH/$NAME
                       fi
                       patch_mixer_toplevel "Set HPX OnOff" "1" $MODPATH/$NAME
                       patch_mixer_toplevel "Set HPX ActiveBe" "1" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 9 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 13 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 17 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 21 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 24 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 15 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "PCM_Dev 33 Topology" "DTS" $MODPATH/$NAME
                       patch_mixer_toplevel "DS2 OnOff" "Off" $MODPATH/$NAME	
                       patch_mixer_toplevel "Codec Wideband" "1" $MODPATH/$NAME
                       patch_mixer_toplevel "HPH Type" "1" $MODPATH/$NAME
                       if $ASP; then
                         patch_mixer_toplevel "Audiosphere Enable" "On" $MODPATH/$NAME
                         patch_mixer_toplevel "MSM ASphere Set Param" "1" $MODPATH/$NAME
                       fi   
                       if [ "$M9" ] || [ "$M8" ] || [ "$M10" ]; then
                         patch_mixer_toplevel "TFA9895 Profile" "hq" $MODPATH/$NAME
                         patch_mixer_toplevel "TFA9895 Playback Volume" "255" $MODPATH/$NAME
                         patch_mixer_toplevel "SmartPA Switch" "1" $MODPATH/$NAME
                       fi	 
                       patch_mixer_toplevel "TAS2552 Volume" "125" $MODPATH/$NAME "updateonly"
                       if [ -f "/system/etc/TAS2557_A.ftcfg" ]; then
                         patch_mixer_toplevel "TAS2557 Volume" "30" $MODPATH/$NAME
                       fi 
                       patch_mixer_toplevel "SRS Trumedia" "1" $MODPATH/$NAME
                       patch_mixer_toplevel "SRS Trumedia HDMI" "1" $MODPATH/$NAME
                       patch_mixer_toplevel "SRS Trumedia I2S" "1" $MODPATH/$NAME
                       patch_mixer_toplevel "SRS Trumedia MI2S" "1" $MODPATH/$NAME       
                       patch_mixer_toplevel "HiFi Function" "On" $MODPATH/$NAME 
                       if $COMP; then
                         sed -i "/<ctl name=\"COMP*[0-9] Switch\"/p" $MODPATH/$NAME
                         sed -i "/<ctl name=\"COMP*[0-9] Switch\"/ { s/\(.*\)value=\".*\" \/>/\1value=\"0\" \/><!--$MODID-->/; n; s/\( *\)\(.*\)/\1<!--$MODID\2$MODID-->/}" $MODPATH/$NAME
                       fi 
                     fi;;
  esac
done
