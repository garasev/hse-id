#!/usr/bin/bash
# Парсинг параметров командной строки
while [[ $# -gt 0 ]]; do
    case "$1" in
        --input_folder)
        input_folder="$2"
        shift 2
        ;;
        --file_extension)
        extension="$2"
        shift 2
        ;;
        --backup_folder)
        backup_folder="$2"
        shift 2
        ;;
        --backup_archive_name)
        backup_archive_name="$2"
        shift 2
        ;;
	*)
	echo "Error: unknown argument - $1"
	exit 1
	;;
    esac
done

# Проверка обязательных параметров
if [ -z "$input_folder" ] || [ -z "$extension" ] || [ -z "$backup_folder" ] || [ -z "$backup_archive_name" ]; then
    echo "Ошибка: Не все обязательные параметры были переданы."
    exit 1
fi

# Создание папки для бэкапа, если она не существует
mkdir -p "$backup_folder"

counter=0

# Поиск файлов с заданным расширением и копирование их содержимого в папку для бэкапа
find "$input_folder" -type f -name "*.$extension" | while read -r file; do
	filename=$(basename -- "$file")
	name="${filename%.*}"
	uniq_name="$counter-$name.${file##*.}"
	cp "$file" "$backup_folder/$uniq_name"
	((counter++))
done
	
# Создание архива с бэкапом
tar -czvf "$backup_archive_name" "$backup_folder"

# Удаление временной папки для бэкапа
rm -rf "$backup_folder"

echo "done"
