Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:56005 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550Ab1IVRWb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 13:22:31 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <zohar@linux.vnet.ibm.com>;
	Thu, 22 Sep 2011 13:17:34 -0400
Subject: Re: [PATCH 2/6] leases: fix write-open/read-lease race
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>
In-Reply-To: <20110921150157.GA21510@fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
	 <1316617097-21384-3-git-send-email-bfields@redhat.com>
	 <20110921150157.GA21510@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Sep 2011 13:17:12 -0400
Message-ID: <1316711832.3159.53.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-09-21 at 11:01 -0400, J. Bruce Fields wrote: 
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
> And maybe someone that knows the open code better than me could confirm
> whether it's reasonable to move the break_lease() call to __dentry_open
> like this....
> 
> --b.

Moving break_lease() from may_open() to __dentry_open(), places the call
immediately after the call to __get_file_write_access(), which
increments i_writecount.

Currently, break_lease() is being called before the transition from
put_filp() to fput(). The move doesn't change this, so I would assume it
should be ok.

Mimi

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




