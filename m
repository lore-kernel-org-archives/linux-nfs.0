Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557Ab3GIUle (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 16:41:34 -0400
Date: Tue, 9 Jul 2013 16:41:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [PATCH 11/12] locks: break delegations on link
Message-ID: <20130709204130.GJ32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-12-git-send-email-bfields@redhat.com>
 <20130709091617.1c175da4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130709091617.1c175da4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 09, 2013 at 09:16:17AM -0400, Jeff Layton wrote:
> On Wed,  3 Jul 2013 16:12:35 -0400
> "J. Bruce Fields" <bfields@redhat.com> wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Cc: Tyler Hicks <tyhicks@canonical.com>
> > Cc: Dustin Kirkland <dustin.kirkland@gazzang.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/ecryptfs/inode.c |    2 +-
> >  fs/namei.c          |   17 +++++++++++++----
> >  fs/nfsd/vfs.c       |    2 +-
> >  include/linux/fs.h  |    2 +-
> >  4 files changed, 16 insertions(+), 7 deletions(-)
> > 
> > diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
> > index af42d88..19e4435 100644
> > --- a/fs/ecryptfs/inode.c
> > +++ b/fs/ecryptfs/inode.c
> > @@ -475,7 +475,7 @@ static int ecryptfs_link(struct dentry *old_dentry, struct inode *dir,
> >  	dget(lower_new_dentry);
> >  	lower_dir_dentry = lock_parent(lower_new_dentry);
> >  	rc = vfs_link(lower_old_dentry, lower_dir_dentry->d_inode,
> > -		      lower_new_dentry);
> > +		      lower_new_dentry, NULL);
> >  	if (rc || !lower_new_dentry->d_inode)
> >  		goto out_lock;
> >  	rc = ecryptfs_interpose(lower_new_dentry, new_dentry, dir->i_sb);
> > diff --git a/fs/namei.c b/fs/namei.c
> > index be00d37..18267e0 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -3566,7 +3566,7 @@ SYSCALL_DEFINE2(symlink, const char __user *, oldname, const char __user *, newn
> >  	return sys_symlinkat(oldname, AT_FDCWD, newname);
> >  }
> >  
> > -int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry)
> > +int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_dentry, struct inode **delegated_inode)
> 
> A kerneldoc comment would be nice here. Ditto for vfs_rename* in the
> previous patch...

OK, done locally, using modified versions of the comment for unlink.
I'll resend the series soon.

--b.
