#!/bin/bash

###########VARIABLES GLOBALES############
nombre_programa="AARL_BACKUPS"
backup_script_dir="/Backup_Script"


if [[ "$(id -u)" != "0" ]]; then

    echo "Este script se debe de ejecutar como root, con sudo." 1>&2
    exit 1
fi

############FUNCIÓN INSTALACIÓ HERRAMIENTA###############
instalacion() {
    if [ -z $(which zenity) ]; then
        sudo apt-get update -y 
        sudo apt-get install zenity -y 
    fi
    if [ -z $(which xdotool) ]; then
        sudo apt-get update -y 
        sudo apt-get install xdotool -y 
    fi

}

#############FUNCION ARBOL DE DIRECTORIOS################
Carpetas() {
 
    selec_part_i=$(zenity --list --width=500 --height=300 --title="Montar Partición" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona la Partición a montar: ")
    mkdir /AARL_Backup
    sudo mount "$selec_part_i" /AARL_Backup
    mkdir -p /AARL_Backup/Backups    
    cd /AARL_Backup/Backups 
    mkdir -p {Full,Incremental,Diferencial,Discos_Particiones_img}     
    cd /
    mkdir -p /Backup_Script 
}


#################FUNCION BACKUPS#########################
backup_archivos_directorios() {
    # Mostrar el diálogo de selección de directorios para la dirección de respaldo
    backup_dir=$(zenity --file-selection --directory --title="Seleccionar directorio para el respaldo")

    # Verificar si se seleccionó un directorio
    if [ -z "$backup_dir" ]; then
        zenity --info --text="No se ha seleccionado un directorio de respaldo."
        Menu
    fi

    # Mostrar el diálogo de selección de archivos/directorios
    selected_files=$(zenity --file-selection --directory --multiple --title="Seleccionar archivos/directorios para respaldo" --filename="$backup_dir")

    # Verificar si se seleccionó al menos un archivo o directorio
    if [ -z "$selected_files" ]; then
        zenity --info --text="No se han seleccionado archivos/directorios para respaldo."
        Menu
    fi

    # Extraer el nombre base del archivo o directorio seleccionado
    nombre_arch_dir=$(basename "$selected_files")

    # Mostrar el diálogo para elegir entre realizar el respaldo inmediato o programarlo
    backup_option=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Programación de Backup" --column="Opción" "Inmediato" "Programado")

    #Realizar el respaldo inmediato 
    if [ "$backup_option" == "Inmediato" ]; then 
        backup_tipo_i=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Tipo de Backup" --column="Opción" "Full" "Incremental" "Diferencial")
        
        if [ "$backup_tipo_i" == "Full" ]; then 
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            mkdir -p "$backup_directorio"
            backup_nom_arch="$backup_directorio/backup_full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"            
            tar -czpvf "$backup_nom_arch" "$selected_files"
            zenity --info --text="Backup-Full realizado correctamente en $backup_nom_arch."

        elif [ "$backup_tipo_i" == "Incremental" ]; then
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            backup_nom_arch_i="$backup_directorio/backup_incremental_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
            mkdir -p "$backup_directorio"
            cd "$backup_directorio"
            tar -czpvf "$backup_nom_arch_i" --listed-incremental="incremental_$nombre_arch_dir.snar" "$selected_files" 
            zenity --info --text="Backup-Incremental realizado correctamente en $backup_nom_arch_i y incremental_$nombre_arch_dir.snar."

        elif [ "$backup_tipo_i" == "Diferencial" ]; then 
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            backup_nom_arch_d="$backup_directorio/backup_diferencial_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
            mkdir -p "$backup_directorio"
            cd "$backup_directorio"
            tar -czpvf "$backup_nom_arch_d" --listed-incremental="diferencial_$nombre_arch_dir.snar" "$selected_files"
            zenity --info --text="Backup-Diferencial realizado correctamente en $backup_nom_arch_d y diferencial_$nombre_arch_dir.snar."

        else 
            zenity --info --text="Programa cancelado"
            Menu 
        fi 
 
     ###########Realizar el respaldo PROGRAMADO##########
  
        
    elif [ "$backup_option" == "Programado" ]; then       
         
       

        backup_opcion_pro=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Tipo de Backup" --column="Opción" "Full" "Incremental" "Diferencial")

        if [ "$backup_opcion_pro" == "Full" ]; then                        

            
                backup_dia_mes_elec=$(zenity --list --width=500 --height=300 --title="$nombre_programa"  --text="¿Quieres que se haga un día del mes en concreto?" --column="Opción" "si" "no")    
                
                if [ "$backup_dia_mes_elec" == "si" ]; then
                    backup_dia_mes=$(zenity --forms --title="Programado-Full" --text="Elige el día del Mes" --add-entry="Ingresa el día (formato 1-31)")

                    backup_dia_sem_elec=$(zenity --list --title="Programado-Full" --text="¿Quieres que se haga un dia de la semana en concreto?" --column="Opción" "si" "no")
                    
                    if [ "$backup_dia_sem_elec" == "si" ]; then 

                        backup_dias_sem=$(zenity --list --width=500 --height=300 --title="Programado-Full" --text="Elige el día de la semana:" --checklist --column="Selección" --column="Día" FALSE Lunes FALSE Martes FALSE Miércoles FALSE Jueves FALSE Viernes FALSE Sábado FALSE Domingo)
                       
                        #Verificar si se seleccionó algún día
                        if [ -z "$backup_dias_sem" ]; then
                        # No se seleccionó ningún día
                            dias_numeros="*"    
                        else                        
                        # Convertir los días seleccionados a números
                            dias_numeros=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miércoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sábado/6/g; s/Domingo/0/g' | tr '|' ',')
                        # Convetir los días a letras
                            dias_letras=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
                        fi
                        
                        
                        # Mostrar el diálogo para elegir la hora y los minutos
                        selected_hour=$(zenity --forms --title="Programado-Full" --text="Hora" --add-entry="Ingresa la hora para el backup (formato HH:MM): ")

                        # Verificar si se seleccionó una hora
                        if [ -z "$selected_hour" ]; then
                            zenity --info --text="Operación cancelada."
                            Menu
                        fi                        
                        
                        # Extraer la hora y los minutos
                        hour=$(echo "$selected_hour" | cut -d":" -f1)
                        minute=$(echo "$selected_hour" | cut -d":" -f2)

                        # Rutas backup 
                        backup_directorio="$backup_dir"/"$nombre_arch_dir"
                        backup_nom_arch="$backup_directorio/backup_full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
                        mkdir -p "$backup_directorio"                        
                        
                        # Crear el nuevo script de respaldo 
                        backup_script="$backup_script_dir/full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').sh"

                        echo "#!/bin/bash" > "$backup_script"
                        echo "backup_dir=\"$backup_nom_arch\"" >> "$backup_script"
                        echo "selected_files=\"$selected_files\"" >> "$backup_script"
                        
                        # Crear el archivo de respaldo
                        echo 'tar -czpvf "$backup_dir" "$selected_files"' >> "$backup_script"                    

                        # Programar el backup en Cron según la frecuencia y la hora seleccionada
                        cron_expression="$minute $hour $backup_dia_mes * $dias_numeros"                        

                        crontab -l > mi_crontab_actual
                        echo "$cron_expression /bin/bash $backup_script" >> mi_crontab_actual
                        crontab mi_crontab_actual
                        rm mi_crontab_actual

                        # Dar permisos de ejecución al script
                        chmod +x "$backup_script"               
             
                        # Mostrar mensaje de éxito
                        zenity --info --width=500 --height=300 --text="Backup Full programado. Hora: $selected_hour, Día del mes: $backup_dia_mes, Día de la semana: $dias_letras"
                        Menu

                    elif [ "$backup_dia_sem_elec" == "no" ]; then                        

                        # Mostrar el diálogo para elegir la hora y los minutos
                        selected_hour=$(zenity --forms --title="Programado-Full" --text="Hora" --add-entry="Ingresa la hora para el backup (formato HH:MM): ")

                        # Verificar si se seleccionó una hora
                        if [ -z "$selected_hour" ]; then
                            zenity --info --text="Operación cancelada."
                            Menu
                        fi                        
                        
                        # Extraer la hora y los minutos
                        hour=$(echo "$selected_hour" | cut -d":" -f1)
                        minute=$(echo "$selected_hour" | cut -d":" -f2)

                        # Rutas backup 
                        backup_directorio="$backup_dir"/"$nombre_arch_dir"
                        backup_nom_arch="$backup_directorio/backup_full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
                        mkdir -p "$backup_directorio"                        
                        
                        # Crear el nuevo script de respaldo 
                        backup_script="$backup_script_dir/full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').sh"

                        echo "#!/bin/bash" > "$backup_script"
                        echo "backup_dir=\"$backup_nom_arch\"" >> "$backup_script"
                        echo "selected_files=\"$selected_files\"" >> "$backup_script"
                        
                        # Crear el archivo de respaldo
                        echo 'tar -czpvf "$backup_dir" "$selected_files"' >> "$backup_script"                    

                        # Programar el backup en Cron según la frecuencia y la hora seleccionada
                        cron_expression="$minute $hour $backup_dia_mes * *"                        

                        crontab -l > mi_crontab_actual
                        echo "$cron_expression /bin/bash $backup_script" >> mi_crontab_actual
                        crontab mi_crontab_actual
                        rm mi_crontab_actual

                        # Dar permisos de ejecución al script
                        chmod +x "$backup_script"               
             
                        # Mostrar mensaje de éxito
                        zenity --info --width=500 --height=300 --text="Backup Full programado. Hora: $selected_hour, Día del mes: $backup_dia_mes"           
                        Menu

                    else
                        zenity --info --text="Operación cancelada"
                        Menu   
                    fi  
              

                elif [ "$backup_dia_mes_elec" == "no" ]; then

                    backup_dias_sem=$(zenity --list --width=500 --height=300 --title="Programado-Full" --text="Elige el día de la semana:" --checklist --column="Selección" --column="Día" FALSE Lunes FALSE Martes FALSE Miércoles FALSE Jueves FALSE Viernes FALSE Sábado FALSE Domingo)
                       
                    #Verificar si se seleccionó algún día
                    if [ -z "$backup_dias_sem" ]; then
                    # No se seleccionó ningún día
                        backup_dias_sem="*"    
                    else                        
                    # Convertir los días seleccionados a números
                        dias_numeros=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miércoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sábado/6/g; s/Domingo/0/g' | tr '|' ',')
                    # Convetir los días a letras
                        dias_letras=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
                    
                    fi

                    # Mostrar el diálogo para elegir la hora y los minutos
                    selected_hour=$(zenity --forms --title="Programado-Full" --text="Hora" --add-entry="Ingresa la hora para el backup (formato HH:MM): ")

                    # Verificar si se seleccionó una hora
                    if [ -z "$selected_hour" ]; then
                        zenity --info --text="Operación cancelada."
                        Menu
                    fi                        
                        
                    # Extraer la hora y los minutos
                    hour=$(echo "$selected_hour" | cut -d":" -f1)
                    minute=$(echo "$selected_hour" | cut -d":" -f2)

                    # Rutas backup 
                    backup_directorio="$backup_dir"/"$nombre_arch_dir"
                    backup_nom_arch="$backup_directorio/backup_full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
                    mkdir -p "$backup_directorio"                        
                        
                    # Crear el nuevo script de respaldo 
                    backup_script="$backup_script_dir/full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').sh"

                    echo "#!/bin/bash" > "$backup_script"
                    echo "backup_dir=\"$backup_nom_arch\"" >> "$backup_script"
                    echo "selected_files=\"$selected_files\"" >> "$backup_script"
                        
                    # Crear el archivo de respaldo
                    echo 'tar -czpvf "$backup_dir" "$selected_files"' >> "$backup_script"                    

                    # Programar el backup en Cron según la frecuencia y la hora seleccionada
                    cron_expression="$minute $hour * * $dias_numeros"                        

                    crontab -l > mi_crontab_actual
                    echo "$cron_expression /bin/bash $backup_script" >> mi_crontab_actual
                    crontab mi_crontab_actual
                    rm mi_crontab_actual

                    # Dar permisos de ejecución al script
                    chmod +x "$backup_script"               
             
                    # Mostrar mensaje de éxito
                    zenity --info --width=500 --height=300 --text="Backup Full programado. Hora: $selected_hour, Día de la semana: $dias_letras"
                    Menu
                else
                    zenity --info --text="Operación cancelada."
                    Menu 
                fi             

            

        elif [ "$backup_opcion_pro" == "Incremental" ]; then 
            
            # Verificar si el usuario cancela la selección o cierra la ventana

                        
            # Pide los días de la semana para el Backup Incremental
            backup_dias_sem_i=$(zenity --list --width=500 --height=300 --title="Programado-Incremental" --text="Elige el día de la semana:" --checklist --column="Selección" --column="Día" FALSE Lunes FALSE Martes FALSE Miércoles FALSE Jueves FALSE Viernes FALSE Sábado FALSE Domingo)

            # Verifica si se seleccionó algún día
            if [ -z "$backup_dias_sem_i" ]; then
                backup_dias_sem_i="*"
            else
                    
                # Convertir los días seleccionados a números
                dias_numeros=$(echo "$backup_dias_sem_i" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miércoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sábado/6/g; s/Domingo/0/g' | tr '|' ',')
                # Convetir los días a letras
                dias_letras=$(echo "$backup_dias_sem_i" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
            fi

            # Pide la hora y los minutos
            selected_hour_i=$(zenity --forms --title="Programado-Incremental" --text="Hora" --add-entry="Ingresa la hora para el backup (formato HH:MM): ")

            # Verifica si se seleccionó una hora
            if [ -z "$selected_hour_i" ]; then
                zenity --info --text="Operación cancelada."
                Menu
            fi

            # Extrae la hora y los minutos
            hour_i=$(echo "$selected_hour_i" | cut -d":" -f1)
            minute_i=$(echo "$selected_hour_i" | cut -d":" -f2)
                
            # Rutas backup 
                
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            backup_nom_arch_i="$backup_directorio/backup_incremental_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
            mkdir -p "$backup_directorio"
                
                      
            # Crear el nuevo script de respaldo 
            backup_script_i="$backup_script_dir/incremental_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').sh"                        
            echo "#!/bin/bash" > "$backup_script_i"
            echo "backup_dir=\"$backup_nom_arch_i\"" >> "$backup_script_i"
            echo "selected_files=\"$selected_files\"" >> "$backup_script_i"
            echo "cd $backup_directorio" >> "$backup_script_i"

            # Agrega líneas para realizar el respaldo                 
            echo "tar -czpvf \"$backup_nom_arch_i\" --listed-incremental=\"incremental_$nombre_arch_dir.snar\" \"$selected_files\"" >> "$backup_script_i"

            # Programa el backup en Cron según la frecuencia y la hora seleccionada
            cron_expression_i="$minute_i $hour_i * * $dias_numeros"
            crontab -l > mi_crontab_actual
            echo "$cron_expression_i /bin/bash $backup_script_i" >> mi_crontab_actual
            crontab mi_crontab_actual
            rm mi_crontab_actual

            # Dar permisos de ejecución al script
            chmod +x "$backup_script_i" 

            zenity --info --width=500 --height=300 --text="Backup Incremental programado. Hora: $selected_hour_i, Día/s de la semana: $dias_letras"
          
            Menu        

        elif [ "$backup_opcion_pro" == "Diferencial" ]; then      

              # Pide los días de la semana para el Backup Diferencial
            backup_dias_sem_d=$(zenity --list --width=500 --height=300 --title="Programado-Diferencial" --text="Elige el día de la semana:" --checklist --column="Selección" --column="Día" FALSE Lunes FALSE Martes FALSE Miércoles FALSE Jueves FALSE Viernes FALSE Sábado FALSE Domingo)

            # Verifica si se seleccionó algún día
            if [ -z "$backup_dias_sem_d" ]; then
                backup_dias_sem_d="*"
            else
            # Convertir los días seleccionados a números
                dias_numeros=$(echo "$backup_dias_sem_d" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miércoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sábado/6/g; s/Domingo/0/g' | tr '|' ',')
            # Convetir los días a letras
                dias_letras=$(echo "$backup_dias_sem_d" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
                 
            fi

            # Pide la hora y los minutos
            selected_hour_d=$(zenity --forms --title="Programado-Diferencial" --text="Hora" --add-entry="Ingresa la hora para el backup (formato HH:MM): ")

            # Verifica si se seleccionó una hora
            if [ -z "$selected_hour_d" ]; then
                zenity --info --text="Operación cancelada."
                Menu
            fi

            # Extrae la hora y los minutos
            hour_d=$(echo "$selected_hour_d" | cut -d":" -f1)
            minute_d=$(echo "$selected_hour_d" | cut -d":" -f2)

            # Rutas backup 
                
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            backup_nom_arch_d="$backup_directorio/backup_diferencial_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
            mkdir -p "$backup_directorio"                
                      
            # Crear el nuevo script de respaldo 
            backup_script_d="$backup_script_dir/diferencial_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').sh"                        
            echo "#!/bin/bash" > "$backup_script_d"
            echo "backup_dir=\"$backup_nom_arch_d\"" >> "$backup_script_d"
            echo "selected_files=\"$selected_files\"" >> "$backup_script_d"
            echo "cd $backup_directorio" >> "$backup_script_d"

            # Agrega líneas para realizar el respaldo                 
            echo "tar -czpvf \"$backup_nom_arch_d\" --listed-incremental=\"diferencial_$nombre_arch_dir.snar\" \"$selected_files\"" >> "$backup_script_d"

            # Programa el backup en Cron según la frecuencia y la hora seleccionada
            cron_expression_d="$minute_d $hour_d * * $dias_numeros"
            crontab -l > mi_crontab_actual
            echo "$cron_expression_d /bin/bash $backup_script_d" >> mi_crontab_actual
            crontab mi_crontab_actual
            rm mi_crontab_actual

            # Dar permisos de ejecución al script
            chmod +x "$backup_script_d"
            
            zenity --info --width=500 --height=300 --text="Backup Diferencial programado. Hora: $selected_hour_d, Día/s de la semana: $dias_letras"
            Menu      

        else
            zenity --info --text="Operación cancelada por el usuario."
            Menu
        fi  
        

    else
        zenity --info --text="Operación cancelada por el usuario."
        Menu
    fi        
}

####################FUNCION CATALOGO#######################
listar__backups() {
    selected_option=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Selecciona una opción" --column="Opciones" \
                        "Listar Backups Full" \
                        "Listar Backups Incremental" \
                        "Listar Backups Diferencial")

    # Verificar si el usuario canceló la selección
    if [ -z "$selected_option" ]; then
        zenity --error --text="No se seleccionó ninguna opción."
        Menu
    fi

    if [ "$selected_option" == "Listar Backups Full" ]; then
        
        # Obtén la lista de archivos en la carpeta seleccionada        
        search_file=$(find / -type f 2> /dev/null | grep 'backup_full*.*.tar.gz')
        # Muestra la lista de archivos en una ventana de Zenity
        zenity --info --width=500 --height=300 --title="Backups Full" --text="Archivos:\n$(for i in $search_file; do echo -e "\n $i"; done)"
    
    elif [ "$selected_option" == "Listar Backups Incremental" ]; then
        search_file_incremental=$(find / -type f 2> /dev/null | grep -E "backup_incremental_.*\.tar\.gz|incremental_.*\.snar")
        # Muestra la lista de archivos en una ventana de Zenity
       zenity --info --width=500 --height=300 --title="Backups Incremental" --text="Archivos:\n$(for i in $search_file_incremental; do echo -e "\n $i"; done)"
    
    elif [ "$selected_option" == "Listar Backups Diferencial" ]; then
        search_file_diferencial=$(find / -type f 2> /dev/null | grep -E "backup_diferencial_.*\.tar\.gz|diferencial_.*\.snar")
        # Muestra la lista de archivos en una ventana de Zenity
        zenity --info --width=500 --height=300 --title="Backups Diferencial" --text="Archivos:\n$(for i in $search_file_diferencial; do echo -e "\n $i"; done)"
    fi
    Menu
    
}

####################FUNCION LIMPIEZA##########################
limpiar_backups() {

    selected_option=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Selecciona una opción" --column="Opciones" \
                        "Limpiar Backup Full" \
                        "Limpiar Backup Incrementales" \
                        "Limpiar Backups Diferenciales")

    

    if [ "$selected_option" == "Limpiar Backup Full" ]; then

        selected_option_2=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Programación de Backup" --column="Opción" "Inmediato" "Programado")
        if [ "$selected_option_2" == "Inmediato" ]; then

            selected_option_3=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Full" --text="Elige cuantos quieres limpiar" --column="Opciones" "Uno" "Todos")
            if [ "$selected_option_3" == "Uno" ]; then
                rest_bf=$(find / -type f 2> /dev/null | grep "backup_full_.*\.tar\.gz")
                rest_bf_e=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Full" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona los archivos a limpiar:")
                sudo rm -r "$rest_bf_e"
                zenity --info --text="Limpieza completada."
                Menu
            elif [ "$selected_option_3" == "Todos" ]; then
                for i in $(find / -type f 2> /dev/null | grep "backup_full_.*\.tar\.gz"); do rm -r $i; done
                zenity --info --text="Limpieza completada."
                Menu
            else
                zenity --error --text="No se seleccionó ninguna opción."
                Menu
            fi

        
        elif [ "$selected_option_2" == "Programado" ]; then
            limpieza_b=$(zenity --forms --title="Programado Full"--text="Días" --add-entry="Ingresa cada cuantos días quieres la limpieza: ") 
            # Crear el nuevo script de respaldo 
            backup_script_limpieza="$backup_script_dir/full_limpieza_$(date +'%Y%m%d_%H%M').sh"                        
            echo "#!/bin/bash" > "$backup_script_limpieza"
            echo "for i in $(find / -type f 2> /dev/null | grep "backup_full_.*\.tar\.gz"); do rm -r $i; done" >> "$backup_script_limpieza"

                                
            # Programa el backup en Cron según la frecuencia y la hora seleccionada
            cron_expression_d="0 0 */"$limpieza_b" * *"
            crontab -l > mi_crontab_actual
            echo "$cron_expression_d /bin/bash $backup_script_limpieza" >> mi_crontab_actual
            crontab mi_crontab_actual
            rm mi_crontab_actual

            # Dar permisos de ejecución al script
            chmod +x "$backup_script_limpieza"

            zenity --info --text="Limpieza completada."
            Menu
        else
            zenity --error --text="No se seleccionó ninguna opción."
            Menu
        fi

    elif [ "$selected_option" == "Limpiar Backup Incrementales" ]; then

    selected_option_2=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Programación de Backup" --column="Opción" "Inmediato" "Programado")

    if [ "$selected_option_2" == "Inmediato" ]; then

       
        selected_option_3=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Incremental" --text="Elige cuantos quieres limpiar" --column="Opciones" "Uno" "Todos")
        if [ "$selected_option_3" == "Uno" ]; then
            rest_bf=$(find / -type f 2> /dev/null | grep "backup_incremental_.*\.tar\.gz")
            rest_bf_2=$(find / -type f 2> /dev/null | grep "incremental.*.snar")

            rest_bf_e=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Incremental" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el Backup para Limpiar: ")
            rest_bf_e_2=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Incremental" --column="Rutas de Archivo" $(for i in $rest_bf_2; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el nombre del archivo .snar a Restaurar: ")
                
            sudo rm -r "$rest_bf_e" "$rest_bf_e_2"
            zenity --info --text="Limpieza completada."
            Menu
        elif [ "$selected_option_3" == "Todos" ]; then
            for i in $(find / -type f 2> /dev/null | grep "backup_incremental_.*\.tar\.gz|incremental_.*\.snar"); do rm -r $i; done
            zenity --info --text="Limpieza completada."
            Menu
        else
            zenity --error --text="No se seleccionó ninguna opción."
            Menu
        fi
        
        
    elif [ "$selected_option_2" == "Programado" ]; then
        limpieza_b=$(zenity --forms --title="Programado Incremental" --text="Días" --add-entry="Ingresa cada cuantos días quieres la limpieza: ") 
       # Crear el nuevo script de respaldo 
        backup_script_limpieza="$backup_script_dir/incremental_limpieza_$(date +'%Y%m%d_%H%M').sh"                        
        echo "#!/bin/bash" > "$backup_script_limpieza"
        echo "for i in $(find / -type f 2> /dev/null | grep -E "backup_incremental_.*\.tar\.gz|incremental_.*\.snar"); do rm -r $i; done" >> "$backup_script_limpieza"

                                
        # Programa el backup en Cron según la frecuencia y la hora seleccionada
        cron_expression_d="0 0 */"$limpieza_b" * *"
        crontab -l > mi_crontab_actual
        echo "$cron_expression_d /bin/bash $backup_script_limpieza" >> mi_crontab_actual
        crontab mi_crontab_actual
        rm mi_crontab_actual

        # Dar permisos de ejecución al script
        chmod +x "$backup_script_limpieza"

        zenity --info --text="Limpieza completada."
        Menu
    else
        zenity --error --text="No se seleccionó ninguna opción."
        Menu
    fi

    elif [ "$selected_option" == "Limpiar Backup Diferenciales" ]; then

    selected_option_2=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Programación de Backup" --column="Opción" "Inmediato" "Programado")

    if [ "$selected_option_2" == "Inmediato" ]; then
        selected_option_3=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Diferencial" --text="Elige cuantos quieres limpiar" --column="Opciones" "Uno" "Todos")
        if [ "$selected_option_3" == "Uno" ]; then
            rest_bf=$(find / -type f 2> /dev/null | grep "backup_diferencial_.*\.tar\.gz")
            rest_bf_2=$(find / -type f 2> /dev/null | grep "diferencial.*.snar")

            rest_bf_e=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Diferencial" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el Backup para Limpiar: ")
            rest_bf_e_2=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Diferencial" --column="Rutas de Archivo" $(for i in $rest_bf_2; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el nombre del archivo .snar a Restaurar: ")
            
            sudo rm -r "$rest_bf_e" "$rest_bf_e_2"
            zenity --info --text="Limpieza completada."
            Menu
        elif [ "$selected_option_3" == "Todos" ]; then
            for i in $(find / -type f 2> /dev/null | grep -E "backup_diferencial_.*\.tar\.gz|diferencial_.*\.snar"); do rm -r $i; done
            zenity --info --text="Limpieza completada."
            Menu
        else
            zenity --error --text="No se seleccionó ninguna opción."
            Menu
        fi  

    elif [ "$selected_option_2" == "Programado" ]; then
        limpieza_b=$(zenity --forms --title="Programado Diferencial" --text="Días" --add-entry="Ingresa cada cuantos días quieres la limpieza: ") 
       # Crear el nuevo script de respaldo 
        backup_script_limpieza="$backup_script_dir/diferencial_limpieza_$(date +'%Y%m%d_%H%M').sh"                        
        echo "#!/bin/bash" > "$backup_script_limpieza"
        echo "for i in $(find / -type f 2> /dev/null | grep -E "backup_diferencial_.*\.tar\.gz|diferencial_.*\.snar"); do rm -r $i; done" >> "$backup_script_limpieza"
        # Programa el backup en Cron según la frecuencia y la hora seleccionada
        cron_expression_d="0 0 */"$limpieza_b" * *"
        crontab -l > mi_crontab_actual
        echo "$cron_expression_d /bin/bash $backup_script_limpieza" >> mi_crontab_actual
        crontab mi_crontab_actual
        rm mi_crontab_actual

        # Dar permisos de ejecución al script
        chmod +x "$backup_script_limpieza"

        zenity --info --text="Limpieza completada."
        Menu
    else
        zenity --error --text="No se seleccionó ninguna opción."
        Menu
    fi

    else
        zenity --error --text="No se seleccionó ninguna opción."
        Menu
    fi
}

