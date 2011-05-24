From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 04/12] pnfs: layout_driver MUST set free_deviceid_node
 if using dev-cache
Date: Tue, 24 May 2011 20:04:23 +0300
Message-ID: <4DDBE517.9090605@panasas.com>
References: <4DDBC611.3050202@panasas.com> <1306249546-23273-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54730 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab1EXRE3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 13:04:29 -0400
In-Reply-To: <1306249546-23273-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-05-24 18:05, Boaz Harrosh wrote:
> A device cache is not a matter of memory store. It is a matter
> of mounting/login and unmounting/logout. So it is not logical
> to not set free_deviceid_node. Who will do the unmount?
> 
> It is better to crash the developer then let him leak mounts.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

OK, we can do that.

Benny

> ---
>  fs/nfs/pnfs_dev.c |   16 ++++------------
>  1 files changed, 4 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 37ca215..1b592d9 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -163,10 +163,7 @@ nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *ld,
>  	d = nfs4_unhash_put_deviceid(ld, clp, id);
>  	if (!d)
>  		return;
> -	if (d->ld->free_deviceid_node)
> -		d->ld->free_deviceid_node(d);
> -	else
> -		kfree(d);
> +	d->ld->free_deviceid_node(d);
>  }
>  EXPORT_SYMBOL_GPL(nfs4_delete_deviceid);
>  
> @@ -232,8 +229,7 @@ nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
>  	hlist_del_init_rcu(&d->node);
>  	spin_unlock(&nfs4_deviceid_lock);
>  	synchronize_rcu();
> -	if (d->ld->free_deviceid_node)
> -		d->ld->free_deviceid_node(d);
> +	d->ld->free_deviceid_node(d);
>  	return true;
>  }
>  EXPORT_SYMBOL_GPL(nfs4_put_deviceid_node);
> @@ -258,12 +254,8 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
>  
>  	synchronize_rcu();
>  	hlist_for_each_entry_safe(d, n, next, &tmp, node)
> -		if (atomic_dec_and_test(&d->ref)) {
> -			if (d->ld->free_deviceid_node)
> -				d->ld->free_deviceid_node(d);
> -			else
> -				kfree(d);
> -		}
> +		if (atomic_dec_and_test(&d->ref))
> +			d->ld->free_deviceid_node(d);
>  }
>  
>  void

