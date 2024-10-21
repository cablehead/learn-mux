
export def "assets list" [] {
	(
	http get
		-u $env.MUX_TOKEN_ID
		-p $env.MUX_TOKEN_SECRET
		https://api.mux.com/video/v1/assets
		)
}

export def "assets upload start" [
    # Possible values: "basic", "plus"
    --video_quality: string = "plus"
    # Possible values: "1080p", "1440p", "2160p"
    --max_resolution_tier: string = "1440p"
    # Possible values: "none", "capped-1080p", "audio-only", "audio-only,capped-1080p"
    --mp4_support: string = "capped-1080p"
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
        -u $env.MUX_TOKEN_ID 
        -p $env.MUX_TOKEN_SECRET 
        https://api.mux.com/video/v1/uploads 
        $body
				)
}
