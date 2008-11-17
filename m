From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 50/51] nfsd41: Add a create session replay cache
Date: Mon, 17 Nov 2008 16:16:28 +0200
Message-ID: <49217CBC.407@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350673-12006-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:14292 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752005AbYKQOQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:16:31 -0500
In-Reply-To: <1226350673-12006-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:57 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Replace the nfs4_client cl_seqid field with a single struct nfs41_slot used
> for the create session replay cache.
> 
> The CREATE_SESSION slot sets the sl_session pointer to NULL. Otherwise, the
> slot and it's replay cache are used just like the session slots.
> 
> Fix unconfirmed create_session replay response by initializing the
> create_session slot sequence id to 0.
> 
> A future patch will set the CREATE_SESSION cache when a SEQUENCE operation
> preceeds the CREATE_SESSION operation. This compound is currently only cached
> in the session slot table.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c        |   45 +++++++++++++++++++++++++++++--------------
>  fs/nfsd/nfs4xdr.c          |   10 +++++---
>  include/linux/nfsd/state.h |    2 +-
>  3 files changed, 37 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index cefb605..0d8fde7 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -610,6 +610,8 @@ free_client(struct nfs4_client *clp)
>  #if defined(CONFIG_NFSD_V4_1)
>  	if (clp->cl_cb_xprt)
>  		svc_xprt_put(clp->cl_cb_xprt);
> +	nfsd4_clear_respages(clp->cl_slot.sl_cache_entry.ce_respages,
> +			     clp->cl_slot.sl_cache_entry.ce_resused);
>  #endif /* CONFIG_NFSD_V4_1 */
>  	if (clp->cl_cred.cr_group_info)
>  		put_group_info(clp->cl_cred.cr_group_info);
> @@ -686,6 +688,8 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
>  	INIT_LIST_HEAD(&clp->cl_openowners);
>  	INIT_LIST_HEAD(&clp->cl_delegations);
>  #if defined(CONFIG_NFSD_V4_1)
> +	nfs41_set_slot_state(&clp->cl_slot, NFS4_SLOT_AVAILABLE);
> +	spin_lock_init(&clp->cl_slot.sl_cache_entry.ce_lock);
>  	INIT_LIST_HEAD(&clp->cl_sessions);
>  	mutex_init(&clp->cl_cb_mutex);
>  #endif /* CONFIG_NFSD_V4_1 */
> @@ -1022,15 +1026,16 @@ nfsd41_set_statp(struct svc_rqst *rqstp, __be32 *statp)
>  void
>  nfsd41_set_cache_entry(struct nfsd4_compoundres *resp)
>  {
> -	struct nfs41_cache_entry *entry =
> -		&resp->current_ses->cs_slot->sl_cache_entry;
> +	struct nfs41_slot *slot = resp->current_ses->cs_slot;
> +	struct nfs41_cache_entry *entry = &slot->sl_cache_entry;
>  	struct svc_rqst *rqstp = resp->rqstp;
>  	struct kvec *resv = &rqstp->rq_res.head[0];
>  
>  	dprintk("--> %s entry %p\n", __func__, entry);
>  
> -	/* Don't cache a failed OP_SEQUENCE */
> -	if (resp->opcnt == 1 && resp->status)
> +	/* Don't cache a failed OP_SEQUENCE. The CREATE_SESSION slot has NULL
> +	 * sl_session pointer */

review 11-13: (The solo CREATE_SESSION ...) in parenthesis.

> +	if (resp->opcnt == 1 && resp->status && slot->sl_session)
>  		return;
>  	spin_lock(&entry->ce_lock);
>  	nfsd4_clear_respages(entry->ce_respages, entry->ce_resused);
> @@ -1215,11 +1220,12 @@ out_copy:
>  	clid->clientid.cl_boot = new->cl_clientid.cl_boot;
>  	clid->clientid.cl_id = new->cl_clientid.cl_id;
>  
> -	new->cl_seqid = clid->seqid = 1;
> +	new->cl_slot.sl_seqid = 0;
> +	clid->seqid = 1;
>  	nfsd4_set_ex_flags(new, clid);
>  
>  	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
> -		new->cl_seqid, new->cl_exchange_flags);
> +		new->cl_slot.sl_seqid, new->cl_exchange_flags);
>  	status = nfs_ok;
>  
>  out:
> @@ -1262,6 +1268,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  {
>  	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
>  	struct nfs4_client *conf, *unconf;
> +	struct current_session *c_ses = cstate->current_ses;
> +	struct nfs41_slot *slot = NULL;
>  	__u32   max_blocksize = svc_max_payload(rqstp);
>  	int status = 0;
>  
> @@ -1277,19 +1285,20 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		goto out;
>  	}
>  	if (conf) {
> -		status = nfs_ok;
> -		if (conf->cl_seqid == cr_ses->seqid) {
> +		slot = &conf->cl_slot;
> +		status = check_slot_seqid(cr_ses->seqid, slot);
> +		if (status == nfserr_replay_cache) {
>  			dprintk("Got a create_session replay! seqid= %d\n",
> -				conf->cl_seqid);
> +				slot->sl_seqid);
>  			goto out_replay;

review 11-13: change this the same way as for SEQUENCE

> -		} else if (cr_ses->seqid != conf->cl_seqid + 1) {
> +		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
>  			status = nfserr_seq_misordered;
>  			dprintk("Sequence misordered!\n");
>  			dprintk("Expected seqid= %d but got seqid= %d\n",
> -				conf->cl_seqid, cr_ses->seqid);
> +				slot->sl_seqid, cr_ses->seqid);
>  			goto out;
>  		}
> -		conf->cl_seqid++;
> +		conf->cl_slot.sl_seqid++;
>  	} else if (unconf) {
>  		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>  		    (ip_addr != unconf->cl_addr)) {
> @@ -1297,11 +1306,15 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  			goto out;
>  		}
>  
> -		if (unconf->cl_seqid != cr_ses->seqid) {
> +		slot = &unconf->cl_slot;
> +		status = check_slot_seqid(cr_ses->seqid, slot);
> +		if (status) {
> +			/* an unconfirmed replay returns misordered */
>  			status = nfserr_seq_misordered;
>  			goto out;
>  		}
>  
> +		slot->sl_seqid++; /* from 0 to 1 */
>  		move_to_confirmed(unconf);
>  
>  		/*
> @@ -1322,9 +1335,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  
>  	status = alloc_init_session(conf, cr_ses);
>  
> -out_replay:
>  	memcpy(cr_ses->sessionid, conf->cl_sessionid, 16);
> -	cr_ses->seqid = conf->cl_seqid;
> +	cr_ses->seqid = slot->sl_seqid;
>  	cr_ses->fore_channel.maxreq_sz = max_blocksize;
>  	cr_ses->fore_channel.maxresp_sz = max_blocksize;
>  	cr_ses->fore_channel.maxresp_cached = max_blocksize;
> @@ -1332,6 +1344,9 @@ out_replay:
>  	cr_ses->back_channel.maxresp_sz = max_blocksize;
>  	cr_ses->back_channel.maxresp_cached = max_blocksize;
>  
> +out_replay:
> +	nfs41_set_slot_state(slot, NFS4_SLOT_INPROGRESS);
> +	c_ses->cs_slot = slot;
>  out:
>  	nfs4_unlock_state();
>  	dprintk("%s returns %d\n", __func__, ntohl(status));
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 4b4f5fb..9799ea1 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3304,10 +3304,11 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  	BUG_ON(iov->iov_len > PAGE_SIZE);
>  #ifdef CONFIG_NFSD_V4_1
>  	if (resp->minorversion == 1) {
> +		struct nfs41_slot *slot;
>  		/*
>  		* Always have a current session.
>  		* The cs_slot is not set on SEQUENCE error, EXCHANGE_ID,
> -		* solo CREATE_SESSION, DESTROY_SESSION compounds.
> +		* and solo DESTROY_SESSION compounds.
>  		*/
>  		if (!resp->current_ses || !resp->current_ses->cs_slot) {
>  			dprintk("%s NO CS_SLOT. current_ses %p\n", __func__,
> @@ -3321,9 +3322,10 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
>  			nfsd41_set_cache_entry(resp);
>  
>  		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
> -		nfs41_set_slot_state(resp->current_ses->cs_slot,
> -				     NFS4_SLOT_AVAILABLE);
> -		nfs41_put_session(resp->current_ses->cs_slot->sl_session);
> +		slot = resp->current_ses->cs_slot;
> +		nfs41_set_slot_state(slot, NFS4_SLOT_AVAILABLE);
> +		if (slot->sl_session)
> +			nfs41_put_session(slot->sl_session);
>  free_current_ses:
>  		nfsd41_current_session_free(resp->current_ses);
>  }
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index e4dc32f..a336687 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -233,7 +233,7 @@ struct nfs4_client {
>  	atomic_t		cl_count;	/* ref count */
>  	u32			cl_firststate;	/* recovery dir creation */
>  #if defined(CONFIG_NFSD_V4_1)
> -	u32			cl_seqid;	/* seqid for create_session */
> +	struct nfs41_slot	cl_slot;	/* create_session slot */
>  	u32			cl_exchange_flags;
>  	nfs41_sessionid		cl_sessionid;
>  
