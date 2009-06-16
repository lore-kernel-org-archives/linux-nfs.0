From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 04/44] nfsd41: turn off create session caching
Date: Tue, 16 Jun 2009 14:27:04 -0400
Message-ID: <20090616182704.GC3045@fieldses.org>
References: <1245115163-6931-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:32887 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbZFPS1C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2009 14:27:02 -0400
In-Reply-To: <1245115163-6931-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:19:23AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> In preparation for switching clientid cache strategies.
> If cstate->slot is not set, nfsdsvc_encode_compoundres will not cache
> the create session response.

This is a regression.  If you can't find a way to replace the reply
cache without a temporary regression, a comment here to that affect
would be helpful.  I guess I can live with this (reluctantly) for code
in this early a state.

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    7 -------
>  1 files changed, 0 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c22ec9b..5fdef66 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1344,7 +1344,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		     struct nfsd4_create_session *cr_ses)
>  {
>  	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
> -	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>  	struct nfs4_client *conf, *unconf;
>  	struct nfsd4_slot *slot = NULL;
>  	int status = 0;
> @@ -1360,11 +1359,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		if (status == nfserr_replay_cache) {
>  			dprintk("Got a create_session replay! seqid= %d\n",
>  				slot->sl_seqid);
> -			cstate->slot = slot;
> -			cstate->status = status;
> -			/* Return the cached reply status */
> -			status = nfsd4_replay_cache_entry(resp, NULL);
> -			goto out;
>  		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
>  			status = nfserr_seq_misordered;
>  			dprintk("Sequence misordered!\n");
> @@ -1413,7 +1407,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	cr_ses->seqid = slot->sl_seqid;
>  
>  	slot->sl_inuse = true;
> -	cstate->slot = slot;
>  	/* Ensure a page is used for the cache */
>  	slot->sl_cache_entry.ce_cachethis = 1;
>  out:
> -- 
> 1.6.3
> 
