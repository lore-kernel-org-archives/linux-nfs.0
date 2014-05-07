Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47246 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222AbaEGQVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 12:21:43 -0400
Date: Wed, 7 May 2014 12:21:42 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 25/70] NFSd: Simplify stateid management
Message-ID: <20140507162142.GE4240@fieldses.org>
References: <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:44:19PM -0400, Trond Myklebust wrote:
> Don't allow stateids to clear the open file pointer until they are
> being destroyed.

It looks like this means the stateid will continue to reference the file
after close in the nfsv4.0 case when we keep the stateid around a little
while just to handle replays.

Ditto in the 4.1 case when we keep a revoked delegation around for
test_stateid/free_stateid.

I'd consider that a regression.  People do occasionally notice when e.g.
a large unlinked file isn't promptly deallocated on close, and there may
be other cases where this matters.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index afb767319f66..51ef179339ae 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -394,7 +394,7 @@ kmem_cache *slab)
>  	struct nfs4_stid *stid;
>  	int new_id;
>  
> -	stid = kmem_cache_alloc(slab, GFP_KERNEL);
> +	stid = kmem_cache_zalloc(slab, GFP_KERNEL);
>  	if (!stid)
>  		return NULL;
>  
> @@ -481,6 +481,8 @@ void
>  nfs4_put_delegation(struct nfs4_delegation *dp)
>  {
>  	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
> +		if (dp->dl_file)
> +			put_nfs4_file(dp->dl_file);
>  		nfs4_free_stid(deleg_slab, &dp->dl_stid);
>  		num_delegations--;
>  	}
> @@ -528,10 +530,8 @@ unhash_delegation(struct nfs4_delegation *dp)
>  		spin_unlock(&fp->fi_inode->i_lock);
>  	}
>  	nfs4_put_deleg_lease(fp);
> -	dp->dl_file = NULL;
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
> -	put_nfs4_file(fp);
>  }
>  
>  
> @@ -701,13 +701,13 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
>  static void close_generic_stateid(struct nfs4_ol_stateid *stp)
>  {
>  	release_all_access(stp);
> -	put_nfs4_file(stp->st_file);
> -	stp->st_file = NULL;
>  }
>  
>  static void free_generic_stateid(struct nfs4_ol_stateid *stp)
>  {
>  	remove_stid(&stp->st_stid);
> +	if (stp->st_file)
> +		put_nfs4_file(stp->st_file);
>  	nfs4_free_stid(stateid_slab, &stp->st_stid);
>  }
>  
> @@ -3265,8 +3265,6 @@ unlock_and_free:
>  	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
>  out_free:
> -	put_nfs4_file(fp);
> -	dp->dl_file = fp;
>  	return status;
>  }
>  
> -- 
> 1.9.0
> 
