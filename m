From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 20/44] nfsd41: remove iovlen field from
	nfsd4_compound_state
Date: Thu, 18 Jun 2009 17:59:32 -0400
Message-ID: <20090618215932.GG12234@fieldses.org>
References: <1245115210-7460-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38126 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbZFRV7a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 17:59:30 -0400
In-Reply-To: <1245115210-7460-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:20:10AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Set resp->p in nfsd4_replay_cache_entry so that the nfs4svc_encode_compoundres
> iov_len calculation is correct.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c       |    2 +-
>  fs/nfsd/nfs4xdr.c         |    5 +----
>  include/linux/nfsd/xdr4.h |    1 -
>  3 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c975719..0f740c1 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1092,7 +1092,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>  
>  	resp->rqstp->rq_resused = entry->ce_resused;
>  	resp->opcnt = slot->sl_opcnt;
> -	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
> +	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);

So before this patch (but after the patch that switched over to the new
cache), was cstate.iovlen being calculated correctly, or are the
cd_datav fields wrong at this point?  In which case this series isn't
really bisectable.

--b.

>  	status = slot->sl_status;
>  
>  	return status;
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 5018483..cebde87 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3314,10 +3314,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
>  	BUG_ON(iov->iov_len > PAGE_SIZE);
>  	if (nfsd4_has_session(&resp->cstate)) {
> -		if (resp->cstate.status == nfserr_replay_cache &&
> -				!nfsd4_not_cached(resp)) {
> -			iov->iov_len = resp->cstate.iovlen;
> -		} else {
> +		if (resp->cstate.status != nfserr_replay_cache) {
>  			nfsd4_store_cache_entry(resp);
>  			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
>  			resp->cstate.slot->sl_inuse = 0;
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 6febc62..76569d2 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -53,7 +53,6 @@ struct nfsd4_compound_state {
>  	struct nfsd4_slot	*slot;
>  	__be32			*statp;
>  	__be32			*datap;
> -	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
>  };
> -- 
> 1.6.3
> 
