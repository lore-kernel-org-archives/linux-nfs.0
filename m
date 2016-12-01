Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754848AbcLATgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 14:36:31 -0500
Subject: Re: [PATCH 2/2] mount: take history into account when assessing if an
 error is permanent.
To: NeilBrown <neilb@suse.com>
References: <148046718451.21092.10685567606499960786.stgit@noble>
 <148046723208.21092.12537997642943826780.stgit@noble>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <0ecc5408-5d21-5c0c-86fb-07cc804f3d4c@RedHat.com>
Date: Thu, 1 Dec 2016 14:36:30 -0500
MIME-Version: 1.0
In-Reply-To: <148046723208.21092.12537997642943826780.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/29/2016 07:53 PM, NeilBrown wrote:
> When attempting an NFSv3 mount request, it is possible to catch the
> server at an "awkward" moment while it is still starting up.
> In these cases it is possible to get an error that would otherwise
> indiciate a permanent error, but which should be considered temporary during
> the start-up window.
> 
> In particular:
>  ECONNREFUSED will be returned between the time the network interface
>    is configured, and the time that rpcbind starts
>  EOPNOTSUPP (representing RPC_PROGNOTREGISTERED) will be returned between
>    the time that rpcbind starts and the time when nfsd registers, and
>  ESTALE will be returned between the time nfsd starts and when filesystems
>    are exported (this windown can be removed with correct configuration).
> 
> So these errors only deserve a relatively small timeout.
> 
> So change nfs_is_permanent_error() to record the previous error
> and the number of times the same error has been seen.
> If ESTALE or EOPNOTSUPP is seen 3 times (over 3 seconds or more)
> or ECONNREFUSED is seen 5 times (15 seconds), report a permanent
> error, others assume it could be temporary.
> 
> A result of this is that if you try a UDP mount from a server which
> doesn't support UDP, you get an error without a few seconds, rather
> than a 2-minute timeout.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  utils/mount/stropts.c |   27 ++++++++++++++++++++++-----
>  1 file changed, 22 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 7b1ad93effc0..ba6593036a50 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -935,20 +935,37 @@ static int nfs_try_mount(struct nfsmount_info *mi)
>   * failed so far, but fail immediately if there is a local
>   * error (like a bad mount option).
>   *
> - * ESTALE is also a temporary error because some servers
> - * return ESTALE when a share is temporarily offline.
> + * If there is a remote error, like ESTALE or RPC_PROGNOTREGISTERED
> + * then it is probably permanent, but there is a small chance
> + * the it is temporary can we caught the server at an awkward
> + * time during start-up.  So require that we see three of those
> + * before treating them as permanent.
> + * For ECONNREFUSED, wait a bit longer as there is often a longer
> + * gap between the network being ready and the NFS server starting.
>   *
>   * Returns 1 if we should fail immediately, or 0 if we
>   * should retry.
>   */
>  static int nfs_is_permanent_error(int error)
>  {
> +	static int prev_error;
> +	static int rpt_cnt;
> +
> +	if (error == prev_error)
> +		rpt_cnt += 1;
> +	else
> +		rpt_cnt = 1;
> +	prev_error = error;
> +
>  	switch (error) {
>  	case ESTALE:
> -	case ETIMEDOUT:
> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
> +		/* If two in a row, assume permanent */
> +		return rpt_cnt >= 3;
This looks good... very clean... and now the time
out is control by the -o retry setting... Perfect!

>  	case ECONNREFUSED:
> +		return rpt_cnt >= 5;
My only question is why mess with this? Over the years 
we've always time out after 2 mins (the default) and now 
we are bring that down to 15 secs? I'm think that might
be a bit short... I seems like we might be fixing something
that is not broken... 

But again the design is very clever... nice work! 

steved.

> +	case ETIMEDOUT:
>  	case EHOSTUNREACH:
> -	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>  	case EAGAIN:
>  		return 0;	/* temporary */
>  	default:
> @@ -1000,7 +1017,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
>  			if (secs > 10)
>  				secs = 10;
>  		}
> -	};
> +	}
>  
>  	mount_error(mi->spec, mi->node, errno);
>  	return EX_FAIL;
> 
> 
