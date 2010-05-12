From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] pnfs: set pnfs_blksize before calling set_pnfs_layoutdriver
Date: Wed, 12 May 2010 09:55:19 +0300
Message-ID: <4BEA50D7.5060509@panasas.com>
References: <20100512053021.GA7476@MDS-78.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
To: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59873 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab0ELGzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 May 2010 02:55:24 -0400
Received: by fxm4 with SMTP id 4so220575fxm.19
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 23:55:23 -0700 (PDT)
In-Reply-To: <20100512053021.GA7476-nK6E9TRyOkVSq9BJjBFyUp/QNRX+jHPU@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-05-12 08:30, Zhang Jingwang wrote:
> For block/volume layout driver, set_pnfs_layoutdriver will call
> initialize_mountpoint() which will check the value of pnfs_blksize.

Looks good.

Thanks!

Benny

> 
> Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
> ---
>  fs/nfs/client.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index dddc75c..94a9be9 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -880,9 +880,9 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fh *mntfh, stru
>  
>  	if (nfs4_has_session(clp) &&
>  	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
> +		server->pnfs_blksize = fsinfo->blksize;
>  		set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
>  		pnfs_set_ds_iosize(server);
> -		server->pnfs_blksize = fsinfo->blksize;
>  	}
>  #endif /* CONFIG_NFS_V4_1 */
>  }

