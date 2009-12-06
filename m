From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] nfs41: Don't clear DRAINING flag on
 NFS4ERR_STALE_CLIENTID
Date: Sun, 06 Dec 2009 12:05:34 -0500
Message-ID: <1260119134.11862.2.camel@localhost>
References: <>
	 <1260098184-19209-1-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260098184-19209-2-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260098184-19209-3-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44305 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933917AbZLFRFb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Dec 2009 12:05:31 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB6H5a1V010144
	for <linux-nfs@vger.kernel.org>; Sun, 6 Dec 2009 09:05:36 -0800 (PST)
In-Reply-To: <1260098184-19209-3-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-12-06 at 03:16 -0800, Ricardo Labiaga wrote: 
> If CREATE_SESSION fails with NFS4ERR_STALE_CLIENTID, don't clear the
> NFS4CLNT_SESSION_DRAINING flag and don't wake RPCs waiting for the
> session to be reestablished.  We don't have a session yet, so there
> is no reason to wake other RPCs.
> 
> This avoids sending spurious compounds with bogus sequenceID during
> session and state recovery.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfs/nfs4state.c |   22 ++++++++++++++++------
>  1 files changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index d236257..94c238d 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1250,7 +1250,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
>  		spin_unlock(&tbl->slot_tbl_lock);
>  		status = wait_for_completion_interruptible(&ses->complete);
>  		if (status) /* -ERESTARTSYS */
> -			goto out;
> +			goto out_wake;
>  	} else {
>  		spin_unlock(&tbl->slot_tbl_lock);
>  	}
> @@ -1259,18 +1259,26 @@ static int nfs4_reset_session(struct nfs_client *clp)
>  	if (status && status != -NFS4ERR_BADSESSION &&
>  	    status != -NFS4ERR_DEADSESSION) {
>  		nfs4_session_recovery_handle_error(clp, status);
> -		goto out;
> +		goto out_wake;
>  	}
>  
>  	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
>  	status = nfs4_proc_create_session(clp);
> -	if (status)
> +	if (status) {
>  		nfs4_session_recovery_handle_error(clp, status);
> -		/* fall through*/
> -out:
> -	/* Wake up the next rpc task even on error */
> +		if (status == -NFS4ERR_STALE_CLIENTID) {

Let's do this with a test bit too...

> +			/*
> +			 * Let the state manager reestablish state
> +			 * without waking other yet.
> +			 */
> +			goto out;
> +		}
> +	}
> +out_wake:
> +	/* Wake up the next rpc task */
>  	clear_bit(NFS4CLNT_SESSION_DRAINING, &clp->cl_state);
>  	rpc_wake_up(&clp->cl_session->fc_slot_table.slot_tbl_waitq);
> +out:
-out: 
> 	if (status == 0)
>  		nfs41_setup_state_renewal(clp);
+out: 
> 	return status;
> @@ -1337,6 +1345,8 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  			status = nfs4_reset_session(clp);
>  			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
>  				continue;
> +			if (status == -NFS4ERR_STALE_CLIENTID)
> +				continue;

This should be redundant. The above test for LEASE_EXPIRED should catch
it first.

> 			if (status < 0)
>  				goto out_error;
>  		}


