Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36456 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933830Ab1ESTiM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2011 15:38:12 -0400
Subject: Re: [PATCH] nfs41: Correct offset for LAYOUTCOMMIT
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@gmail.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Date: Thu, 19 May 2011 15:38:10 -0400
In-Reply-To: <1305832245-17318-1-git-send-email-gusev.vitaliy@nexenta.com>
References: <1305832245-17318-1-git-send-email-gusev.vitaliy@nexenta.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1305833890.5552.0.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-05-19 at 23:10 +0400, Vitaliy Gusev wrote: 
> A client sends offset to MDS as it was seen by DS. As result,
> file size after copy is only half of original file size in case
> of 2 DS.
> 
> Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
> ---
>  fs/nfs/nfs4filelayout.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index be79dc9..790eb1d 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -167,6 +167,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
>  	    wdata->res.verf->committed == NFS_FILE_SYNC)
>  		return;
>  
> +	wdata->args.offset = wdata->mds_offset;
>  	pnfs_set_layoutcommit(wdata);
>  	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
>  		(unsigned long) wdata->lseg->pls_end_pos);

Err... Shouldn't we rather be fixing pnfs_set_layoutcommit() to use the
mds_offset instead of hacking args.offset?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

