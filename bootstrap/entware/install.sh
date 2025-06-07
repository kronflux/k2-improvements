#!/bin/ash
# Entware package manager installation script for K2 Plus
# Installs Entware to /mnt/UDISK/opt with proper symlinks and service management

cd $(dirname ${0})

# Clear any existing library paths that might interfere
unset LD_LIBRARY_PATH
unset LD_PRELOAD

# Entware configuration for ARM architecture
LOADER=ld-linux.so.3
GLIBC=2.29

echo -e "Info: Removing old directories..."
rm -rf /opt
rm -rf /mnt/UDISK/opt

echo -e "Info: Creating directory..."
mkdir -p /mnt/UDISK/opt

echo -e "Info: Linking folder..."
ln -snf /mnt/UDISK/opt /opt

echo -e "Info: Creating subdirectories..."
for folder in bin etc lib/opkg tmp var/lock
do
  mkdir -p /mnt/UDISK/opt/$folder
done

echo -e "Info: Downloading opkg package manager from Entware repo..."
chmod 755 ./wget-ssl.py
PRIMARY_URL="https://bin.entware.net/armv7sf-k3.2/installer"
MIRROR_URL="https://entware.diversion.ch/armv7sf-k3.2/installer"
URL=""

download_files() {
  local url="$1"
  local output_file="$2"
  ./wget-ssl.py "$url" -O "$output_file"
  return $?
}

if download_files "$PRIMARY_URL/opkg" "/opt/bin/opkg"; then
  URL=$PRIMARY_URL
  download_files "$URL/opkg.conf" "/opt/etc/opkg.conf"
elif download_files "$MIRROR_URL/opkg" "/opt/bin/opkg"; then
  URL=$MIRROR_URL
  download_files "$URL/opkg.conf" "/opt/etc/opkg.conf"
  echo "Info: updating opkg.conf to use mirror..."
  sed -i 's|http[s]*://bin.entware.net|https://entware.diversion.ch|g' /opt/etc/opkg.conf
else
  echo -e "Info: Failed to download from Entware repos..."
  rm -rf /opt
  rm -rf /mnt/UDISK/opt
  exit 1
fi

echo -e "Info: Applying permissions..."
chmod 755 /opt/bin/opkg
chmod 777 /opt/tmp

# Temporarily use Python wget for bootstrap (K2 doesn't have full wget with SSL)
cp wget-ssl.py /bin/wget

echo -e "Info: Installing basic packages..."
/opt/bin/opkg update
# Replace bootstrap wget with proper wget-ssl from Entware
/opt/bin/opkg install wget-ssl
rm -f /bin/wget
# Ensure Entware binaries are in PATH for subsequent commands
export PATH=/opt/bin:$PATH
/opt/bin/opkg install \
  curl \
  entware-opt \
  git \
  git-http \
  jq \
  openssl-util \
  unzip

echo -e "Info: Replacing system certificate store..."
# Create a timestamped backup of the original certificates
tar -czf /etc/ssl/system-certs-backup-$(date +%F).tar.gz /etc/ssl/certs /etc/ssl/cert.pem
# Download the latest trusted CA bundle from the cURL project
wget -O /tmp/cacert.pem https://curl.se/ca/cacert.pem
if [ $? -eq 0 ]; then
    echo "Info: New certificate bundle downloaded successfully."
    # Clean out the old certificates
    rm -f /etc/ssl/certs/*
    rm -f /etc/ssl/cert.pem
    # Install the new bundle
    cp /tmp/cacert.pem /etc/ssl/cert.pem
    # Split the bundle into individual, meaningfully-named files (ash-compatible)
    cert_count=0
    while IFS= read -r line; do
      cert_body="${cert_body}${line}\n"
      if [ "$line" = "-----END CERTIFICATE-----" ]; then
        subject=$(echo -e "$cert_body" | /opt/bin/openssl x509 -subject -noout -nameopt multiline | grep "commonName\|organizationName" | head -1)
        filename=$(echo "$subject" | sed -e 's/.*= //' -e 's/[^a-zA-Z0-9._-]/_/g' -e 's/__*/_/g')
        if [ -z "$filename" ]; then
          cert_count=$((cert_count + 1))
          filename="unnamed_cert_${cert_count}"
        fi
        if [ -f "/etc/ssl/certs/${filename}.crt" ]; then
            count=2
            while [ -f "/etc/ssl/certs/${filename}_${count}.crt" ]; do
                count=$((count + 1))
            done
            filename="${filename}_${count}"
        fi
        echo -e "$cert_body" > "/etc/ssl/certs/${filename}.crt"
        cert_body=""
      fi
    done < /tmp/cacert.pem
    # Re-create the hashed symlinks for fast lookups
    /opt/bin/openssl rehash /etc/ssl/certs
    echo "Info: System certificates updated."
else
    echo "Warning: Failed to download new certificate bundle. Leaving system certificates untouched."
fi
# Clean up the temporary file
rm -f /tmp/cacert.pem

echo -e "Info: Installing SFTP server support..."
/opt/bin/opkg install openssh-sftp-server
ln -snf /opt/libexec/sftp-server /usr/libexec/sftp-server

echo -e "Info: Configuring system integration..."
# Link system user/group files to Entware
for file in passwd group shells shadow gshadow; do
  if [ -f /etc/$file ]; then
    ln -snf /etc/$file /opt/etc/$file
  else
    [ -f /opt/etc/$file.1 ] && cp /opt/etc/$file.1 /opt/etc/$file
  fi
done

# Link timezone information
[ -f /etc/localtime ] && ln -snf /etc/localtime /opt/etc/localtime

echo -e "Info: Updating system PATH..."
# Add Entware binaries to system PATH for all users
mkdir -p /etc/profile.d
echo 'export PATH="/opt/bin:/opt/sbin:$PATH"' > /etc/profile.d/entware.sh

echo -e "Info: Setting up Entware service management..."
# Install Entware service manager (unslung) with debug logging
cp unslung.init /etc/init.d/unslung
chmod 755 /etc/init.d/unslung
# Create symlinks for automatic startup/shutdown
ln -snf /etc/init.d/unslung /etc/rc.d/S99unslung  # Start late in boot process
ln -snf /etc/init.d/unslung /etc/rc.d/K01unslung  # Stop early in shutdown
