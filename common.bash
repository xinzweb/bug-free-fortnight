
build_orca() {
	local workspace
	readonly workspace=$(workspace)

	docker run --rm -ti \
		--volume gpdbccache:/ccache \
		--volume orca:/orca \
		--volume ${workspace}:/workspace:ro \
		--env CCACHE_DIR=/ccache \
		--env CCACHE_UMASK=0000 \
		yolo/orcadev:centos5 \
		/workspace/bug-free-fortnight/streamline-master/build_orca.bash
}

build_image() {
	local dir
	dir=$(dirname $0)
	docker build -q ${dir}
}

run_in_container() {
	local container_id
	local path

	container_id=$1
	path=$2

	docker exec ${container_id} ${path}
}

workspace() {
	local -r whereami=$(absdir)

	dirname $(dirname ${whereami})
}

absdir() {
	(
	cd "$(dirname "$0")"
	pwd
	)
}

set_ccache_max_size() {
	local -r cache_size=8G

	docker run --rm \
		--volume gpdbccache:/ccache \
		--env CCACHE_DIR=/ccache \
		--env CCACHE_UMASK=0000 \
		yolo/gpdbdev:centos6 \
		ccache -M ${cache_size}
}
