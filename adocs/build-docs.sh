#!/bin/bash
#set -e


ADOCS_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PRJ_DIR="${ADOCS_FOLDER}/.."
DOCS_OUT_FOLDER="${PRJ_DIR}/common/docs"

asciidoctor ${ADOCS_FOLDER}/2048-workshop.adoc -o ${DOCS_OUT_FOLDER}/2048-workshop.html -a stylesheet=stylesheet.css -a imagesdir=images
sed -i -e "/<title>/r ${DOCS_OUT_FOLDER}/clipboard.html" ${DOCS_OUT_FOLDER}/2048-workshop.html
rm ${DOCS_OUT_FOLDER}/2048-workshop.html-e

rm -r ${DOCS_OUT_FOLDER}/images 
cp -r ${ADOCS_FOLDER}/images ${DOCS_OUT_FOLDER}/images 

