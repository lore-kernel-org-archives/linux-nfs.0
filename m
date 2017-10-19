Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:46356 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdJSKyt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Oct 2017 06:54:49 -0400
Received: by mail-yw0-f193.google.com with SMTP id t71so3104945ywc.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Oct 2017 03:54:49 -0700 (PDT)
Message-ID: <1508410486.4912.11.camel@redhat.com>
Subject: Re: [PATCH] nfds: avoid gettimeofday for nfssvc_boot time
From: Jeff Layton <jlayton@redhat.com>
To: Arnd Bergmann <arnd@arndb.de>, y2038@lists.linaro.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Deepa Dinamani <deepa.kernel@gmail.com>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 19 Oct 2017 06:54:46 -0400
In-Reply-To: <20171019100435.1170955-1-arnd@arndb.de>
References: <20171019100435.1170955-1-arnd@arndb.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-10-19 at 12:04 +0200, Arnd Bergmann wrote:
> do_gettimeofday() is deprecated and we should generally use time64_t
> based functions instead.
> 
> In case of nfsd, all three users of nfssvc_boot only use the initial
> time as a unique token, and are not affected by it overflowing, so they
> are not affected by the y2038 overflow.
> 
> This converts the structure to timespec64 anyway and adds comments
> to all uses, to document that we have thought about it and avoid
> having to look at it again.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  fs/nfsd/netns.h    |  2 +-
>  fs/nfsd/nfs3xdr.c  | 10 ++++++----
>  fs/nfsd/nfs4proc.c |  5 +++--
>  fs/nfsd/nfssvc.c   |  2 +-
>  4 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 3714231a9d0f..1c91391f4805 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -107,7 +107,7 @@ struct nfsd_net {
>  	bool lockd_up;
>  
>  	/* Time of server startup */
> -	struct timeval nfssvc_boot;
> +	struct timespec64 nfssvc_boot;
>  
>  	/*
>  	 * Max number of connections this nfsd container will allow. Defaults
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index bf444b664011..3579e0ae1131 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -747,8 +747,9 @@ nfs3svc_encode_writeres(struct svc_rqst *rqstp, __be32 *p)
>  	if (resp->status == 0) {
>  		*p++ = htonl(resp->count);
>  		*p++ = htonl(resp->committed);
> -		*p++ = htonl(nn->nfssvc_boot.tv_sec);
> -		*p++ = htonl(nn->nfssvc_boot.tv_usec);
> +		/* unique identifier, y2038 overflow can be ignored */
> +		*p++ = htonl((u32)nn->nfssvc_boot.tv_sec);
> +		*p++ = htonl(nn->nfssvc_boot.tv_nsec);
>  	}
>  	return xdr_ressize_check(rqstp, p);
>  }
> @@ -1118,8 +1119,9 @@ nfs3svc_encode_commitres(struct svc_rqst *rqstp, __be32 *p)
>  	p = encode_wcc_data(rqstp, p, &resp->fh);
>  	/* Write verifier */
>  	if (resp->status == 0) {
> -		*p++ = htonl(nn->nfssvc_boot.tv_sec);
> -		*p++ = htonl(nn->nfssvc_boot.tv_usec);
> +		/* unique identifier, y2038 overflow can be ignored */
> +		*p++ = htonl((u32)nn->nfssvc_boot.tv_sec);
> +		*p++ = htonl(nn->nfssvc_boot.tv_nsec);
>  	}
>  	return xdr_ressize_check(rqstp, p);
>  }
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 7896f841482e..008ea0b627d0 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -564,10 +564,11 @@ static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
>  
>  	/*
>  	 * This is opaque to client, so no need to byte-swap. Use
> -	 * __force to keep sparse happy
> +	 * __force to keep sparse happy. y2038 time_t overflow is
> +	 * irrelevant in this usage.
>  	 */
>  	verf[0] = (__force __be32)nn->nfssvc_boot.tv_sec;
> -	verf[1] = (__force __be32)nn->nfssvc_boot.tv_usec;
> +	verf[1] = (__force __be32)nn->nfssvc_boot.tv_nsec;
>  	memcpy(verifier->data, verf, sizeof(verifier->data));
>  }
>  
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 6bbc717f40f2..28ff3e078af6 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -516,7 +516,7 @@ int nfsd_create_serv(struct net *net)
>  		register_inet6addr_notifier(&nfsd_inet6addr_notifier);
>  #endif
>  	}
> -	do_gettimeofday(&nn->nfssvc_boot);		/* record boot time */
> +	ktime_get_real_ts64(&nn->nfssvc_boot); /* record boot time */
>  	return 0;
>  }
>  

I wonder if we'd be better off just using nfssvc_boot.tv_sec as the
verifier? I don't see us ever calling that ktime_get_real_ts64 more than
once per second for this purpose, and that would eliminate wraparound.
That said, wraparound is not a huge concern here anyway, so this is
certainly fine for now:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
