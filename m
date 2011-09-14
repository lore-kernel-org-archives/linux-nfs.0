Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:59809 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933184Ab1INUeq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 16:34:46 -0400
Date: Wed, 14 Sep 2011 13:34:41 -0700
From: Simon Kirby <sim@hostway.ca>
To: Lin Ming <mlin@ss.pku.edu.cn>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Fabio Coatti <fabio.coatti@gmail.com>
Subject: Re: [3.1-rc4] vfs_rmdir() -> mutex_unlock() Oops
Message-ID: <20110914203441.GA10169@hostway.ca>
References: <20110908222420.GE8043@hostway.ca> <20110912221700.GA11962@hostway.ca> <20110913164342.GA1039@hostway.ca> <CAF1ivSa3i=4=sdD_ajdQ-fS-ifErFVDrOA1suLZTDG0BZ3TpZg@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAF1ivSa3i=4=sdD_ajdQ-fS-ifErFVDrOA1suLZTDG0BZ3TpZg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 14, 2011 at 09:48:09PM +0800, Lin Ming wrote:

> > ---[ end trace f515ec8376bdb799 ]---
> >
> > How can I further debug this? At this point, it seems to be happening several times daily.
> 
> Fabio reported a similar bug,
> 3.0.3 [BUG] unable to handle kernel NULL pointer dereference
> http://marc.info/?t=131416920900001&r=1&w=2
> 
> Do you have a test case to trigger this bug reliably?

Hello!

Sorry, I didn't realize I took this off list after replying to Linus'
resent mail, but the problem has been tracked down and fixed, and should
show up in Linus' next push.

The problem was introduced by 64252c75a2196a0cf1e0d3777143ecfe0e3ae650,
and Al Viro's patch is reproduced below.

I was able to reproduce the issue reliably with:

ssh <nfs_client> 'cd /mnt/test; mkdir foo; sleep 1; mkdir foo' ; \
ssh <nfs_server> rmdir /export/test/foo ; \
ssh <nfs_client> rmdir /mnt/test/foo

Simon-

>From Al:

[PATCH] restore pinning the victim dentry in vfs_rmdir()/vfs_rename_dir()

We used to get the victim pinned by dentry_unhash() prior to commit
0cf1e0d3777143ecfe0e3ae650 and ->rmdir()/->rename() instances relied on
that; most of them don't care, but ones that used d_delete() themselves
do.  As the result, we are getting rmdir() oopses on NFS now.

Just grab the reference before locking the victim and drop it explicitly
after unlocking, same as vfs_rename_other() does.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/namei.c b/fs/namei.c
index 5422080..22c2d5d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2619,6 +2619,7 @@ int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 	if (!dir->i_op->rmdir)
 		return -EPERM;
 
+	dget(dentry);
 	mutex_lock(&dentry->d_inode->i_mutex);
 
 	error = -EBUSY;
@@ -2639,6 +2640,7 @@ int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 
 out:
 	mutex_unlock(&dentry->d_inode->i_mutex);
+	dput(dentry);
 	if (!error)
 		d_delete(dentry);
 	return error;
@@ -3028,6 +3030,7 @@ static int vfs_rename_dir(struct inode *old_dir, struct dentry *old_dentry,
 	if (error)
 		return error;
 
+	dget(new_dentry);
 	if (target)
 		mutex_lock(&target->i_mutex);
 
@@ -3048,6 +3051,7 @@ static int vfs_rename_dir(struct inode *old_dir, struct dentry *old_dentry,
 out:
 	if (target)
 		mutex_unlock(&target->i_mutex);
+	dput(new_dentry);
 	if (!error)
 		if (!(old_dir->i_sb->s_type->fs_flags & FS_RENAME_DOES_D_MOVE))
 			d_move(old_dentry,new_dentry);
