Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:62823 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbaGAKvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 06:51:07 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so3172783qga.9
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 03:51:06 -0700 (PDT)
Date: Tue, 1 Jul 2014 06:51:03 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 027/114] nfsd: shrink st_access_bmap and st_deny_bmap
Message-ID: <20140701065103.0aca978f@f20.localdomain>
In-Reply-To: <1404143423-24381-28-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-28-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2014 11:48:56 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> We never use anything above bit #3, so an unsigned long for each is
> wasteful. Shrink them to a char each, and add some WARN_ON_ONCE calls if
> we try to set or clear bits that would go outside those sizes.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 26 +++++++++++++++-----------
>  fs/nfsd/state.h     |  4 ++--
>  2 files changed, 17 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 485a0dc039d5..9dba8b7baf3b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -722,42 +722,46 @@ test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
>  static inline void
>  set_access(u32 access, struct nfs4_ol_stateid *stp)
>  {
> -	__set_bit(access, &stp->st_access_bmap);
> +	WARN_ON_ONCE(access > NFS4_SHARE_ACCESS_BOTH);
> +	__set_bit(access, (unsigned long *)&stp->st_access_bmap);

Doh! Stupid braino on my part here, and self-NAK on this patch.

The above won't work (or be safe) on a big-endian machine. Probably, the
thing to do is to convert this not to use atomic bitops since atomicity
doesn't seem to be a huge factor anyway. Let me respin this patch and do
that. Luckily the rest of the series shouldn't be greatly affected by
this (aside from a few merge conflicts).

>  }
>  
>  /* clear share access for a given stateid */
>  static inline void
>  clear_access(u32 access, struct nfs4_ol_stateid *stp)
>  {
> -	__clear_bit(access, &stp->st_access_bmap);
> +	WARN_ON_ONCE(access > NFS4_SHARE_ACCESS_BOTH);
> +	__clear_bit(access, (unsigned long *)&stp->st_access_bmap);
>  }
>  
>  /* test whether a given stateid has access */
>  static inline bool
>  test_access(u32 access, struct nfs4_ol_stateid *stp)
>  {
> -	return test_bit(access, &stp->st_access_bmap);
> +	return test_bit(access, (unsigned long *)&stp->st_access_bmap);
>  }
>  
>  /* set share deny for a given stateid */
>  static inline void
> -set_deny(u32 access, struct nfs4_ol_stateid *stp)
> +set_deny(u32 deny, struct nfs4_ol_stateid *stp)
>  {
> -	__set_bit(access, &stp->st_deny_bmap);
> +	WARN_ON_ONCE(deny > NFS4_SHARE_DENY_BOTH);
> +	__set_bit(deny, (unsigned long *)&stp->st_deny_bmap);
>  }
>  
>  /* clear share deny for a given stateid */
>  static inline void
> -clear_deny(u32 access, struct nfs4_ol_stateid *stp)
> +clear_deny(u32 deny, struct nfs4_ol_stateid *stp)
>  {
> -	__clear_bit(access, &stp->st_deny_bmap);
> +	WARN_ON_ONCE(deny > NFS4_SHARE_DENY_BOTH);
> +	__clear_bit(deny, (unsigned long *)&stp->st_deny_bmap);
>  }
>  
>  /* test whether a given stateid is denying specific access */
>  static inline bool
> -test_deny(u32 access, struct nfs4_ol_stateid *stp)
> +test_deny(u32 deny, struct nfs4_ol_stateid *stp)
>  {
> -	return test_bit(access, &stp->st_deny_bmap);
> +	return test_bit(deny, (unsigned long *)&stp->st_deny_bmap);
>  }
>  
>  /* release all access and file references for a given stateid */
> @@ -4270,12 +4274,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
>  		goto out; 
>  	status = nfserr_inval;
>  	if (!test_access(od->od_share_access, stp)) {
> -		dprintk("NFSD: access not a subset current bitmap: 0x%lx, input access=%08x\n",
> +		dprintk("NFSD: access not a subset of current bitmap: 0x%hhx, input access=%08x\n",
>  			stp->st_access_bmap, od->od_share_access);
>  		goto out;
>  	}
>  	if (!test_deny(od->od_share_deny, stp)) {
> -		dprintk("NFSD:deny not a subset current bitmap: 0x%lx, input deny=%08x\n",
> +		dprintk("NFSD: deny not a subset of current bitmap: 0x%hhx, input deny=%08x\n",
>  			stp->st_deny_bmap, od->od_share_deny);
>  		goto out;
>  	}
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index dc56ec234df7..949b331d9e13 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -407,8 +407,8 @@ struct nfs4_ol_stateid {
>  	struct list_head              st_locks;
>  	struct nfs4_stateowner      * st_stateowner;
>  	struct nfs4_file            * st_file;
> -	unsigned long                 st_access_bmap;
> -	unsigned long                 st_deny_bmap;
> +	unsigned char                 st_access_bmap;
> +	unsigned char                 st_deny_bmap;
>  	struct nfs4_ol_stateid         * st_openstp;
>  };
>  


-- 
Jeff Layton <jlayton@poochiereds.net>
