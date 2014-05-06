Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45379 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbaEFQhe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 12:37:34 -0400
Date: Tue, 6 May 2014 12:37:34 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/70] NFSd: call rpc_destroy_wait_queue() from
 free_client()
Message-ID: <20140506163734.GE18281@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:43:57PM -0400, Trond Myklebust wrote:
> Mainly to ensure that we don't leave any hanging timers.

Thanks, applying for 3.15 and stable.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 230d21cb1717..32b699bebb9c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1107,6 +1107,7 @@ free_client(struct nfs4_client *clp)
>  		WARN_ON_ONCE(atomic_read(&ses->se_ref));
>  		free_session(ses);
>  	}
> +	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
>  	free_svc_cred(&clp->cl_cred);
>  	kfree(clp->cl_name.data);
>  	idr_destroy(&clp->cl_stateids);
> -- 
> 1.9.0
> 
