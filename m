Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756402Ab1D0NyX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 09:54:23 -0400
Date: Wed, 27 Apr 2011 09:54:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd41: Deny new lock before RECLAIM_COMPLETE done
Message-ID: <20110427135422.GA1618@fieldses.org>
References: <4DB76D60.3010802@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DB76D60.3010802@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 27, 2011 at 09:12:00AM +0800, Mi Jinlong wrote:
> Before nfs41 client's RECLAIM_COMPLETE done, nfs server should 
> deny it's new lock.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

Is nfserr_grace the right error?  (Honest question, I haven't looked it
up.)

Also I'd think this check should go in nfsd4_open: opens are also
prohibited before RECLAIM_COMPLETE, and if we check there then we don't
need to check here, as you have to have open state before you can do a
lock.

--b.

> ---
>  fs/nfsd/nfs4state.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4b36ec3..43cda94 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3803,6 +3803,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		 */
>  		struct nfs4_stateid *open_stp = NULL;
>  		
> +		/*
> +		 * RFC5661 18.51.3
> +		 * Before RECLAIM_COMPLETE done, return NFS4ERR_GRACE
> +		 */
> +		status = nfserr_grace;
> +		if (nfsd4_has_session(cstate) &&
> +		    !cstate->session->se_client->cl_firststate)
> +			goto out;
> +
>  		status = nfserr_stale_clientid;
>  		if (!nfsd4_has_session(cstate) &&
>  		    STALE_CLIENTID(&lock->lk_new_clientid))
> -- 
> 1.7.4.1
> 
> 
