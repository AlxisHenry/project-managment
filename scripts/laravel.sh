#!/bin/bash

#- This script will prepare code in dist folder for laravel project
#- ================================================================

#- Import environment variables
#- ============================
source .env;

# Install dependencies
# --------------------
# @param {string} $1
# @return {void}
dependencies () {
	if [ "$1" == "--production" ]; then
		rm -rf vendor/ node_modules/;
		composer install --no-dev --optimize-autoloader && npm install --omit=dev;
    elif [ "$1" == "--development" ]; then
		#- All dependencies are needed for build process
		composer install && npm install;
    fi
}

# Laravel configuration 
# ---------------------
# @return {void}
configuration () {
	# Generate app key
	key=$(php artisan key:generate --show);
	sed -i "s/APP_KEY=.*/APP_KEY=$key/g" .env.example;
	# Configure environment
	sed -i "s/APP_ENV=.*/APP_ENV=production/g" .env.example;
	sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/g" .env.example;
}

# Laravel clear storage 
# ---------------------
# @return {void}
storage () {
	# Clearing cached files
	php artisan optimize:clear;
	# Delete session files
	rm -f storage/framework/sessions/*;
	# Clear logs
	rm -f storage/logs/laravel.log;
}

# Build assets
# -------------
# @return {void}
build () {
	npm run build;
}

# Clean useless folders/files
# ---------------------------
# @return {void}
clean () {
	# Folders
	folders="resources/js resources/scss";
	for folder in $folders; do
		rm -rf $folder;
	done
	# Files
	files=".editorconfig postcss.config.js tailwind.config.js vite.config.js package.json package-lock.json webpack.mix.js composer.lock";
	for file in $files; do
		rm -f $file;
	done
	# Scripts
	extensions="sh gitignore md bat env";
	for extension in $extensions; do
		find -iname "*.$extension" -not -path "./vendor/*" -delete
	done
}

# Call functions
# --------------
# @return {void}
main () {
	dependencies --development;
	configuration;
	storage;
	build;
	dependencies --production;
	clean;
}

cd $PATH_TO_DIST/$CURRENT_APP_NAME && main > /dev/null 2>&1;