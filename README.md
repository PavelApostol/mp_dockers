# mp_dockers
Dockerfile и образ для PHP 7.4.10, можно использовать как cli, так и fpm 

Есть библиотеки почти все возможные - mysql, gd, iconv, curl, imap, rabbitmq, sqlite, calendar, dom, xml, ftp, json, mbstring, bcmatch.

Включена поддержка opcache...

Не стал добавлять Oracle, т.к. это плюсом мегабайт 300, без него контейнер более чем в три раза меньше, ради этого можно отдельно потом сделать с oci8, но на продакте пока не использую такое
