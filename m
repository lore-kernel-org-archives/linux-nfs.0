Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:56697 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab2IJFLH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2012 01:11:07 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <linuxram@us.ibm.com>;
	Sun, 9 Sep 2012 23:11:06 -0600
Date: Mon, 10 Sep 2012 13:10:37 +0800
From: Ram Pai <linuxram@us.ibm.com>
To: Guo Chao <yan@linux.vnet.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH 05/13] vfs: take i_mutex on renamed file
Message-ID: <20120910051037.GA2466@ram-ThinkPad-T61>
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-6-git-send-email-bfields@redhat.com>
 <20120906030526.GB6679@yanx>
 <20120906175118.GC21736@fieldses.org>
 <20120907022705.GA20453@yanx>
 <20120907213901.GA5927@fieldses.org>
 <20120910024051.GA10405@yanx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120910024051.GA10405@yanx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 10, 2012 at 10:40:51AM +0800, Guo Chao wrote:
> On Fri, Sep 07, 2012 at 05:39:01PM -0400, J. Bruce Fields wrote:
> > On Fri, Sep 07, 2012 at 10:27:05AM +0800, Guo Chao wrote:
> > > On Thu, Sep 06, 2012 at 01:51:18PM -0400, J. Bruce Fields wrote:
> > > > On Thu, Sep 06, 2012 at 11:05:26AM +0800, Guo Chao wrote:
> > > > > On Wed, Sep 05, 2012 at 04:55:15PM -0400, J. Bruce Fields wrote:
> > > > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > > > diff --git a/fs/namei.c b/fs/namei.c
> > > > > > index 1b46439..6156135 100644
> > > > > > --- a/fs/namei.c
> > > > > > +++ b/fs/namei.c
> > > > > > @@ -3658,6 +3658,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> > > > > >  			    struct inode *new_dir, struct dentry *new_dentry)
> > > > > >  {
> > > > > >  	struct inode *target = new_dentry->d_inode;
> > > > > > +	struct inode *source = old_dentry->d_inode;
> > > > > >  	int error;
> > > > > > 
> > > > > >  	error = security_inode_rename(old_dir, old_dentry, new_dir, new_dentry);
> > > > > > @@ -3665,8 +3666,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> > > > > >  		return error;
> > > > > > 
> > > > > >  	dget(new_dentry);
> > > > > > -	if (target)
> > > > > > -		mutex_lock(&target->i_mutex);
> > > > > > +	lock_two_nondirectories(source, target);
> > > > > > 
> > > > > >  	error = -EBUSY;
> > > > > >  	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
> > > > > > @@ -3681,8 +3681,7 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
> > > > > >  	if (!(old_dir->i_sb->s_type->fs_flags & FS_RENAME_DOES_D_MOVE))
> > > > > >  		d_move(old_dentry, new_dentry);
> > > > > >  out:
> > > > > > -	if (target)
> > > > > > -		mutex_unlock(&target->i_mutex);
> > > > > > +	unlock_two_nondirectories(source, target);
> > > > > >  	dput(new_dentry);
> > > > > >  	return error;
> > > > > >  }
> > > > > >
> > > > > 
> > > > > This change also fixes a race between rename and mount.
> > > > > 
> > > > > Apparently we avoid to rename source or target if they are
> > > > > mountpoint. But nothing prevents source being the mountpoint 
> > > > > after d_mountpoint check because we do not hold its i_mutex.
> > > > > 
> > > > > Thus we are actually able to rename a mountpoint.
> > > > > 
> > > > > Rename directory should also need this care.
> > > > 
> > > > Do you have any practical way to reproduce that race?
> > > > 
> > > > --b.
> > > 
> > > Rename a mountpoint? Of course.
> > > 
> > > One script ...
> > > 
> > > #!/bin/bash
> > > while true
> > > do
> > > 	mount -t sysfs nodev mnt && umount mnt
> > > done
> > > 
> > > 
> > > 
> > > The other ...
> > > 
> > > #!/bin/bash
> > > while true
> > > do
> > > 	mv mnt mnt2 && mv mnt2 mnt
> > > done
> > > 
> > > 
> > > 
> > > Run them simultaneously in two consoles. When mount keeps reporting 
> > > 'mount point mnt does not exist', stop them, then you will see the 
> > > familiar sysfs under mnt2.
> > 
> > Oh, thanks, for some reason I assumed it would be more difficult to
> > reproduce.
> > 
> > I think we can do this--I don't think it even requires any care to the
> > locking order of the renamed vs the victim directory, though I can't
> > completely convince myself of that.
> > 
> > Is it necessary to fix this, though?  Does it cause any problems other
> > than unexpected behavior?
> > 
> > --b.
> > --
> 
> Hard to say whether it's a bug or what's problems of being able to rename 
> mountpoint.

'man 2 rename' says it is ok to rename a directory that is already
mounted.

EBUSY The rename fails because oldpath or newpath is a directory that is
in use by some process (perhaps as current working directory, or as root
directory, or beacuse it was open for reading) or is in use by the
system (for example as mount point), while the system considers this an
error. (Note that there is no requirement to return EBUSY in such
cases-- there is nothing wrong with doing the rename anyway -- but is
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
allowed to return EBUSY if the system cannot otherwise handle such
situations)

RP

