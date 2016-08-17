#!/bin/bash
# docker build -t streamline-master ~/workspace/ci-infrastructure/streamline-master
# docker run --rm -ti --volume ~/workspace:/workspace:ro streamline-master

set -u -e -o pipefail
set -x

_main() {
	local prefix
	prefix=/build/install
	build_the_universe ${prefix}
	make_cluster ${prefix}
	$(dirname $0)/icg.bash
}

build_the_universe() {
	local prefix
	prefix=$1
	mkdir -p /build/{install,gporca,gpos,gp-xerces}

	cd /build/gp-xerces
	/workspace/gp-xerces/configure --prefix ${prefix}
	make -j8 install

	cd /build/gpos
	cmake -DCMAKE_INSTALL_PREFIX=${prefix} /workspace/gpos
	make -j8 install

	cd /build/gporca
	cmake -DCMAKE_INSTALL_PREFIX=${prefix} /workspace/gporca
	make -j8 install

	cd /build
	git clone /workspace/gpdb
	cd gpdb
	./configure --enable-orca --enable-mapreduce --with-perl --with-libxml --with-python --disable-gpfdist --prefix=${prefix} --with-includes=${prefix}/include --with-libs=${prefix}/lib
	make -j8 install
}

make_cluster() {
	local prefix
	prefix=$1
	set +u
	cd /build/gpdb/gpAux/gpdemo
	source ${prefix}/greenplum_path.sh
	make cluster
}

_main "$@"