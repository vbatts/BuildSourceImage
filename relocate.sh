#!/bin/bash

## depracted code for moving containers (what skopeo does)

#
# copy an image from one location to another
#
push_img() {
    local src="${1}"
    local dst="${2}"

    _debug "pushing image ${src} to ${dst}"
    ## TODO: check for authfile, creds, and whether it's an insecure registry
    skopeo copy --dest-tls-verify=false "$(ref_prefix "${src}")" "$(ref_prefix "${dst}")" # XXX for demo only
    #skopeo copy "$(ref_prefix "${src}")" "$(ref_prefix "${dst}")"
    ret=$?
    return $ret
}


#
# call out to registry for the image reference's digest checksum
#
fetch_img_digest() {
    local ref="${1}"
    local dgst
    local ret

    ## TODO: check for authfile, creds, and whether it's an insecure registry
    dgst=$(skopeo inspect "$(ref_prefix "${ref}")" | jq .Digest | tr -d \")
    ret=$?
    if [ $ret -ne 0 ] ; then
        echo "ERROR: check the image reference: ${ref}" >&2
        return $ret
    fi

    echo -n "${dgst}"
}


#
# an inline prefixer for containers/image tools
#
ref_prefix() {
    local ref="${1}"
    local pfxs
    local ret

    # get the supported prefixes of the current version of skopeo
    mapfile -t pfxs < <(skopeo copy --help | grep -A1 "Supported transports:" | grep -v "Supported transports" | sed 's/, /\n/g')
    ret=$?
    if [ ${ret} -ne 0 ] ; then
        return ${ret}
    fi

    for pfx in "${pfxs[@]}" ; do
        if echo "${ref}" | grep -q "^${pfx}:" ; then
            # break if we match a known prefix
            echo "${ref}"
            return 0
        fi
    done
    # else default
    echo "docker://${ref}"
}

#
# pull down the image to an OCI layout
# arguments: image ref
# returns: path:tag to the OCI layout
#
# any commands should only output to stderr, so that the caller can receive the
# path reference to the OCI layout.
#
fetch_img() {
    local ref="${1}"
    local dst="${2}"
    local base
    local tag
    local dgst
    local from
    local ret

    _mkdir_p "${dst}"

    base="$(parse_img_base "${ref}")"
    tag="$(parse_img_tag "${ref}")"
    dgst="$(parse_img_digest "${ref}")"
    from=""
    # skopeo currently only support _either_ tag _or_ digest, so we'll be specific.
    if [ -n "${dgst}" ] ; then
        from="$(ref_prefix "${base}")@${dgst}"
    else
        from="$(ref_prefix "${base}"):${tag}"
    fi

    ## TODO: check for authfile, creds, and whether it's an insecure registry
    ## destination name must have the image tag included (umoci expects it)
    skopeo \
        copy \
        "${from}" \
        "oci:${dst}:${tag}" >&2
    ret=$?
    if [ ${ret} -ne 0 ] ; then
        return ${ret}
    fi
    echo -n "${dst}:${tag}"
}

dump() {
        inspect_image_digest="$(parse_img_digest "${input_image_ref}")"
        # determine missing digest before fetch, so that we fetch the precise image
        # including its digest.
        if [ -z "${inspect_image_digest}" ] ; then
            inspect_image_digest="$(fetch_img_digest "$(parse_img_base "${input_image_ref}"):$(parse_img_tag "${input_image_ref}")")"
            ret=$?
            if [ ${ret} -ne 0 ] ; then
                _error "failed to detect image digest"
            fi
        fi
        _debug "inspect_image_digest: ${inspect_image_digest}"

        img_layout=""
        # if inspect and fetch image, then to an OCI layout dir
        if [ ! -d "${work_dir}/layouts/${inspect_image_digest/:/\/}" ] ; then
            # we'll store the image to a path based on its digest, that it can be reused
            img_layout="$(fetch_img "$(parse_img_base "${input_image_ref}")":"$(parse_img_tag "${input_image_ref}")"@"${inspect_image_digest}" "${work_dir}"/layouts/"${inspect_image_digest/:/\/}" )"
            ret=$?
            if [ ${ret} -ne 0 ] ; then
                _error "failed to copy image: $(parse_img_base "${input_image_ref}"):$(parse_img_tag "${input_image_ref}")@${inspect_image_digest}"
            fi
        else
            img_layout="${work_dir}/layouts/${inspect_image_digest/:/\/}:$(parse_img_tag "${input_image_ref}")"
        fi
        _debug "image layout: ${img_layout}"

}

#
# an inline prefixer for containers/image tools
# XXX redo this to only validate for 'oci:...', otherwise bail
ref_prefix() {
    local ref="${1}"
    local pfxs
    local ret

    # get the supported prefixes of the current version of skopeo
    mapfile -t pfxs < <(skopeo copy --help | grep -A1 "Supported transports:" | grep -v "Supported transports" | sed 's/, /\n/g')
    ret=$?
    if [ ${ret} -ne 0 ] ; then
        return ${ret}
    fi

    for pfx in "${pfxs[@]}" ; do
        if echo "${ref}" | grep -q "^${pfx}:" ; then
            # break if we match a known prefix
            echo "${ref}"
            return 0
        fi
    done
    # else default
    echo "docker://${ref}"
}

#
# an inline namer for the source image
# Initially this is a tagging convention (which if we try estesp/manifest-tool
# can be directly mapped into a manifest-list/image-index).
#
ref_src_img_tag() {
    local ref="${1}"
    echo -n "$(parse_img_tag "${ref}")""${source_image_suffix}"
}

