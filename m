Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11318 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160Ab1FMTiH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 15:38:07 -0400
Subject: Re: [PATCH] NFS: return -EAGAIN when skipped commit in
 nfs_commit_unstable_pages()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Date: Mon, 13 Jun 2011 15:38:06 -0400
In-Reply-To: <20110610140459.GA8021@localhost>
References: <20110610140459.GA8021@localhost>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1307993886.5569.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-06-10 at 22:04 +0800, Wu Fengguang wrote: 
> It's confusing to return success while redirtying the inode at the
> same time in ->write_inode(). Return -EAGAIN to indicate that we've
> not finished with this inode.
> 
> Impact: it's a cleanup, not bug fix.
> 
> CC: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/nfs/write.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next.orig/fs/nfs/write.c	2011-06-10 21:52:34.000000000 +0800
> +++ linux-next/fs/nfs/write.c	2011-06-10 21:52:37.000000000 +0800
> @@ -1521,7 +1521,7 @@ static int nfs_commit_unstable_pages(str
>  {
>  	struct nfs_inode *nfsi = NFS_I(inode);
>  	int flags = FLUSH_SYNC;
> -	int ret = 0;
> +	int ret = -EAGAIN;
>  
>  	if (wbc->sync_mode == WB_SYNC_NONE) {
>  		/* Don't commit yet if this is a non-blocking flush and there

Looks good, but since this is a cleanup, I'm queueing it for 3.1 rather
than pushing it in the regression-fixing window.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

