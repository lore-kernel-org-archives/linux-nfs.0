From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/44] nfsd41: use static buffers for sessions DRC
Date: Wed, 17 Jun 2009 18:03:25 -0400
Message-ID: <20090617220325.GO24040@fieldses.org>
References: <1245115189-7229-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40570 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbZFQWDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 18:03:22 -0400
In-Reply-To: <1245115189-7229-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 16, 2009 at 04:19:49AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Change from page based to memory based NFSv4.1 DRC.
> 
> We need to allocate memory for the session DRC in the CREATE_SESSION operation
> because of the guarantee to the client that the memory resource is available
> for caching responses.
> 
> In preparation to remove struct nfsd4_cache_entry, add static storage to
> struct nfsd4_slot to hold up to NFSD_SLOT_CACH_SIZE of all encoded operation
> data past the encoded sequence operation.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c        |    9 +++++++++
>  fs/nfsd/nfs4xdr.c          |    1 +
>  include/linux/nfsd/state.h |    2 ++
>  include/linux/nfsd/xdr4.h  |    1 +
>  4 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a6a7968..bf40c6b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1052,6 +1052,7 @@ nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
>  void
>  nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
>  {
> +	struct nfsd4_slot *slot = resp->cstate.slot;
>  	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
>  	struct svc_rqst *rqstp = resp->rqstp;
>  	struct nfsd4_compoundargs *args = rqstp->rq_argp;
> @@ -1076,10 +1077,14 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
>  	if (nfsd4_not_cached(resp)) {
>  		entry->ce_resused = 0;
>  		entry->ce_rpchdrlen = 0;
> +		slot->sl_datalen = 0;
>  		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
>  			resp->cstate.slot->sl_cache_entry.ce_cachethis);
>  		return;
>  	}
> +	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
> +	memcpy(slot->sl_data, resp->cstate.datap, slot->sl_datalen);

A response (e.g. a read) can span multiple pages, even if it's short.
So this doesn't work.

--b.

> +
>  	entry->ce_resused = rqstp->rq_resused;
>  	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
>  		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
> @@ -1127,6 +1132,7 @@ __be32
>  nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>  			 struct nfsd4_sequence *seq)
>  {
> +	struct nfsd4_slot *slot = resp->cstate.slot;
>  	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
>  	__be32 status;
>  
> @@ -1147,6 +1153,9 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>  		return nfs_ok;
>  	}
>  
> +	/* The sequence operation has been encoded, cstate->datap set. */
> +	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
> +
>  	if (!nfsd41_copy_replay_data(resp, entry)) {
>  		/*
>  		 * Not enough room to use the replay rpc header, send the
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c4eda89..7ab83cc 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3072,6 +3072,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
>  	WRITE32(0);
>  
>  	ADJUST_ARGS();
> +	resp->cstate.datap = p;	/* DRC cache data pointer */
>  	return 0;
>  }
>  
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 1ebb05e..8d5daf7 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -113,6 +113,8 @@ struct nfsd4_cache_entry {
>  struct nfsd4_slot {
>  	bool				sl_inuse;
>  	u32				sl_seqid;
> +	u32				sl_datalen;
> +	char				sl_data[NFSD_SLOT_CACHE_SIZE];
>  	struct nfsd4_cache_entry	sl_cache_entry;
>  };
>  
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 5e4beb0..5144c92 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -52,6 +52,7 @@ struct nfsd4_compound_state {
>  	struct nfsd4_session	*session;
>  	struct nfsd4_slot	*slot;
>  	__be32			*statp;
> +	__be32			*datap;
>  	size_t			iovlen;
>  	u32			minorversion;
>  	u32			status;
> -- 
> 1.6.3
> 
