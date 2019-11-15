#!/usr/bin/env bats -t

load helpers

@test "parse_img_base-00" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_base oci:/tmp/image/foo:8"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "/tmp/image/foo" ]]
}

@test "parse_img_base-01" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_base /tmp/image/foo:8"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "/tmp/image/foo" ]]
}

@test "parse_img_base-02" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_base /tmp/image/foo"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "/tmp/image/foo" ]]
}

@test "parse_img_base-03" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_base oci:/tmp/image/foo:8@deadbeaf"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "/tmp/image/foo" ]]
}

@test "parse_img_base-04" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_base oci:/tmp/image/foo@deadbeaf"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "/tmp/image/foo" ]]
}

@test "parse_img_tag-00" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_tag oci:/tmp/image/foo:8"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "8" ]]
}

@test "parse_img_tag-01" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_tag /tmp/image/foo:8"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "8" ]]
}

# no tag provided, should return default "latest"
@test "parse_img_tag-02" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_tag /tmp/image/foo"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "latest" ]]
}

@test "parse_img_tag-03" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_tag /tmp/image/foo:8@deadbeef"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "8" ]]
}

# no tag provided, should return default "latest"
@test "parse_img_tag-04" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_tag /tmp/image/foo@deadbeef"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "latest" ]]
}

# no digest provided, none returned
@test "parse_img_digest-00" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_digest oci:/tmp/image/foo:8"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "" ]]
}

# no digest provided, none returned
@test "parse_img_digest-01" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_digest /tmp/image/foo:8"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "" ]]
}

# no digest provided, none returned
@test "parse_img_digest-02" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_digest /tmp/image/foo"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "" ]]
}

# tag and digest
@test "parse_img_digest-03" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_digest docker://docker.io/centos:8@deadbeef"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "deadbeef" ]]
}

# just digest
@test "parse_img_digest-04" {
	run bash -c "source ./BuildSourceImage.sh ; parse_img_digest docker://docker.io/centos@deadbeef"
	[ "$status" -eq 0 ]
	echo "${lines[0]}"
	[[ ${lines[0]} =~ "deadbeef" ]]
}

