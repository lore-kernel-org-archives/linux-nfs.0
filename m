Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbcGNTzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2016 15:55:44 -0400
Date: Thu, 14 Jul 2016 15:55:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Close race between nfsd4_release_lockowner and
 nfsd4_lock
Message-ID: <20160714195542.GB16311@fieldses.org>
References: <20160713202810.19268.64046.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160713202810.19268.64046.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 13, 2016 at 04:40:14PM -0400, Chuck Lever wrote:
> nfsd4_release_lockowner finds a lock owner that has no lock state,
> and drops cl_lock. Then release_lockowner picks up cl_lock and
> unhashes the lock owner.
> 
> During the window where cl_lock is dropped, I don't see anything
> preventing a concurrent nfsd4_lock from finding that same lock owner
> and adding lock state to it.
> 
> Move release_lockowner() into nfsd4_release_lockowner and hang onto
> the cl_lock until after the lock owner's state cannot be found
> again.
> 
> Fixes: 2c41beb0e5cf ("nfsd: reduce cl_lock thrashing in ... ")
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Makes sense.  Applying with just one line added to the changelog, in
case it's useful to someone: "Found by inspection, we don't currently
have a reproducer."

> ---
> Hi Bruce-
> 
> Noticed this recently. I've been running with this patch on my test
> NFS server for over a week. Haven't noticed any issues, but I wonder
> if my clients or tests actually exercise this code in parallel.
> 
> The reason I was looking at this area is that one of our internal
> testers encountered a related problem with NFSv4.1. LOCK and
> FREE_STATEID are racing: LOCK returns an existing lock stateid, then
> FREE_STATEID frees that stateid (NFS4_OK). FREE_STATEID should
> return NFS4ERR_LOCKS_HELD in this case?

Looks like free_stateid is deciding whether to return LOCKS_HELD by
inspecting the list of vfs locks, but nfsd4_lock creates the lock
stateid before the vfs lock, so maybe there's a race like:

	create lock stateid
				free_stateid
	vfs_lock_file

but I haven't checked that in detail.

I haven't thought about the protocol side--does hitting this race
require an incorrect client?

--b.

> 
> I have not been able to reproduce this, but our tester is able to
> hit it fairly reliably with Oracle's v4.1-based kernel running on
> his server. Recent upstream kernels make the issue rare, but it is
> still encountered on occasion.
> 
> 
>  fs/nfsd/nfs4state.c |   40 +++++++++++++++++-----------------------
>  1 file changed, 17 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f5f82e1..31c993f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1200,27 +1200,6 @@ free_ol_stateid_reaplist(struct list_head *reaplist)
>  	}
>  }
>  
> -static void release_lockowner(struct nfs4_lockowner *lo)
> -{
> -	struct nfs4_client *clp = lo->lo_owner.so_client;
> -	struct nfs4_ol_stateid *stp;
> -	struct list_head reaplist;
> -
> -	INIT_LIST_HEAD(&reaplist);
> -
> -	spin_lock(&clp->cl_lock);
> -	unhash_lockowner_locked(lo);
> -	while (!list_empty(&lo->lo_owner.so_stateids)) {
> -		stp = list_first_entry(&lo->lo_owner.so_stateids,
> -				struct nfs4_ol_stateid, st_perstateowner);
> -		WARN_ON(!unhash_lock_stateid(stp));
> -		put_ol_stateid_locked(stp, &reaplist);
> -	}
> -	spin_unlock(&clp->cl_lock);
> -	free_ol_stateid_reaplist(&reaplist);
> -	nfs4_put_stateowner(&lo->lo_owner);
> -}
> -
>  static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp,
>  				       struct list_head *reaplist)
>  {
> @@ -5938,6 +5917,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  	__be32 status;
>  	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
>  	struct nfs4_client *clp;
> +	LIST_HEAD (reaplist);
>  
>  	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
>  		clid->cl_boot, clid->cl_id);
> @@ -5968,9 +5948,23 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  		nfs4_get_stateowner(sop);
>  		break;
>  	}
> +	if (!lo) {
> +		spin_unlock(&clp->cl_lock);
> +		return status;
> +	}
> +
> +	unhash_lockowner_locked(lo);
> +	while (!list_empty(&lo->lo_owner.so_stateids)) {
> +		stp = list_first_entry(&lo->lo_owner.so_stateids,
> +				       struct nfs4_ol_stateid,
> +				       st_perstateowner);
> +		WARN_ON(!unhash_lock_stateid(stp));
> +		put_ol_stateid_locked(stp, &reaplist);
> +	}
>  	spin_unlock(&clp->cl_lock);
> -	if (lo)
> -		release_lockowner(lo);
> +	free_ol_stateid_reaplist(&reaplist);
> +	nfs4_put_stateowner(&lo->lo_owner);
> +
>  	return status;
>  }
>  
