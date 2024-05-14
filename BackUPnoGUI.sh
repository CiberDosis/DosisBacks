#!/bin/bash

# Creado por CiberDosis, una remodelacion del script inicial creado por mis compañeros y yo, culaquier cambio en mi github CiberDosis/Dosis_Backs.



################################Colores#############################

green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

################################Variables################################


nombre_programa="AARL_BACKUPS"
backup_script_dir="/Backup_Script"

directorio_raiz=""




################################Funciones################################

ctrl_c() {
  echo -e "${red}\n\n[!] Saliendo...${end}\n"
  exit 1
}
trap ctrl_c INT


Carpetas() {

    echo -e "\n$(sudo fdisk -l | grep "/dev/")\n Escoge una particion para el disco para montar el directorio del programa...(Ruta COMPLETA)" && read selec_part_i
    echo -e "\n${yellow}[+]${end} ${gray}Creando directorios de respaldo proporcionados por el programa DosisBacks...${end}"
    mkdir /AARL_Backup && echo -e "${green} Directorio $directorio_raiz creado correctamente." 
    sudo mount "$selec_part_i" /AARL_Backup
    mkdir -p /AARL_Backup/Backups    
    cd /AARL_Backup/Backups 
    mkdir -p {Full,Incremental,Diferencial,Discos_Particiones_img}     
    cd /
    mkdir -p /Backup_Script 
}
helpPanel() {

    echo -e "\n${yellow}{+}${end} ${red}Este es el panel de ayuda para la herramienta DOSIBACKS.${end}"
    
    echo -e "\n${yellow}{+}${end} ${red}En DOSIBACKS estan disponibles las siguientes funciones:${end}\n"
    
    echo -e "\n${yellow}{+}${end} ${purple}[ Realizar Copia De Seguridad ]${end}${turquoise}
    Esta opción te permite respaldar archivos importantes y configuraciones
    Asi se puede prevenir pérdidas de datos en caso de fallos del sistema o eventos inesperados.${end}"
    
    echo -e "\n${yellow}{+}${end} ${purple}[ Listar Copias De Seguridad ]${end}${turquoise}
    Accede a un listado detallado de todas las copias de seguridad realizadas.
    Aquí podrás revisar la fecha y la hora de cada respaldo,
    proporcionándote un panorama completo de tus datos respaldados para una gestión eficiente.${end}"
    
    echo -e "\n${yellow}{+}${end} ${purple}[ Limpieza de Copias De Seguridad ]${end}${turquoise}
    La limpieza de backups es esencial para optimizar el espacio de almacenamiento.
    Esta opción te permite eliminar copias de seguridad antiguas o innecesarias,
    liberando espacio y garantizando que solo retengas la información más relevante y actualizada.${end}"
    
    echo -e "\n${yellow}{+}${end} ${purple}[ Restauracion de Backups ]${end}${turquoise}
    Esta función te permite recuperar archivos y configuraciones desde copias de seguridad previamente creadas,
    restaurando tu sistema a un estado anterior funcional y confiable.${end}" 
    
    echo -e "\n${yellow}{+}${end} ${purple}[ Disco - Particion ]${end}${turquoise}
    Realiza una copia completa de tu disco, partición o restaura tu sistema a partir de una copia existente.
    Esta opción es esencial para respaldar y recuperar tu sistema operativo, aplicaciones y archivos esenciales,
    proporcionándote una solución integral para la gestión de tu sistema.${end}"
    
    echo -e "\n${yellow}{+}${end} ${purple}[ Eliminar Tareas del Cron ]${end}${turquoise}
    Esta sección te administra las tareas del cron de manera que puedes eliminar a tu eleccion
    y sin que se borren las demas tareas asignadas.${end}" 
     
    echo -e "\n${yellow}{+}${end} ${blue}Un placer informarte $USER ${green}:)${end}"

}

#######################################################################################



#Validacion de ROOT

if [[ "$(id -u)" != "0" ]]; then

    echo -e "\n${red}ESTE SCRIPT SE DEBE EJECUTAR CON PERMISOS DE ADMINISTRADOR $USER, CON SUDO.${end}\n" 1>&2
    helpPanel
    exit 1
fi

verificacioncontenido() {
    if [[ -f /etc/visto && -d /AARL_Backup ]]; then
        echo "Ya ha creado todo el contenido."; sleep 2
        clear
    else
        sudo touch /etc/visto
        Carpetas
    fi 
}








#############################Intro#############################
clear
echo -e "\n${gray}[+]${end} ${red}Antes de seguir con el programa se necesita tener una particion del disco duro creada y libre.
    (Tiene que estar listo para poder montar el directorio, formateado...)${end}"
read -p "Pulsa Enter para continuar cuando estes listo :)..."
echo -e "${blue}Estamos verificando el contenido.....${end}"; sleep 2
verificacioncontenido

    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
   


echo -e "\n${purple}[+]${end}"
echo -e "\n${yellow}[+]${end} ${green}Este Script es una automatizacion de copias de seguridad para sistemas UNIX. [Linux] ${end}"
echo -e "${yellow}[+]${end} ${green}Segun si tiene interfaz grafica o no tendras las distintas vistas de este programa. ${end}"
echo -e "${yellow}[+]${end} ${green}Espero que te sirva de ayuda. Cualquier cosa ya sabes Coge tu Dosis ;) ${end}"
echo -e "\n${purple}[+]${end}\n"


######################FUNCION MENU#############################



