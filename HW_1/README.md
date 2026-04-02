# Обновление ядра Ubuntu до mainline версии

## Текст задания

Обновить ядро Ubuntu до mainline-версии (самой свежей стабильной сборки от команды Ubuntu) двумя способами:
- основное задание: обновление из mainline-репозитория с помощью скрипта или вручную;
- задание со звёздочкой (по желанию): сборка ядра из исходных кодов.

В рамках данного отчёта выполнено основное задание: ручная установка mainline-ядра версии 6.19.10.

## Ход работы

### 1. Обновление списка пакетов:

```bash
sudo apt update
```

### 2. полное обновление (включая ядро):

```bash
sudo apt full-upgrade -y
```

### 3. Перезагрузка, чтобы новое ядро вступило в силу:
```bash
sudo reboot
```

### 4. Текущая версия ядра до обновления

```bash
uname -sr
```

```text
Linux 6.8.0-107-generic
```

### 5. Подготовка директории и загрузка deb-пакетов
Создана отдельная директория kernel, в неё скачаны четыре необходимых пакета для версии v6.19.10:

```bash
mkdir kernel && cd kernel

wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-headers-6.19.10-061910-generic_6.19.10-061910.202603251147_amd64.deb
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-headers-6.19.10-061910_6.19.10-061910.202603251147_all.deb
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-image-unsigned-6.19.10-061910-generic_6.19.10-061910.202603251147_amd64.deb
wget https://kernel.ubuntu.com/mainline/v6.19.10/amd64/linux-modules-6.19.10-061910-generic_6.19.10-061910.202603251147_amd64.deb
'''

Сокращённый вывод (успешная загрузка):

```text
linux-headers-... 100%[=================>]   3.86M  5.09MB/s
linux-headers-... 100%[=================>]  13.95M  8.22MB/s
linux-image-...   100%[=================>]  16.22M  6.57MB/s
linux-modules-... 100%[=================>] 159.43M  10.2MB/s
```

### 6. Установка пакетов

```bash
sudo dpkg -i *.deb
```

Ключевые фрагменты вывода:

```text
Selecting previously unselected package linux-headers-6.19.10-061910...
Unpacking ...
Setting up linux-image-unsigned-6.19.10-061910-generic ...
I: /boot/vmlinuz is now a symlink to vmlinuz-6.19.10-061910-generic
I: /boot/initrd.img is now a symlink to initrd.img-6.19.10-061910-generic
Processing triggers ...
update-initramfs: Generating /boot/initrd.img-6.19.10-061910-generic
/etc/kernel/postinst.d/vboxadd:
VirtualBox Guest Additions: Building the modules for kernel 6.19.10-061910-generic.
(Предупреждение: смотрите /var/log/vboxadd-setup.log)
/etc/kernel/postinst.d/zz-update-grub:
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.19.10-061910-generic
Found initrd image: /boot/initrd.img-6.19.10-061910-generic
Found linux image: /boot/vmlinuz-6.8.0-107-generic
...
done
```

### 7. Обновление загрузчика и перезагрузка

```bash
sudo update-grub
sudo reboot
```

После перезагрузки система успешно загрузилась с новым ядром.

### 8. Проверка версии после обновления

```bash
uname -sr
```

Вывод:

```text
Linux 6.19.10-061910-generic
```
