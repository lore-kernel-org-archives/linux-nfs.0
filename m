Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48655 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab1IHXVO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 19:21:14 -0400
Date: Thu, 8 Sep 2011 16:07:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self
 permission flags
Message-ID: <20110908200754.GB17215@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20110907203916.GE8074@fieldses.org>
 <87ipp35qjx.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87ipp35qjx.fsf@skywalker.in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 08, 2011 at 03:00:58PM +0530, Aneesh Kumar K.V wrote:
> On Wed, 7 Sep 2011 16:39:16 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Mon, Sep 05, 2011 at 10:55:31PM +0530, Aneesh Kumar K.V wrote:
> > > From: Andreas Gruenbacher <agruen@kernel.org>
> > > 
> > > Normally, deleting a file requires write access to the parent directory.
> > > Some permission models use a different permission on the parent
> > > directory to indicate delete access.  In addition, a process can have
> > > per-file delete access even without delete access on the parent
> > > directory.
> > > 
> > > Introduce two new inode_permission() mask flags and use them in
> > > may_delete()
> > > 
> > > Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> > > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > > ---
> > >  fs/namei.c         |   41 +++++++++++++++++++++++++++--------------
> > >  include/linux/fs.h |    2 ++
> > >  2 files changed, 29 insertions(+), 14 deletions(-)
> > > 
> > > diff --git a/fs/namei.c b/fs/namei.c
> > > index d52a4cd..eacb530 100644
> > > --- a/fs/namei.c
> > > +++ b/fs/namei.c
> > > @@ -337,7 +337,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
> > >   * are used for other things.
> > >   *
> > >   * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> > > - * MAY_WRITE must also be set in @mask.
> > > + * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
> > >   */
> > >  int inode_permission(struct inode *inode, int mask)
> > >  {
> > > @@ -1862,7 +1862,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
> > >  		return 0;
> > >  
> > >  other_userns:
> > > -	return !ns_capable(inode_userns(inode), CAP_FOWNER);
> > > +	return 1;
> > >  }
> > >  
> > >  /*
> > > @@ -1884,30 +1884,43 @@ other_userns:
> > >   * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
> > >   *     nfs_async_unlink().
> > >   */
> > > -static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> > > +static int may_delete(struct inode *dir, struct dentry *victim,
> > > +		      int isdir, int replace)
> > >  {
> > > -	int error;
> > > +	int mask, error, is_sticky;
> > > +	struct inode *inode = victim->d_inode;
> > >  
> > > -	if (!victim->d_inode)
> > > +	if (!inode)
> > >  		return -ENOENT;
> > >  
> > >  	BUG_ON(victim->d_parent->d_inode != dir);
> > >  	audit_inode_child(victim, dir);
> > >  
> > > -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> > > +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> > > +	if (replace)
> > > +		mask |= S_ISDIR(inode->i_mode) ?
> > > +			MAY_CREATE_DIR : MAY_CREATE_FILE;
> > 
> > I'm having trouble understanding this next bit:
> > 
> > > +	is_sticky = check_sticky(dir, inode);
> > > +	error = inode_permission(dir, mask);
> > > +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> > > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> > > +	    !inode_permission(inode, MAY_DELETE_SELF))
> > > +		error = 0;
> > 
> > OK, so we can ignore the lack of write or delete permissions on the
> > parent if we have delete_self permissions on the child.  I guess that's
> > right.
> > 
> > Why the "|| is_sticky" above?
> > 
> > Is there some less complicated why to write this?
> 
> we removed the ns_capable check out of check_sticky, because we don't
> want to do capability check when richacl allows access. We also want to
> make sure that even if mode bits allow access (inode_permission(dir, mask))
> if sticky bit is set we do additional check.

Why are the two inode_permissions ANDed?  The windows semantics are that
you can delete if you have MAY_DELETE_CHILD *or* MAY_DELETE_SELF.

--b.
