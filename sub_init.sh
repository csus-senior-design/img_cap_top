#!/bin/bash

git submodule init
git submodule update
cd adv7513
git checkout master
cd ../frame_buf_alt
git checkout frame_buf_alt_fst
cd ../i2c
git checkout master
cd ../ov_7670
git checkout master
cd ../ram_int_4p
git checkout ram_int_4p_fst
cd ../videogen
git checkout master
cd ..