#

path=$(pwd)
mpath="/my${path##*/my}"
dname=${mpath##*/}
rm -rf prev
qm=$(ipfs add -Q -r .)
echo qm: $qm
#ipfs files rm -r $mpath~ 2>/dev/null
ipfs files rm -r $mpath/prev 2>/dev/null
ipfs files mv $mpath $mpath~
ipfs files cp /ipfs/$qm $mpath
ipfs files mv $mpath~ $mpath/prev
qm=$(ipfs files stat --hash $mpath)
echo qm: $qm

