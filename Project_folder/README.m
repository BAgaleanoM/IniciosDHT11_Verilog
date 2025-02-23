Esta es la carpeta del proyecto, la organización de los módulos es:

El módulo StartModule se encarga de enviar los primeros pulsos al sensro para indicarle que envíe de vuelta los datos, además le indica al módulo DataReciverModule que emperazá a recibir los datos de parte del sensor

El módulo DataReciverModule se encaga de recibir el bus de 40 bits para ser separados en los datos de temperatura y humedad, para luego pasárselos al módulo de la pantalla.
