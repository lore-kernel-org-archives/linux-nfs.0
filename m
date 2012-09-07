Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46926 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101Ab2IGVjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Sep 2012 17:39:06 -0400
Date: Fri, 7 Sep 2012 17:39:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Guo Chao <yan@linux.vnet.ibm.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH 05/13] vfs: take i_mutex on renamed file
Message-ID: <20120907213901.GA5927@fieldses.org>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-6-git-send-email-bfields@redhat.com>
 <20120906030526.GB6679@yanx>
 <20120906175118.GC21736@fieldses.org>
 <20120907022705.GA20453@yanx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120907022705.GA20453@yanx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 07, 2012 at 10:27:05AM +0800, Guo Chao wrote:
> On Thu, Sep 06, 2012 at 01:51:18PM -0400, J. Bruce Fields wrote:
> > On Thu, Sep 06, 2012 at 11:05:26AM +0800, Guo Chao wrote:
> > > On Wed, Sep 05, 2012 at 04:55:15PM -0400, J. Bruce Fields wrote:
> > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > diff --git a/fs/namei.c b/fs/namei.c
> > > > index 1b46439..6156135 100644
> > > > --- a/fs/namei.c
> > > > +++ b/fs/namei.c
> > > > @@ -3658,6 +3658,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> > > >  			    struct inode *new_dir, struct dentry *new_dentry)
> > > >  {
> > > >  	struct inode *target = new_dentry->d_inode;
> > > > +	struct inode *source = old_dentry->d_inode;
> > > >  	int error;
> > > > 
> > > >  	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
> > > > @@ -3665,8 +3666,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> > > >  		return error;
> > > > 
> > > >  	dget(new_dentry);
> > > > -	if (target)
> > > > -		mutex_lock(&target->i_mutex);
> > > > +	lock_two_nondirectories(source, target);
> > > > 
> > > >  	error = -EBUSY;
> > > >  	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
> > > > @@ -3681,8 +3681,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> > > >  	if (!(old_dir->i_sb->s_type->fs_flags & FS_RENAME_DOES_D_MOVE))
> > > >  		d_move(old_dentry, new_dentry);
> > > >  out:
> > > > -	if (target)
> > > > -		mutex_unlock(&target->i_mutex);
> > > > +	unlock_two_nondirectories(source, target);
> > > >  	dput(new_dentry);
> > > >  	return error;
> > > >  }
> > > >
> > > 
> > > This change also fixes a race between rename and mount.
> > > 
> > > Apparently we avoid to rename source or target if they are
> > > mountpoint. But nothing prevents source being the mountpoint 
> > > after d_mountpoint check because we do not hold its i_mutex.
> > > 
> > > Thus we are actually able to rename a mountpoint.
> > > 
> > > Rename directory should also need this care.
> > 
> > Do you have any practical way to reproduce that race?
> > 
> > --b.
> 
> Rename a mountpoint? Of course.
> 
> One script ...
> 
> #!/bin/bash
> while true
> do
> 	mount -t sysfs nodev mnt && umount mnt
> done
> 
> 
> 
> The other ...
> 
> #!/bin/bash
> while true
> do
> 	mv mnt mnt2 && mv mnt2 mnt
> done
> 
> 
> 
> Run them simultaneously in two consoles. When mount keeps reporting 
> 'mount point mnt does not exist', stop them, then you will see the 
> familiar sysfs under mnt2.

Oh, thanks, for some reason I assumed it would be more difficult to
reproduce.

I think we can do this--I don't think it even requires any care to the
locking order of the renamed vs the victim directory, though I can't
completely convince myself of that.

Is it necessary to fix this, though?  Does it cause any problems other
than unexpected behavior?

--b.
