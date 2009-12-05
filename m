From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/3] nfs41: Handle session errors during delegation
 return
Date: Sat, 05 Dec 2009 15:38:36 -0500
Message-ID: <1260045516.29208.8.camel@localhost>
References: <>
	 <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260043884-16267-3-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8326 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756521AbZLEUlS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 15:41:18 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5KfO3l011185
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 12:41:25 -0800 (PST)
In-Reply-To: <1260043884-16267-3-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-12-05 at 12:11 -0800, Ricardo Labiaga wrote: 
> Add session error handling to nfs4_open_delegation_recall()
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index fb94ed0..97d4a82 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1169,6 +1169,18 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
>  			case -ENOENT:
>  			case -ESTALE:
>  				goto out;
> +			case -NFS4ERR_BADSESSION:
> +			case -NFS4ERR_BADSLOT:
> +			case -NFS4ERR_BAD_HIGH_SLOT:
> +			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> +			case -NFS4ERR_DEADSESSION:
> +			case -NFS4ERR_SEQ_FALSE_RETRY:
> +			case -NFS4ERR_SEQ_MISORDERED:
> +				dprintk("%s ERROR: %d Reset session\n",
> +					__func__, err);
> +				set_bit(NFS4CLNT_SESSION_SETUP,
> +					&server->nfs_client->cl_state);
> +				goto out;
>  			case -NFS4ERR_STALE_CLIENTID:
>  			case -NFS4ERR_STALE_STATEID:
>  			case -NFS4ERR_EXPIRED:

BADSESSION and DEADSESSION should call nfs4_schedule_state_recovery()
instead.

The rest can continue to call NFS4CLNT_SESSION_RESET, but should also
call nfs4_schedule_state_manager().

Trond
