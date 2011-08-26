Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40655 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522Ab1HZUj1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 16:39:27 -0400
Date: Fri, 26 Aug 2011 16:39:24 -0400
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period
 expiration
Message-ID: <20110826203924.GC17196@fieldses.org>
References: <4E45C164.1070604@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E45C164.1070604@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 12, 2011 at 05:12:20PM -0700, Boaz Harrosh wrote:
> 
> locks_in_grace() was called twice one for the "yes" case second
> for the "no" case. If the status changes between these two calls
> the Server would do the wrong thing. Sample it only once.

I don't see how this fixes any bug.  The only thing that could happen in
between those two checks is that the grace period could end.  In that
case op_claim_type must be NFS4_OPEN_CLAIM_PREVIOUS (otherwise we would
have jumped to out and not hit the second case).  The second condition
will therefore be true and we'll fail with err_no_grace.  I don't see
that is incorrect, as in fact the grace period is now over.

There may be a different bug: if the grace period ends *any time* after
locks_in_grace() is called but before we actually do the lock or open,
then a reclaim could be incorrectly granted.  The state lock prevents
this happening between two nfsv4 clients, but it could happen between
a v4 client and a lockd client, I think.  In more detail:


	lockd client		NFSv4 client
	------------		------------

				reclaim request passes grace check
		-- grace period ends --
	gets conflicting lock
	drops conflicting lock
				reclaim request granted

One fix might be to take some sort of reference count as long as you're
processing a reclaim request, and not end the grace period till that
count goes to zero.

Another might be push the grace checks down into the core lock code and
make sure there's a lock that provides mutual exclusion between the
locks_end_grace() call and lock reclaims.

--b.


> 
> Also Add a DMESG print in the case of a bad (old) client that does
> *not* send a RECLAIM_COMPLETE before doing new opens. The admin might
> want to know it has an unsupported client at hand. Because in this
> case with our server the client will get stuck in an endless loop.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfsd/nfs4proc.c |   23 ++++++++++++++++-------
>  1 files changed, 16 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a68384f..efc6369 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -301,8 +301,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	 */
>  	if (nfsd4_has_session(cstate) &&
>  	    !cstate->session->se_client->cl_firststate &&
> -	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> +	    open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS) {
> +		printk(KERN_INFO
> +			"NFSD: nfsd4_open: Broken client, "
> +			"open sent before RECLAIM_COMPLETE done\n");
>  		return nfserr_grace;
> +	}
>  
>  	if (nfsd4_has_session(cstate))
>  		copy_clientid(&open->op_clientid, cstate->session);
> @@ -333,12 +337,17 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  
>  	/* Openowner is now set, so sequence id will get bumped.  Now we need
>  	 * these checks before we do any creates: */
> -	status = nfserr_grace;
> -	if (locks_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
> -		goto out;
> -	status = nfserr_no_grace;
> -	if (!locks_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
> -		goto out;
> +	if (locks_in_grace()) {
> +		if (open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS) {
> +			status = nfserr_grace;
> +			goto out;
> +		}
> +	} else {
> +		if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS) {
> +			status = nfserr_no_grace;
> +			goto out;
> +		}
> +	}
>  
>  	switch (open->op_claim_type) {
>  		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
> -- 
> 1.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
