#!/bin/sh

level=$(light)
echo "L:${level%???}" >> /tmp/panel
