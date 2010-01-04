From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] nfsd: make sure data is on disk before calling
	->fsync
Date: Mon, 4 Jan 2010 15:42:06 -0500
Message-ID: <20100104204206.GD30129@fieldses.org>
References: <20091225164445.GA4578@lst.de> <20100104135045.GA18072@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@zeniv.linux.org.uk, jack@suse.cz, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100104135045.GA18072@lst.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 04, 2010 at 02:50:45PM +0100, Christoph Hellwig wrote:
> ping?  this fixes a quite nasty issue introduced in 2.6.32, so we should
> fix it ASAP (including backport to -stable)

Apologies for the delay.  Which commit exactly introduced the original
regression?  I'll take over getting them into 2.6.33 and 2.6.32.y unless
you tell me you're already doing that.

--b.

> 
> On Fri, Dec 25, 2009 at 05:44:45PM +0100, Christoph Hellwig wrote:
> > nfsd is not using vfs_fsync, so I missed it when changing the calling
> > convention during the 2.6.32 window.  This patch fixes it to not only
> > start the data writeout, but also wait for it to complete before calling
> > into ->fsync.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > Index: linux-2.6/fs/nfsd/vfs.c
> > ===================================================================
> > --- linux-2.6.orig/fs/nfsd/vfs.c	2009-12-25 17:21:32.371024157 +0100
> > +++ linux-2.6/fs/nfsd/vfs.c	2009-12-25 17:31:39.644006085 +0100
> > @@ -780,12 +780,9 @@ static inline int nfsd_dosync(struct fil
> >  	int (*fsync) (struct file *, struct dentry *, int);
> >  	int err;
> >  
> > -	err = filemap_fdatawrite(inode->i_mapping);
> > +	err = filemap_write_and_wait(inode->i_mapping);
> >  	if (err == 0 && fop && (fsync = fop->fsync))
> >  		err = fsync(filp, dp, 0);
> > -	if (err == 0)
> > -		err = filemap_fdatawait(inode->i_mapping);
> > -
> >  	return err;
> >  }
> >  
> ---end quoted text---
