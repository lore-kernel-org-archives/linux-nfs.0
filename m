Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12317 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755178Ab1D0SA5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 14:00:57 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p3RI0sqY003787
	for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2011 11:00:55 -0700 (PDT)
Subject: Re: [PATCH] NFS: move pnfs layouts to nfs_server structure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1303922649-25478-1-git-send-email-dros@netapp.com>
References: <1303922649-25478-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 14:00:51 -0400
Message-ID: <1303927251.13195.19.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-27 at 12:44 -0400, Weston Andros Adamson wrote:
> Layouts should be tracked per FSID (aka superblock, aka struct nfs_server)
> instead of per struct nfs_client, which may have multiple FSIDs associated
> with it.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfs/callback_proc.c    |   60 +++++++++++++++++++++++++++-----------------
>  fs/nfs/client.c           |    6 ++--
>  fs/nfs/pnfs.c             |   13 +++++++--
>  include/linux/nfs_fs_sb.h |    2 +-
>  4 files changed, 51 insertions(+), 30 deletions(-)
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 139be96..f72fd39 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -188,9 +188,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  	cred = rpc_lookup_machine_cred();
>  	if (!IS_ERR(cred))
>  		clp->cl_machine_cred = cred;
> -#if defined(CONFIG_NFS_V4_1)
> -	INIT_LIST_HEAD(&clp->cl_layouts);
> -#endif
>  	nfs_fscache_get_client_cookie(clp);
>  
>  	return clp;
> @@ -1060,6 +1057,9 @@ static struct nfs_server *nfs_alloc_server(void)
>  	INIT_LIST_HEAD(&server->client_link);
>  	INIT_LIST_HEAD(&server->master_link);
>  	INIT_LIST_HEAD(&server->delegations);
> +#if defined(CONFIG_NFS_V4_1)
> +	INIT_LIST_HEAD(&server->layouts);
> +#endif

Can we please just drop the #ifdef here?

>  	atomic_set(&server->active, 0);

Otherwise it looks good to me...
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

