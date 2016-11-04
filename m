Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:36847 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933631AbcKDPAH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2016 11:00:07 -0400
Received: by mail-qt0-f173.google.com with SMTP id w33so49519707qtc.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2016 08:00:07 -0700 (PDT)
Message-ID: <1478271605.28785.6.camel@redhat.com>
Subject: Re: [PATCH] NFS: Don't print a pNFS error if we aren't using pNFS
From: Jeff Layton <jlayton@redhat.com>
To: Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Date: Fri, 04 Nov 2016 11:00:05 -0400
In-Reply-To: <20161104130841.17150-1-Anna.Schumaker@Netapp.com>
References: <20161104130841.17150-1-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-11-04 at 09:08 -0400, Anna.Schumaker@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> We used to check for a valid layout type id before verifying pNFS flags
> as an indicator for if we are using pNFS.  This changed in 3132e49ece
> with the introduction of multiple layout types, since now we are passing
> an array of ids instead of just one.  Since then, users have been seeing
> a KERN_ERR printk show up whenever mounting NFS v4 without pNFS.  This
> patch restores the original behavior of exiting set_pnfs_layoutdriver()
> early if we aren't using pNFS.
> 
> Fixes 3132e49ece ("pnfs: track multiple layout types in fsinfo
> structure")
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
>  fs/nfs/pnfs.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 56b2d96..259ef85 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -146,6 +146,8 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
>  	u32 id;
>  	int i;
>  
> +	if (fsinfo->nlayouttypes == 0)
> +		goto out_no_driver;
>  	if (!(server->nfs_client->cl_exchange_flags &
>  		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
>  		printk(KERN_ERR "NFS: %s: cl_exchange_flags 0x%x\n",

Good catch!

Reviewed-by: Jeff Layton <jlayton@redhat.com>
