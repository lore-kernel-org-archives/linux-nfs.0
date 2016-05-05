Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:34693 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226AbcEELAW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2016 07:00:22 -0400
Received: by mail-qg0-f45.google.com with SMTP id 90so37454451qgz.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2016 04:00:21 -0700 (PDT)
Message-ID: <1462446017.28919.7.camel@poochiereds.net>
Subject: Re: [PATCH] nfsd: handle seqid wraparound in
 nfsd4_preprocess_layout_stateid
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Date: Thu, 05 May 2016 07:00:17 -0400
In-Reply-To: <1462445627-15093-1-git-send-email-jeff.layton@primarydata.com>
References: <1462445627-15093-1-git-send-email-jeff.layton@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-05-05 at 06:53 -0400, Jeff Layton wrote:
> Move the existing static function to an inline helper, and call it.
> 
> Cc: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

This is just something I noticed by inspection while ensuring that some
client-side changes that I have queued won't cause a problem. I don't
have a knfsd pnfs test rig though, so I can't test this easily.

As a side note though...should we also be verifying that the seqid is not zero in this function? That's never allowed for layout stateids.

> ---
>  fs/nfsd/nfs4layouts.c | 2 +-
>  fs/nfsd/nfs4state.c   | 8 +-------
>  fs/nfsd/state.h       | 5 +++++
>  3 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 825c7bc8d789..953c0755cb37 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -289,7 +289,7 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
>  
>  		status = nfserr_bad_stateid;
>  		mutex_lock(&ls->ls_mutex);
> -		if (stateid->si_generation > stid->sc_stateid.si_generation)
> +		if (nfsd4_stateid_generation_after(stateid, &stid->sc_stateid))
>  			goto out_unlock_stid;
>  		if (layout_type != ls->ls_layout_type)
>  			goto out_unlock_stid;
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0462eeddfff9..f5f82e145018 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4651,12 +4651,6 @@ grace_disallows_io(struct net *net, struct inode *inode)
>  	return opens_in_grace(net) && mandatory_lock(inode);
>  }
>  
> -/* Returns true iff a is later than b: */
> -static bool stateid_generation_after(stateid_t *a, stateid_t *b)
> -{
> -	return (s32)(a->si_generation - b->si_generation) > 0;
> -}
> -
>  static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
>  {
>  	/*
> @@ -4670,7 +4664,7 @@ static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_s
>  		return nfs_ok;
>  
>  	/* If the client sends us a stateid from the future, it's buggy: */
> -	if (stateid_generation_after(in, ref))
> +	if (nfsd4_stateid_generation_after(in, ref))
>  		return nfserr_bad_stateid;
>  	/*
>  	 * However, we could see a stateid from the past, even from a
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index c050c53036a6..986e51e5ceac 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -573,6 +573,11 @@ enum nfsd4_cb_op {
>  	NFSPROC4_CLNT_CB_SEQUENCE,
>  };
>  
> +/* Returns true iff a is later than b: */
> +static inline bool nfsd4_stateid_generation_after(stateid_t *a, stateid_t *b)
> +{
> +	return (s32)(a->si_generation - b->si_generation) > 0;
> +}
>  
>  struct nfsd4_compound_state;
>  struct nfsd_net;
-- 
Jeff Layton <jlayton@poochiereds.net>
