export def "assets list" [] {
	(
	http get
		-u $env.MUX_TOKEN_ID
		-p $env.MUX_TOKEN_SECRET
		https://api.mux.com/video/v1/assets
		) | get data |
        | update created_at { into int | $in * 1_000_000_000 | into datetime --timezone LOCAL }
}

export def "upload start" [
    --video_quality: string = "plus" # Possible values: "basic", "plus"
    --max_resolution_tier: string = "1440p" # Possible values: "1080p", "1440p", "2160p"
    --mp4_support: string = "capped-1080p" # Possible values: "none", "capped-1080p", "audio-only", "audio-only,capped-1080p"
] {
    let body = {
        new_asset_settings: {
            video_quality: $video_quality
            max_resolution_tier: $max_resolution_tier
            mp4_support: $mp4_support
            playback_policy: ["public"]
        }
    }
    (
		http post
				--content-type 'application/json'
        -u $env.MUX_TOKEN_ID
        -p $env.MUX_TOKEN_SECRET
        https://api.mux.com/video/v1/uploads
        $body
				) | get data
}

export def "upload list" [
    --limit: int = 25  # Number of items to include in the response (default: 25)
    --page: int = 1    # Offset by this many pages, of the size of limit (default: 1)
] {
		(
    http get
        -u $env.MUX_TOKEN_ID
        -p $env.MUX_TOKEN_SECRET
        $"https://api.mux.com/video/v1/uploads?({
					limit: $limit
					page: $page
				} | url build-query)"
				) | get data
}

export def "upload info" [
    upload_id: string
] {
	(
    http get
        -u $env.MUX_TOKEN_ID
        -p $env.MUX_TOKEN_SECRET
        $"https://api.mux.com/video/v1/uploads/($upload_id)"
	) | get data
}

export def "upload put" [
    upload_id: string  # ID of the upload, obtained from the 'upload start' command
    file_path: path,  # Path to the file you want to upload
] {
    let upload_info = (upload info $upload_id)
    let upload_url = $upload_info.url

    if ($upload_url | is-empty) {
        error make {msg: "Failed to get upload URL"}
    }

    open -r $file_path | http put $upload_url
}
