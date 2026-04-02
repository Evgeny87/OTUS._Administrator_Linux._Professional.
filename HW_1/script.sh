#!/usr/bin/env bash
set -e

# Проверка версии
uname -sr

# Подготовка директории и загрузка deb-пакетов
mkdir kernel && cd kernel
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-headers-6.19.10-061910-generic_6.19.10-061910.202603251147_amd64.deb
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-headers-6.19.10-061910_6.19.10-061910.202603251147_all.deb
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-image-unsigned-6.19.10-061910-generic_6.19.10-061910.202603251147_amd64.deb
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-modules-6.19.10-061910-generic_6.19.10-061910.202603251147_amd64.deb

# Установка пакетов
sudo dpkg -i *.deb

# Обновление загрузчика
sudo update-grub
sudo grub-set-default 0
