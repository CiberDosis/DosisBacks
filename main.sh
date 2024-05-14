#!/bin/bash

source BackUpGUI.sh
source BackUPnoGUI.sh



#!/bin/bash

# Función para detectar si hay una interfaz gráfica disponible
detectar_interfaz_grafica() {
    # Verifica si el sistema tiene un proceso de servidor gráfico en ejecución
    if [ -n "$(pgrep -x Xorg)" ]; then
        echo "Se detectó una interfaz gráfica."
        return 0  # Retorna 0 para indicar que se detectó una interfaz gráfica
    else
        echo "No se detectó una interfaz gráfica."
        return 1  # Retorna 1 para indicar que no se detectó una interfaz gráfica
    fi
}

# Verificar si hay una interfaz gráfica
if detectar_interfaz_grafica; then
    echo "Cargando scripts para interfaz gráfica..."
    # Coloca aquí los comandos para cargar tus scripts específicos para interfaz gráfica
    source BackUpGUI.sh
else
    echo "Cargando scripts para entorno de terminal..."
    # Coloca aquí los comandos para cargar tus scripts específicos para terminal
    source BackUPnoGUI.sh
fi