###################FUNCION RESTAURAR######################
restaurar__backups () {

    selected_option=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Selecciona una opción" --column="Opciones" \
                        "Restaurar Backup Full" \
                        "Restaurar Backup Incrementales" \
                        "Restaurar Backups Diferenciales")

    

    if [ "$selected_option" == "Restaurar Backup Full" ]; then
        rest_bf=$(find / -type f -name "backup_full_*.tar.gz" | xargs ls) 

        rest_bf_e=$(zenity --list --width=500 --height=300 --title="Restaurar Backup Full" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona los archivos a Restaurar:")
        rest_bf_s=$(zenity --file-selection --directory --title="Seleccionar directorio para la Restauración")
        tar -xzvf "$rest_bf_e" -C "$rest_bf_s"
        zenity --info --text="Restauración Full completada."
        Menu

    elif [ "$selected_option" == "Restaurar Backup Incrementales" ]; then
        rest_bf=$(find / -type f 2> /dev/null | grep "backup_incremental_.*\.tar\.gz")
        rest_bf_2=$(find / -type f 2> /dev/null | grep "incremental.*.snar" | rev | cut -d'/' -f1 | rev)
 
        rest_bf_e=$(zenity --list --width=500 --height=300 --title="Restaurar Backup Incrementales" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el Backup para Restaurar: ")
        rest_bf_e_2=$(zenity --list --width=500 --height=300 --title="Restaurar Backup Incrementales" --column="Rutas de Archivo" $(for i in $rest_bf_2; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el nombre del archivo .snar a Restaurar: ")
         
        rest_bf_s=$(zenity --file-selection --directory --title="Seleccionar directorio para la Restauración")
         
        tar -xzvf "$rest_bf_e" --listed-incremental="$rest_bf_e_2" -C "$rest_bf_s"
        zenity --info --text="Restauración Incremental completada."
        Menu

    elif [ "$selected_option" == "Restaurar Backup Diferenciales" ]; then
        rest_bf=$(find / -type f 2> /dev/null | grep "backup_diferencial_.*\.tar\.gz")
        rest_bf_2=$(find / -type f 2> /dev/null | grep "diferencial.*.snar" | rev | cut -d'/' -f1 | rev)

        rest_bf_e=$(zenity --list --width=500 --height=300 --title="Restaurar Backup Diferenciales" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el Backup para Restaurar: ")
        rest_bf_e_2=$(zenity --list --width=500 --height=300 --title="Restaurar Backup Diferenciales" --column="Rutas de Archivo" $(for i in $rest_bf_2; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el nombre del archivo .snar a Restaurar: ")
         
        rest_bf_s=$(zenity --file-selection --directory --title="Seleccionar directorio para la Restauración")
         
        tar -xzvf "$rest_bf_e" --listed-incremental="$rest_bf_e_2" -C "$rest_bf_s"
        zenity --info --text="Restauración Incremental completada."
        Menu
    else
        zenity --error --text="No se seleccionó ninguna opción."
        Menu
    fi
    
}


#########################FUNCION DISCOS Y PARTICIONES###############################
cp_disk_part () {

    opcion_particion=$(zenity --list --width=500 --height=300 --title="$nombre_programa / Discos y Particones" --text="Elige una tarea" --column="Opción" "Copia" "Restauración") 
    if [ "$opcion_particion" == "Copia" ]; then  

        opcion_particion_2=$(zenity --list --width=500 --height=300 --title="Copia" --text="Elige una opción" --column="Opción" "Disco" "Partición")

        if [ "$opcion_particion_2" == "Disco" ]; then

            selec_disco_e=$(zenity --list --width=500 --height=300 --title="Copia / Disco" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $2}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona el Disco a copiar: ")
            
            opcion_particion_3=$(zenity --list --title="Copia / Disco" --text="¿Quieres hacer la copia en otro Disco o en un directorio?" --column="Opción" "Disco" "Directorio") 
            
            if [ "$opcion_particion_3" == "Disco" ]; then
                selec_disco_s=$(zenity --list --width=500 --height=300 --title="Copia / Disco" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $2}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona el Disco donde quieres copiar: ")
                if [ $(mount -l | grep $selec_disco_s) ]; then
                   
                    validacion_disco=$(zenity --list --width=500 --height=300 --title="$nombre_programa / Discos y Particones" --text="Esta opción va a borrar el contenido este disco $selec_disco_s" --column="Opción" "si" "no")
                    if [ "$validacion_disco" == "si" ]; then
                        sudo dd if="$selec_disco_e" of="$selec_disco_s" bs=4M status=progress               
                        zenity --info --width=400 --height=200 --text="Copia del Disco $selec_disco_e hecha en $selec_disco_s completada." 
                        Menu
                    else
                        cp_disk_part
                    fi

                else 
                    sudo dd if="$selec_disco_e" of="$selec_disco_s" bs=4M status=progress               
                    zenity --info --width=400 --height=200 --text="Copia del Disco $selec_disco_e hecha en $selec_disco_s completada." 
                    Menu
                fi
                
        
            elif [ "$opcion_particion_3" == "Directorio" ]; then
                selec_direc=$(zenity --file-selection --directory --title="Seleccionar directorio para el respaldo")

                sudo dd if="$selec_disco_e" of="$selec_direc"/Backup_Disco_"$selec_disco_e".img bs=4M status=progress
                

                zenity --info --width=400 --height=200 --text="Copia del Disco $selec_disco_e hecha en "$selec_direc"/Backup_Disco_"$selec_disco_e".img completada."
                Menu
            else
                zenity --info --text="Operación cancelada."
                Menu
            fi    

            

        elif [ "$opcion_particion_2" == "Partición" ]; then            
            selec_part=$(zenity --list --width=500 --height=300 --title="Copia / Disco" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona la Partición a copiar: ")
    
            opcion_particion_3=$(zenity --list --title="¿Quieres hacer la copia en otra Partición o en un directorio?" --column="Opción" "Partición" "Directorio")       
            
            if [ "$opcion_particion_3" == "Partición" ]; then
                selec_particion_s=$(zenity --list --width=500 --height=300 --title="Copia / Disco" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona la Partición donde quieres copiar: ")
                
                
                if [ $(mount -l | grep $selec_particion_s) ]; then
                   
                    validacion_disco=$(zenity --list --width=500 --height=300 --title="$nombre_programa / Discos y Particones" --text="Esta opción va a borrar el contenido este disco $selec_particion_s" --column="Opción" "si" "no")
                    if [ "$validacion_disco" == "si" ]; then
                        sudo dd if="$selec_part" of="$selec_particion_s" bs=4M status=progress
                        zenity --info --width=400 --height=200 --text="Copia de la Partición $selec_part hecha en $selec_particion_s completada."
                        Menu
                    else
                        cp_disk_part
                    fi

                else 
                    sudo dd if="$selec_part" of="$selec_particion_s" bs=4M status=progress
                    zenity --info --width=400 --height=200 --text="Copia de la Partición $selec_part hecha en $selec_particion_s completada."
                    Menu
                fi
                  
                
            elif [ "$opcion_particion_3" == "Directorio" ]; then
                selec_direc=$(zenity --file-selection --directory --title="Seleccionar directorio para el respaldo")
                sudo dd if="$selec_part" of="$selec_direc"/Backup_"$selec_part".img bs=4M status=progress
                zenity --info --width=400 --height=200 --text="Copia de la Partición $selec_part hecha en $selec_direc/Backup_$selec_part.img completada."
                Menu
            else
                zenity --info --text="Operación cancelada."
                Menu
            fi
        else
            zenity --info --text="Operación cancelada."
            Menu
        fi

 


    elif [ "$opcion_particion" == "Restauración" ]; then

        opcion_res=$(zenity --list --width=500 --height=300 --title="Restauración" --text="Elige una opción" --column="Opción" "Disco" "Partición") 
        if [ "$opcion_res" == "Disco" ]; then
            selec_disc_r=$(zenity --file-selection --multiple --title="Selecciona el Disco a restaurar")

            if [ -z "$selec_disc_r" ]; then
                zenity --info --text="No se ha seleccionado ninguna Partición."
                Menu
            fi   

            selec_disc_s=$(zenity --list --width=500 --height=300 --title="Restauración / Disco" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $2}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona el Disco donde quieres restaurar: ")       
            sudo dd if="$selec_disc_r" of="$selec_disc_s" bs=4M status=progress
            zenity --info --width=400 --height=200 --text="El Disco $selec_disc_r ha sido restaurada en $selec_disc_s."
            Menu

    

        elif [ "$opcion_res" == "Partición" ]; then
            selec_part_r=$(zenity --file-selection --multiple --title="Selecciona la Partición a restaurar")
            
            if [ -z "$selec_part_r" ]; then
                zenity --info --text="No se ha seleccionado ninguna Partición."
                Menu
            fi   

            selec_part_s=$(zenity --list --width=500 --height=300 --title="Restauración / Disco" --column="Rutas de Archivo" $(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':') --multiple --separator=' ' --text="Selecciona la Partición donde quieres restaurar: ")       
            sudo dd if="$selec_part_r" of="$selec_part_s" bs=4M status=progress
            zenity --info --width=400 --height=200 --text="La Partición $selec_part_r ha sido restaurada en $selec_part_s."
            Menu

        else
            zenity --info --text="Operación cancelada por el usuario."
            Menu
        fi
   
    else
        zenity --info --text="Operación cancelada por el usuario."
        Menu
    fi

}

Eliminar_Tareas() {
    IFS=$'\n' # Establece el separador como nueva línea
    seleccion=$(zenity --list --width=500 --height=300 --title="Restauración / Disco" --column="Rutas de Archivo" $(sudo crontab -l | awk '{$1=$1};1') --multiple --separator=' ' --text="Selecciona la Partición donde quieres restaurar: ")
    unset IFS # Restaura el IFS al valor predeterminado
    echo $seleccion
    if [ -z $seleccion ]; then 
        zenity --error --text="Necesitas seleccionar una tarea."
        Menu
    else
        seleccion2=$(echo "$seleccion" | awk '{print $7}')
        sudo crontab -l | grep -v "$seleccion2" | sudo crontab -
        zenity --info --text="Tareas actualizadas"
        Menu
    fi
}


########################FUNCION AYUDA####################3
ayuda() {
    zenity --info --width=600 --height=500 --title="Ayuda / $nombre_programa" --text="
############## Realizar Copias de Seguridad ##############

Esta opción te permite respaldar archivos importantes y configuraciones para prevenir pérdidas de datos en caso de fallos del sistema o eventos inesperados.


############## Listado de Backups ##############

Accede a un listado detallado de todas las copias de seguridad realizadas. Aquí podrás revisar la fecha y la hora de cada respaldo, proporcionándote un panorama completo de tus datos respaldados para una gestión eficiente.


############## Limpieza de Backups ##############

La limpieza de backups es esencial para optimizar el espacio de almacenamiento. Esta opción te permite eliminar copias de seguridad antiguas o innecesarias, liberando espacio y garantizando que solo retengas la información más relevante y actualizada.


############## Restauración de Backups ##############

Esta función te permite recuperar archivos y configuraciones desde copias de seguridad previamente creadas, restaurando tu sistema a un estado anterior funcional y confiable.


############## Disco - Partición ##############

Realiza una copia completa de tu disco, partición o restaura tu sistema a partir de una copia existente. Esta opción es esencial para respaldar y recuperar tu sistema operativo, aplicaciones y archivos esenciales, proporcionándote una solución integral para la gestión de tu sistema.


############## Eliminar Tareas del cron ##############

Esta sección te administra las tareas del cron de manera que puedes eliminar a tu eleccion y sin que se borren las demas tareas asignadas.  "


    Menu
}

######################FUNCION MENU#############################
Menu() {
    choice=$(zenity --list --width=500 --height=300 --title="$nombre_programa" --text="Menú Copias de Seguridad" --column="Opcion" \
    "Realizar Copias de Seguridad" \
    "Listado de Backups" \
    "Limpieza de Backups" \
    "Restauracion de Backups" \
    "Disco - Particion " \
    "Eliminar Tareas" \
    "Ayuda" \
    "Salir")

    if [ -z "$choice" ]; then
        zenity --error --text="No se seleccionó ninguna opción."
        exit 1
    fi

    if [ "$choice" == "Realizar Copias de Seguridad" ]; then 
        backup_archivos_directorios    
    elif [ "$choice" == "Listado de Backups" ]; then
        listar__backups
    elif [ "$choice" == "Limpieza de Backups" ]; then
        limpiar_backups
    elif [ "$choice" == "Restauracion de Backups" ]; then
        restaurar__backups
    elif [ "$choice" == "Disco - Particion " ]; then
        cp_disk_part
    elif [ "$choice" == "Eliminar Tareas" ]; then
        Eliminar_Tareas
    elif [ "$choice" == "Ayuda" ]; then
        ayuda
    elif [ "$choice" == "Salir" ]; then
        exit 0
    fi

}

################FUNCION PROGRESO########################
Progreso() {
    if [[ "$(id -u)" != "0" ]]; then

        echo "Este script se debe de ejecutar como root, con sudo." 1>&2
        exit 1
    else
    (
            echo "10" ; sleep 1
            echo "# Verificacion de usuario completada" ; sleep 1
            echo "20" ; sleep 1
            echo "# Verificando Instalación" ; sleep 1
            instalacion
            echo "50" ; sleep 1
            echo "This Verificando directorio" ; sleep 1
            Carpetas
            echo "75" ; sleep 1
            echo "# Iniciando" ; sleep 1
            echo "100" ; sleep 1
        ) |
        zenity --progress \
          --title="Launcher Programa" \
          --text="Escanenado..." \
          --width=300 \
          --percentage=0


        if [ "$?" = -1 ] ; then
                zenity --error \
                --text="Operacion cancelada"
            exit 1

        fi
        Menu  
    fi
  
}

##################FUNCION VERIFICACION INICIO####################
primera() {
 
    if [ -f /etc/visto ]; then

        echo "Ya ha creado todo el contenido."
        Menu

    else
        
        sudo touch /etc/visto
        Progreso
    fi 
}
xdotool getactivewindow windowminimize
primera 

