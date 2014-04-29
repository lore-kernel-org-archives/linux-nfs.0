Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:5656 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752002AbaD2AF6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 20:05:58 -0400
Date: Tue, 29 Apr 2014 10:04:02 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 05/22] vfs: Add new file and directory create
 permission flags
Message-ID: <20140429000402.GO15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1398615293-22931-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20140428072301.123674d4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140428072301.123674d4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 28, 2014 at 07:23:01AM -0400, Jeff Layton wrote:
> On Sun, 27 Apr 2014 21:44:36 +0530
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > From: Andreas Gruenbacher <agruen@kernel.org>
> > 
> > Some permission models distinguish between the permission to create a
> > non-directory and a directory.  Pass this information down to
> > inode_permission() as mask flags
> > 
> > Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > ---
> >  fs/namei.c         | 21 ++++++++++++---------
> >  include/linux/fs.h |  2 ++
> >  2 files changed, 14 insertions(+), 9 deletions(-)
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 7d93d195f0e5..028bc8bcf77c 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -445,7 +445,8 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
> >   * this, letting us set arbitrary permissions for filesystem access without
> >   * changing the "normal" UIDs which are used for other things.
> >   *
> > - * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
> > + * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> > + * MAY_WRITE must also be set in @mask.
> >   */
> >  int inode_permission(struct inode *inode, int mask)
> >  {
> > @@ -2444,14 +2445,16 @@ static int may_delete(struct inode *dir, struct dentry *victim, bool isdir)
> >   *  3. We should have write and exec permissions on dir
> >   *  4. We can't do it if dir is immutable (done in permission())
> >   */
> > -static inline int may_create(struct inode *dir, struct dentry *child)
> > +static inline int may_create(struct inode *dir, struct dentry *child, bool isdir)
> >  {
> > +	int mask = isdir ? MAY_CREATE_DIR : MAY_CREATE_FILE;
> > +
> >  	audit_inode_child(dir, child, AUDIT_TYPE_CHILD_CREATE);
> >  	if (child->d_inode)
> >  		return -EEXIST;
> >  	if (IS_DEADDIR(dir))
> >  		return -ENOENT;
> > -	return inode_permission(dir, MAY_WRITE | MAY_EXEC);
> > +	return inode_permission(dir, MAY_WRITE | MAY_EXEC | mask);
> >  }
> >  
> >  /*
> > @@ -2501,7 +2504,7 @@ EXPORT_SYMBOL(unlock_rename);
> >  int vfs_create(struct inode *dir, struct dentry *dentry, umode_t mode,
> >  		bool want_excl)
> >  {
> > -	int error = may_create(dir, dentry);
> > +	int error = may_create(dir, dentry, 0);
> 
> nit: since the third argument here is a bool, this should be "false"
> and not "0". Ditto for all of the other calls of may_create.

IMO, the third argument should be MAY_CREATE_FILE or MAY_CREATE_DIR,
which is what the boolean evaluates to in may_create()....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
