#!/system/bin/sh

#
# To be run with the /system/system.prop (system.prop) and
# /vendor/system.prop (vendor-system.prop) from the stock
# ROM of a device you want to spoof values from

# Command line options:
# "prop" forces prop format instead of default json
# "all" forces sometimes optional fields like SECURITY_PATCH to always be included
# "deprecated" forces the use of extra/incorrect chiteroman PIF fields and names
# "advanced" adds the verbose logging module setting entry

# credits to chiteroman and osm0sis and x1337cn
# This script needs v15.2 play integrity fix by chiteroman
# https://github.com/chiteroman/PlayIntegrityFix/releases/download/v15.2/PlayIntegrityFix_v15.2.zip
# script modified by mohamedamrnady, to be compatible with pixel props
N="
";

echo "system system.prop to custom.pif.json/.prop creator \
    $N  by osm0sis @ xda-developers";

item() { echo "$N- $@"; }
die() { echo "$N$N! $@"; exit 1; }
file_getprop() { grep -m1 "^$2=" "$1" 2>/dev/null | cut -d= -f2-; }

if [ -d "$1" ]; then
  DIR="$1/dummy";
  LOCAL="$(readlink -f "$PWD")";
  shift;
else
  case "$0" in
    *.sh) DIR="$0";;
       *) DIR="$(lsof -p $$ 2>/dev/null | grep -o '/.*gen_pif_custom.sh$')";;
  esac;
fi;
DIR=$(dirname "$(readlink -f "$DIR")");
if [ "$LOCAL" ]; then
  item "Using prop directory: $DIR";
  item "Using output directory: $LOCAL";
  LOCAL="$LOCAL/";
fi;
cd "$DIR";

FORMAT=json;
PROP_FILE="$MODPATH/system.prop"
ALLFIELDS=false;
OLDFIELDS=false;
ADVANCED=false;
until [ -z "$1" ]; do
  case $1 in
    json|prop) FORMAT=$1; shift;;
    all) ALLFIELDS=true; shift;;
    deprecated) OLDFIELDS=true; STYLE="(Deprecated)"; shift;;
    advanced) ADVANCED=true; [ -z "$STYLE" ] && STYLE="(Advanced)"; shift;;
  esac;
done;
item "Using format: $FORMAT $STYLE";

[ ! -f "$PROP_FILE" ]  \
   && die "No system.prop files found in script directory";

item "Parsing system.prop(s) ...";


  _comment="https://t.me/PixelProps"
  PRODUCT=$(file_getprop "$PROP_FILE" ro.product.name);
  DEVICE=$(file_getprop "$PROP_FILE" ro.product.device);
  MANUFACTURER=$(file_getprop "$PROP_FILE" ro.product.manufacturer);
  BRAND=$(file_getprop "$PROP_FILE" ro.product.brand);
  MODEL=$(file_getprop "$PROP_FILE" ro.product.model);
  FINGERPRINT=$(file_getprop "$PROP_FILE" ro.build.fingerprint);

  [ -z "$PRODUCT" ] && PRODUCT=$(file_getprop "$PROP_FILE" ro.product.system.name);
  [ -z "$DEVICE" ] && DEVICE=$(file_getprop "$PROP_FILE" ro.product.system.device);
  [ -z "$MANUFACTURER" ] && MANUFACTURER=$(file_getprop "$PROP_FILE" ro.product.system.manufacturer);
  [ -z "$BRAND" ] && BRAND=$(file_getprop "$PROP_FILE" ro.product.system.brand);
  [ -z "$MODEL" ] && MODEL=$(file_getprop "$PROP_FILE" ro.product.system.model);
  [ -z "$FINGERPRINT" ] && FINGERPRINT=$(file_getprop "$PROP_FILE" ro.system.build.fingerprint);

if [ -z "$FINGERPRINT" ]; then
  if [ -f "$PROP_FILE" ]; then
    die "No fingerprint found, use a /system/system.prop to start";
  else
    die "No fingerprint found, unable to continue";
  fi;
