#!/bin/bash

PROJECT="img_cap_top"
#REV="_beta"

TIMESTAMP=_$(date +%Y%m%d_%H%M)
quartus_sh --flow compile "$PROJECT"
mv output_files/"$PROJECT".sof output_files/"$PROJECT""$TIMESTAMP".sof