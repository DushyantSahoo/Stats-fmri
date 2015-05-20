declare -a sub=('sub001'  'sub002'  'sub003'  'sub005'  'sub007'  'sub008'  'sub009'  'sub010'  'sub011'  'sub014'  'sub015'  'sub017'  'sub018'  'sub019'  'sub021'  'sub022'  'sub025'  'sub026'  'sub027'  'sub028'  'sub029'  'sub030'  'sub031'  'sub032'  'sub034'  'sub036'  'sub038'  'sub039'  'sub040'  'sub042'  'sub043'  'sub047'  'sub048')

STR="/media/dushyant/Entertainment/fmri_assignment/" 

for i in `seq 0 32`
do
# {arr[i]} to access an element where i is the index
# sed -i 's/old-word/new-word/g' file to substitute old-word with new-word in file
# to run the file in feat with design.fsf
	echo ${sub[`expr $i + 1`]}

	mkdir $STR${sub[`expr $i + 1`]}/BOLD/task001_run002/results_sound
	mkdir $STR${sub[`expr $i + 1`]}/BOLD/task001_run002/output_sound
	

done

