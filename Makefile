# Environment includes
-include .env

# Required includes
-include ./makefile-utils/make.d/colors.make
-include ./makefile-utils/make.d/strings.make
-include ./makefile-utils/make.d/helper.make

# Optional includes - comment them as you see fit
-include ./makefile-utils/make.d/docker.make

# Makefile configuration
.DEFAULT_GOAL := help
SHELL := /bin/bash

# Your own targets starts here
init: ## initialize github environment
	@git submodule init
	@git submodule add -f https://github.com/XSlender/makefile-utils.git
	@git submodule update --remote

copy_env: ## copy the .env file template to the root folder
	@if [ -f "./.env" ]; then \
  		$(call str_print_line_break); \
		$(call str_print_line,Backuping old .env file to .env_save...); \
		mv .env .env_save; \
		$(call str_print_success,.env file saved under .env_save); \
	fi;

	@$(call str_print_line_break)

	@$(call str_print_step,Copying env file for development...)
	@cp env.d/.env .env
	@$(call str_print_success,.env file generated !)
	@$(call str_print_line_break)
	@$(call str_print_line,You should now start to fill the .env file, and run 'make install' when ready.)

up: ## shorthand to launch the project
	@${MAKE} --no-print-directory docker_launch

down: ## shorthand to stop the project
	@${MAKE} --no-print-directory docker_down

restart: ## shorthand to stop and start the project
	@${MAKE} --no-print-directory down
	@${MAKE} --no-print-directory up

install: ## installs the project and launch it
	@if [ ! -f ".env" ]; then \
  		$(call str_print_line_break); \
		$(call str_print_error,You must have a proper '.env' file to install this stack.); \
		$(call str_print_line,You must run 'make copy_env' to copy the .env file, then fill it, then re use this command to install the stack.); \
		$(call str_print_line_break); \
		exit; \
	fi;

	@$(call str_print_line_break)
	@$(call str_print_step,Stopping existing containers, if any...)
	@docker-compose down --remove-orphans

	@$(call str_print_line_break)
	@$(call str_print_step,Installing docker components...)
	@${MAKE} --no-print-directory docker_update

connect: ## connects to the running server
	@docker-compose logs --tail=250
	@docker attach ${COMPOSE_PROJECT_NAME}-minecraft-server