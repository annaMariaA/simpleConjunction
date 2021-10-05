folder for copying to HPC cluster 

should include wrapper file, R code to fit Stan model and data


code for running on the cluster:


cd cluster
dos2unix <scriptname>
chmod 770 <scriptname>
qsub ./<scriptname>