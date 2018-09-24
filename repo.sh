#!/usr/bin/env bash

set -e
set -o pipefail



export OPENEDX_RELEASE="hawthorn.master"
# Script for Git repos housing edX services. These repos are mounted as
# data volumes into their corresponding Docker containers to facilitate development.
# Repos are cloned to/removed from the directory above the one housing this file.

if [ -z "$DEVSTACK_WORKSPACE" ]; then
    echo "need to set workspace dir"
    exit 1
elif [ -d "$DEVSTACK_WORKSPACE" ]; then
    cd $DEVSTACK_WORKSPACE
else
    echo "Workspace directory $DEVSTACK_WORKSPACE doesn't exist"
    exit 1
fi

repos=(
    "https://github.com/edx/course-discovery.git -b open-release/$OPENEDX_RELEASE"
    "https://github.com/edx/credentials.git -b open-release/$OPENEDX_RELEASE"
    "https://github.com/edx/cs_comments_service.git -b open-release/$OPENEDX_RELEASE"
    "https://github.com/edx/ecommerce.git -b open-release/$OPENEDX_RELEASE"
    "https://github.com/edx/edx-e2e-tests.git -b open-release/$OPENEDX_RELEASE"
    "https://github.com/edx/edx-notes-api.git -b open-release/$OPENEDX_RELEASE"
    "git@gitlab.fccn.pt:nau/edx-platform.git -b open-release/hawthorn.nau"
    "https://github.com/edx/xqueue.git -b open-release/$OPENEDX_RELEASE"
    "https://github.com/edx/edx-analytics-pipeline.git -b open-release/$OPENEDX_RELEASE"
    "git@gitlab.fccn.pt:nau/nau-themes.git -b master"
)

volumes=(
    "edxapp_studio_assets"
    "edxapp_lms_assets"
    "discovery_assets"
    "mysql_data"
    "mongo_data"
    "elasticsearch_data"
)

private_repos=(
    # Needed to run whitelabel tests.
    "https://github.com/edx/edx-themes.git"
)

name_pattern=".*/(.*).git"

_checkout ()
{
    repos_to_checkout=("$@")

    if [ -z "$OPENEDX_RELEASE" ]; then
        branch="master"
    else
        branch="open-release/${OPENEDX_RELEASE}"
    fi
    for repo in "${repos_to_checkout[@]}"
    do
        # Use Bash's regex match operator to capture the name of the repo.
        # Results of the match are saved to an array called $BASH_REMATCH.
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        # If a directory exists and it is nonempty, assume the repo has been cloned.
        if [ -d "$name" -a -n "$(ls -A "$name" 2>/dev/null)" ]; then
            cd $name
            echo "Checking out branch $branch of $name"
            git pull
            git checkout "$branch"
            cd ..
        fi
    done
}

checkout ()
{
    _checkout "${repos[@]}"
}


_clone ()
{
    # for repo in ${repos[*]}
    repos_to_clone=("$@")

    for repo in "${repos_to_clone[@]}"
    do
        # Use Bash's regex match operator to capture the name of the repo.
        # Results of the match are saved to an array called $BASH_REMATCH.
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        # If a directory exists and it is nonempty, assume the repo has been checked out.
        if [ -d "$name" -a -n "$(ls -A "$name" 2>/dev/null)" ]; then
            printf "The [%s] repo is already checked out. Continuing.\n" $name
        else
            if [ "${SHALLOW_CLONE}" == "1" ]; then
                git clone --depth=1 $repo
            else
                git clone $repo
            fi
        fi
    done
    cd - &> /dev/null
}

_create_volumes ()
{
    if [[ ! -d "${DEVSTACK_WORKSPACE}/volumes" ]]; then
        mkdir "${DEVSTACK_WORKSPACE}/volumes";
    fi
    cd "${DEVSTACK_WORKSPACE}/volumes"
    for vol in "${volumes[@]}"
    do
        if [[ ! -d "${DEVSTACK_WORKSPACE}/volumes/${vol}" ]]; then
            mkdir "${DEVSTACK_WORKSPACE}/volumes/${vol}";
        fi
    done
}

clone ()
{
    _clone "${repos[@]}"
     _create_volumes
}

clone_private ()
{
    _clone "${private_repos[@]}"
}

reset ()
{
    currDir=$(pwd)
    for repo in ${repos[*]}
    do
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        if [ -d "$name" ]; then
            cd $name;git reset --hard HEAD;git checkout master;git reset --hard origin/master;git pull;cd "$currDir"
        else
            printf "The [%s] repo is not cloned. Continuing.\n" $name
        fi
    done
    cd - &> /dev/null
}

status ()
{
    currDir=$(pwd)
    for repo in ${repos[*]}
    do
        [[ $repo =~ $name_pattern ]]
        name="${BASH_REMATCH[1]}"

        if [ -d "$name" ]; then
            printf "\nGit status for [%s]:\n" $name
            cd $name;git status;cd "$currDir"
        else
            printf "The [%s] repo is not cloned. Continuing.\n" $name
        fi
    done
    cd - &> /dev/null
}

if [ "$1" == "checkout" ]; then
    checkout
elif [ "$1" == "clone" ]; then
    clone
elif [ "$1" == "whitelabel" ]; then
    clone_private
elif [ "$1" == "reset" ]; then
    read -p "This will override any uncommited changes in your local git checkouts. Would you like to proceed? [y/n] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reset
    fi
elif [ "$1" == "status" ]; then
    status
fi
