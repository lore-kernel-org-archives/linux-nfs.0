Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803Ab3GIO0x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 10:26:53 -0400
Date: Tue, 9 Jul 2013 10:26:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 03/12] vfs: rename I_MUTEX_QUOTA now that it's not used
 for quotas
Message-ID: <20130709142652.GA32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-4-git-send-email-bfields@redhat.com>
 <20130709065400.5a55a655@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709065400.5a55a655@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 06:54:00AM -0400, Jeff Layton wrote:
> On Wed,  3 Jul 2013 16:12:27 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > I_MUTEX_QUOTA is now just being used whenever we want to lock two
> > non-directories.  So the name isn't right.  I_MUTEX_NONDIR2 isn't
> > especially elegant but it's the best I could think of.
> > 
> > Also fix some outdated documentation.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/inode.c         |    4 ++--
> >  include/linux/fs.h |    9 ++++++---
> >  2 files changed, 8 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/inode.c b/fs/inode.c
> > index 942451b..304db4c 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -988,10 +988,10 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
> >  {
> >  	if (inode1 < inode2) {
> >  		mutex_lock(&inode1->i_mutex);
> > -		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_QUOTA);
> > +		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_NONDIR2);
> >  	} else {
> >  		mutex_lock(&inode2->i_mutex);
> > -		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_QUOTA);
> > +		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_NONDIR2);
> >  	}
> >  }
> >  EXPORT_SYMBOL(lock_two_nondirectories);
> > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > index 3258761..ec88235 100644
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -620,10 +620,13 @@ static inline int inode_unhashed(struct inode *inode)
> >   * 0: the object of the current VFS operation
> >   * 1: parent
> >   * 2: child/target
> > - * 3: quota file
> > + * 3: xattr
> > + * 4: second non-directory
> > + * The last is for certain operations (such as rename) which lock two
> > + * non-directories at once.
> >   *
> >   * The locking order between these classes is
> > - * parent -> child -> normal -> xattr -> quota
> > + * parent -> child -> normal -> xattr -> second non-directory
> >   */
> >  enum inode_i_mutex_lock_class
> >  {
> > @@ -631,7 +634,7 @@ enum inode_i_mutex_lock_class
> >  	I_MUTEX_PARENT,
> >  	I_MUTEX_CHILD,
> >  	I_MUTEX_XATTR,
> > -	I_MUTEX_QUOTA
> > +	I_MUTEX_NONDIR2
> >  };
> >  
> >  void lock_two_nondirectories(struct inode *, struct inode*);
> 
> Ugly name, but I'm not sure what to call it either. Wonder if it would
> make sense to do some sort of SOURCE/TARGET lock class and rearrange
> the code to take that into account?

You need to order the locks globally somehow (e.g. by ancestor order in
the case of the parent directories)--you can't always take them in the
order source and target, for example, because a rename from A/ into B/
could then deadlock with a simultaneous rename from B/ into A/.  So I
don't think SOURCE and TARGET would work for names.  The current names
have a certain logic, but there's probably something more elegant.

Currently: after these patches a rename of regular a regular file onto
another regular file will take locks on the source and target parents,
and source and target (victim) files.  The first two will take PARENT
and CHILD, the second NORMAL and NONDIR2.

--b.

> But, that's just bikeshedding, so...
> 
> Acked-by: Jeff Layton <jlayton@redhat.com>
