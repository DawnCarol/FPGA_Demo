

all	: compile run

compile	:
	vcs -full64 -sverilog -cm line+tgl+cond+branch+fsm -cm_libs yv+celldefine -cm_cond allops -j16 -kdb -noIncrComp -q -debug_acc+all -debug_region+cell+encrypt +lint=TFIPC-L	\
	-f tbench.vc

run	:
	./simv -cm line+tgl+cond+branch+fsm

verdi	:
	verdi -dbdir simv.daidir -ssf dump.fsdb

