#

path=$(pwd)
mpath="/my${path##*/my}"
dname=${mpath##*/}
qm=$(ipfs files stat $mpath --hash)
echo qm: $qm
ipfs get -o prev /ipfs/$qm
mv -n prev/* .
