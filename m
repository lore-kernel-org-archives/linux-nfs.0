Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38487 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006Ab3JBPnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 11:43:49 -0400
Date: Wed, 2 Oct 2013 11:43:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20131002154320.GE14808@fieldses.org>
References: <20130912160324.GE1462@fieldses.org>
 <20130912193328.GP13318@ZenIV.linux.org.uk>
 <20130929115454.GA3953@infradead.org>
 <20131002142527.GD14808@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002142527.GD14808@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 10:25:27AM -0400, J. Bruce Fields wrote:
> On Sun, Sep 29, 2013 at 04:54:54AM -0700, Christoph Hellwig wrote:
> > On Thu, Sep 12, 2013 at 08:33:28PM +0100, Al Viro wrote:
> > > i_ino use is entirely up to filesystem; it may be used by library helpers,
> > > provided that the choice of using or not using those is, again, up to
> > > filesystem in question.
> > 
> > With more and more filesystems using large inode numbers I'm starting to
> > wonder if this still makes sense.  But given that it's been this way for
> > a long time we should have more documentation of it for sure.
> > 
> > > NFSD has no damn business looking at it; library
> > > helpers in fs/exportfs might, but that makes them not suitable for use
> > > by filesystems without inode numbers or with 64bit ones.
> > > 
> > > The reason why it's there at all is that it serves as convenient icache
> > > search key for many filesystems.  IOW, it's used by iget_locked() and
> > > avoiding the overhead of 64bit comparisons on 32bit hosts is the main
> > > reason to avoid making it u64.
> > > 
> > > Again, no fs-independent code has any business looking at it, 64bit or
> > > not.  From the VFS point of view there is no such thing as inode number.
> > > And get_name() is just a library helper.  For many fs types it works
> > > as suitable ->s_export_op->get_name() instance, but decision to use it
> > > or not belongs to filesystem in question and frankly, it's probably better
> > > to provide an instance of your own anyway.
> > 
> > Given that these days most exportable filesystems use 64-bit inode
> > numbers I think we should put the patch from Bruce in.  Nevermind that
> > it's in a slow path, so the overhead of vfs_getattr really doesn't hurt.
> 
> Calling vfs_getattr adds a security_inode_getattr() call that wasn't
> there before.  Any chance of that being a problem?
> 
> If so then it's no huge code duplication to it by hand:
> 
> 	if (inode->i_op->getattr)
> 		inode->i_op->getattr(path->mnt, path->dentry, &stat);
> 	else
> 		generic_fillattr(inode, &stat);

Just for fun, I took a stab at an xfs-specific method.

Pretty much untested and probably wrong as I know nothing about xfs, but
it does seem like it allows some minor simplifications compared to the
common helper.

But as Christoph says other filesystems have the same problem so we
probably want to fix the common helper anyway.

--b.

commit 1d2c2fa899d94aef5283aa66f4bd453305a62030
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Sep 20 16:14:53 2013 -0400

    exportfs: fix 32-bit nfsd handling of 64-bit inode numbers
    
    Symptoms were spurious -ENOENTs on stat of an NFS filesystem from a
    32-bit NFS server exporting a very large XFS filesystem, when the
    server's cache is cold (so the inodes in question are not in cache).
    
    Reported-by: Trevor Cordes <trevor@tecnopolis.ca>
    Signed-off-by: J.  Bruce Fields <bfields@redhat.com>

diff --git a/fs/xfs/xfs_export.c b/fs/xfs/xfs_export.c
index 066df42..e76a288 100644
--- a/fs/xfs/xfs_export.c
+++ b/fs/xfs/xfs_export.c
@@ -31,6 +31,7 @@
 #include "xfs_inode_item.h"
 #include "xfs_trace.h"
 #include "xfs_icache.h"
+#include "xfs_dir2_priv.h"
 
 /*
  * Note that we only accept fileids which are long enough rather than allow
@@ -240,10 +241,90 @@ xfs_fs_nfs_commit_metadata(
 	return _xfs_log_force_lsn(mp, lsn, XFS_LOG_SYNC, NULL);
 }
 
+struct getdents_callback {
+	struct dir_context ctx;
+	char *name;		/* name that was found. It already points to a
+				   buffer NAME_MAX+1 is size */
+	u64 ino;		/* the inum we are looking for */
+	int found;		/* inode matched? */
+	int sequence;		/* sequence counter */
+};
+
+/*
+ * A rather strange filldir function to capture
+ * the name matching the specified inode number.
+ */
+static int filldir_one(void * __buf, const char * name, int len,
+			loff_t pos, u64 ino, unsigned int d_type)
+{
+	struct getdents_callback *buf = __buf;
+	int result = 0;
+
+	buf->sequence++;
+	if (buf->ino == ino && len <= NAME_MAX) {
+		memcpy(buf->name, name, len);
+		buf->name[len] = '\0';
+		buf->found = 1;
+		result = -1;
+	}
+	return result;
+}
+
+STATIC int
+xfs_fs_get_name(
+	struct dentry *parent,
+	char *name,
+	struct dentry *child)
+{
+	struct inode *dir = parent->d_inode;
+	int error;
+	struct xfs_inode *ip = XFS_I(child->d_inode);
+	struct getdents_callback buffer = {
+		.ctx.actor = filldir_one,
+		.name = name,
+		.ino = ip->i_ino
+	};
+	size_t	bufsize;
+
+	error = -ENOTDIR;
+	if (!dir || !S_ISDIR(dir->i_mode))
+		goto out;
+
+	/* See comment in fs/xfs/xfs_file.c:xfs_file_readdir */
+	bufsize = (size_t)min_t(loff_t, 32768, ip->i_d.di_size);
+
+	buffer.sequence = 0;
+	while (1) {
+		int old_seq = buffer.sequence;
+
+		error = mutex_lock_killable(&dir->i_mutex);
+		if (error)
+			goto out;
+		if (!IS_DEADDIR(dir))
+			error = -xfs_readdir(ip, &buffer.ctx, bufsize);
+		mutex_unlock(&dir->i_mutex);
+		if (buffer.found) {
+			error = 0;
+			break;
+		}
+
+		if (error)
+			break;
+
+		error = -ENOENT;
+		if (old_seq == buffer.sequence)
+			break;
+	}
+
+out:
+	return error;
+}
+
 const struct export_operations xfs_export_operations = {
 	.encode_fh		= xfs_fs_encode_fh,
 	.fh_to_dentry		= xfs_fs_fh_to_dentry,
 	.fh_to_parent		= xfs_fs_fh_to_parent,
 	.get_parent		= xfs_fs_get_parent,
 	.commit_metadata	= xfs_fs_nfs_commit_metadata,
+	.get_name		= xfs_fs_get_name
 };
