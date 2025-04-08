#!/bin/bash

# Масив програм для інсталяції
selectProgramsForUbuntu=("apache2" "mariadb-server" "ufw" "docker.io")

selectProgramsForFedora=("httpd" "mariadb-server" "ufw" "docker.io")

selectProgramsForCentOS=("httpd" "mariadb-server" "firewalld" "docker")

# Лог файл: визначення ОС, інсталяція прогам, оновлення встановлених програм.
log_file="/var/log/install_programs.log"
# Лог файл для помилок.
log_file_error="/var/log/install_programs_error.log"
# Визначаємо систему.

whatOS=$(lsb_release -si 2>/dev/null)

# Якщо lsb_release не спрацював, спробуємо /etc/os-release
if [ -z "$whatOS" ]; then
  whatOS=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d '=' -f 2 | tr -d '"')
fi

# Якщо /etc/os-release не спрацював, спробуємо uname
if [ -z "$whatOS" ]; then
  whatOS=$(uname -s)
fi

# Якщо жоден з методів не спрацював, запишемо помилку в лог
if [ -z "$whatOS" ]; then
  echo "Помилка: не вдалося визначити назву ОС" >> $log_file_error
else
  echo "Назва ОС: $whatOS" >> $log_file
fi

install_programs_for_ubuntu() {
  # Оновлення списку пакетів
 sudo  apt-get update
 if [ $? -ne 0 ]; then
         echo "Помилка оновлення пакетів " >> $log_file_error
       else
         echo "Пакети оновлено успішно." >> $log_file
       fi

  # Цикл по масиву програм
  for program in "${selectProgramsForUbuntu[@]}"; do
    # Перевірка, чи програма вже встановлена
    if dpkg -s "$program" &> /dev/null; then
      echo "$program вже встановлено." >> $log_file
    else
      # Встановлення програми
      echo "Встановлення $program..." >> $log_file
      sudo apt-get install -y "$program" 2>> $log_file_error
      sleep $((RANDOM % 5 + 1))
      if [ $? -ne 0 ]; then
        echo "Помилка встановлення $program" >> $log_file_error
      else
        echo "$program встановлено успішно." >> $log_file
      fi
    fi
  done
}

install_programs_for_fedora() {
  # Оновлення списку пакетів
  sudo dnf update
  if [ $? -ne 0 ]; then
           echo "Помилка оновлення пакетів " >> $log_file_error
         else
           echo "Пакети оновлено успішно." >> $log_file
         fi

  # Цикл по масиву програм
  for program in "${selectProgramsForFedora[@]}"; do
    # Перевірка, чи програма вже встановлена
    if rpm -qi "$program" &> /dev/null; then
      echo "$program вже встановлено." >> $log_file
    else
      # Встановлення програми
      echo "Встановлення $program..." >> $log_file
      sudo dnf install -y "$program" 2>> log_file_error
      sleep $((RANDOM % 5 + 1))
      if [ $? -ne 0 ]; then
        echo "Помилка встановлення $program" >> $log_file_error
      else
        echo "$program встановлено успішно." >> $log_file
      fi
    fi
  done
}

install_programs_for_centOS() {
  # Оновлення списку пакетів
 sudo yum update
 if [ $? -ne 0 ]; then
          echo "Помилка оновлення пакетів " >> $log_file_error
        else
          echo "Пакети оновлено успішно." >> $log_file
        fi
  # Цикл по масиву програм
  for program in "${selectProgramsForCentOS[@]}"; do
    # Перевірка, чи програма вже встановлена
    if rpm -qi "$program" &> /dev/null; then
      echo "$program вже встановлено." >> $log_file
    else
      # Встановлення програми
      echo "Встановлення $program..." >> $log_file
      sudo yum install -y "$program" 2>> log_file_error
      sleep $((RANDOM % 5 + 1))
      if [ $? -ne 0 ]; then
        echo "Помилка встановлення $program" >> $log_file_error
      else
        echo "$program встановлено успішно." >> $log_file
      fi
    fi
  done
}

if [ -n "$whatOS" ]; then
  # Визначаємо який пакет програм буде встановлено для даної системи
  case "$whatOS" in
    "Ubuntu")
      install_programs_for_ubuntu
      ;;
    "fedora")
      install_programs_for_fedora
      ;;
    "centos")
      install_programs_for_centOS
      ;;
    *)
     echo "Невідомий дистрибутив $whatOS" >> log_file 2>> log_file_error
      ;;
  esac
fi
