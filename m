Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49682 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811Ab1J1Iqb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 04:46:31 -0400
Date: Fri, 28 Oct 2011 04:46:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/6] leases: fix write-open/read-lease race
Message-ID: <20111028084627.GC2010@fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-3-git-send-email-bfields@redhat.com>
 <20111010215911.GC17936@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111010215911.GC17936@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 10, 2011 at 05:59:11PM -0400, bfields wrote:
> On Wed, Sep 21, 2011 at 10:58:13AM -0400, J. Bruce Fields wrote:
> > In setlease, we use i_writecount to decide whether we can give out a
> > read lease.
> > 
> > In open, we break leases before incrementing i_writecount.
> > 
> > There is therefore a window between the break lease and the i_writecount
> > increment when setlease could add a new read lease.
> > 
> > This would leave us with a simultaneous write open and read lease, which
> > shouldn't happen.
> 
> Al, could you apply this for 3.2, if you don't see any problem?

Ping?  What should I do with this patch?

--b.

> 
> (Patch 1 of this series only touches locks.c, and I'm queueing up such
> patches through the nfsd tree.  Patches 3-6 I intend to rewrite,
> probably not in time for 3.2 unless I'm very lucky.)
> 
> --b.
> 
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/namei.c |    5 +----
> >  fs/open.c  |    4 ++++
> >  2 files changed, 5 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 2826db3..6ff59e5 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -2044,10 +2044,7 @@ static int may_open(struct path *path, int acc_mode, int flag)
> >  	if (flag & O_NOATIME && !inode_owner_or_capable(inode))
> >  		return -EPERM;
> >  
> > -	/*
> > -	 * Ensure there are no outstanding leases on the file.
> > -	 */
> > -	return break_lease(inode, flag);
> > +	return 0;
> >  }
> >  
> >  static int handle_truncate(struct file *filp)
> > diff --git a/fs/open.c b/fs/open.c
> > index f711921..22c41b5 100644
> > --- a/fs/open.c
> > +++ b/fs/open.c
> > @@ -685,6 +685,10 @@ static struct file *__dentry_open(struct dentry *dentry, struct vfsmount *mnt,
> >  	if (error)
> >  		goto cleanup_all;
> >  
> > +	error = break_lease(inode, f->f_flags);
> > +	if (error)
> > +		goto cleanup_all;
> > +
> >  	if (!open && f->f_op)
> >  		open = f->f_op->open;
> >  	if (open) {
> > -- 
> > 1.7.4.1
> > 
