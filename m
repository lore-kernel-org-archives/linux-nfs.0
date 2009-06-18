From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 32/44] nfsd41: only reference the session on non-replay
	sequence
Date: Thu, 18 Jun 2009 18:20:23 -0400
Message-ID: <20090618222023.GJ12234@fieldses.org>
References: <1245115244-7857-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39361 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872AbZFRWUU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 18:20:20 -0400
In-Reply-To: <1245115244-7857-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:20:44AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Solo CREATE_SESSION replays used to share the logic in nfsdsvc_enc_compound_res
> and use nfsd4_store_cache_entry, but not set the cstate session nor take a
> reference on the session. CREATE_SESSION no longer uses nfsd4_store_cache_entry.
> 
> The SEQUENCE operation only needs to reference the session to call
> nfsd4_store_cache_entry.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    9 ++++-----
>  fs/nfsd/nfs4xdr.c   |   14 ++++++--------
>  2 files changed, 10 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 591879d..c91b333 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1436,13 +1436,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	cstate->slot = slot;
>  	cstate->session = session;
>  
> +	/* Hold a session reference until done caching the response */
> +	nfsd4_get_session(session);
> +
>  replay_cache:
> -	/* Renew the clientid on success and on replay.
> -	 * Hold a session reference until done processing the compound:
> -	 * nfsd4_put_session called only if the cstate slot is set.
> -	 */
> +	/* Renew the clientid on success and on replay */
>  	renew_client(session->se_client);
> -	nfsd4_get_session(session);
>  out:
>  	spin_unlock(&sessionid_lock);
>  	dprintk("%s: return %d\n", __func__, ntohl(status));
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index cebde87..e1b1397 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3300,6 +3300,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  	/*
>  	 * All that remains is to write the tag and operation count...
>  	 */
> +	struct nfsd4_compound_state *cs = &resp->cstate;
>  	struct kvec *iov;
>  	p = resp->tagp;
>  	*p++ = htonl(resp->taglen);
> @@ -3313,14 +3314,11 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  		iov = &rqstp->rq_res.head[0];
>  	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
>  	BUG_ON(iov->iov_len > PAGE_SIZE);
> -	if (nfsd4_has_session(&resp->cstate)) {
> -		if (resp->cstate.status != nfserr_replay_cache) {
> -			nfsd4_store_cache_entry(resp);
> -			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> -			resp->cstate.slot->sl_inuse = 0;
> -		}
> -		if (resp->cstate.session)
> -			nfsd4_put_session(resp->cstate.session);
> +	if (nfsd4_has_session(cs) && cs->status != nfserr_replay_cache) {
> +		nfsd4_store_cache_entry(resp);
> +		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> +		cs->slot->sl_inuse = 0;
> +		nfsd4_put_session(cs->session);

This chunkc seems to be irrelevant to the rest of the patch?

>  	}
>  	return 1;
>  }
> -- 
> 1.6.3
> 
