#!/bin/bash

wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb -O k9s.deb
sudo dpkg -i k9s.deb
rm k9s.deb

