Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59647 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab1FOO6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2011 10:58:30 -0400
Received: by eyx24 with SMTP id 24so195300eyx.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2011 07:58:29 -0700 (PDT)
Message-ID: <4DF8C891.6030402@gmail.com>
Date: Wed, 15 Jun 2011 10:58:25 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: andros@netapp.com
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Bakeathon version 2 1/1] NFSv4.1: fix hlist_del in _deviceid_purge_client
References: <1308147910-17057-1-git-send-email-andros@netapp.com>
In-Reply-To: <1308147910-17057-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-15 10:25, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> cc:stable@kernel.org [2.6.39]

Looks good to me.

Benny

> ---
>  fs/nfs/inode.c    |    2 ++
>  fs/nfs/pnfs.h     |    1 +
>  fs/nfs/pnfs_dev.c |   14 +++++++++++++-
>  3 files changed, 16 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 6f4850d..55ba1b0 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1595,6 +1595,8 @@ static int __init init_nfs_fs(void)
>  	if (err)
>  		goto out0;
>  
> +	nfs4_init_deviceid_cache();
> +
>  #ifdef CONFIG_PROC_FS
>  	rpc_proc_register(&nfs_rpcstat);
>  #endif
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index e46edac..67400bc 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -212,6 +212,7 @@ void nfs4_init_deviceid_node(struct nfs4_deviceid_node *,
>  struct nfs4_deviceid_node *nfs4_insert_deviceid_node(struct nfs4_deviceid_node *);
>  bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
>  void nfs4_deviceid_purge_client(const struct nfs_client *);
> +void nfs4_init_deviceid_cache(void);
>  
>  static inline int lo_fail_bit(u32 iomode)
>  {
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 037a5c6..923a9da 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -161,6 +161,15 @@ nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
>  }
>  EXPORT_SYMBOL_GPL(nfs4_init_deviceid_node);
>  
> +void
> +nfs4_init_deviceid_cache()
> +{
> +	long h;
> +
> +	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
> +		INIT_HLIST_HEAD(&nfs4_deviceid_cache[h]);
> +}
> +
>  /*
>   * Uniquely initialize and insert a deviceid node into cache
>   *
> @@ -236,9 +245,10 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
>  
>  	synchronize_rcu();
>  	while (!hlist_empty(&tmp)) {
> +		d = hlist_entry(tmp.first, struct nfs4_deviceid_node, tmpnode);
> +		hlist_del_init(&d->tmpnode);
>  		if (atomic_dec_and_test(&d->ref))
>  			d->ld->free_deviceid_node(d);
> -		hlist_del_init(&d->tmpnode);
>  	}
>  }
>  
> @@ -247,6 +257,8 @@ nfs4_deviceid_purge_client(const struct nfs_client *clp)
>  {
>  	long h;
>  
> +	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
> +		return;
>  	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
>  		_deviceid_purge_client(clp, h);
>  }
