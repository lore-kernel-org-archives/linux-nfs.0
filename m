Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:14377 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab1FAGiu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 02:38:50 -0400
Message-ID: <4DE5DE71.2090601@panasas.com>
Date: Wed, 01 Jun 2011 09:38:41 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: trond@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: fix umount of pnfs filesystems
References: <1306891804-8070-1-git-send-email-dros@netapp.com>
In-Reply-To: <1306891804-8070-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/01/2011 04:30 AM, Weston Andros Adamson wrote:
> Unmounting a pnfs filesystem hangs using filelayout and possibly others.
> This fixes the use of the rcu protected node by making use of a new 'tmpnode'
> for the temporary purge list. Also, the spinlock shouldn't be held when calling
> synchronize_rcu().
> 

I like the new code, but I have two questions:

* Why didn't I see this hang? (Maybe because I run uni-processor)
* How do you have this problem. Usually with the regular usage of device-cache
  all deviceids get released when layouts go away. So by the time client_purge comes
  in there are no more devices in the cache. At objects-ld I take an extra ref at
  first add_dev which is then get released in client_purge?

Thanks
Boaz

> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> Fix proposed by Trond
> 
>  fs/nfs/pnfs.h     |    1 +
>  fs/nfs/pnfs_dev.c |   11 +++++++----
>  2 files changed, 8 insertions(+), 4 deletions(-)
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
> index c65e133..81e642f 100644
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
> @@ -241,21 +242,25 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
>  	struct hlist_node *n, *next;
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

