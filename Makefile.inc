# Head make file include 
# This file is one of two files that:
#  - Find folders with *.h files and add this path do INCLUDES
# -  Find *.c and *.s files and add its to C and S variables

# Part two do:
# - Compile any *.c and *.s file in own folder in subfolder obj/release or obj/debug 
# - Include folders ( folders with *.h files) are added to gcc automatically
# - These files targets  ARM devices however with few changes it will be work on any toolchain


 H   = $(shell find . -name "*.h" -exec dirname {} \; | sort -u)
 C   = $(subst ./,,$(shell find . -name "*.c"))
 S   = $(subst ./,,$(shell find . -name "*.s"))
 Supper = $(subst ./,,$(shell find . -name "*.S"))  # sporadic upper 's' extensions
 INCLUDES = $(addprefix -I,$(H))
 

export CROSS_COMPILE ?= arm-none-eabi-
export CC = $(CROSS_COMPILE)gcc
export LD = $(CROSS_COMPILE)ld
export OBJDUMP = $(CROSS_COMPILE)objdump
export OBJCOPY = $(CROSS_COMPILE)objcopy
export SIZE = $(CROSS_COMPILE)size
export NM = $(CROSS_COMPILE)nm