Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42726 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932493Ab1IHJbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 05:31:08 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self permission flags
In-Reply-To: <20110907203916.GE8074@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110907203916.GE8074@fieldses.org>
Date: Thu, 08 Sep 2011 15:00:58 +0530
Message-ID: <87ipp35qjx.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 7 Sep 2011 16:39:16 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Sep 05, 2011 at 10:55:31PM +0530, Aneesh Kumar K.V wrote:
> > From: Andreas Gruenbacher <agruen@kernel.org>
> > 
> > Normally, deleting a file requires write access to the parent directory.
> > Some permission models use a different permission on the parent
> > directory to indicate delete access.  In addition, a process can have
> > per-file delete access even without delete access on the parent
> > directory.
> > 
> > Introduce two new inode_permission() mask flags and use them in
> > may_delete()
> > 
> > Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  fs/namei.c         |   41 +++++++++++++++++++++++++++--------------
> >  include/linux/fs.h |    2 ++
> >  2 files changed, 29 insertions(+), 14 deletions(-)
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index d52a4cd..eacb530 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -337,7 +337,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
> >   * are used for other things.
> >   *
> >   * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> > - * MAY_WRITE must also be set in @mask.
> > + * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
> >   */
> >  int inode_permission(struct inode *inode, int mask)
> >  {
> > @@ -1862,7 +1862,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
> >  		return 0;
> >  
> >  other_userns:
> > -	return !ns_capable(inode_userns(inode), CAP_FOWNER);
> > +	return 1;
> >  }
> >  
> >  /*
> > @@ -1884,30 +1884,43 @@ other_userns:
> >   * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
> >   *     nfs_async_unlink().
> >   */
> > -static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> > +static int may_delete(struct inode *dir, struct dentry *victim,
> > +		      int isdir, int replace)
> >  {
> > -	int error;
> > +	int mask, error, is_sticky;
> > +	struct inode *inode = victim->d_inode;
> >  
> > -	if (!victim->d_inode)
> > +	if (!inode)
> >  		return -ENOENT;
> >  
> >  	BUG_ON(victim->d_parent->d_inode != dir);
> >  	audit_inode_child(victim, dir);
> >  
> > -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> > +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> > +	if (replace)
> > +		mask |= S_ISDIR(inode->i_mode) ?
> > +			MAY_CREATE_DIR : MAY_CREATE_FILE;
> 
> I'm having trouble understanding this next bit:
> 
> > +	is_sticky = check_sticky(dir, inode);
> > +	error = inode_permission(dir, mask);
> > +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> > +	    !inode_permission(inode, MAY_DELETE_SELF))
> > +		error = 0;
> 
> OK, so we can ignore the lack of write or delete permissions on the
> parent if we have delete_self permissions on the child.  I guess that's
> right.
> 
> Why the "|| is_sticky" above?
> 
> Is there some less complicated why to write this?

we removed the ns_capable check out of check_sticky, because we don't
want to do capability check when richacl allows access. We also want to
make sure that even if mode bits allow access (inode_permission(dir, mask))
if sticky bit is set we do additional check.


-aneesh
