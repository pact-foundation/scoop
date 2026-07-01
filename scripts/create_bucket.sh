#!/bin/bash

# REPO=${REPO:-https://github.com/pact-foundation/pact-reference.git}
TOOL_NAME=${TOOL_NAME:-pact-mock-server}
download_and_checksum() {
  rm -f $1
  echo "⬇️  Downloading $version :\t $1"
  gh release download --repo $REPO $tag -p $1
  shasignature=($(eval "openssl dgst -sha256 $1"))
  echo "🔏 Checksum SHA256:\t ${shasignature[1]} for ${1}"
  rm -f $1
}

if [[ $TOOL_NAME == 'pact_mock_server_cli' ]]; then
  description="Installer for Pact Mock Server CLI"
  homepage="https://github.com/pact-foundation/pact-reference/blob/master/rust/pact_mock_server_cli/README.md"
  location="https://github.com/pact-foundation/pact-core-mock-server"
  license="MIT"
  bin='"pact-mock-server.exe"'
  REPO=pact-foundation/pact-core-mock-server
elif [[ $TOOL_NAME == 'pact_verifier_cli' ]]; then
  description="Installer for Pact Verifier CLI"
  homepage="https://github.com/pact-foundation/pact-reference/blob/master/rust/pact_verifier_cli/README.md"
  location="https://github.com/pact-foundation/pact-reference"
  license="MIT"
  bin='"pact-verifier.exe"'
  REPO=pact-foundation/pact-reference
elif [[ $TOOL_NAME == 'pact-plugin-cli' ]]; then
  description="Installer for Pact Plugin CLI"
  homepage="https://github.com/pact-foundation/pact-plugins/blob/main/cli/README.md"
  location="https://github.com/pact-foundation/pact-plugins"
  license="MIT"
  bin='"pact-plugin.exe"'
  REPO=pact-foundation/pact-plugins
elif [[ $TOOL_NAME == 'pact-stub-server' ]]; then
  description="Installer for Pact Stub Server"
  homepage="https://github.com/pact-foundation/pact-stub-server/blob/master/README.md"
  location="https://github.com/pact-foundation/pact-stub-server"
  license="MIT"
  bin='"pact-stub-server.exe"'
  REPO=pact-foundation/pact-stub-server
elif [[ $TOOL_NAME == 'pact-broker-cli' ]]; then
  description="Installer for Pact Broker Client"
  homepage="https://github.com/pact-foundation/pact-broker-cli/blob/main/README.md"
  location="https://github.com/pact-foundation/pact-broker-cli"
  license="MIT"
  bin='"pact-broker-client.exe"'
  REPO=pact-foundation/pact-broker-cli
elif [[ $TOOL_NAME == 'pact-cli' ]]; then
  description="Installer for Pact Cli"
  homepage="https://github.com/pact-foundation/pact-cli/blob/main/README.md"
  location="https://github.com/pact-foundation/pact-cli"
  license="MIT"
  bin='"pact.exe"'
  REPO=pact-foundation/pact-cli
elif [[ $TOOL_NAME == 'pact-legacy' ]]; then
  description="Installer for Pact Ruby Standalone"
  homepage="https://github.com/pact-foundation/ruby-standalone/README.md"
  location="https://github.com/pact-foundation/pact-standalone"
  license="MIT"
  bin=['"pact\\bin\\pact-broker.bat","pact\\bin\\pact-stub-service.bat","pact\\bin\\pact-message.bat","pact\\bin\\pact-provider-verifier.bat","pact\\bin\\pact-mock-service.bat","pact\\bin\\pact-publish.bat","pact\\bin\\pactflow.bat"'\]
  REPO=pact-foundation/pact-standalone
fi

if [[ $1 ]]; then
  tags=($1)
else
  if [[ $TOOL_NAME == 'pact-legacy' ]]; then
    tags=$(gh release list --repo $REPO --limit 1000 | cut -f3)
  else
    tags=$(gh release list --repo $REPO --limit 1000 | cut -f3 | grep -e $TOOL_NAME)
  fi
fi

