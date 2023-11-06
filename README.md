# EmojiUI

Протез эмпатии для длюдей с расстройством аутистического спектра.<br />
Проект команды Hackateam

## Как запустить

Для того, чтобы запустить приложение необходимо склонировать последнюю версию проекта из [production](https://github.com/LekasNet/EmojiUI/tree/production) ветки.<br /><br />
Открыть проект необходимо в android studio (или любом другом редакторе с возможностью компилирования Flutter приложения), а папку server в проекте можно переместить в любое другое место и открыть в pycharm (или в любом другом редакторе, способном запустить pyhton файл).<br /><br />
Так как сервер не находится на домене, или хотя-бы статичном адресе, то в config.json в поле apiUrl значение нужно заменить на ваш нынешний IPv4 в формате <br /><br />
```"http://<Your IPv4>:3000"```<br /><br />
То же самое необходимо сделать с main.py в server. Там в поле app.run (самый низ файла) в графе host необходимо вставить Ваш IPv4<br />
После всех действий запускаете сервер, билдите приложение на свой телефон, или виртуальное устройство под управлением OC Android и можно пользоваться.<br />
