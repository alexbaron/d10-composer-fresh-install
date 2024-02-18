#!/bin/sh

if [ "$1" ]; then
 PROJECT_NAME="$1"
else
 echo "Please specify a project name ex: my-project"
fi

CUSTOM_OPTION=$(echo "$2" | cut -d= -f2)
CUSTOM_COMPOSER="N"
if [ "$CUSTOM_OPTION" = "Y" ]; then
    CUSTOM_COMPOSER=$CUSTOM_OPTION
fi

echo "Install custom : "$CUSTOM_COMPOSER

# Create the folder that will contain the Drupal project sources
initFolder() {
 if [ -z "$PROJECT_NAME" ]; then
    read -p "Please enter the name of the folder to create: " PROJECT_NAME
 fi

 FOLDER_BASE=$HOME'/dev/'

 echo "The full path of the folder will be: $FOLDER_BASE$PROJECT_NAME"

 # Check if the folder already exists
 if [ -d "$FOLDER_NAME" ]; then
    echo "The folder $FOLDER_NAME already exists."
    exit 1
 fi

 mkdir $FOLDER_BASE$PROJECT_NAME -p

 # Check if the folder creation was successful
 if [ $? -eq 0 ]; then
    echo "The folder $PROJECT_NAME was created successfully."
 else
    echo "Error creating folder $PROJECT_NAME."
 fi

 cd $FOLDER_BASE$PROJECT_NAME
 echo "Execution directory $FOLDER_BASE$PROJECT_NAME"
 pwd
}

# Configure the DDEV project for a Drupal 10 project
initDdev() {
    ddev config --project-type=drupal10 --docroot=web
    ddev start
    # To work on Drupal core
    # ddev composer create joachim-n/drupal-core-development-project -y
}

# Install composer libs; either with the recommended--project or
# with the custom repository
composerInstall() {
    echo $PROJECT_NAME
    echo "Custom = "$CUSTOM_COMPOSER

    if [ "$CUSTOM_COMPOSER" = "Y" ]; then
        echo "Custom composer install"
        git clone git@github.com:alexbaron/d10-composer-fresh-install.git
        mv -f d10-composer-fresh-install/composer.json $FOLDER_BASE$PROJECT_NAME/composer.json
        rm -rf d10-composer-fresh-install
        ls
        ddev composer install
    else
        echo "Standard composer install"
        ddev composer create drupal/recommended-project -y
        ddev composer require drush/drush
    fi
}

# Run the drush site install command to create a basic Drupal install
siteInstall() {
    ddev drush site:install --account-name=admin --account-pass=admin -y
    ddev drush uli
    ddev launch
}

runVscode() {
    # Test if VS Code is installed
    if which code >/dev/null; then
    # Run the command `code .`
    echo "Opening VS Code."
        code .
    else
        # Display a message indicating that VS Code is not installed
        echo "VS Code is not installed."
    fi
}

initFolder
initDdev
composerInstall
siteInstall
runVscode


