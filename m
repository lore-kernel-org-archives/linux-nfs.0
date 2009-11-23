From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 03/10] nfs41: fix cb_recall bug
Date: Mon, 23 Nov 2009 18:16:48 -0500
Message-ID: <1259018208.8700.111.camel@localhost>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
	 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
	 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:33702 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbZKWXQp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 18:16:45 -0500
In-Reply-To: <1259013287-3349-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-11-23 at 13:54 -0800, Alexandros Batsakis wrote: 
> in NFSv4.1 the seqid part of a stateid in CB_RECALL must be 0
> 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/delegation.c |   21 +++++++++++++++++----
>  1 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index 6dd48a4..4096dcf 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -432,18 +432,31 @@ int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *s
>  {
>  	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
>  	struct nfs_delegation *delegation;
> +	u32 seqid_len = 0;
>  
>  	rcu_read_lock();
>  	delegation = rcu_dereference(NFS_I(inode)->delegation);
> -	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
> -				sizeof(delegation->stateid.data)) != 0) {
> -		rcu_read_unlock();
> -		return -ENOENT;
> +	if (delegation == NULL)
> +		goto enoent;
> +
> +	if (clp->cl_minorversion > 0) {
> +		if (((u32 *) &stateid->data)[0] != 0)
> +			goto enoent;
> +		seqid_len = 4;
>  	}
> +
> +	if (memcmp(&delegation->stateid.data[seqid_len],
> +		   &stateid->data[seqid_len],
> +		   sizeof(stateid->data)-seqid_len))
> +		goto enoent;

cl_minorversion has nothing to do with generic delegation code. Please
just let the comparison be a pointer-to-function argument to
nfs_async_inode_return_delegation.

> +
>  	nfs_mark_return_delegation(clp, delegation);
>  	rcu_read_unlock();
>  	nfs_delegation_run_state_manager(clp);
>  	return 0;
> +enoent:
> +	rcu_read_unlock();
> +	return -ENOENT;
>  }
>  
>  /*



