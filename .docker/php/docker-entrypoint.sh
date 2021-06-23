#!/bin/sh
set -e

if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

#if [ "$1" = 'php-fpm' ] || [ "$1" = 'bin/console' ]; then
#
#  setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var
#	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var
#
#fi



exec "$@"
