Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604AbbDMMQq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Apr 2015 08:16:46 -0400
Date: Mon, 13 Apr 2015 08:16:42 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: make sure mounting nfs with v4,vers=4 and
 nfsvers=4
In-Reply-To: <552A5F3F.1090206@gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1504130805140.4187@planck.local>
References: <552A5F3F.1090206@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Kinglong,  I can't seem to figure out how to reproduce your problem, and
I don't see show this change fixes it.  Your mount is falling back to a v3
attempt without this patch?  What's set in nfsmount.conf?

Ben

On Sun, 12 Apr 2015, Kinglong Mee wrote:

> When mounting nfs with -ov4, -overs=4 or -onfsvers=4, fail as,
>
> # mount -t nfs -ov4 192.168.31.12:/ /testidr/
> mount.nfs: access denied by server while mounting 192.168.31.12:/
>
> Fixes: f980298853 "mount.nfs: configurable minor version defaults"
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
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
> --
> 2.3.5
>
>
