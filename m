Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48658 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567Ab1IHXVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 19:21:17 -0400
Date: Thu, 8 Sep 2011 18:02:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 09/26] vfs: Add delete child and delete self
 permission flags
Message-ID: <20110908220246.GD17215@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1315243548-18664-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20110907203916.GE8074@fieldses.org>
 <87ipp35qjx.fsf@skywalker.in.ibm.com>
 <20110908200754.GB17215@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110908200754.GB17215@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 08, 2011 at 04:07:54PM -0400, J. Bruce Fields wrote:
> On Thu, Sep 08, 2011 at 03:00:58PM +0530, Aneesh Kumar K.V wrote:
> > On Wed, 7 Sep 2011 16:39:16 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > On Mon, Sep 05, 2011 at 10:55:31PM +0530, Aneesh Kumar K.V wrote:
> > > > +static int may_delete(struct inode *dir, struct dentry *victim,
> > > > +		      int isdir, int replace)
> > > >  {
> > > > -	int error;
> > > > +	int mask, error, is_sticky;
> > > > +	struct inode *inode = victim->d_inode;
> > > >  
> > > > -	if (!victim->d_inode)
> > > > +	if (!inode)
> > > >  		return -ENOENT;
> > > >  
> > > >  	BUG_ON(victim->d_parent->d_inode != dir);
> > > >  	audit_inode_child(victim, dir);
> > > >  
> > > > -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> > > > +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> > > > +	if (replace)
> > > > +		mask |= S_ISDIR(inode->i_mode) ?
> > > > +			MAY_CREATE_DIR : MAY_CREATE_FILE;
> > > 
> > > I'm having trouble understanding this next bit:
> > > 
> > > > +	is_sticky = check_sticky(dir, inode);
> > > > +	error = inode_permission(dir, mask);
> > > > +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> > > > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&
> > > > +	    !inode_permission(inode, MAY_DELETE_SELF))
> > > > +		error = 0;
> > > 
> > > OK, so we can ignore the lack of write or delete permissions on the
> > > parent if we have delete_self permissions on the child.  I guess that's
> > > right.
> > > 
> > > Why the "|| is_sticky" above?
> > > 
> > > Is there some less complicated why to write this?
> > 
> > we removed the ns_capable check out of check_sticky, because we don't
> > want to do capability check when richacl allows access. We also want to
> > make sure that even if mode bits allow access (inode_permission(dir, mask))
> > if sticky bit is set we do additional check.
> 
> Why are the two inode_permissions ANDed?  The windows semantics are that
> you can delete if you have MAY_DELETE_CHILD *or* MAY_DELETE_SELF.

Either way, those conditions are just really hard to follow.  Could you
simplify the logic, add comments, maybe move the richacl stuff into a
little helper function?

Also, a nit:

> > > > +	    !inode_permission(dir, mask & ~(MAY_WRITE | MAY_DELETE_CHILD)) &&

The way you calculated mask above it always includes MAY_WRITE and
MAY_DELETE_CHILD, so the above is equivalent to just

		    !inode_permission(dir, MAY_WRITE | MAY_DELETE_CHILD) &&

isn't it?

--b.
