Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:29290 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751522AbbDGWUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 18:20:07 -0400
Date: Wed, 8 Apr 2015 08:19:27 +1000
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: xfs@oss.sgi.com, linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk
Subject: Re: [PATCH] xfs: unlock i_mutex in xfs_break_layouts
Message-ID: <20150407221927.GD15810@dastard>
References: <1428420944-20965-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1428420944-20965-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 07, 2015 at 05:35:44PM +0200, Christoph Hellwig wrote:
> We want to drop all I/O path locks when recalling layouts, and that includes
> i_mutex for the write path.  Without this we get stuck processe when recalls
> take too long.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
.....
>  		xfs_iunlock(ip, iolock);
> diff --git a/fs/xfs/xfs_pnfs.c b/fs/xfs/xfs_pnfs.c
> index 365dd57..981a657 100644
> --- a/fs/xfs/xfs_pnfs.c
> +++ b/fs/xfs/xfs_pnfs.c
> @@ -31,7 +31,8 @@
>  int
>  xfs_break_layouts(
>  	struct inode		*inode,
> -	uint			*iolock)
> +	uint			*iolock,
> +	bool			with_imutex)
>  {
>  	struct xfs_inode	*ip = XFS_I(inode);
>  	int			error;
> @@ -40,8 +41,12 @@ xfs_break_layouts(
>  
>  	while ((error = break_layout(inode, false) == -EWOULDBLOCK)) {
>  		xfs_iunlock(ip, *iolock);
> +		if (with_imutex && (*iolock & XFS_IOLOCK_EXCL))
> +			mutex_unlock(&inode->i_mutex);
>  		error = break_layout(inode, true);
>  		*iolock = XFS_IOLOCK_EXCL;
> +		if (with_imutex)
> +			mutex_lock(&inode->i_mutex);
>  		xfs_ilock(ip, *iolock);
>  	}

That's kinda nasty, and it has no documentation explaining when or
why we'd need to drop the i_mutex. How are we supposed to know if we
need to drop the i_mutex or not? What happens if the upper VFS
layers change or we have a multiple call paths that have different
i_mutex contexts (i.e. one holds, another doesn't)?

Which makes me wonder - is this layout breaking stuff at the right
layer?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
