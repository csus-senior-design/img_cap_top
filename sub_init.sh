#!/bin/bash

git submodule update --recursive --init
git submodule foreach --recursive git checkout master
cd frame_buf_alt
git checkout frame_buf_alt_fst
cd ../ram_int_4p
git checkout ram_int_4p_fst
cd ..