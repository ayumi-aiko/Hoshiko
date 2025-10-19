#
# Copyright (C) 2025 愛子あゆみ <ayumi.aiko@outlook.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# build arguments, its good to use tons of variable for portability.
CC_ROOT = /home/ayumi/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/bin
CFLAGS = -std=c23 -O3 -static
INCLUDE = ./hoshiko-cli/src/include
SRCS = ./hoshiko-cli/src/include/daemon.c
TARGET = ./hoshiko-cli/src/yuki/main.c
BUILD_LOGFILE = ./hoshiko-cli/build/logs/logs
OUTPUT_DIR = ./hoshiko-cli/build/

# Avoid SDK/ARCH checks for 'clean'
ifneq ($(filter clean help,$(MAKECMDGOALS)),clean help)
	ifeq ($(ARCH),arm64)
		CC := $(CC_ROOT)/aarch64-linux-android$(SDK)-clang
	endif
	ifeq ($(ARCH),arm)
		CC := $(CC_ROOT)/armv7a-linux-androideabi$(SDK)-clang
	endif
	ifeq ($(ARCH),x86)
		CC := $(CC_ROOT)/i686-linux-android$(SDK)-clang
	endif
	ifeq ($(ARCH),x86_64)
		CC := $(CC_ROOT)/x86_64-linux-android$(SDK)-clang
	endif
endif

# checks args
checkArgs:
	@if [ -z "$(SDK)" ]; then \
	  printf "\033[0;31mmake: Error: SDK is not set. Please specify the Android API level, e.g., 'SDK=30'\033[0m\n"; \
	  exit 1; \
	fi; \
	if [ -z "$(ARCH)" ]; then \
	  printf "\033[0;31mmake: Error: ARCH is not set. Please specify the target architecture, e.g., 'ARCH=arm64'\033[0m\n"; \
	  exit 1; \
	fi

# check the existance of compiler before trying to build.
checkCompilerExistance: checkArgs
	@[ -x "$(CC)" ] || { \
		printf "\033[0;31mmake: Error: Compiler '%s' not found or not executable. Please check the path or install it.\033[0m\n" "$(CC)"; \
		exit 1; \
	}

# this builds the program after checking the existance of the clang or gcc compiler existance.
yuki: checkCompilerExistance banner
	@echo "\e[0;35mmake: Info: Trying to build Yuki..\e[0;37m"
	@$(CC) $(CFLAGS) -I$(INCLUDE) $(SRCS) $(TARGET) -o $(OUTPUT_DIR)/mitsuha-yuki 2>./$(BUILD_LOGFILE) || { \
		printf "\033[0;31mmake: Error: Build failure, check the logs for information. File can be found at $(BUILD_LOGFILE)\033[0m\n"; \
		exit 1; \
	}
	@echo "\e[0;36mmake: Info: Build finished without errors, be sure to check logs if concerned. Thank you!\e[0;37m"

# this builds the program after checking dependencies, this is for managing the daemon.
alya: checkCompilerExistance banner
	@echo "\e[0;35mmake: Info: Trying to build Alya..\e[0;37m"
	@$(CC) $(CFLAGS) -I$(INCLUDE) $(SRCS) ./hoshiko-cli/src/alya/main.c -o $(OUTPUT_DIR)/mitsuha-alya 2>./$(BUILD_LOGFILE) || { \
		printf "\033[0;31mmake: Error: Build failure, check the logs for information. File can be found at $(BUILD_LOGFILE)\033[0m\n"; \
		exit 1; \
	}
	@echo "\e[0;36mmake: Info: Build finished without errors, be sure to check logs if concerned. Thank you!\e[0;37m"

# builds all:
all: clean yuki alya

# prints the banner of the program.
banner:
	@printf "\033[0;31mM\"\"MMMMM\"\"MM                   dP       oo dP\n"
	@printf "M  MMMMM  MM                   88          88\n"
	@printf "M         \`M .d8888b. .d8888b. 88d888b. dP 88  .dP  .d8888b.\n"
	@printf "M  MMMMM  MM 88'  \`88 Y8ooooo. 88'  \`88 88 88888\"   88'  \`88\n"
	@printf "M  MMMMM  MM 88.  .88       88 88    88 88 88  \`8b. 88.  .88\n"
	@printf "M  MMMMM  MM \`88888P' \`88888P' dP    dP dP dP   \`YP \`88888P'\n"
	@printf "MMMMMMMMMMMM                                                 \n"

help:
	@echo "\033[1;36mUsage:\033[0m make <target> [SDK=<level>] [ARCH=<arch>]"
	@echo ""
	@echo "\033[1;36mTargets:\033[0m"
	@echo "  \033[0;32myuki\033[0m     Build the Hoshiko daemon binary"
	@echo "  \033[0;32malya\033[0m     Build the Hoshiko daemon manager"
	@echo "  \033[0;32mclean\033[0m      Remove build artifacts"
	@echo "  \033[0;32mhelp\033[0m       Show this help message"
	@echo ""
	@echo "\033[1;36mExample:\033[0m"
	@echo "  make \033[0;32myuki\033[0m SDK=30 ARCH=arm64"

# removes the stuff made by compiler and makefile.
clean:
	@rm -f $(BUILD_LOGFILE) $(OUTPUT_DIR)/mitsuha-yuki $(OUTPUT_DIR)/mitsuha-alya
	@echo "\033[0;32mmake: Info: Clean complete.\033[0m"

.PHONY: yuki alya clean checkArgs checkCompilerExistance banner all