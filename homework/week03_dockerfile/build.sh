#!/bin/bash
PROGRAM_DIR="$( cd "$( dirname "$0" )" && pwd )"
NAMESPACE=`grep 'NAMESPACE:' $PROGRAM_DIR'/.project'`
if [ ! -n "$NAMESPACE" ] ; then
    NAMESPACE=""
else
    NAMESPACE="$( echo $NAMESPACE|awk -F":" '{print $2}' )"
    NAMESPACE="$( echo $NAMESPACE| sed 's/ //g' )"
fi
if [ ! -n "$NAMESPACE" ] ; then
    NAMESPACE="dev"
fi
PROGRAM_NAME=`grep 'NAME:' $PROGRAM_DIR'/.project'`
if [ ! -n "$PROGRAM_NAME" ] ; then
    PROGRAM_NAME=""
else
    PROGRAM_NAME="$( echo $PROGRAM_NAME|awk -F":" '{print $2}' )"
    PROGRAM_NAME="$( echo $PROGRAM_NAME| sed 's/ //g' )"
fi
if [ ! -n "$PROGRAM_NAME" ] ; then
    PROGRAM_NAME="$( basename $PROGRAM_DIR )"
fi
VERSION=`grep 'VERSION:' $PROGRAM_DIR'/.project'`
if [ ! -n "$VERSION" ] ; then
    VERSION=""
else
    VERSION="$( echo $VERSION|awk -F":" '{print $2}' )"
    VERSION="$( echo $VERSION| sed 's/ //g' )"
fi

echo $NAMESPACE
build(){
    echo "Docker build $PROGRAM_NAME";
    if [ ! -n "$VERSION" ] ; then
        echo "Warning cloud not define version.";
    else
        docker build -t $NAMESPACE/$PROGRAM_NAME:$VERSION $PROGRAM_DIR
    fi
    docker build -t $NAMESPACE/$PROGRAM_NAME:latest $PROGRAM_DIR
}

push(){
    if [ ! -n "$VERSION" ] ; then
        echo "Warning cloud not define version.";
    else
        echo "Create tag $PROGRAM_NAME:$VERSION";
    fi
    echo "Create tag "$PROGRAM_NAME":latest";
    docker tag $NAMESPACE/$PROGRAM_NAME:latest hub.docker.com/$NAMESPACE/$PROGRAM_NAME:"latest"
    echo "Push tag "$PROGRAM_NAME"latest";
    docker push hub.docker.com/$NAMESPACE/$PROGRAM_NAME:"latest"
}

rm(){
    echo "Remove $PROGRAM_NAME";
    docker rmi $PROGRAM_NAME
    docker rmi $NAMESPACE/$PROGRAM_NAME
}
ACTION=$1
shift
args_count=$#
i=0
case "$ACTION" in
    build)
        build;
        shift
        i=`expr $i + 1`
        ;;
    push)
        push;
        shift
        i=`expr $i + 1`
        ;;
    rm)
        rm;
        shift
        i=`expr $i + 1`
        ;;
    *)
        echo "Usage: $0 {build|push|rm}"
        ;;
esac
exit 0
