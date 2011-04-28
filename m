Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13428 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910Ab1D1EQg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2011 00:16:36 -0400
Message-ID: <4DB8EA18.1030508@panasas.com>
Date: Thu, 28 Apr 2011 07:16:24 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: trond@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: move pnfs layouts to nfs_server structure
References: <1303944050-29932-1-git-send-email-dros@netapp.com> <1303944050-29932-2-git-send-email-dros@netapp.com>
In-Reply-To: <1303944050-29932-2-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-28 01:40, Weston Andros Adamson wrote:
...

> @@ -167,18 +176,27 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
>  	};
>  
>  	spin_lock(&clp->cl_lock);
> -	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>  		if ((args->cbl_recall_type == RETURN_FSID) &&
> -		    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
> -			   &args->cbl_fsid, sizeof(struct nfs_fsid)))
> -			continue;
> -		if (!igrab(lo->plh_inode))
> +		    memcmp(&server->fsid, &args->cbl_fsid,
> +			   sizeof(struct nfs_fsid)))
>  			continue;
> -		get_layout_hdr(lo);
> -		BUG_ON(!list_empty(&lo->plh_bulk_recall));
> -		list_add(&lo->plh_bulk_recall, &recall_list);
> +
> +		list_for_each_entry(lo, &server->layouts, plh_layouts) {
> +			if (!igrab(lo->plh_inode))
> +				continue;
> +			get_layout_hdr(lo);
> +			BUG_ON(!list_empty(&lo->plh_bulk_recall));
> +			list_add(&lo->plh_bulk_recall, &recall_list);
> +		}
> +
> +		if (args->cbl_recall_type == RETURN_FSID)
> +			break;

I actually thought of suggesting that yesterday but
I'm not sure fsid is unique per nfs_server.  Is it?

Benny

>  	}
> +	rcu_read_unlock();
>  	spin_unlock(&clp->cl_lock);
> +
>  	list_for_each_entry_safe(lo, tmp,
>  				 &recall_list, plh_bulk_recall) {
>  		ino = lo->plh_inode;