#################FUNCION BACKUPS#########################
backup_archivos_directorios() {
    clear
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
    # Mostrar el diálogo de selección de directorios para la dirección de respaldo
    echo -e "\n${gray}Escribe la ruta completa de donde quieres guardar el resplado:${end} " && read backup_dir

    # Verificar si se seleccionó un directorio
    if [ -d "$backup_dir" ]; then
       echo -e "\n${gray}Se ha seleccionado un directorio de respaldo.${end}${green}[ $backup_dir ]${end}"
    else
        echo -e "\n${red}No se ha seleccionado un directorio de respaldo.${end}"
        echo -e "\n${yellow}Creando directorio $backup_dir....${end}"
        mkdir -p $backup_dir
        echo -e "\n${green}Directorio $backup_dir creado.${end}"
    fi
    # Mostrar el diálogo de selección de archivos/directorio
    echo -e "\n${gray}Selecciona la ruta completa del directorio que quieres hacer la copia de seguridad:  ${end}" && read selected_files
    # Verificar si se seleccionó al menos un archivo o directorio
    if [ -d "$selected_files" ]; then
        echo -e "\n${green}Se ha seleccionado un directorio de respaldo $selected_files.${end}"; sleep 1
    else
        echo -e "\n${red}No se ha seleccionado un directorio de respaldo $selected_files.${end}"; sleep 2
        Menu
    fi
    # Extraer el nombre base del archivo o directorio seleccionado
    nombre_arch_dir=$(basename "$selected_files")

    # Mostrar el diálogo para elegir entre realizar el respaldo inmediato o programarlo
    echo -e "\n${gray}[+] Escribe si quieres hacer un respaldo Inmediato o Programado.${end}" && read backup_option
    #Realizar el respaldo inmediato 
    if [ "$backup_option" == "Inmediato" ]; then 
        echo -e "\n${gray}Escribes si quieres hacer un respaldo Full, Incremental o Diferencial.${end}" && read backup_tipo_i
        if [ -z $backup_tipo_i ]; then
            echo -e "\n${red}No has seleccionado ninguna opcion${end}"; sleep 2
            backup_archivos_directorios
        fi
        if [ "$backup_tipo_i" == "Full" ]; then 
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            mkdir -p "$backup_directorio"
            backup_nom_arch="$backup_directorio/backup_full_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"            
            tar -czpvf "$backup_nom_arch" "$selected_files"
            echo -e "\n${green}Backup-Full realizado correctamente en $backup_nom_arch.${end}"; sleep 2
            Menu
        elif [ "$backup_tipo_i" == "Incremental" ]; then
            backup_directorio="$backup_dir/$nombre_arch_dir"
            backup_nom_arch_i="$backup_directorio/backup_incremental_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
            backup_snar="$backup_directorio/incremental_$nombre_arch_dir.snar"
            mkdir -p "$backup_directorio"

            # Cambiar temporalmente al directorio de respaldo
            (
                cd "$backup_directorio" || exit
                # Ejecutar el comando tar dentro del directorio de respaldo
                tar -czpvf "$backup_nom_arch_i" --listed-incremental="$backup_snar" "$selected_files"
            )

            echo -e "\n${green}Backup-Incremental realizado correctamente en $backup_nom_arch_i y $backup_snar.${end}"
            sleep 2
            Menu
        elif [ "$backup_tipo_i" == "Diferencial" ]; then 
            backup_directorio="$backup_dir"/"$nombre_arch_dir"
            backup_nom_arch_d="$backup_directorio/backup_diferencial_${nombre_arch_dir}_$(date +'%Y%m%d_%H%M').tar.gz"
            mkdir -p "$backup_directorio"
            cd "$backup_directorio"
            tar -czpvf "$backup_nom_arch_d" --listed-incremental="diferencial_$nombre_arch_dir.snar" "$selected_files"
            echo -e "\n${green}Backup-Diferencial realizado correctamente en $backup_nom_arch_d y diferencial_$nombre_arch_dir.snar.${green}"; sleep 2
            Menu
        else 
            echo -e "\n${red}Programa cancelado${end}"
            Menu 
        fi 
 
     ###########Realizar el respaldo PROGRAMADO##########      
    elif [ "$backup_option" == "Programado" ]; then       
        echo -e "\n${gray}Escribe si quieres hacer un respaldo Full, Incremental o Diferencial.${end}" && read backup_opcion_pro
        if [ -z $backup_opcion_pro ]; then
            echo -e "\n${red}No has seleccionado ninguna opcion.${end}"
            backup_archivos_directorios
        fi
        if [ "$backup_opcion_pro" == "Full" ]; then                        
            echo -e "\n${green}¿Quieres que se haga un dia del mes en concreto? Respuesta (si/no)...${end}" && read backup_dia_mes_elec
            if [ -z $backup_dia_mes_elec ]; then
                echo -e "${red}No has seleccionado ningun opcion.${end}"
                backup_archivos_directorios
            fi
            if [ "$backup_dia_mes_elec" == "si" ]; then
                echo -e "\n${green}[+] Ingresa el día del mes en (formato 1-31)${end}" && read backup_dia_mes

                echo -e "\n${green}[+] ¿Quieres que se haga un dia de la semana en concreto? Respuesta: (si/no)${end}" && read backup_dia_sem_elec 
                    
                if [ "$backup_dia_sem_elec" == "si" ]; then 

                    echo -e "\n${green}[+] Elige el dia de la semana: Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo${end}" && read backup_dias_sem 

                    #Verificar si se seleccionó algún día
                    if [ -z "$backup_dias_sem" ]; then
                        # No se seleccionó ningún día
                        dias_numeros="*"    
                    else                        
                        # Convertir los días seleccionados a números
                        dias_numeros=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miercoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sabado/6/g; s/Domingo/0/g' | tr '|' ',')
                        # Convetir los días a letras
                        dias_letras=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
                    fi
                        
                        
                    # Mostrar el diálogo para elegir la hora y los minutos
                    echo -e "\n${green}[+] Ingresa la hora para el backup (formato HH:MM)${end}" && read selected_hour

                    # Verificar si se seleccionó una hora
                    if [ -z "$selected_hour" ]; then
                        echo -e "${red}Operación cancelada.${end}"
                        Menu
                    fi                        
                        
                    # Extraer la hora y los minutos
                    hour=$(echo "$selected_hour" | cut -d ':' -f1)
                    minute=$(echo "$selected_hour" | cut -d ':' -f2)

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
                    backup_script_abs=$(realpath "$backup_script")

                    crontab -l > mi_crontab_actual
                    echo "$cron_expression $backup_script_abs" >> mi_crontab_actual
                    crontab mi_crontab_actual
                    rm mi_crontab_actual

                    # Dar permisos de ejecución al script
                    chmod +x "$backup_script"               
             
                    # Mostrar mensaje de éxito
                    echo -e "\n\t${green}Backup Full programado.${end}${yellow} Hora:${end}${green} $selected_hour${end}, ${blue}Día del mes:${end}${green} $backup_dia_mes,${end}${purple} Día de la semana:${end}${green} $dias_letras${end}"; sleep 3
                    Menu

                elif [ "$backup_dia_sem_elec" == "no" ]; then                        

                        # Mostrar el diálogo para elegir la hora y los minutos
                        echo -e "\n${green}[+] Ingresa la hora para el backup (formato HH:MM):${end} " && read selected_hour

                        # Verificar si se seleccionó una hora
                        if [ -z "$selected_hour" ]; then
                            echo -e "${red}Operación cancelada.${end}"; sleep 2
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
                        echo -e "\n\t${green}Backup Full programado.${end}${yellow} Hora:${end}${green} $selected_hour,${end}${blue} Dia del mes:${end}${green} $backup_dia_mes${end}"; sleep 3           
                        Menu

                else
                    echo -e "${red}Operación cancelada${end}"
                    Menu   
                fi  
              

            elif [ "$backup_dia_mes_elec" == "no" ]; then

                echo -e "\n${green}[+] Elige el dia de la semana: Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo${end}" && read backup_dias_sem
                       
                #Verificar si se seleccionó algún día
                if [ -z "$backup_dias_sem" ]; then
                    # No se seleccionó ningún día
                    backup_dias_sem="*"    
                else                        
                    # Convertir los días seleccionados a números
                    dias_numeros=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miercoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sabado/6/g; s/Domingo/0/g' | tr '|' ',')
                    # Convetir los días a letras
                    dias_letras=$(echo "$backup_dias_sem" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
                    
                fi

                # Mostrar el diálogo para elegir la hora y los minutos
                echo -e "\n${green}[+] Ingresa la hora para el backup (formato HH:MM):${end} " && read selected_hour

                # Verificar si se seleccionó una hora
                if [ -z "$selected_hour" ]; then
                    echo -e "${red}Operación cancelada.${end}"
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
                echo -e "\n\t${green}Backup Full programado.${end}${yellow} Hora:${end}${blue} $selected_hour,${end}${gray}} Día de la semana:${end}${blue} $dias_letras${end}"; sleep 3
                Menu
            else
                echo -e "\n${red}Operación cancelada${end}"
                Menu 
            fi             
        elif [ "$backup_opcion_pro" == "Incremental" ]; then 
                     
            # Pide los días de la semana para el Backup Incremental
            echo -e "\n${green}[+] Elige el dia de la semana: Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo${end}" && read backup_dias_sem_i

            # Verifica si se seleccionó algún día
            if [ -z "$backup_dias_sem_i" ]; then
                backup_dias_sem_i="*"
            else
                    
                # Convertir los días seleccionados a números
                dias_numeros=$(echo "$backup_dias_sem_i" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miercoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sabado/6/g; s/Domingo/0/g' | tr '|' ',')
                # Convetir los días a letras
                dias_letras=$(echo "$backup_dias_sem_i" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
            fi
            
            # Pide la hora y los minutos
            echo -e "\n${green}[+] Ingresa la hora para el backup incremental (formato HH:MM): ${end}" && read selected_hour_i

            # Verifica si se seleccionó una hora
            if [ -z "$selected_hour_i" ]; then
                echo -e "${red}Operación cancelada.${end}"; sleep 3
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

            echo -e "\n${green}[+] Backup Incremental programado.${end}${yellow} Hora:${end}${blue} $selected_hour_i,${end}${green} Dia/s de la semana:${end}${blue} $dias_letras${end}"; sleep 3
            read -p "Pulsa Enter para continuar"
            Menu        

        elif [ "$backup_opcion_pro" == "Diferencial" ]; then      

            # Pide los dias de la semana para el Backup Diferencial
            echo -e "\n${green}[+] Elige el dia de la semana: Lunes, Martes, Miercoles, Jueves, Viernes, Sabado, Domingo${end}" && read backup_dias_sem_d

            # Verifica si se seleccionó algún día
            if [ -z "$backup_dias_sem_d" ]; then
                backup_dias_sem_d="*"
            else
                # Convertir los días seleccionados a números
                dias_numeros=$(echo "$backup_dias_sem_d" | tr '\n' ',' | sed 's/,$//' | sed 's/,/ /g' | sed 's/Lunes/1/g; s/Martes/2/g; s/Miercoles/3/g; s/Jueves/4/g; s/Viernes/5/g; s/Sabado/6/g; s/Domingo/0/g' | tr '|' ',')
                # Convetir los días a letras
                dias_letras=$(echo "$backup_dias_sem_d" | tr '\n' ',' | sed 's/,/ /g' | tr '|' ',')
                 
            fi

            # Pide la hora y los minutos
            echo -e "\n${green}[+] Ingresa la hora para el backup diferencial (formato HH:MM):${end} " && read selected_hour_d

            # Verifica si se seleccionó una hora
            if [ -z "$selected_hour_d" ]; then
                echo -e "${red}Operacion cancelada.${end}"; sleep 2
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
            
            echo -e "\n${green}[+] Backup Diferencial programado.${end}${yellow} Hora:${end}${green} $selected_hour_d,${end}${blue} Día/s de la semana:${end}${purple} $dias_letras${end}"; sleep 3
            Menu      

        else
            echo -e "${red}Operación cancelada por $USER.${end}"
            Menu
        fi  
        

    else
        echo -e "${red}Operación cancelada por $USER.${end}"
        Menu
    fi        
}

####################FUNCION CATALOGO#######################
listar__backups() {
    clear
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
    echo -e "${green}------------------------------${end}"
    echo -e "${green}| Listar Copias de Seguridad |${end}"
    echo -e "${green}------------------------------${end}"
    echo -e "${yellow}---->${end}${gray} [ 1 ] Listar Backups Full${end}" 
    echo -e "${yellow}---->${end}${gray} [ 2 ] Listar Backups Incremental${end} "
    echo -e "${yellow}---->${end}${gray} [ 3 ] Listar Backups Diferencial${end} "
    echo -e "${green}---------------------------------------${end}"
    echo -e "\n${blue}Selecciona una opcion:${end} " && read selected_option
    # Verificar si el usuario canceló la selección
    if [ -z "$selected_option" ]; then
        echo -e "${red}No se seleccionó ninguna opción.${end}"
        Menu
    fi

    if [ "$selected_option" -eq "1" ]; then
        echo -e "\n${yellow}Obteniendo listado de copias de seguridad totales...${end}\n"
        # Obtén la lista de archivos en la carpeta seleccionada        
        search_files=$(find / -type f 2> /dev/null | grep 'backup_full*.*.tar.gz')
        counter=0
        for i in $search_files; do
            ((counter++))
            echo -e "${purple}[$counter] $i${end}" | column
        done
        echo -e "\n${green}Total de Backups Full:${end} ${turquoise}$counter${end}"
        echo -e "\n${green}Pulsa ENTER para continuar:${end}" && read
    elif [ "$selected_option" -eq "2" ]; then
        echo -e "\n${yellow}Obteniendo listado de copias de seguridad incrementales y archivos snar...${end}\n"
        search_files=$(find / -type f 2> /dev/null | grep -E "backup_incremental_.*\.tar\.gz|incremental_.*\.snar")
        counter=0
        for i in $search_files; do
            ((counter++))
            echo -e "${purple}[$counter] $i${end}" | column
        done
        echo -e "\n${yellow}Total de Backups Incrementales y Snar:${end} ${turquoise}$counter${end}"
        echo -e "\n${green}Pulsa ENTER para continuar:${end}" && read
    elif [ "$selected_option" -eq "3" ]; then
        echo -e "\n${yellow}Obteniendo listado de copias de seguridad diferenciales y archivos snar...${end}\n"
        search_files=$(find / -type f 2> /dev/null | grep -E "backup_diferencial_.*\.tar\.gz|diferencial_.*\.snar")
        counter=0
        for i in $search_files; do
            ((counter++))
            echo -e "${purple}[$counter] $i${end}" | column
        done
        echo -e "\n${yellow}Total de Backups Diferenciales y Snar:${end} ${turquoise}$counter${end}"
        echo -e "\n${green}Pulsa ENTER para continuar:${end}" && read
    fi
    Menu
    
}

####################FUNCION LIMPIEZA##########################
limpiar_backups() {
    clear
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
    echo -e "${green}------------------------------${end}"
    echo -e "${green}| Limpiar Copias de Seguridad |${end}"
    echo -e "${green}------------------------------${end}"
    echo -e "${yellow}---->${end}${gray} [ 1 ] Limpiar Backups Full${end}" 
    echo -e "${yellow}---->${end}${gray} [ 2 ] Limpiar Backups Incremental${end} "
    echo -e "${yellow}---->${end}${gray} [ 3 ] Limpiar Backups Diferencial${end} "
    echo -e "${green}---------------------------------------${end}"
    echo -e "\n${blue}Selecciona una opcion:${end} " && read selected_option

    if [ "$selected_option" -eq "1" ]; then
        echo -e "\n${green}[+] Escribe la Programación de Limpieza Backup: Inmediato o Programado:${end} " && read selected_option_2
        if [ "$selected_option_2" == "Inmediato" ]; then
            echo -e "\n${green}[+] Elige cuantos quieres limpiar: Uno o Todos${end}" && read selected_option_3 
            if [ "$selected_option_3" == "Uno" ]; then
                rest_bf="$(find / -type f 2> /dev/null | grep "backup_full_.*\.tar\.gz")"
                declare -i counter=1
                  for i in $rest_bf; do 
                    echo -e "${yellow}[$counter]${end} ${green}$i${end}"
                    ((counter++))
                done
                echo -e "\n${green}Selecciona el número de la copia de seguridad que quieres borrar:${end} " && read selected_backup_number

                selected_backup=$(echo "$rest_bf" | sed -n "${selected_backup_number}p")
                if [ -z "$selected_backup" ]; then
                    echo -e "\n${red}[+] No se seleccionó ninguna copia de seguridad.${end}"
                    Menu
                fi

                if sudo rm -r "$selected_backup"; then
                    echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
                     Menu
                else
                    echo -e "\n${red}[+] No se pudo limpiar la copia de seguridad.${end}"
                    sleep 2
                    Menu
                fi
            elif [ "$selected_option_3" == "Todos" ]; then
                    for i in $(find / -type f 2> /dev/null | grep "backup_full_.*\.tar\.gz"); do rm -r $i; done
                    echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
                    Menu
                else
                    echo -e "\n${red}[+] No se seleccionó ninguna opción.${end}"; sleep 2
                    Menu
                fi
        elif [ "$selected_option_2" == "Programado" ]; then
            echo -e "\n${green}[+] Ingresa cada cuantos días quieres la limpieza: ${end}" && read limpieza_b
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

            echo -e "\n${green}[+] Limpieza completada. Pulsa enter para continuar.${end}"; sleep 2
            Menu
        else
            echo -e "\n${red}[+] No se seleccionó ninguna opción.${end}"; sleep 2
            Menu
        fi

    elif [ "$selected_option" -eq "2" ]; then

        echo -e "\n${green}[+] Escribe la Programación de Limpieza Backup: Inmediato o Programado...${end} " && read selected_option_2

        if [ "$selected_option_2" == "Inmediato" ]; then

       
            echo -e "\n${green}[+] Elige cuantos quieres limpiar: Opciones / Uno / Todos..." && read selected_option_3
            if [ "$selected_option_3" == "Uno" ]; then
                rest_bf=$(find / -type f 2> /dev/null | grep "backup_incremental_.*\.tar\.gz")
                rest_bf_2=$(find / -type f 2> /dev/null | grep "incremental.*.snar")

                #rest_bf_e=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Incremental" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el Backup para Limpiar: ")
                #rest_bf_e_2=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Incremental" --column="Rutas de Archivo" $(for i in $rest_bf_2; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el nombre del archivo .snar a Limpiar: ")
                echo "Selecciona el Backup para Limpiar:"
                select file in $rest_bf; do
                    if [ -n "$file" ]; then
                        echo -e "\n${green}[+] Has seleccionado esta copia de seguridad:${end}${blue} $file${end}"; sleep 2
                        break
                    else
                        echo -e "\n${red}[+] Selección no válida. Inténtalo de nuevo.${end}"; sleep 2
                        Menu
                    fi
                done
                 echo -e "\n${green}[+] Selecciona el snar para Limpiar:${end}"
                select file2 in $rest_bf_2; do
                    if [ -n "$file" ]; then
                        echo -e "\n${green}[+] Has seleccionado esta copia de seguridad:${end}${blue} $file2${end}"; sleep 2
                        break
                    else
                        echo -e "\n${red}[+] Selección no válida. Inténtalo de nuevo.${end}"; sleep 2
                        Menu
                    fi
                done
                if sudo rm -r "$file" "$file2"; then
                    echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 3
                    Menu
                else
                    echo -e "\n${red}[+] Error${end}"; sleep 2
                    Menu
                fi
            elif [ "$selected_option_3" == "Todos" ]; then
                for i in $(find / -type f 2> /dev/null | grep "backup_incremental_.*\.tar\.gz|incremental_.*\.snar"); do rm -r $i; done
                echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
                Menu
            else
                echo -e "\n${red}[+] No se seleccionó ninguna opción.${end}"; sleep 2
                Menu
            fi
        
        
        elif [ "$selected_option_2" == "Programado" ]; then
            echo -e "\n${green}[+] Ingresa cada cuantos días quieres la limpieza:${end} " && read limpieza_b
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

            echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
            Menu
        else
            echo -e "\n${red}[+] No se seleccionó ninguna opción.${end}"; sleep 2
            Menu
        fi

    elif [ "$selected_option" -eq "3" ]; then

        echo -e "\n${green}[+] Programación de Limpieza Backup: Opción / Inmediato / Programado${end}" && read selected_option_2

        if [ "$selected_option_2" == "Inmediato" ]; then
            echo -e "\n${green}[+] Elige cuantos quieres limpiar: Opciones / Uno / Todos...${end} " && read selected_option_3
            if [ "$selected_option_3" == "Uno" ]; then
                rest_bf=$(find / -type f 2> /dev/null | grep "backup_diferencial_.*\.tar\.gz")
                rest_bf_2=$(find / -type f 2> /dev/null | grep "diferencial.*.snar")

                #rest_bf_e=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Diferencial" --column="Rutas de Archivo" $(for i in $rest_bf; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el Backup para Limpiar: ")
                #rest_bf_e_2=$(zenity --list --width=500 --height=300 --title="Limpiar Backup Diferencial" --column="Rutas de Archivo" $(for i in $rest_bf_2; do echo "$i"; done) --multiple --separator=' ' --text="Selecciona el nombre del archivo .snar a Restaurar: ")
                echo -e "\n${green}[+] Selecciona el Backup diferencial para Limpiar:${end}"
                select file in $rest_bf; do
                    if [ -n "$file" ]; then
                        echo -e "\n${green}[+] Has seleccionado esta copia de seguridad:${end}${blue} $file${end}"
                        break
                    else
                        echo -e "\n${red}[+] Selección no válida. Inténtalo de nuevo.${end}"
                    fi
                done
                echo -e "\n${green}[+] Selecciona el snar para Limpiar:${end}"
                select file2 in $rest_bf_2; do
                    if [ -n "$file" ]; then
                        echo -e "\n${green}[+]Has seleccionado esta copia de seguridad:${end}${blue} $file2${end}"
                        break
                    else
                        echo -e "\n${red}[+]Selección no válida. Inténtalo de nuevo.${end}"
                    fi
                done
                sudo rm -r "$file" "$file2"
                echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
                Menu
            elif [ "$selected_option_3" == "Todos" ]; then
                for i in $(find / -type f 2> /dev/null | grep -E "backup_diferencial_.*\.tar\.gz|diferencial_.*\.snar"); do rm -r $i; done
                echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
                Menu
            else
                echo -e "\n${red}[+] No se seleccionó ninguna opción.${end}"; sleep 2
                Menu
            fi  
        elif [ "$selected_option_2" == "Programado" ]; then
            echo -e "\n${green}[+] Ingresa cada cuantos días quieres la limpieza: ${end}" && read limpieza_b
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

            echo -e "\n${green}[+] Limpieza completada.${end}"; sleep 2
            Menu
        else
            echo -e "\n${green}[+] No se seleccionó ninguna opción.${end}"; sleep 2
            Menu
        fi

    else
        echo -e "\n${green}[+] No se seleccionó ninguna opción.${green}"; sleep 2
        Menu
    fi
}

###################FUNCION RESTAURAR######################
restaurar__backups () {
    clear
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
    echo -e "${green}---------------------------------${end}"
    echo -e "${green}| Restaurar Copias de Seguridad |${end}"
    echo -e "${green}---------------------------------${end}"
    echo -e "${yellow}---->${end}${gray} [ 1 ] Restaurar Backups Full${end}" 
    echo -e "${yellow}---->${end}${gray} [ 2 ] Restaurar Backups Incremental${end} "
    echo -e "${yellow}---->${end}${gray} [ 3 ] Restaurar Backups Diferencial${end} "
    echo -e "${green}---------------------------------------${end}"
    echo -e "\n${blue}[+] Selecciona una opcion:${end} " && read selected_option
    

    if [ "$selected_option" -eq "1" ]; then
        rest_bf=$(sudo find / -type f -name "backup_full_*.tar.gz") 
        if [ -z $rest_bf ]; then
            echo -e "No hay copias totales para restaurar. Pulsa ENTER para continuar" && read 
        else
            echo -e "\n${green}[+] Selecciona los archivos a Restaurar:${end}"
            select file in $rest_bf; do
                if [ -n "$file" ]; then
                    read -p "${green}[+] Selecciona el directorio para la Restauración: ${end}" rest_bf_s
                    tar -xzvf "$file" -C "$rest_bf_s"
                    echo -e "${green}[+] Restauración Full completada.${end}"
                    Menu
                else
                    echo -e "${red}[+] Selección no válida. Inténtalo de nuevo.${end}"
                fi
            done
        fi

        

    elif [ "$selected_option" -eq "2" ]; then
        rest_bf=$(sudo find / -type f -name "backup_incremental_*.tar.gz")
        rest_bf_2=$(sudo find / -type f -name "incremental*.snar" | rev | cut -d'/' -f1 | rev)
        if [[ -z $rest_bf && -z rest_bf_2 ]]; then
            echo -e "No hay copias incrementales ni archivos snar para restaurar. Pulsa ENTER para continuar" && read 
        else
            echo -e "\n${green}[+] Selecciona el Backup para Restaurar:${end}"
            select file in $rest_bf; do
                if [ -n "$file" ]; then
                    echo -e "\n${green}[+] Selecciona el nombre del archivo .snar a Restaurar:${end}"
                    select file_2 in $rest_bf_2; do
                        if [ -n "$file_2" ]; then
                            read -p "${green}[+] Selecciona el directorio para la Restauración: ${end}" rest_bf_s
                            tar -xzvf "$file" --listed-incremental="$file_2" -C "$rest_bf_s"
                            echo -e "${green}[+] Restauración Incremental completada.${end}"
                            Menu
                        else
                            echo -e "${red}[+] Selección no válida. Inténtalo de nuevo.${end}"
                        fi
                    done
                else
                    echo -e "${red}[+] Selección no válida. Inténtalo de nuevo.${end}"
                fi
            done
        fi
    elif [ "$selected_option" -eq "3" ]; then
        rest_bf=$(sudo find / -type f -name "backup_diferencial_*.tar.gz")
        rest_bf_2=$(sudo find / -type f -name "diferencial*.snar" | rev | cut -d'/' -f1 | rev)
        if [[ -z $rest_bf && -z rest_bf_2 ]]; then
            echo -e "No hay copias diferenciales ni archivos snar para restaurar. Pulsa ENTER para continuar" && read 
        else
            echo -e "\n${green}[+] Selecciona el Backup diferencial para Restaurar:${end}"
            select file in $rest_bf; do
                if [ -n "$file" ]; then
                    echo -e "\n${green}[+] Selecciona el nombre del archivo .snar a Restaurar:${end}"
                    select file_2 in $rest_bf_2; do
                        if [ -n "$file_2" ]; then
                            read -p "${green}[+] Selecciona el directorio para la Restauración: ${end}" rest_bf_s
                            tar -xzvf "$file" --listed-incremental="$file_2" -C "$rest_bf_s"
                            echo -e "${green}[+] Restauración Diferencial completada.${end}"
                            Menu
                        else
                            echo -e "${red}[+] Selección no válida. Inténtalo de nuevo.${end}"
                        fi
                    done
                else
                    echo -e "${red}[+] Selección no válida. Inténtalo de nuevo.${end}"
                fi
            done
        fi
    else
        echo -e "${red}[+] No se seleccionó ninguna opción.${end}"
        Menu
    fi
    
}


#########################FUNCION DISCOS Y PARTICIONES###############################
cp_disk_part () {
    clear 
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
    echo -e "\n${green}[+] Elige una tarea: Copia / Restauración... ${end}" && read opcion_particion
    if [ "$opcion_particion" == "Copia" ]; then  

        echo -e "\n${green}[+] Elige una opción: Disco / Partición" && read opcion_particion_2

        if [ "$opcion_particion_2" == "Disco" ]; then

            echo -e "\n${green}[+] Selecciona el Disco a copiar:${end}${gray} \n$(sudo fdisk -l | grep "/dev/" | awk '{print $2}' | grep "/dev/" | tr -d ':')\n${end}" && read selec_disco_e
            
            echo -e "\n${green}[+] ¿Quieres hacer la copia en otro Disco o en un Directorio?${end}" && read opcion_particion_3
            
            if [ "$opcion_particion_3" == "Disco" ]; then
                echo -e "\n${green}[+] Selecciona el Disco donde quieres copiar: ${end}${blue}\n$(sudo fdisk -l | grep "/dev/" | awk '{print $2}' | grep "/dev/" | tr -d ':')\n${end}" && read selec_disco_s
                if [ $(mount -l | grep $selec_disco_s) ]; then
                   
                    echo -e "\n${green}[+] Esta opción va a borrar el contenido este disco $selec_disco_s. Quieres seguir si o no?${end}" && read validacion_disco
                    if [ "$validacion_disco" == "si" ]; then
                        sudo dd if="$selec_disco_e" of="$selec_disco_s" bs=4M status=progress               
                        echo -e "\n${green}[+] Copia del Disco $selec_disco_e hecha en $selec_disco_s completada.${end}"; sleep 3 
                        Menu
                    else
                        cp_disk_part
                    fi

                else 
                    sudo dd if="$selec_disco_e" of="$selec_disco_s" bs=4M status=progress               
                    echo -e "\n${green}[+] Copia del Disco $selec_disco_e hecha en $selec_disco_s completada.${end}"; sleep 2 
                    Menu
                fi
                
        
            elif [ "$opcion_particion_3" == "Directorio" ]; then
                echo -e "Seleccionar directorio (ruta completa) para el respaldo" && read selec_direc

                sudo dd if="$selec_disco_e" of="$selec_direc"/Backup_Disco_"$selec_disco_e".img bs=4M status=progress
                

                echo -e "\n${green}[+] Copia del Disco $selec_disco_e hecha en "$selec_direc"/Backup_Disco_"$selec_disco_e".img completada.${end}"; sleep 2
                Menu
            else
                echo -e "Operación cancelada."; sleep 2
                Menu
            fi    

            

        elif [ "$opcion_particion_2" == "Partición" ]; then            
            echo -e "Selecciona la Partición a copiar: \n$(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':')\n" && read selec_part
    
            echo -e "¿Quieres hacer la copia en otra Particion o en un Directorio?" && read opcion_particion_3     
            
            if [ "$opcion_particion_3" == "Particion" ]; then
                echo -e "\n${green}[+] Selecciona la Partición donde quieres copiar:${end}${gray}  $(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':')\n${end} " && read selec_particion_s
                
                
                if [ $(mount -l | grep $selec_particion_s) ]; then
                   
                    echo -e "\nEsta opción va a borrar el contenido este disco $selec_particion_s. Elige SI o NO" && read validacion_disco
                    if [ "$validacion_disco" == "si" ]; then
                        sudo dd if="$selec_part" of="$selec_particion_s" bs=4M status=progress
                        echo -e "Copia de la Partición $selec_part hecha en $selec_particion_s completada."; sleep 2
                        Menu
                    else
                        cp_disk_part
                    fi

                else 
                    sudo dd if="$selec_part" of="$selec_particion_s" bs=4M status=progress
                    echo -e "Copia de la Partición $selec_part hecha en $selec_particion_s completada."; sleep 2
                    Menu
                fi
                  
                
            elif [ "$opcion_particion_3" == "Directorio" ]; then
                echo -e "Seleccionar directorio para el respaldo" && read selec_direc
                sudo dd if="$selec_part" of="$selec_direc"/Backup_"$selec_part".img bs=4M status=progress
               echo -e "Copia de la Partición $selec_part hecha en $selec_direc/Backup_$selec_part.img completada."; sleep 2
                Menu
            else
                echo -e "Operación cancelada."; sleep 2
                Menu
            fi
        else
            echo -e "Operación cancelada."; sleep 2
            Menu
        fi

 


    elif [ "$opcion_particion" == "Restauración" ]; then

        echo -e "Elige una opción: Disco / Partición" && read opcion_res
        if [ "$opcion_res" == "Disco" ]; then
            echo -e "Selecciona el Disco a restaurar" && read selec_disc_r

            if [ -z "$selec_disc_r" ]; then
                echo -e "No se ha seleccionado ninguna Partición."; sleep 2
                Menu
            fi   

            echo -e "Selecciona el Disco donde quieres restaurar: \n$(sudo fdisk -l | grep "/dev/" | awk '{print $2}' | grep "/dev/" | tr -d ':')\n" && read selec_disc_s      
            sudo dd if="$selec_disc_r" of="$selec_disc_s" bs=4M status=progress
            echo -e "El Disco $selec_disc_r ha sido restaurada en $selec_disc_s."; sleep 2
            Menu

    

        elif [ "$opcion_res" == "Partición" ]; then
            echo -e "Selecciona la Partición a restaurar" && read selec_part_r
            
            if [ -z "$selec_part_r" ]; then
                echo -e "No se ha seleccionado ninguna Partición."
                Menu
            fi   

            echo -e "Rutas de Archivo: \n$(sudo fdisk -l | grep "/dev/" | awk '{print $1}' | grep "/dev/" | tr -d ':') \n Selecciona la Partición donde quieres restaurar: " && read selec_part_s       
            sudo dd if="$selec_part_r" of="$selec_part_s" bs=4M status=progress
            echo -e "La Partición $selec_part_r ha sido restaurada en $selec_part_s."
            Menu

        else
            echo -e "Operación cancelada por el usuario."; sleep 2
            Menu
        fi
   
    else
        echo -e "Operación cancelada por el usuario."; sleep 2 
        Menu
    fi

}
################################################################333
Eliminar_Tareas() {
    clear
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
    
 
    tareas="$(sudo crontab -l | awk '{print NR".",$0}')"
    if [ -z $tareas ]; then
        echo -e "\n\t${red}No existen tareas definidas en el cron...${end}"
        echo -e "\n${green}Pulsa ENTER para continuar...${end}" && read
        Menu
    else
        # Mostrar las tareas del cron numeradas
        echo -e "\n${green}[+] Elige la tarea del cron que deseas eliminar:${end}\n"
        echo -e "$(sudo crontab -l | awk '{print NR".",$0}')"

        # Leer la selección del usuario
        echo -e "\n${green}[+] Ingresa el número de la tarea que deseas eliminar: ${end}"
        read -r seleccion

        # Obtener la lista de tareas del cron y guardarlas en un archivo temporal
        sudo crontab -l > /tmp/cron_temp

        # Eliminar la tarea seleccionada del archivo temporal
        sed -i "${seleccion}d" /tmp/cron_temp

        # Instalar el archivo temporal como la nueva configuración del cron
        sudo crontab /tmp/cron_temp

        # Eliminar el archivo temporal
        rm /tmp/cron_temp

        echo -e "\n${green}[+] Tarea eliminada del cron. Presiona Enter para continuar...${end}" && read; sleep 2
        Menu
    fi
   

}
Menu() {
    clear
    echo -e "   █████████████████████████████"
    echo -e "   ┌───┐██████┌──┐██████┌┐██████"
    echo -e "   └┐┌┐│██████│┌┐│██████││██████"
    echo -e "   █│││├──┬──┬┤└┘└┬──┬──┤│┌┬──┐█"
    echo -e "   █││││┌┐│──┼┤┌─┐│┌┐│┌─┤└┘┤──┤█"
    echo -e "   ┌┘└┘│└┘├──││└─┘│┌┐│└─┤┌┐┼──│█"
    echo -e "   └───┴──┴──┴┴───┴┘└┴──┴┘└┴──┘█"
   echo -e "${green}----------------------------${end}"
   echo -e "${green}|     Menu DosisBack       |${end}" 
   echo -e "${green}----------------------------${end}"
   echo -e "${gray}[ 1 ] Realizar Copias de Seguridad${end} "
   echo -e "${gray}[ 2 ] Listado de Backups${end} "
   echo -e "${gray}[ 3 ] Limpieza de Backups${end}" 
   echo -e "${gray}[ 4 ] Restauracion de Backups${end}" 
   echo -e "${gray}[ 5 ] Disco - Particion${end} " 
   echo -e "${gray}[ 6 ] Eliminar Tareas${end} "
   echo -e "${gray}[ 7 ] Ayuda${end} "
   echo -e "${red}[ x ] Salir${end}"
   echo -e "-----------------------------"
   echo -e "\n${blue}Ingresa el numero de la opcion a ejecutar: ${end}" && read choice

    if [ -z "$choice" ]; then
        echo -e "\t${red}No se seleccionó ninguna opción.${end}"
        exit 1
    fi

    case $choice in
        1) backup_archivos_directorios ;;
        2) listar__backups ;;
        3) limpiar_backups ;;
        4) restaurar__backups ;;
        5) cp_disk_part ;;
        6) Eliminar_Tareas ;;
        7) helpPanel && echo -e "Pulsa Enter para continuar..." && read; Menu ;;
        x) exit 0 ;;
        *) 
            echo -e "\n${red}Intento fallido: No existe esa opción.${end}"
            helpPanel
            ;;
    esac

}
Menu



