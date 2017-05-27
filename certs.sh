#!/bin/bash

set -e

KEY_BITS=2048
CERT_DURATION="-days 1825"

init() {
  is_redo=
  while [ $# -gt 0 ]; do
    case $1 in
      -redo)
        is_redo=true
        shift 1 ;;
      *)
        echo "Usage: $0 init [ -redo ]"
        exit 1 ;;
    esac
  done

  if [ "$is_redo" = true ]; then
    rm -f ca-key.pem ca.pem
  fi

  openssl req -new -x509 $CERT_DURATION -extensions v3_ca -keyout ca-key.pem -out ca.pem
  chmod -c 400 ca-key.pem
  chmod -c 444 ca.pem

  echo "
Created CA cert andkey
"
}

create() {
  is_redo=
  is_server=
  is_client=

  if [ $# = 0 ]; then
    echo "
NOTE: use -h to see extra options to use when creating certs
"
  fi

  while [ $# -gt 0 ]; do
    case $1 in
      -name)
        name=$2
        shift 2 ;;
      -cn)
        cn=$2
        shift 2 ;;
      -alt)
        subjectAltName=$2
        shift 2 ;;
      -client)
        is_client=true
        shift 1 ;;
      -server)
        is_server=true
        shift 1 ;;
      -redo)
        is_redo=true
        shift 1 ;;
      *)
        echo "Usage: $0 create -name NAME -cn SUBJECT [-alt SUBJECT_ALT_NAME] [-server] [-client] [-redo]"
        exit 1
    esac
  done

  if [ -z "$name" ]; then
    read -p "Name: " name
  fi
  if [ -z "$cn" ]; then
    read -p "Subject canonical name: " cn
  fi
  if [ "$is_redo" = true ]; then
    rm -f ${name}-{key,cert}.pem
  fi

  cnf_file="extfile.$$.cnf"
  trap "rm -f $cnf_file" EXIT
  touch $cnf_file

  if [ ! -f ${name}-cert.pem ]; then
    openssl req -subj "/CN=$cn" -new -nodes -keyout ${name}-key.pem -out ${name}.csr

    echo >> $cnf_file <<END
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid
END
    if [ -n "$subjectAltName" ]; then
      if [[ ! $subjectAltName =~ ((email|URI|DNS|RID|IP|dirName|otherName):) ]]; then
        echo "
ERROR: subjectAltName is missing types. See http://bit.ly/subjectAltName
" > /dev/stderr
        exit 2
      fi

      echo "subjectAltName = $subjectAltName" >> $cnf_file
    fi
    if [ "$is_client" = true -a "$is_server" = true ]; then
      echo "extendedKeyUsage = serverAuth,clientAuth" >> $cnf_file
    elif [ "$is_client" = true ]; then
      echo "extendedKeyUsage = clientAuth" >> $cnf_file
    elif [ "$is_server" = true ]; then
      echo "extendedKeyUsage = serverAuth" >> $cnf_file
    fi

    if [ -f $cnf_file ]; then
      ext_arg="-extfile $cnf_file"
    fi

    openssl x509 -req $CERT_DURATION -in ${name}.csr -CA ca.pem -CAkey ca-key.pem \
      -CAcreateserial -out ${name}-cert.pem $ext_arg
    rm ${name}.csr
    chmod -c 444 ${name}-cert.pem
  fi

  echo "
Created key and cert for $name
"
}

ssh() {
  name=
  host=
  idfile=
  user="core"
  # Transfer to /tmp by default since $HOME might be read only filesystem
  remote_path="/tmp"

  if [ $# = 0 ]; then
    echo "
NOTE: use -h to see extra options to use when transferring certs
"
  fi

  while [ $# -gt 0 ]; do
    case $1 in
      -host)
        host=$2
        shift 2 ;;
      -user)
        user=$2
        shift 2 ;;
      -path)
        remote_path=$2
        shift 2 ;;
      -name)
        name=$2
        shift 2 ;;
      -id)
        idfile=$2
        shift 2 ;;
      *)
        echo "Usage: $0 ssh -name NAME -host REMOTE_HOST [ -user $user ] [ -path $remote_path ] [ -id IDFILE ]"
        exit 1
    esac
  done

  if [ -z "$name" ]; then
    read -p "Name: " name
  fi
  if [ ! -f ${name}-cert.pem ]; then
    create -name $name
  fi

  if [ -z "$host" ]; then
    host=$(openssl x509 -in ${name}-cert.pem -noout -subject -nameopt oneline | awk '{print $4}')
    read -p "Remote host [$host]: " ans
    host=${ans:-$host}
  fi

  if [ -n "$idfile" ]; then
    id_args="-i $idfile"
  fi

  if scp $id_args ca.pem ${name}-key.pem ${name}-cert.pem ${user}@${host}:${remote_path} ; then
    echo "
Transferred cert and key for $name and CA cert to ${remote_path} on ${user}@${host}
"
  fi
}

bundle() {
  name=

  while [ $# -gt 0 ]; do
    case $1 in
      -name)
        name=$2
        shift 2 ;;
      *)
        echo "Usage: $0 bundle -name NAME"
        exit 1
    esac
  done

  if [ -z "$name" ]; then
    read -p "Name: " name
  fi
  if [ ! -f ${name}-cert.pem ]; then
    create -name $name
  fi

  out=/tmp/${name}-certs.tgz
  tar zcf $out ca.pem ${name}-key.pem ${name}-cert.pem
  chmod -c 400 $out

  echo "
Bundled certificate files in $out
"
}

mkdir -p .certs
cd .certs

case $1 in
  init|create|ssh|bundle)
    cmd="$1"
    shift
    $cmd $@
    ;;
  *)
    echo "Usage: $0 init|create|ssh|bundle"
    ;;
esac
