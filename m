Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:42808 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754578Ab1IIF0Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 01:26:24 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 9 Sep 2011 01:26:23 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self permission flags
In-Reply-To: <87r53q47jc.fsf@skywalker.in.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20110907203916.GE8074@fieldses.org> <87ipp35qjx.fsf@skywalker.in.ibm.com> <20110908200754.GB17215@fieldses.org> <20110908220246.GD17215@fieldses.org> <87r53q47jc.fsf@skywalker.in.ibm.com>
Date: Fri, 09 Sep 2011 10:55:29 +0530
Message-ID: <87obyu4792.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 09 Sep 2011 10:49:19 +0530, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> On Thu, 8 Sep 2011 18:02:46 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Thu, Sep 08, 2011 at 04:07:54PM -0400, J. Bruce Fields wrote:
> > > On Thu, Sep 08, 2011 at 03:00:58PM +0530, Aneesh Kumar K.V wrote:
> > > > On Wed, 7 Sep 2011 16:39:16 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > > On Mon, Sep 05, 2011 at 10:55:31PM +0530, Aneesh Kumar K.V wrote:
> > > > > > +static int may_delete(struct inode *dir, struct dentry *victim,
> > > > > > +		      int isdir, int replace)
> > > > > >  {
> > > > > > -	int error;
> > > > > > +	int mask, error, is_sticky;
> > > > > > +	struct inode *inode = victim->d_inode;
> > > > > >  
> > > > > > -	if (!victim->d_inode)
> > > > > > +	if (!inode)
> > > > > >  		return -ENOENT;
> > > > > >  
> > > > > >  	BUG_ON(victim->d_parent->d_inode != dir);
> > > > > >  	audit_inode_child(victim, dir);
> > > > > >  
> > > > > > -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> > > > > > +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> > > > > > +	if (replace)
> > > > > > +		mask |= S_ISDIR(inode->i_mode) ?
> > > > > > +			MAY_CREATE_DIR : MAY_CREATE_FILE;
> > > > > 
> > > > > I'm having trouble understanding this next bit:
> > > > > 
> > > > > > +	is_sticky = check_sticky(dir, inode);
> > > > > > +	error = inode_permission(dir, mask);
> > > > > > +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> > > > > > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> > > > > > +	    !inode_permission(inode, MAY_DELETE_SELF))
> > > > > > +		error = 0;
> > > > > 
> > > > > OK, so we can ignore the lack of write or delete permissions on the
> > > > > parent if we have delete_self permissions on the child.  I guess that's
> > > > > right.
> > > > > 
> > > > > Why the "|| is_sticky" above?
> > > > > 
> > > > > Is there some less complicated why to write this?
> > > > 
> > > > we removed the ns_capable check out of check_sticky, because we don't
> > > > want to do capability check when richacl allows access. We also want to
> > > > make sure that even if mode bits allow access (inode_permission(dir, mask))
> > > > if sticky bit is set we do additional check.
> > > 
> > > Why are the two inode_permissions ANDed?  The windows semantics are that
> > > you can delete if you have MAY_DELETE_CHILD *or* MAY_DELETE_SELF.
> > 
> > Either way, those conditions are just really hard to follow.  Could you
> > simplify the logic, add comments, maybe move the richacl stuff into a
> > little helper function?
> > 
> > Also, a nit:
> > 
> > > > > > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> > 
> > The way you calculated mask above it always includes MAY_WRITE and
> > MAY_DELETE_CHILD, so the above is equivalent to just
> > 
> > 		    !inode_permission(dir, MAY_WRITE | MAY_DELETE_CHILD) &&
> > 
> > isn't it?
> > 
> 
> I guess i can simplify it as 
>   !inode_permission(dir, MAY_EXEC | replace_mask)
>   

diff --git a/fs/namei.c b/fs/namei.c
index 1054bc3..e545c81 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1912,8 +1912,9 @@ other_userns:
 static int may_delete(struct inode *dir, struct dentry *victim,
 		      int isdir, int replace)
 {
-	int mask, error, is_sticky;
 	struct inode *inode = victim->d_inode;
+	int mask, replace_mask = 0, error, is_sticky;
+
 
 	if (!inode)
 		return -ENOENT;
@@ -1923,12 +1924,12 @@ static int may_delete(struct inode *dir, struct dentry *victim,
 
 	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
 	if (replace)
-		mask |= S_ISDIR(inode->i_mode) ?
-			MAY_CREATE_DIR : MAY_CREATE_FILE;
+		replace_mask = S_ISDIR(inode->i_mode) ?
+				MAY_CREATE_DIR : MAY_CREATE_FILE;
 	is_sticky = check_sticky(dir, inode);
-	error = inode_permission(dir, mask);
+	error = inode_permission(dir, mask | replace_mask);
 	if ((error || is_sticky) && IS_RICHACL(inode) &&
-	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
+	    !inode_permission(dir, MAY_EXEC | replace_mask) &&
 	    !inode_permission(inode, MAY_DELETE_SELF))
 		error = 0;
 	else if (!error && is_sticky &&

