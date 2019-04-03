include Makefile.inc
.SECONDEXPANSION:

DEFINES = -DSTM32F207xx -DARM_MATH_CM3
OUTOFCOMPILER = "./nocompile"

 #INCLUDES  := $(filter-out $(OUTOFCOMPILER) ,$(INCLUDES))
 #C  := $(filter-out $(OUTOFCOMPILER), $(C))
 #S  := $(filter-out $(OUTOFCOMPILER) , $(S)) 

CC_FLAGS += $(INCLUDES) $(DEFINES) -mcpu=cortex-m3  -mthumb -mlittle-endian  -Wall -fdata-sections -ffunction-sections 
CC_FLAGS += -Wstrict-prototypes -fverbose-asm -nostdlib -pipe

LD_FLAGS += -lm
LD_FLAGS +=  -mthumb -mcpu=cortex-m3 -Wl,-Map=project.map,--cref,--no-warn-mismatch 
LD_FLAGS += -nostartfiles -specs=nano.specs -TSTM32F217IGHx_FLASH.ld -Wl,--gc-sections

LIBPATH = /usr/arm-none-eabi/lib/thumb/v6-m/nofp/
LIBS = $(LIBPATH)libm.a $(LIBPATH)libc_nano.a

.PHONY:  clean flash

O  = $(C:%.c=%.o)
O += $(S:%.s=%.o)
O += $(Supper:%.S=%.o)

ifeq ($(TARGET), release)
	ELF = bin/release.elf
	CC_FLAGS += -O3 -DRELEASE
	OBJPATH = obj/release
else
	ELF = bin/debug.elf
	CC_FLAGS += -g -O0 -DDEBUG
	OBJPATH = obj/debug
endif

OBJ = $(addprefix $(OBJPATH)/, $(O))


all: makepath build

build: $(OBJ) 
	@echo ---- LINKING ----
	@$(CC) $(OBJ) $(LIBS) $(LD_FLAGS)  -o $(ELF) 
	@$(OBJCOPY) -O ihex $(ELF) $(ELF:%.elf=%.hex)
	@$(OBJCOPY) -O srec $(ELF) $(ELF:%.elf=%.s19)
	@$(OBJCOPY) -O binary $(ELF)  $(ELF:%.elf=%.bin)
	@$(NM)  $(ELF) 
	@echo 
	@$(SIZE)  --format=Berkeley $(ELF) 

	@echo ---- FINISHED ----

makepath: 
	@mkdir -p $(dir $(OBJ))	


$(OBJPATH)/%.o:%.c
	@echo ---- C ----
	$(CC) $(CC_FLAGS) -c $<  -o $@

$(OBJPATH)/%.o:%.s
	@echo ---- S ----
	$(CC) $(CC_FLAGS) -c $<  -o $@

$(OBJPATH)/%.o:%.S
	@echo ---- S ----
	$(CC) $(CC_FLAGS) -c $<  -o $@

flash:
	@echo ---- FLASHING ----
	st-flash erase
	st-flash --reset write  $(ELF:%.elf=%.bin) 0x08000000
	$(SIZE) -A -d $(ELF)
	@$(OBJDUMP) -d -M force-thumb -S $(ELF) >  $(ELF:%.elf=%.lst)

clean:
	@echo ---- CLEANING ----
	@rm -f -R ./obj/debug/*
	@rm -f -R ./obj/release/*
	@rm  -f  ./bin/*
	@find -name *.elf -delete

rebuild: clean 
	@echo ---- REBUILD ALL ----
	@make TARGET=release
	@make TARGET=debug

debugmake:
	@echo $(O)
	@echo $(Supper)