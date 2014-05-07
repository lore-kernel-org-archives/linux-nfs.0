Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbaEGTUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 15:20:06 -0400
Date: Wed, 7 May 2014 15:20:04 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 27/70] NFSd: Don't let the laundromat reap clients that
 are referenced
Message-ID: <20140507192004.GC8324@fieldses.org>
References: <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks redundant with the check just made in
mark_client_expired_locked().

--b.

On Fri, Apr 18, 2014 at 02:44:21PM -0400, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 273bdddb2458..41314e493110 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3600,6 +3600,9 @@ nfs4_laundromat(struct nfsd_net *nn)
>  				clp->cl_clientid.cl_id);
>  			continue;
>  		}
> +		/* Hey, I'm busy with this guy! */
> +		if (atomic_read(&clp->cl_refcount) != 0)
> +			continue;
>  		list_move(&clp->cl_lru, &reaplist);
>  	}
>  	spin_unlock(&nn->client_lock);
> -- 
> 1.9.0
> 
