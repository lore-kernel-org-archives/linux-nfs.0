From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix the locking in
 nfs_inode_reclaim_delegation()
Date: Tue, 20 Apr 2010 15:21:40 -0700
Message-ID: <20100420222140.GN2628@linux.vnet.ibm.com>
References: <20100420102608.31956.93404.stgit@warthog.procyon.org.uk>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:52764 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753295Ab0DTWVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 18:21:44 -0400
In-Reply-To: <20100420102608.31956.93404.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 20, 2010 at 11:26:08AM +0100, David Howells wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Ensure that we correctly rcu-dereference the delegation itself, and that we
> protect against removal while we're changing the contents.

I queued both of these, thank you Trond and David!

Trond, if you would rather carry these in your tree, please let me know.

							Thanx, Paul

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  fs/nfs/delegation.c |   42 ++++++++++++++++++++++++++++--------------
>  1 files changed, 28 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 1567124..8d9ec49 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -129,21 +129,35 @@ again:
>   */
>  void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
>  {
> -	struct nfs_delegation *delegation = NFS_I(inode)->delegation;
> -	struct rpc_cred *oldcred;
> +	struct nfs_delegation *delegation;
> +	struct rpc_cred *oldcred = NULL;
> 
> -	if (delegation == NULL)
> -		return;
> -	memcpy(delegation->stateid.data, res->delegation.data,
> -			sizeof(delegation->stateid.data));
> -	delegation->type = res->delegation_type;
> -	delegation->maxsize = res->maxsize;
> -	oldcred = delegation->cred;
> -	delegation->cred = get_rpccred(cred);
> -	clear_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
> -	NFS_I(inode)->delegation_state = delegation->type;
> -	smp_wmb();
> -	put_rpccred(oldcred);
> +	rcu_read_lock();
> +	delegation = rcu_dereference(NFS_I(inode)->delegation);
> +	if (delegation != NULL) {
> +		spin_lock(&delegation->lock);
> +		if (delegation->inode != NULL) {
> +			memcpy(delegation->stateid.data, res->delegation.data,
> +			       sizeof(delegation->stateid.data));
> +			delegation->type = res->delegation_type;
> +			delegation->maxsize = res->maxsize;
> +			oldcred = delegation->cred;
> +			delegation->cred = get_rpccred(cred);
> +			clear_bit(NFS_DELEGATION_NEED_RECLAIM,
> +				  &delegation->flags);
> +			NFS_I(inode)->delegation_state = delegation->type;
> +			spin_unlock(&delegation->lock);
> +			put_rpccred(oldcred);
> +			rcu_read_unlock();
> +		} else {
> +			/* We appear to have raced with a delegation return. */
> +			spin_unlock(&delegation->lock);
> +			rcu_read_unlock();
> +			nfs_inode_set_delegation(inode, cred, res);
> +		}
> +	} else {
> +		rcu_read_unlock();
> +	}
>  }
> 
>  static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
> 
