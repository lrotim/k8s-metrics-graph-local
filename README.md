# k8s-metrics-graph-local

## Dependencies

- gnuplot (https://gnuplot.sourceforge.io/)
- kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Install gnuplot

#### Linux/Ubuntu
```bash
sudo apt-get install gnuplot
```

#### MacOS
```bash
brew install gnuplot
```

A simple bash script that uses kubectl top command to get the CPU and Memory usage of the pods in a k8s cluster and then uses gnuplot to plot the graphs.

## Usage

Clone the repository and run the script.

```bash
git clone
cd k8s-metrics-graph-local
./kmg.sh <namespace1> <namespace2> <namespace3> ...
```

Script will continuously run in a loop and update the graphs every 2 seconds, from the data acquired using `kubectl top` command.

It will render results in `plot.html` file, simply open in in your browser to see the graphs - it will automatically refresh every 3 seconds.

If you don't want to clone the repo simply run the following command as a one liner you can copy and paste into your terminal:

### Clenup

Script will create temporary files in the current directory, to clean them up run the following command:

```bash
./kmg.sh -c
```