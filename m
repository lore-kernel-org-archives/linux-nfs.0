Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756063AbaAFUe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 15:34:26 -0500
Date: Mon, 6 Jan 2014 15:34:24 -0500
From: "J.;Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Fix a memory leak in nfsd4_create_session
Message-ID: <20140106203424.GE31764@fieldses.org>
References: <8BF6D2DF-CFD3-40F2-99BE-5AB6A4BD4A5F@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8BF6D2DF-CFD3-40F2-99BE-5AB6A4BD4A5F@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 01, 2014 at 12:35:47AM +0800, Kinglong Mee wrote:
> If failed after calling alloc_session but before init_session, nfsd will call __free_session to 
> free se_slots in session. But, session->se_fchannel.maxreqs is not initialized (value is zero).
> So that, the memory malloced for slots will be lost in free_session_slots for maxreqs is zero. 
> 
> This path sets the information for channel in alloc_session after mallocing slots succeed,
> instead in init_session.

Thanks, applying.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 9a6d088..7d613a7 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -832,10 +832,11 @@ static void nfsd4_put_drc_mem(struct nfsd4_channel_attrs *ca)
>  	spin_unlock(&nfsd_drc_lock);
>  }
>  
> -static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *attrs)
> +static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fattrs,
> +					   struct nfsd4_channel_attrs *battrs)
>  {
> -	int numslots = attrs->maxreqs;
> -	int slotsize = slot_bytes(attrs);
> +	int numslots = fattrs->maxreqs;
> +	int slotsize = slot_bytes(fattrs);
>  	struct nfsd4_session *new;
>  	int mem, i;
>  
> @@ -852,6 +853,10 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *attrs)
>  		if (!new->se_slots[i])
>  			goto out_free;
>  	}
> +
> +	memcpy(&new->se_fchannel, fattrs, sizeof(struct nfsd4_channel_attrs));
> +	memcpy(&new->se_bchannel, battrs, sizeof(struct nfsd4_channel_attrs));
> +
>  	return new;
>  out_free:
>  	while (i--)
> @@ -997,10 +1002,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>  	list_add(&new->se_perclnt, &clp->cl_sessions);
>  	spin_unlock(&clp->cl_lock);
>  	spin_unlock(&nn->client_lock);
> -	memcpy(&new->se_fchannel, &cses->fore_channel,
> -			sizeof(struct nfsd4_channel_attrs));
> -	memcpy(&new->se_bchannel, &cses->back_channel,
> -			sizeof(struct nfsd4_channel_attrs));
> +
>  	if (cses->flags & SESSION4_BACK_CHAN) {
>  		struct sockaddr *sa = svc_addr(rqstp);
>  		/*
> @@ -1917,7 +1919,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	if (status)
>  		goto out_release_drc_mem;
>  	status = nfserr_jukebox;
> -	new = alloc_session(&cr_ses->fore_channel);
> +	new = alloc_session(&cr_ses->fore_channel, &cr_ses->back_channel);
>  	if (!new)
>  		goto out_release_drc_mem;
>  	conn = alloc_conn_from_crses(rqstp, cr_ses);
> -- 
> 1.8.4.2
> 
