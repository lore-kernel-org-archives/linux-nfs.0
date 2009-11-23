From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 05/10] nfs4: return/expire delegations depending on
 their type
Date: Mon, 23 Nov 2009 18:07:03 -0500
Message-ID: <1259017623.8700.102.camel@localhost>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
	 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
	 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
	 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
	 <1259013287-3349-5-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40199 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755951AbZKWXG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 18:06:59 -0500
In-Reply-To: <1259013287-3349-5-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-23 at 13:54 -0800, Alexandros Batsakis wrote: 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/delegation.c |   20 ++++++++++++++++----
>  1 files changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 71d5094..a14df44 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -371,29 +371,41 @@ void nfs_super_return_all_delegations(struct super_block *sb)
>  	nfs_client_return_marked_delegations(clp);
>  }
>  
> -static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
> +static
> +void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp, fmode_t flags)
>  {
>  	struct nfs_delegation *delegation;
>  
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
> -		nfs_mark_return_delegation(clp, delegation);
> +		if (delegation->type & flags)
> +			nfs_mark_return_delegation(clp, delegation);

This will be confusing. In all other parts of the code, we label write
delegations as FMODE_READ|FMODE_WRITE, since a write delegation implies
a read delegation too.

> 	}
>  	rcu_read_unlock();
>  }
>  
> +static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
> +{
> +	nfs_client_mark_return_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
> +}
> +
>  static void nfs_delegation_run_state_manager(struct nfs_client *clp)
>  {
>  	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
>  		nfs4_schedule_state_manager(clp);
>  }
>  
> -void nfs_expire_all_delegations(struct nfs_client *clp)
> +void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags)

Should be static void since there is no declaration of
nfs_expire_all_delegation types in any header files (that only appears
in patch 07/10).

> {
> -	nfs_client_mark_return_all_delegations(clp);
> +	nfs_client_mark_return_all_delegation_types(clp, flags);
>  	nfs_delegation_run_state_manager(clp);
>  }
>  
> +void nfs_expire_all_delegations(struct nfs_client *clp)
> +{
> +	nfs_expire_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
> +}
> +
>  /*
>   * Return all delegations following an NFS4ERR_CB_PATH_DOWN error.
>   */



