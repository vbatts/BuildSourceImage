#!/usr/bin/env bats -t

@test "build from RPMS" {
	d=$(mktemp -d)
	run $CTR_ENGINE run --rm -v $(pwd)/.testprep/srpms/:/src:ro -v ${d}:/output/ $CTR_IMAGE -s /src 
	[ "$status" -eq 0 ]
	#echo ${lines[@]}
	[[ ${lines[0]} =~ "[SrcImg][INFO] calling source collection drivers" ]]
	# get the number of the last line
	n=$(expr ${#lines[@]} - 1)
	[[ ${lines[${n}]} =~ "[SrcImg][INFO] copied to oci:/output:latest-source" ]]
	
	echo "${d}"
	[ -f "${d}/index.json" ]
	[ -f "${d}/oci-layout" ]
	[ "$(du -b ${d}/index.json | awk '{ print $1 }')" -gt 0 ]
	[ "$(du -b ${d}/oci-layout | awk '{ print $1 }')" -gt 0 ]
	[ "$(find ${d} -type f | wc -l)" -eq 7 ]
}
