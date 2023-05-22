#!/bin/bash

rm -rf deploy
mkdir -p deploy

mvn clean package
mv target/streaming-games-1.0.jar deploy/streaming-games-1.0.jar
