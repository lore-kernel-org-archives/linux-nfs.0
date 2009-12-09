Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:45560 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758116AbZLIWVf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 17:21:35 -0500
Message-ID: <4B2022F5.9060002@panasas.com>
Date: Thu, 10 Dec 2009 00:21:41 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: pnfs@linux-nfs.org
CC: "J. Bruce Fields" <bfields@citi.umich.edu>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [pnfs] [PATCH 9/9] SQUASHME: pnfs: filelayout: mask out server's
 MDS capability flag for DSs
References: <4B1F7AF6.2080305@panasas.com> <1260354530-12578-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1260354530-12578-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Dec. 09, 2009, 12:28 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> When establishing a session with a DS mask out its MDS
> exchange_id flag so we know we use it as DS-only.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4filelayoutdev.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 128715a..cb8ae88 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -272,6 +272,9 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
>  	if (err)
>  		goto out_put;
>  
> +	/* mask out the server's MDS capability flag */
> +	clp->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_DS;
> +

Duh, that should be
	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;

Or I'm just utterly tired ;-)

Benny

>  	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
>  		printk(KERN_INFO "ip:port %s is not a pNFS Data Server\n",
>  			ds->r_addr);
