#!/bin/bash

# Function to generate gnuplot script
function generate_gnuplot_script {
  local output_file="$1"
  local input_dat="$2"
  local idx="$3"
  local resourceInfo="$4"
  local metricUnit="$5"
  cat << EOF > "$output_file"
set terminal svg enhanced font "Verdana,10"
set output "${output_file}.svg"
set title "Usage plot for $resourceInfo"
set xlabel "Time"
set ylabel "$resourceInfo in $metricUnit"
set grid
plot "$input_dat" using 1:$idx with lines title "$resourceInfo-$metricUnit"
EOF
}

# clean all files
rm -f *.dat
rm -f *.p
rm -f *.svg

# if param is -c then clean all files and exit
if [ "$1" == "-c" ]; then
   exit 0
fi

tc=0

namespaces="$@"

while true; do
   plot_html_content="<html><head><title>Resource usage plots</title><meta http-equiv="refresh" content="3" ></head><body>"

   # loop all namespaces
   for ns in $namespaces; do

      # get the current cpu and memory usage
      results=$(kubectl top pod -n $ns | tail -n +2 | tr -s [:blank:])

      while read -r line; do
         podname=$(echo $line | cut -d ' ' -f1)
         podname=$ns-$podname
         cpu=$(echo $line | cut -d ' ' -f2)
         memory=$(echo $line | cut -d ' ' -f3)

         # remove m suffix from cpu
         cpu=$(echo $cpu | tr -d 'm')

         # remove Mi suffix from memory
         memory=$(echo $memory | tr -d 'Mi')

         # append the current time, cpu and memory usage to the dat file, gnuplot will use this file to plot the graph
         printf "$tc\t$cpu\t$memory\n" >> $podname.dat
      done <<< "$results"


      while read -r line; do
         podname=$(echo $line | cut -d ' ' -f1)
         podname=$ns-$podname
         plot_html_content+="<h1>$podname</h1>"

         generate_gnuplot_script "$podname-cpu.p" "$podname.dat" "2" "Cpu" "mili"
         
         # Run gnuplot to generate SVG image
         gnuplot < "$podname-cpu.p"

         # Create basic HTML with the generated SVG
         plot_html_content+="<img src=\"${podname}-cpu.p.svg\" alt=\"Cpu data\">"

         generate_gnuplot_script "$podname-memory.p" "$podname.dat" "3" "Memory" "Mi"

         # Run gnuplot to generate SVG image
         gnuplot < "$podname-memory.p"

         # Create basic HTML with the generated SVG
         plot_html_content+="<img src=\"${podname}-memory.p.svg\" alt=\"Memory data\">"
         plot_html_content+="<br>"
      done <<< "$results"
   done

   plot_html_content+="</body></html>"

   # Create basic HTML with the generated SVG
   html_file="plot.html"
   echo $plot_html_content > "$html_file"

   # wait for 2 seconds
   sleep 2
   tc=$((tc+2))
done


