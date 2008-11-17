From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 17/51] nfsd41: clientid handling
Date: Mon, 17 Nov 2008 16:03:39 +0200
Message-ID: <492179BB.2040902@panasas.com>
References: <491895A0.3040809@panasas.com> <1226349987-10735-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:14996 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751331AbYKQODm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:03:42 -0500
In-Reply-To: <1226349987-10735-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:46 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Marc Eshel <eshel@almaden.ibm.com>
> 
> Extract the clientid from sessionid to set the op_clientid on open.
> Verify that the clid for other stateful ops is zero for minorversion != 0
> (and do all other checks only for minorversion 0).
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4proc.c  |   13 +++++++++++++
>  fs/nfsd/nfs4state.c |   21 ++++++++++++++++-----
>  fs/nfsd/nfs4xdr.c   |   10 ++++++++++
>  3 files changed, 39 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index b17948b..26aae5d 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -164,6 +164,14 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
>  	return status;
>  }
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +static void
> +nfsd41_set_clientid(clientid_t *clid, struct current_session *cses)
> +{
> +	clid->cl_boot = cses->cs_sid.clientid.cl_boot;
> +	clid->cl_id = cses->cs_sid.clientid.cl_id;
> +}
> +#endif /* CONFIG_NFSD_V4_1 */
>  
>  static __be32
>  nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> @@ -178,6 +186,11 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
>  		return nfserr_inval;
>  
> +#if defined(CONFIG_NFSD_V4_1)
> +	/* Set the NFSv4.1 client id */
> +	if (open->op_minorversion)
> +		nfsd41_set_clientid(&open->op_clientid, cstate->current_ses);
> +#endif /* CONFIG_NFSD_V4_1 */
>  	nfs4_lock_state();
>  
>  	/* check seqid for replay. set nfs4_owner */
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 2e6e9d5..14c1a0e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -413,8 +413,8 @@ STALE_CLIENTID(clientid_t *clid)
>  {
>  	if (clid->cl_boot == boot_time)
>  		return 0;
> -	dprintk("NFSD stale clientid (%08x/%08x)\n", 
> -			clid->cl_boot, clid->cl_id);
> +	dprintk("NFSD stale clientid (%08x/%08x) boot_time %08lx\n",
> +			clid->cl_boot, clid->cl_id, boot_time);
>  	return 1;
>  }
>  
> @@ -2270,7 +2270,8 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
>  		if (lock->lk_is_new) {
>  			if (!sop->so_is_open_owner)
>  				return nfserr_bad_stateid;
> -			if (!same_clid(&clp->cl_clientid, lockclid))
> +			if (sop->so_minorversion == 0 &&
> +			    !same_clid(&clp->cl_clientid, lockclid))
>  			       return nfserr_bad_stateid;
>  			/* stp is the open stateid */
>  			status = nfs4_check_openmode(stp, lkflg);
> @@ -2747,6 +2748,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	unsigned int strhashval;
>  	unsigned int cmd;
>  	int err;
> +#if defined(CONFIG_NFSD_V4_1)
> +	struct current_session *cses = cstate->current_ses;
> +#endif /* CONFIG_NFSD_V4_1 */

review 11-12: when cstate is going to be embedded in compoundres
this will change.

>  
>  	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
>  		(long long) lock->lk_offset,
> @@ -2773,8 +2777,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		struct nfs4_file *fp;
>  		
>  		status = nfserr_stale_clientid;
> -		if (STALE_CLIENTID(&lock->lk_new_clientid))
> +#if defined(CONFIG_NFSD_V4_1)
> +		if (!cses && STALE_CLIENTID(&lock->lk_new_clientid))
>  			goto out;
> +#endif /* CONFIG_NFSD_V4_1 */
>  
>  		/* validate and update open stateid and open seqid */
>  		status = nfs4_preprocess_seqid_op(&cstate->current_fh,
> @@ -2902,6 +2908,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct file_lock file_lock;
>  	int error;
>  	__be32 status;
> +#if defined(CONFIG_NFSD_V4_1)
> +	struct current_session *cses = cstate->current_ses;
> +#endif /* CONFIG_NFSD_V4_1 */
>  
>  	if (locks_in_grace())
>  		return nfserr_grace;
> @@ -2913,8 +2922,10 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	nfs4_lock_state();
>  
>  	status = nfserr_stale_clientid;
> -	if (STALE_CLIENTID(&lockt->lt_clientid))
> +#if defined(CONFIG_NFSD_V4_1)
> +	if (!cses && STALE_CLIENTID(&lockt->lt_clientid))
>  		goto out;
> +#endif /* CONFIG_NFSD_V4_1 */
>  
>  	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0))) {
>  		dprintk("NFSD: nfsd4_lockt: fh_verify() failed!\n");
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 9b26ba9..4675339 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -148,6 +148,11 @@ xdr_error:					\
>  	}					\
>  } while (0)
>  
> +static int zero_clientid(clientid_t *clid)
> +{
> +	return ((clid->cl_boot == 0) && (clid->cl_id == 0));
> +}
> +
>  static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  {
>  	/* We want more bytes than seem to be available.
> @@ -585,6 +590,8 @@ nfsd4_decode_lockt(struct nfsd4_compoundargs *argp, struct nfsd4_lockt *lockt)
>  	READ_BUF(lockt->lt_owner.len);
>  	READMEM(lockt->lt_owner.data, lockt->lt_owner.len);
>  
> +	if (argp->minorversion && !zero_clientid(&lockt->lt_clientid))
> +		return nfserr_inval;
>  	DECODE_TAIL;
>  }
>  
> @@ -1003,6 +1010,9 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
>  	READ_BUF(rlockowner->rl_owner.len);
>  	READMEM(rlockowner->rl_owner.data, rlockowner->rl_owner.len);
>  
> +	if (argp->minorversion && !zero_clientid(&rlockowner->rl_clientid))
> +		return nfserr_inval;
> +
>  	DECODE_TAIL;
>  }
>  
