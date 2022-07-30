#!/bin/sh

export VERSION=0.0.1
export PLATFORM=linux/amd64
export GCP_REPO=eu.gcr.io
export GCP_PROJECTID=thegym-263112

export CLOUDRUN_ENDPOINT=https://thegym.theblackapp.de/collect
read -p "Please insert the API_KEY shared by Grafana Agent and device: " API_KEY 
export API_KEY

sed "s@{CLOUDRUN_ENDPOINT}@$CLOUDRUN_ENDPOINT@g; s@{API_KEY}@$API_KEY@g;" garmin-connectiq/resources/strings/strings.xml.template >garmin-connectiq/resources/strings/strings.xml
