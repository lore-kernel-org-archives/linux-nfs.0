Return-Path: <SteveD@redhat.com>
Message-ID: <554B7324.3010904@RedHat.com>
Date: Thu, 07 May 2015 10:13:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: bcodding@redhat.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: make sure mounting nfs with v4,vers=4 and nfsvers=4
References: <552A5F3F.1090206@gmail.com>
In-Reply-To: <552A5F3F.1090206@gmail.com>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>



On 04/12/2015 08:04 AM, Kinglong Mee wrote:
> When mounting nfs with -ov4, -overs=4 or -onfsvers=4, fail as,
> 
> # mount -t nfs -ov4 192.168.31.12:/ /testidr/
> mount.nfs: access denied by server while mounting 192.168.31.12:/
> 
> Fixes: f980298853 "mount.nfs: configurable minor version defaults" 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
Committed... 

steved
> ---
>  utils/mount/stropts.c | 12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index df67fac..2ae532e 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -108,12 +108,6 @@ static void nfs_default_version(struct nfsmount_info *mi)
>  		return;
>  	}
>  
> -	if (mi->version.v_mode == V_GENERAL &&
> -		config_default_vers.v_mode == V_DEFAULT) {
> -		mi->version.v_mode = V_SPECIFIC;
> -		return;
> -	}
> -
>  	if (mi->version.v_mode == V_DEFAULT &&
>  		config_default_vers.v_mode != V_DEFAULT) {
>  		mi->version.major = config_default_vers.major;
> @@ -121,9 +115,9 @@ static void nfs_default_version(struct nfsmount_info *mi)
>  		return;
>  	}
>  
> -	if (mi->version.v_mode == V_GENERAL &&
> -		config_default_vers.v_mode != V_DEFAULT) {
> -		if (mi->version.major == config_default_vers.major)
> +	if (mi->version.v_mode == V_GENERAL) {
> +		if (config_default_vers.v_mode != V_DEFAULT &&
> +		    mi->version.major == config_default_vers.major)
>  			mi->version.minor = config_default_vers.minor;
>  		return;
>  	}
> 
