Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21281 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758768Ab1FAMAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 08:00:14 -0400
Message-ID: <4DE629CB.1040806@panasas.com>
Date: Wed, 01 Jun 2011 15:00:11 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: trond@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: fix umount of pnfs filesystems
References: <1306892810-8416-1-git-send-email-dros@netapp.com>
In-Reply-To: <1306892810-8416-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-01 04:46, Weston Andros Adamson wrote:
> Unmounting a pnfs filesystem hangs using filelayout and possibly others.
> This fixes the use of the rcu protected node by making use of a new 'tmpnode'
> for the temporary purge list. Also, the spinlock shouldn't be held when calling
> synchronize_rcu().
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>

ACK.
Looks good to me, thanks!

Benny

> ---
> Fix proposed by Trond.  Reposted without 'unused variable' warning.
> 
>  fs/nfs/pnfs.h     |    1 +
>  fs/nfs/pnfs_dev.c |   13 ++++++++-----
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 48d0a8e..96bf4e6 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -186,6 +186,7 @@ int pnfs_ld_read_done(struct nfs_read_data *);
>  /* pnfs_dev.c */
>  struct nfs4_deviceid_node {
>  	struct hlist_node		node;
> +	struct hlist_node		tmpnode;
>  	const struct pnfs_layoutdriver_type *ld;
>  	const struct nfs_client		*nfs_client;
>  	struct nfs4_deviceid		deviceid;
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index c65e133..503186e 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -174,6 +174,7 @@ nfs4_init_deviceid_node(struct nfs4_deviceid_node *d,
>  			const struct nfs4_deviceid *id)
>  {
>  	INIT_HLIST_NODE(&d->node);
> +	INIT_HLIST_NODE(&d->tmpnode);
>  	d->ld = ld;
>  	d->nfs_client = nfs_client;
>  	d->deviceid = *id;
> @@ -238,24 +239,28 @@ static void
>  _deviceid_purge_client(const struct nfs_client *clp, long hash)
>  {
>  	struct nfs4_deviceid_node *d;
> -	struct hlist_node *n, *next;
> +	struct hlist_node *n;
>  	HLIST_HEAD(tmp);
>  
> +	spin_lock(&nfs4_deviceid_lock);
>  	rcu_read_lock();
>  	hlist_for_each_entry_rcu(d, n, &nfs4_deviceid_cache[hash], node)
>  		if (d->nfs_client == clp && atomic_read(&d->ref)) {
>  			hlist_del_init_rcu(&d->node);
> -			hlist_add_head(&d->node, &tmp);
> +			hlist_add_head(&d->tmpnode, &tmp);
>  		}
>  	rcu_read_unlock();
> +	spin_unlock(&nfs4_deviceid_lock);
>  
>  	if (hlist_empty(&tmp))
>  		return;
>  
>  	synchronize_rcu();
> -	hlist_for_each_entry_safe(d, n, next, &tmp, node)
> +	while (!hlist_empty(&tmp)) {
>  		if (atomic_dec_and_test(&d->ref))
>  			d->ld->free_deviceid_node(d);
> +		hlist_del_init(&d->tmpnode);
> +	}
>  }
>  
>  void
> @@ -263,8 +268,6 @@ nfs4_deviceid_purge_client(const struct nfs_client *clp)
>  {
>  	long h;
>  
> -	spin_lock(&nfs4_deviceid_lock);
>  	for (h = 0; h < NFS4_DEVICE_ID_HASH_SIZE; h++)
>  		_deviceid_purge_client(clp, h);
> -	spin_unlock(&nfs4_deviceid_lock);
>  }

