#!/bin/bash
# cd ..
make clean
make build

# test
wget -P test/ https://miplib.zib.de/WebData/instances/2club200v15p5scn.mps.gz
./build/cupdlpx test/2club200v15p5scn.mps.gz test/ -v