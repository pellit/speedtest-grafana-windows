# speedtest-grafana-windows
Repository containing an internet speed meter for windows with dashboard in grafana and service with autoit and go.

View
-------------------------------------------------

![Pellit - Speedtest_view1](https://user-images.githubusercontent.com/57459067/127653636-82fe98fb-a445-4d5b-96dc-be107f53ccd5.JPG)
-------------------------------------------------

Installation

1 - Install XAMPP 
-------------------------------------------------

https://www.apachefriends.org/es/download.html --> Windows version.
-------------------------------------------------
Activate server mysql in port 3306 and apache.

Config in control panel to XAMPP --> MySQL --> Config --> my.ini

password = "" --> and save change

user(Default) = root


2 - Install grafana
-------------------------------------------------
https://grafana.com/get/?plcmt=top-nav&cta=downloads --> Windows version.
-------------------------------------------------

3 - Download repository https://github.com/pellit/speedtest-grafana-windows
-------------------------------------------------

4 - Run install [Install-Speedtest_PELLIT.exe]
-------------------------------------------------
install.exe copy folder Produccion_v1.0 in [windows-programfile]/PELLIT/Produccion_v1.0 , and generate two file .ini, one file config.ini with ip private to monitoring and other file with config for BOT telegram alert sending


5 - Run install [speedtest_mysql_3306.exe]
-------------------------------------------------
This file create a database in mysql (xampp runing in your host and mysql online in port 3306 -->user=root and --> pass="")
Verify database with XAMPP-->mysql-->admin-->phpmyadmin(phpmyadmin online have must too activate apache)

6 - Run Grafana in you browser [http://localhost:3000]
-------------------------------------------------
In grafana + --> import --> charge file [windows-programfile]/PELLIT/Produccion_v1.0/PELLIT - Speedtest.json 



References
-------------------------------------------------
https://kruemcke.wordpress.com/2021/01/18/monitoring-home-internet-speed-on-windows-10-using-python-influxdb-and-grafana/
https://github.com/pablokbs/peladonerd --> https://www.youtube.com/watch?v=C8pcbFyN7og
https://github.com/geerlingguy/internet-monitoring
