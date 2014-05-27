Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48152 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbaE0QAp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2014 12:00:45 -0400
Date: Tue, 27 May 2014 09:00:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: commit layouts in fdatasync
Message-ID: <20140527160044.GA17587@infradead.org>
References: <20140421172917.GA20036@infradead.org>
 <20140505065624.GA32658@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140505065624.GA32658@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 04, 2014 at 11:56:24PM -0700, Christoph Hellwig wrote:
> ping?  This is a fairly serious data integrity issue for pnfs users.

ping^2

without this fdatasync and O_DSYNC writes on pnfs are more or less
noops, so at least getting a review would be helpful, nevermind
forwarding it to Linus and -stable.

> 
> On Mon, Apr 21, 2014 at 10:29:17AM -0700, Christoph Hellwig wrote:
> > >From fdatasync(2):
> > 
> >  "fdatasync() is similar to fsync(), but does not flush modified metadata
> >   unless that metadata is needed in order  to  allow  a  subsequent  data
> >   retrieval to be correctly handled."
> > 
> > We absolutely need to commit the layouts to be able to retrieve the data
> > in case either the client, the server or the storage subsystem go down.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 8de3407..464db9d 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -100,8 +100,7 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
> >  			break;
> >  		mutex_lock(&inode->i_mutex);
> >  		ret = nfs_file_fsync_commit(file, start, end, datasync);
> > -		if (!ret && !datasync)
> > -			/* application has asked for meta-data sync */
> > +		if (!ret)
> >  			ret = pnfs_layoutcommit_inode(inode, true);
> >  		mutex_unlock(&inode->i_mutex);
> >  		/*
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> ---end quoted text---
---end quoted text---
