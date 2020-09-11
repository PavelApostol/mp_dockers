# mp_dockers
Dockerfile и образ для PHP 7.4.10, можно использовать как cli, так и fpm 

Есть библиотеки почти все возможные - mysql, gd, iconv, curl, imap, rabbitmq, sqlite, calendar, dom, xml, ftp, json, mbstring, bcmatch.

Включена поддержка opcache...

Не стал добавлять Oracle, т.к. это плюсом мегабайт 300, без него контейнер более чем в три раза меньше, ради этого можно отдельно потом сделать с oci8, но на продакте пока не использую такое

После обработки через docker_slim образ всего 32 мегабайта, удобно развернуть и настроить быстро


```
docker run -d -p 9000:9000 -v /var/www/html:/var/www/html -w /var/www/html php-mp
```

Подробное описание тут https://tech-research.ru/docker-start/
