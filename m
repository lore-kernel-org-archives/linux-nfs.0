From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/2] nfsd4: complete enforcement of 4.1 op ordering
Date: Thu, 22 Apr 2010 10:48:31 -0400
Message-ID: <20100422144831.GA5926@fieldses.org>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47321 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212Ab0DVOsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 10:48:32 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1O4xhf-0001az-M8
	for linux-nfs@vger.kernel.org; Thu, 22 Apr 2010 10:48:31 -0400
In-Reply-To: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 10:32:23AM -0400, J. Bruce Fields wrote:
> Enforce the rules about compound op ordering.
> 
> Motivated by implementing RECLAIM_COMPLETE, for which the client is
> implicit in the current session, so it is important to ensure a
> succesful SEQUENCE proceeds the RECLAIM_COMPLETE.

The other problem here is that while we have a reference count on the
session itself preventing it from going away till the compound is done,
I don't see what prevents the associated clientid from going away.

To fix that, and to be more polite to 4.0 clients, I think we want to
also add a client pointer to the compound_state structure, keep count of
the number of compounds in progress which reference that client, and not
start the client's expiry timer until we've encoded the reply to the
compound.

One question there is whether it's really correct to assume that a
single compound can reference only one client.  (I don't think rfc 3530
explicitly forbids a single compound referring to multiple clients.  rfc
5661 explicitly allows it in the case of DESTROY_CLIENTID, though that's
a special case.)

--b.

> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfsd/nfs4proc.c  |   44 ++++++++++++++++++++++++++++++--------------
>  fs/nfsd/nfs4state.c |   13 +++++++++++++
>  2 files changed, 43 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 37514c4..e147dbc 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -968,20 +968,36 @@ static struct nfsd4_operation nfsd4_ops[];
>  static const char *nfsd4_op_name(unsigned opnum);
>  
>  /*
> - * Enforce NFSv4.1 COMPOUND ordering rules.
> + * Enforce NFSv4.1 COMPOUND ordering rules:
>   *
> - * TODO:
> - * - enforce NFS4ERR_NOT_ONLY_OP,
> - * - DESTROY_SESSION MUST be the final operation in the COMPOUND request.
> + * Also note, enforced elsewhere:
> + *	- SEQUENCE other than as first op results in
> + *	  NFS4ERR_SEQUENCE_POS. (Enforced in nfsd4_sequence().)
> + *	- BIND_CONN_TO_SESSION must be the only op in its compound
> + *	  (Will be enforced in nfsd4_bind_conn_to_session().)
> + *	- DESTROY_SESSION must be the final operation in a compound, if
> + *	  sessionid's in SEQUENCE and DESTROY_SESSION are the same.
> + *	  (Enforced in nfsd4_destroy_session().)
>   */
> -static bool nfs41_op_ordering_ok(struct nfsd4_compoundargs *args)
> +static __be32 nfs41_check_op_ordering(struct nfsd4_compoundargs *args)
>  {
> -	if (args->minorversion && args->opcnt > 0) {
> -		struct nfsd4_op *op = &args->ops[0];
> -		return (op->status == nfserr_op_illegal) ||
> -		       (nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP);
> -	}
> -	return true;
> +	struct nfsd4_op *op = &args->ops[0];
> +
> +	/* These ordering requirements don't apply to NFSv4.0: */
> +	if (args->minorversion == 0)
> +		return nfs_ok;
> +	/* This is weird, but OK, not our problem: */
> +	if (args->opcnt == 0)
> +		return nfs_ok;
> +	if (op->status == nfserr_op_illegal)
> +		return nfs_ok;
> +	if (!(nfsd4_ops[op->opnum].op_flags & ALLOWED_AS_FIRST_OP))
> +		return nfserr_op_not_in_session;
> +	if (op->opnum == OP_SEQUENCE)
> +		return nfs_ok;
> +	if (args->opcnt != 1)
> +		return nfserr_not_only_op;
> +	return nfs_ok;
>  }
>  
>  /*
> @@ -1023,13 +1039,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>  	if (args->minorversion > nfsd_supported_minorversion)
>  		goto out;
>  
> -	if (!nfs41_op_ordering_ok(args)) {
> +	status = nfs41_check_op_ordering(args);
> +	if (status) {
>  		op = &args->ops[0];
> -		op->status = nfserr_sequence_pos;
> +		op->status = status;
>  		goto encode_op;
>  	}
>  
> -	status = nfs_ok;
>  	while (!status && resp->opcnt < args->opcnt) {
>  		op = &args->ops[resp->opcnt++];
>  
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5051ade..e444829 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1365,6 +1365,14 @@ out:
>  	return status;
>  }
>  
> +static bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
> +{
> +	struct nfsd4_compoundres *resp = rqstp->rq_resp;
> +	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
> +
> +	return argp->opcnt == resp->opcnt;
> +}
> +
>  __be32
>  nfsd4_destroy_session(struct svc_rqst *r,
>  		      struct nfsd4_compound_state *cstate,
> @@ -1380,6 +1388,11 @@ nfsd4_destroy_session(struct svc_rqst *r,
>  	 * - Do we need to clear any callback info from previous session?
>  	 */
>  
> +	if (!memcmp(&sessionid->sessionid, &cstate->session->se_sessionid,
> +					sizeof(struct nfs4_sessionid))) {
> +		if (!nfsd4_last_compound_op(r))
> +			return nfserr_not_only_op;
> +	}
>  	dump_sessionid(__func__, &sessionid->sessionid);
>  	spin_lock(&sessionid_lock);
>  	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
> -- 
> 1.6.3.3
> 
