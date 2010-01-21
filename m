From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] nfs41: clear NFS4CLNT_RECALL_SLOT bit on session
 reset
Date: Thu, 21 Jan 2010 14:42:55 -0500
Message-ID: <1264102975.3721.9.camel@localhost>
References: <1264101557-6619-1-git-send-email-andros@netapp.com>
	 <1264101557-6619-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47015 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436Ab0AUTni convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2010 14:43:38 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0LJhbES028230
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jan 2010 11:43:37 -0800 (PST)
In-Reply-To: <1264101557-6619-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-21 at 14:19 -0500, andros@netapp.com wrote: 
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4state.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 069dcb3..c7f2944 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1291,9 +1291,12 @@ static int nfs4_reset_session(struct nfs_client *clp)
>  
>  	memset(clp->cl_session->sess_id.data, 0, NFS4_MAX_SESSIONID_LEN);
>  	status = nfs4_proc_create_session(clp);
> -	if (status)
> +	if (status) {
>  		status = nfs4_recovery_handle_error(clp, status);
> -
> +		goto out;
> +	}
> +	/* create_session negotiated new slot table */
> +	clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state);
>  out:
>  	/*
>  	 * Let the state manager reestablish state

Errm.... Looking at nfs4_reset_session, wouldn't it make sense to move
that 'out:' label down one line, so that we can get rid of that test for
'status == 0'?

Trond