fi;
echo "$FINGERPRINT";

LIST="_comment MANUFACTURER MODEL FINGERPRINT BRAND PRODUCT DEVICE";
BUILD_ID=$(file_getprop "$PROP_FILE" ro.product.build.id);
[ ! -z "$BUILD_ID" ] && LIST="$LIST BUILD_ID";

if ! $ALLFIELDS; then
  item "Parsing build UTC date ...";
  UTC=$(file_getprop "$PROP_FILE" ro.build.date.utc);
  [ -z "$UTC" ] && UTC=$(file_getprop "$PROP_FILE" ro.build.date.utc);
  date -u -d @$UTC;
fi;

if [ "$UTC" -gt 1521158400 ] || $ALLFIELDS; then
  $ALLFIELDS || item "Build date newer than March 2018, adding SECURITY_PATCH ...";
  SECURITY_PATCH=$(file_getprop "$PROP_FILE" ro.build.version.security_patch);
  [ -z "$SECURITY_PATCH" ] && SECURITY_PATCH=$(file_getprop "$PROP_FILE" ro.build.version.security_patch);
  LIST="$LIST SECURITY_PATCH";
  $ALLFIELDS || echo "$SECURITY_PATCH";
fi;

item "Parsing build first API level ...";
  FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.product.first_api_level);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.board.first_api_level);
  [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.board.api_level);

  if [ -z "$FIRST_API_LEVEL" ]; then
    [ ! -f vendor-"$PROP_FILE" ] && die "No first API level found, add vendor-"$PROP_FILE"";
    item "No first API level found, falling back to build SDK version ...";
    [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.build.version.sdk);
    [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.system.build.version.sdk);
    [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.build.version.sdk);
    [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.system.build.version.sdk);
    [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.vendor.build.version.sdk);
    [ -z "$FIRST_API_LEVEL" ] && FIRST_API_LEVEL=$(file_getprop "$PROP_FILE" ro.product.build.version.sdk);
  fi;
  echo "$FIRST_API_LEVEL";

  if [ "$FIRST_API_LEVEL" -gt 32 ]; then
    item "First API level 33 or higher, resetting to 32 ...";
    FIRST_API_LEVEL=32;
  fi;
  [ ! -z "$FIRST_API_LEVEL" ] && LIST="$LIST FIRST_API_LEVEL";
  
if $OLDFIELDS; then
  VNDK_VERSION=$(file_getprop "$PROP_FILE" ro.vndk.version);
  [ -z "$VNDK_VERSION" ] && VNDK_VERSION=$(file_getprop "$PROP_FILE" ro.product.vndk.version);
  [ ! -z "$VNDK_VERSION" ] && LIST="$LIST VNDK_VERSION";
fi;

if [ -f "$LOCAL"pif.$FORMAT ]; then
  item "Removing existing custom.pif.$FORMAT ...";
  rm -f "$LOCAL"pif.$FORMAT;
fi;

{
item "Writing new custom.pif.$FORMAT ...";
  [ "$FORMAT" == "json" ] && echo '{' | tee -a "$LOCAL"pif.json;
  for PROP in $LIST; do
    case $FORMAT in
      json) eval echo '\ \ \"$PROP\": \"'\$$PROP'\",';;
      prop) eval echo $PROP=\$$PROP;;
    esac;
  done | sed '$s/,//' | tee -a "$LOCAL"pif.$FORMAT;
  [ "$FORMAT" == "json" ] && echo '}' | tee -a "$LOCAL"pif.json;

  echo
  echo "Patch Done!"
  su -c killall com.google.android.gms.unstable
  echo "Killed Google Play Services!"
  cp "$LOCAL"pif.json /data/adb/;
  cp "$LOCAL"pif.json /data/adb/modules/playintegrityfix/;
  rm -f "$LOCAL"pif.json
  echo "Custom PIF moved!"
}

echo "Thanks to Chiteroman and osm0sis and x1337cn"
