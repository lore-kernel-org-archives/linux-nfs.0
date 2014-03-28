Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbaC1VWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 17:22:00 -0400
Date: Fri, 28 Mar 2014 17:22:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: Optimize code for nfsd4_proc_compound
Message-ID: <20140328212200.GE6041@fieldses.org>
References: <5332998D.9000304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5332998D.9000304@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 26, 2014 at 05:10:37PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks like reasonable cleanup, thanks.

--b.

> ---
>  fs/nfsd/nfs4proc.c | 28 +++++++++++++++-------------
>  1 file changed, 15 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 82189b2..550faf2 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1273,6 +1273,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	struct nfsd4_op	*op;
>  	struct nfsd4_operation *opdesc;
>  	struct nfsd4_compound_state *cstate = &resp->cstate;
> +	struct svc_fh *current_fh = &cstate->current_fh;
> +	struct svc_fh *save_fh = &cstate->save_fh;
>  	int		slack_bytes;
>  	u32		plen = 0;
>  	__be32		status;
> @@ -1288,11 +1290,11 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	resp->tag = args->tag;
>  	resp->opcnt = 0;
>  	resp->rqstp = rqstp;
> -	resp->cstate.minorversion = args->minorversion;
> -	resp->cstate.replay_owner = NULL;
> -	resp->cstate.session = NULL;
> -	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
> -	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
> +	cstate->minorversion = args->minorversion;
> +	cstate->replay_owner = NULL;
> +	cstate->session = NULL;
> +	fh_init(current_fh, NFS4_FHSIZE);
> +	fh_init(save_fh, NFS4_FHSIZE);
>  	/*
>  	 * Don't use the deferral mechanism for NFSv4; compounds make it
>  	 * too hard to avoid non-idempotency problems.
> @@ -1345,12 +1347,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
> 
>  		opdesc = OPDESC(op);
> 
> -		if (!cstate->current_fh.fh_dentry) {
> +		if (!current_fh->fh_dentry) {
>  			if (!(opdesc->op_flags & ALLOWED_WITHOUT_FH)) {
>  				op->status = nfserr_nofilehandle;
>  				goto encode_op;
>  			}
> -		} else if (cstate->current_fh.fh_export->ex_fslocs.migrated &&
> +		} else if (current_fh->fh_export->ex_fslocs.migrated &&
>  			  !(opdesc->op_flags & ALLOWED_ON_ABSENT_FS)) {
>  			op->status = nfserr_moved;
>  			goto encode_op;
> @@ -1377,12 +1379,12 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  				clear_current_stateid(cstate);
> 
>  			if (need_wrongsec_check(rqstp))
> -				op->status = check_nfsd_access(cstate->current_fh.fh_export, rqstp);
> +				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
>  		}
> 
>  encode_op:
>  		/* Only from SEQUENCE */
> -		if (resp->cstate.status == nfserr_replay_cache) {
> +		if (cstate->status == nfserr_replay_cache) {
>  			dprintk("%s NFS4.1 replay from cache\n", __func__);
>  			status = op->status;
>  			goto out;
> @@ -1411,10 +1413,10 @@ encode_op:
>  		nfsd4_increment_op_stats(op->opnum);
>  	}
> 
> -	resp->cstate.status = status;
> -	fh_put(&resp->cstate.current_fh);
> -	fh_put(&resp->cstate.save_fh);
> -	BUG_ON(resp->cstate.replay_owner);
> +	cstate->status = status;
> +	fh_put(current_fh);
> +	fh_put(save_fh);
> +	BUG_ON(cstate->replay_owner);
>  out:
>  	/* Reset deferral mechanism for RPC deferrals */
>  	rqstp->rq_usedeferral = 1;
> -- 
> 1.8.5.3
> 