for tag in ${tags[@]}; do
  if [[ $TOOL_NAME == 'pact_mock_server_cli' ]]; then
    SCOOP_FILENAME=pact-mock-server.json
  elif [[ $TOOL_NAME == 'pact_verifier_cli' ]]; then
    SCOOP_FILENAME=pact-verifier.json
  elif [[ $TOOL_NAME == 'pact-plugin-cli' ]]; then
    SCOOP_FILENAME=pact-plugin.json
  elif [[ $TOOL_NAME == 'pact-cli' ]]; then
    SCOOP_FILENAME=pact.json
  elif [[ $TOOL_NAME == 'pact-broker-cli' ]]; then
    SCOOP_FILENAME=pact-broker-client.json
  else
    SCOOP_FILENAME=${TOOL_NAME}.json
  fi
  version=${tag#v}
  echo creating tap for $version
  echo release assets
  echo $(gh release view --repo $REPO $tag --json assets | jq -r '[.assets[].name]')
  windows_arm64=$(gh release view --repo $REPO $tag --json assets -q '.assets[].name' | grep 'windows' | grep -E 'arm64|aarch64' | grep -v 'checksum' | grep -v 'sha256')
  echo "windows_arm64: $windows_arm64"
  windows_x64=$(gh release view --repo $REPO $tag --json assets -q '.assets[].name' | grep 'windows' | grep x86_64 | grep -v 'checksum' | grep -v 'sha256')
  if [[ $TOOL_NAME == 'pact-cli' || $TOOL_NAME == 'pact-broker-cli' ]]; then
    windows_x64=$(echo "$windows_x64" | grep '.zip' | grep -v '.sha256')
  fi
  echo "windows_x64: $windows_x64"
  windows_x86=$(gh release view --repo $REPO $tag --json assets -q '.assets[].name' | grep 'windows' | grep -e 'x86\.' | grep -v 'checksum' | grep -v 'sha256')
  echo "windows_x86: $windows_x86"
  if [[ -z $windows_x64 && -z $windows_x86  ]]; then
      windows_x64=$(gh release view --repo $REPO $tag --json assets -q '.assets[].name' | grep 'win32' | grep -v 'checksum' | grep -v 'sha256')
  fi

  if [[ $windows_arm64 || $windows_x64 || $windows_x86 ]]; then

    if [[ $windows_arm64 || $windows_x64 || $windows_x86 ]]; then
      if [[ $windows_arm64 ]]; then
        download_and_checksum $windows_arm64
        windows_arm64_shashum=${shasignature[1]}
        windows_arm64_url="$location/releases/download/$tag/$windows_arm64"
        echo "👮‍♀️ Checksum SHA256:\t $windows_arm64_shashum"
      fi
      if [[ $windows_x64 ]]; then
        download_and_checksum $windows_x64
        windows_x64_shashum=${shasignature[1]}
        windows_x64_url="$location/releases/download/$tag/$windows_x64"
        # if pact-legacy, set arm64 variables to x64 values
        ################################################################################
        ################################################################################
        if [[ $TOOL_NAME == 'pact-legacy' || $TOOL_NAME == 'pact-broker-cli' || $TOOL_NAME == 'pact-cli' ]] && [[ -z $windows_arm64 ]]; then
          windows_arm64_shashum=$windows_x64_shashum
          windows_arm64_url=$windows_x64_url
          echo "No windows_arm64, so setting to windows_x64 values"
        fi
        ################################################################################
        ################################################################################

        echo "👮‍♀️ Checksum SHA256:\t $windows_x64_shashum"
      fi

      if [[ $windows_x86 ]]; then
      echo "windows_x86: $windows_x86"
        download_and_checksum $windows_x86
        windows_x86_shashum=${shasignature[1]}
        windows_x86_url="$location/releases/download/$tag/$windows_x86"
        echo "👮‍♀️ Checksum SHA256:\t $windows_x86_shashum"
      fi
    fi

  fi

  if [[ $windows_x64_shashum ]]; then
    if [[ $TOOL_NAME == 'pact-broker-cli' ]]; then
      SCOOP_X64_TEMPLATE=\"64bit\":{\"url\":\"$windows_x64_url\",\"hash\":\"$windows_x64_shashum\",\"bin\":[[\"pact-broker-cli.exe\",\"pact-broker-client\"\]\]}
    else
    SCOOP_X64_TEMPLATE=\"64bit\":{\"url\":\"$windows_x64_url\",\"hash\":\"$windows_x64_shashum\",\"bin\":$bin}
    fi
  else
    SCOOP_X64_TEMPLATE=""
  fi
  if [[ $windows_arm64_shashum ]]; then
    if [[ $TOOL_NAME == 'pact-broker-cli' ]]; then
      SCOOP_ARM64_TEMPLATE=,\"arm64\":{\"url\":\"$windows_arm64_url\",\"hash\":\"$windows_arm64_shashum\",\"bin\":[[\"pact-broker-cli.exe\",\"pact-broker-client\"\]\]}
    else
    SCOOP_ARM64_TEMPLATE=,\"arm64\":{\"url\":\"$windows_arm64_url\",\"hash\":\"$windows_arm64_shashum\",\"bin\":$bin}
    fi
  else
    SCOOP_ARM64_TEMPLATE=,\"arm64\":{}
  fi
  if [[ $windows_x86_shashum ]]; then
    if [[ $TOOL_NAME == 'pact-broker-cli' ]]; then
      SCOOP_X86_TEMPLATE=,\"32bit\":{\"url\":\"$windows_x86_url\",\"hash\":\"$windows_x86_shashum\",\"bin\":[[\"pact-broker-cli.exe\",\"pact-broker-client\"\]\]}
    else
      SCOOP_X86_TEMPLATE=,\"32bit\":{\"url\":\"$windows_x86_url\",\"hash\":\"$windows_x86_shashum\",\"bin\":$bin}
    fi
  else
    SCOOP_X86_TEMPLATE=,\"32bit\":{}
  fi


  SCOOP_STRING=$(jq -n \
    --arg description "$description" \
    --arg homepage "$homepage" \
    --arg license "$license" \
    --arg tag "${version#$TOOL_NAME-v}" \
    --arg bin $bin \
    --arg SCOOP_X64_TEMPLATE $SCOOP_X64_TEMPLATE \
    --arg SCOOP_X86_TEMPLATE $SCOOP_X86_TEMPLATE \
    --arg SCOOP_ARM64_TEMPLATE $SCOOP_ARM64_TEMPLATE \
    '{version: $tag,description: $description,homepage: $homepage,license: $license,architecture: {'$SCOOP_X64_TEMPLATE''$SCOOP_X86_TEMPLATE''$SCOOP_ARM64_TEMPLATE'}}')
  echo $SCOOP_STRING >bucket/$SCOOP_FILENAME.tmp
  echo "" >>bucket/$SCOOP_FILENAME.tmp
  jq . --indent 4 bucket/$SCOOP_FILENAME.tmp >bucket/$SCOOP_FILENAME
  rm bucket/$SCOOP_FILENAME.tmp

done
