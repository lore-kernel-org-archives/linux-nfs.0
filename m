Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51420 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753616AbaBTQka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 11:40:30 -0500
Date: Thu, 20 Feb 2014 11:40:21 -0500
To: Neil Brown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] nfsd: set nlm grace time to make NFSv4 grace time
Message-ID: <20140220164021.GC15803@fieldses.org>
References: <20140220063616.6548.42556.stgit@notabene.brown>
 <20140220063648.6548.44668.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140220063648.6548.44668.stgit@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 20, 2014 at 05:36:48PM +1100, Neil Brown wrote:
> These two values are conceptually very similar, so it probably makes
> sense to set them to the same value at the same time.

Agreed.  It was a mistake to add nfsv4gracetime in the first place, but
I guess we can't get rid of it now.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  utils/nfsd/nfsd.man |    3 ++-
>  utils/nfsd/nfssvc.c |    8 ++++++++
>  2 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
> index 58b53cbff009..c6d3ffbd3675 100644
> --- a/utils/nfsd/nfsd.man
> +++ b/utils/nfsd/nfsd.man
> @@ -89,7 +89,8 @@ clients need to confirm their state with the server. Valid range is
>  from 10 to 3600 seconds.
>  .TP
>  .B \-G " or " \-\-grace-time seconds
> -Set the grace-time used for NFSv4.  New file open requests will not be
> +Set the grace-time used for NFSv4 and NLM (for NFSv2 and NFSv3).
> +New file open requests (NFSv4) and new file locks (NLM) will not be
>  allowed until after this time has passed to allow clients to recover state.
>  .TP
>  .I nproc
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 337ab169c194..5e14cce58053 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -317,6 +317,14 @@ nfssvc_set_time(const char *type, const int seconds)
>  			xlog(L_ERROR, "Unable to set nfsv4%stime: %m", type);
>  		close(fd);
>  	}
> +	if (strcmp(type, "grace") == 0) {
> +		/* set same value for lockd */
> +		fd = open("/proc/sys/fs/nfs/nlm_grace_period", O_WRONLY);
> +		if (fd >= 0) {
> +			write(fd, nbuf, strlen(nbuf));
> +			close(fd);
> +		}
> +	}
>  }
>  
>  void
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
