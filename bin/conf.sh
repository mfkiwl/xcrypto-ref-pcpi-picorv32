
#!/bin/sh


echo "-------------------------[Setting Up Project]--------------------------"

# Top level environment variables
export REPO_HOME=`pwd`
export XC_WORK=$REPO_HOME/build
export LIBSCARV=$REPO_HOME/extern/libscarv

if [ -z $YOSYS_ROOT ] ; then
    # Export a dummy "Yosys Root" path environment variable.
    export YOSYS_ROOT=
fi

if [ -z $RISCV ] ; then
    echo "[WARN] No 'RISCV' environment variable defined"
fi

if [ -z $VERILATOR_ROOT ] ; then
    echo "[WARN] No 'VERILATOR_ROOT' environment variable defined"
    echo "       - See $REPO_HOME/flow/verilator/README.md"
fi

export TEXMFLOCAL="::${REPO_HOME}/extern/texmf"
texhash &> /dev/null

echo "REPO_HOME      = $REPO_HOME"
echo "XC_WORK        = $XC_WORK"
echo "YOSYS_ROOT     = $YOSYS_ROOT"
echo "LIBSCARV       = $LIBSCARV"
echo "RISCV          = $RISCV"
echo "VERILATOR_ROOT = $VERILATOR_ROOT"
echo "TEXMFLOCAL     = $TEXMFLOCAL"

echo "------------------------------[Finished]-------------------------------"
