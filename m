Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50840 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752521AbdKHU6M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 15:58:12 -0500
Date: Wed, 8 Nov 2017 15:58:12 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: fix locking validator warning on
 nfs4_ol_stateid->st_mutex class
Message-ID: <20171108205812.GP24262@fieldses.org>
References: <20171108005726.35092-1-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171108005726.35092-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 07, 2017 at 07:57:26PM -0500, Andrew Elble wrote:
> The use of the st_mutex has been confusing the validator. Use the
> proper nested notation so as to not produce warnings.

Looking around, the usual pattern for simple nesting seems to be to use
just mutex_lock() for the outer lock (equivalent to
mutex_lock_nested(0)), and mutex_lock_nested(., SINGLE_DEPTH_NESTING)
for the inner lock.

Or we could define a new LOCK_STATEID_MUTEX, assuming the rule here is
"lock stateid's are locked after open stateid's".  Just a question of
might be simpler to understand.

--b.

> 
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  v2: added mutex_lock_nested to init_lock_stateid() for consistency
>  
>  fs/nfsd/nfs4state.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0d98d73bd84e..62909f3947b2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3548,7 +3548,7 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
>  {
>  	__be32 ret;
>  
> -	mutex_lock(&stp->st_mutex);
> +	mutex_lock_nested(&stp->st_mutex, 1);
>  	ret = nfsd4_verify_open_stid(&stp->st_stid);
>  	if (ret != nfs_ok)
>  		mutex_unlock(&stp->st_mutex);
> @@ -3612,7 +3612,7 @@ static void nfs4_free_openowner(struct nfs4_stateowner *so)
>  	stp = open->op_stp;
>  	/* We are moving these outside of the spinlocks to avoid the warnings */
>  	mutex_init(&stp->st_mutex);
> -	mutex_lock(&stp->st_mutex);
> +	mutex_lock_nested(&stp->st_mutex, 0);
>  
>  retry:
>  	spin_lock(&oo->oo_owner.so_client->cl_lock);
> @@ -5692,7 +5692,7 @@ static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
>  	struct nfs4_ol_stateid *retstp;
>  
>  	mutex_init(&stp->st_mutex);
> -	mutex_lock(&stp->st_mutex);
> +	mutex_lock_nested(&stp->st_mutex, 0);
>  retry:
>  	spin_lock(&clp->cl_lock);
>  	spin_lock(&fp->fi_lock);
> -- 
> 1.8.3.1
