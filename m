Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493Ab3GITij (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 15:38:39 -0400
Date: Tue, 9 Jul 2013 15:38:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 09/12] locks: helper functions for delegation breaking
Message-ID: <20130709193836.GI32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-10-git-send-email-bfields@redhat.com>
 <20130709092310.476b6ca7@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709092310.476b6ca7@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 09:23:10AM -0400, Jeff Layton wrote:
> On Wed,  3 Jul 2013 16:12:33 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > We'll need the same logic for rename and link.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/namei.c         |   13 +++----------
> >  include/linux/fs.h |   33 +++++++++++++++++++++++++++++++--
> >  2 files changed, 34 insertions(+), 12 deletions(-)
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index cba3db1..a9d4031 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -3401,14 +3401,9 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegate
> >  	else {
> >  		error = security_inode_unlink(dir, dentry);
> >  		if (!error) {
> > -			error = break_deleg(target, O_WRONLY|O_NONBLOCK);
> > -			if (error) {
> > -				if (error == -EWOULDBLOCK && delegated_inode) {
> > -					*delegated_inode = target;
> > -					ihold(target);
> > -				}
> > +			error = try_break_deleg(target, delegated_inode);
> > +			if (error)
> >  				goto out;
> > -			}
> >  			error = dir->i_op->unlink(dir, dentry);
> >  			if (!error)
> >  				dont_mount(dentry);
> > @@ -3478,9 +3473,7 @@ exit2:
> >  		iput(inode);	/* truncate the inode here */
> >  	inode = NULL;
> >  	if (delegated_inode) {
> > -		error = break_deleg(delegated_inode, O_WRONLY);
> > -		iput(delegated_inode);
> > -		delegated_inode = NULL;
> > +		error = break_deleg_wait(&delegated_inode);
> >  		if (!error)
> >  			goto retry_deleg;
> >  	}
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index f951588..c37e463 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -1894,6 +1894,9 @@ extern bool our_mnt(struct vfsmount *mnt);
> >  
> >  extern int current_umask(void);
> >  
> > +extern void ihold(struct inode * inode);
> > +extern void iput(struct inode *);
> > +
> >  /* /sys/fs */
> >  extern struct kobject *fs_kobj;
> >  
> > @@ -1962,6 +1965,28 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
> >  	return 0;
> >  }
> >  
> > +static inline int try_break_deleg(struct inode *inode, struct inode **delegated_inode)
> > +{
> > +	int ret;
> > +
> > +	ret = break_deleg(inode, O_WRONLY|O_NONBLOCK);
> > +	if (ret == -EWOULDBLOCK && delegated_inode) {
> > +		*delegated_inode = inode;
> > +		ihold(inode);
> > +	}
> > +	return ret;
> > +}
> > +
> 
> Actually, now that I look...
> 
> Suppose a vfs_unlink caller passes in a NULL delegated_inode pointer.
> He'll get back a -EWOULDBLOCK here if there's a delegation on it.
> Presumably he'll just treat that as a hard error and the delegation
> would never get broken. Is that expected?

Yes.

The callers that pass in NULL are callers who should really never
encounter a write delegation.  E.g. it might happen if you exported a
filesystem that you're also stacking ecryptfs on top of (assuming that's
possible).  Maybe I'm missing something, but that looks pointless.
Erroring out seems a safe way to handle it.

It wouldn't be a problem to convert more of those callers to do the same
retry loop, it just seems better to avoid the extra spaghetti to support
what looks like a nutty use case.

--b.
