Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53555 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751234AbdLLIxw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Dec 2017 03:53:52 -0500
Message-ID: <1513068823.27299.0.camel@pengutronix.de>
Subject: Re: [PATCH] NFS: fix access bit translation in _nfs4_proc_access()
From: Lucas Stach <l.stach@pengutronix.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de, patchwork-lst@pengutronix.de
Date: Tue, 12 Dec 2017 09:53:43 +0100
In-Reply-To: <20171110150356.31050-1-l.stach@pengutronix.de>
References: <20171110150356.31050-1-l.stach@pengutronix.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Freitag, den 10.11.2017, 16:03 +0100 schrieb Lucas Stach:
> Since bd8b2441742b (NFS: Store the raw NFS access mask in the inode's
> access cache) the mask already contains the NFS access bits, so it is
> wrong to try to map them from the MAY_* bits to the NFS_MAY_* bits
> in _nfs4_proc_access(). This leads to bogus access permissions being
> returned from the server.
> 
> Fix this by using the mask directly, but be careful to not ask for
> to broad permissions from the calling nfs_do_access().
> 
> CC: stable@vger.kernel.org #4.13+
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> Tested-by: Björn Lässig <b.laessig@pengutronix.de>

This patch is incomplete, as it misses the NFSv3 parts. Please ignore
this patch.

Regards,
Lucas

> ---
>  fs/nfs/dir.c      |  8 ++++++--
>  fs/nfs/nfs4proc.c | 19 +------------------
>  2 files changed, 7 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 5ceaeb1f6fb6..dd3a06353bdc 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2426,8 +2426,12 @@ static int nfs_do_access(struct inode *inode,
> struct rpc_cred *cred, int mask)
>  		goto out;
>  
>  	/* Be clever: ask server to check for all possible rights */
> -	cache.mask = NFS_MAY_LOOKUP | NFS_MAY_EXECUTE
> -		     | NFS_MAY_WRITE | NFS_MAY_READ;
> +	cache.mask = NFS_MAY_READ;
> +	if (S_ISDIR(inode->i_mode))
> +		cache.mask |= NFS_DIR_MAY_WRITE | NFS_MAY_LOOKUP;
> +	else
> +		cache.mask |= NFS_FILE_MAY_WRITE | NFS_MAY_EXECUTE;
> +
>  	cache.cred = cred;
>  	status = NFS_PROTO(inode)->access(inode, &cache);
>  	if (status != 0) {
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6c61e2b99635..cb7b5aafaef6 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3889,6 +3889,7 @@ static int _nfs4_proc_access(struct inode
> *inode, struct nfs_access_entry *entry
>  	struct nfs4_accessargs args = {
>  		.fh = NFS_FH(inode),
>  		.bitmask = server->cache_consistency_bitmask,
> +		.access = entry->mask,
>  	};
>  	struct nfs4_accessres res = {
>  		.server = server,
> @@ -3899,26 +3900,8 @@ static int _nfs4_proc_access(struct inode
> *inode, struct nfs_access_entry *entry
>  		.rpc_resp = &res,
>  		.rpc_cred = entry->cred,
>  	};
> -	int mode = entry->mask;
>  	int status = 0;
>  
> -	/*
> -	 * Determine which access bits we want to ask for...
> -	 */
> -	if (mode & MAY_READ)
> -		args.access |= NFS4_ACCESS_READ;
> -	if (S_ISDIR(inode->i_mode)) {
> -		if (mode & MAY_WRITE)
> -			args.access |= NFS4_ACCESS_MODIFY |
> NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE;
> -		if (mode & MAY_EXEC)
> -			args.access |= NFS4_ACCESS_LOOKUP;
> -	} else {
> -		if (mode & MAY_WRITE)
> -			args.access |= NFS4_ACCESS_MODIFY |
> NFS4_ACCESS_EXTEND;
> -		if (mode & MAY_EXEC)
> -			args.access |= NFS4_ACCESS_EXECUTE;
> -	}
> -
>  	res.fattr = nfs_alloc_fattr();
>  	if (res.fattr == NULL)
>  		return -ENOMEM;
