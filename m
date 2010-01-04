Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:39995 "EHLO verein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977Ab0ADNux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2010 08:50:53 -0500
Date: Mon, 4 Jan 2010 14:50:45 +0100
From: Christoph Hellwig <hch@lst.de>
To: bfields@fieldses.org, viro@zeniv.linux.org.uk, jack@suse.cz
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: make sure data is on disk before calling ->fsync
Message-ID: <20100104135045.GA18072@lst.de>
References: <20091225164445.GA4578@lst.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20091225164445.GA4578@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

ping?  this fixes a quite nasty issue introduced in 2.6.32, so we should
fix it ASAP (including backport to -stable)

On Fri, Dec 25, 2009 at 05:44:45PM +0100, Christoph Hellwig wrote:
> nfsd is not using vfs_fsync, so I missed it when changing the calling
> convention during the 2.6.32 window.  This patch fixes it to not only
> start the data writeout, but also wait for it to complete before calling
> into ->fsync.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/fs/nfsd/vfs.c
> ===================================================================
> --- linux-2.6.orig/fs/nfsd/vfs.c	2009-12-25 17:21:32.371024157 +0100
> +++ linux-2.6/fs/nfsd/vfs.c	2009-12-25 17:31:39.644006085 +0100
> @@ -780,12 +780,9 @@ static inline int nfsd_dosync(struct fil
>  	int (*fsync) (struct file *, struct dentry *, int);
>  	int err;
>  
> -	err = filemap_fdatawrite(inode->i_mapping);
> +	err = filemap_write_and_wait(inode->i_mapping);
>  	if (err == 0 && fop && (fsync = fop->fsync))
>  		err = fsync(filp, dp, 0);
> -	if (err == 0)
> -		err = filemap_fdatawait(inode->i_mapping);
> -
>  	return err;
>  }
>  
---end quoted text---
