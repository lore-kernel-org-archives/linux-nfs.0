Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46768 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754069AbdBITda (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 14:33:30 -0500
Date: Thu, 9 Feb 2017 14:32:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: restore owner override for truncate
Message-ID: <20170209193210.GB32200@fieldses.org>
References: <20170209142238.5322-1-hch@lst.de>
 <20170209160131.GE17622@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170209160131.GE17622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 09, 2017 at 11:01:31AM -0500, J. Bruce Fields wrote:
> On Thu, Feb 09, 2017 at 03:22:38PM +0100, Christoph Hellwig wrote:
> > The switch to vfs_truncate in nfsd_setattr dropped the owner override
> > used for NFS permissions.  Add a copy of vfs_truncate with it restored
> > to the nfsd code for now as it's very late in the cycle, but there
> > should be a way to consolidate it back in the future.
> 
> This also needs:
> 
> 
> diff --git a/fs/open.c b/fs/open.c
> index 9921f70bc5ca..5d8126b230d9 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -64,6 +64,7 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
>  	inode_unlock(dentry->d_inode);
>  	return ret;
>  }
> +EXPORT_SYMBOL_GPL(do_truncate);
>  
>  long vfs_truncate(const struct path *path, loff_t length)
>  {

Also there's still a warning about a nested mnt_want_write when called
from nfsd4_setattr.

Probably not hard to fix.

But at this point I'd like to revert the original 4af53350 "nfsd:
special case truncates some more".  It fixed a real bug (incorrect
handling of setattrs with both mode and file size), but a bug we've had
for a long time.  It can wait another week or two for us to get this all
right.

--b.
