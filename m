Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:56003 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611AbaIIRRM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 13:17:12 -0400
Message-ID: <540F35FD.3060707@Netapp.com>
Date: Tue, 9 Sep 2014 13:16:45 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/9] pnfs: add flag to force read-modify-write in ->write_begin
References: <1410280853-3964-1-git-send-email-hch@lst.de> <1410280853-3964-3-git-send-email-hch@lst.de>
In-Reply-To: <1410280853-3964-3-git-send-email-hch@lst.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/09/2014 12:40 PM, Christoph Hellwig wrote:
> Like all block based filesystems, the pNFS block layout driver can't read
> or write at a byte granularity and thus has to perform read-modify-write
> cycles on writes smaller than this granularity.
>
> Add a flag so that the core NFS code always reads a whole page when
> starting a smaller write, so that we can do it in the place where the VFS
> expects it instead of doing in very deadlock prone way in the writeback
> handler.
>
> Note that in theory we could do less than page size reads here for disks
> that have a smaller sector size which are server by a server with a smaller
Nit:  This should read "served by a server" :)

Anna
> pnfs block size.  But so far that doesn't seem like a worthwhile
> optimization.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/file.c |  7 +++++++
>  fs/nfs/pnfs.h | 15 +++++++++++++++
>  2 files changed, 22 insertions(+)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 524dd80..05ef7dc 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -36,6 +36,7 @@
>  #include "internal.h"
>  #include "iostat.h"
>  #include "fscache.h"
> +#include "pnfs.h"
>  
>  #include "nfstrace.h"
>  
> @@ -327,6 +328,12 @@ static int nfs_want_read_modify_write(struct file *file, struct page *page,
>  	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
>  	unsigned int end = offset + len;
>  
> +	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
> +		if (!PageUptodate(page))
> +			return 1;
> +		return 0;
> +	}
> +
>  	if ((file->f_mode & FMODE_READ) &&	/* open for read? */
>  	    !PageUptodate(page) &&		/* Uptodate? */
>  	    !PagePrivate(page) &&		/* i/o request already? */
> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
> index 8835b5a..a4c530e 100644
> --- a/fs/nfs/pnfs.h
> +++ b/fs/nfs/pnfs.h
> @@ -72,6 +72,7 @@ enum layoutdriver_policy_flags {
>  	/* Should the pNFS client commit and return the layout upon a setattr */
>  	PNFS_LAYOUTRET_ON_SETATTR	= 1 << 0,
>  	PNFS_LAYOUTRET_ON_ERROR		= 1 << 1,
> +	PNFS_READ_WHOLE_PAGE		= 1 << 2,
>  };
>  
>  struct nfs4_deviceid_node;
> @@ -370,6 +371,14 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
>  }
>  
>  static inline bool
> +pnfs_ld_read_whole_page(struct inode *inode)
> +{
> +	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
> +		return false;
> +	return NFS_SERVER(inode)->pnfs_curr_ld->flags & PNFS_READ_WHOLE_PAGE;
> +}
> +
> +static inline bool
>  pnfs_layoutcommit_outstanding(struct inode *inode)
>  {
>  	struct nfs_inode *nfsi = NFS_I(inode);
> @@ -445,6 +454,12 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
>  }
>  
>  static inline bool
> +pnfs_ld_read_whole_page(struct inode *inode)
> +{
> +	return false;
> +}
> +
> +static inline bool
>  pnfs_roc(struct inode *ino)
>  {
>  	return false;

