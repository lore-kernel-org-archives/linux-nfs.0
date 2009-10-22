From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 2/2] nfs41: fix race on session reset
Date: Thu, 22 Oct 2009 15:20:18 +0200
Message-ID: <4AE05C12.7070403@panasas.com>
References: <1256149492-25481-1-git-send-email-andros@netapp.com>	<1256149492-25481-2-git-send-email-andros@netapp.com> <1256149492-25481-3-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:29030 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755219AbZJVNUS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2009 09:20:18 -0400
In-Reply-To: <1256149492-25481-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct. 21, 2009, 20:24 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Do not clear the NFS4CLNT_SESSION_SETUP bit until after the session has been
> reset (a possible EXCHANGE_ID, a DESTROY_SESSION, and a CREATE_SESSION) to
> prevent a race with nfs41_setup_sequence assigning a slot on a
> partially reset session.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c  |    3 +++
>  fs/nfs/nfs4state.c |   15 +++++++++------
>  2 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index eb245a1..80764e2 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4788,6 +4788,9 @@ int nfs4_proc_create_session(struct nfs_client *clp, int reset)
>  	if (status)
>  		goto out;
>  
> +	/* Signal nfs41_setup_sequence that the session is ready for use */
> +	clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
> +
>  	ptr = (unsigned *)&session->sess_id.data[0];
>  	dprintk("%s client>seqid %d sessionid %u:%u:%u:%u\n", __func__,
>  		clp->cl_seqid, ptr[0], ptr[1], ptr[2], ptr[3]);
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 1394dfb..09ca30b 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1252,17 +1252,20 @@ static void nfs4_state_manager(struct nfs_client *clp)
>  				continue;
>  		}
>  		/* Initialize or reset the session */
> -		if (test_and_clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
> -		   && nfs4_has_session(clp)) {
> +		if (test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)
> +		    && nfs4_has_session(clp)) {
>  			if (clp->cl_cons_state == NFS_CS_SESSION_INITING)
>  				status = nfs4_initialize_session(clp);
>  			else
>  				status = nfs4_reset_session(clp);
> -			if (status) {
> -				if (status == -NFS4ERR_STALE_CLIENTID)
> -					continue;
> +			if (status == -NFS4ERR_STALE_CLIENTID)
> +				continue;
> +			/* For error case. On success the bit is cleared in
> +			 * nfs4_proc_create_session */

Why the separation?
Why not handle both success and error cases here?

Benny

> +			clear_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
> +
> +			if (status)
>  				goto out_error;
> -			}
>  		}
>  		/* First recover reboot state... */
>  		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
