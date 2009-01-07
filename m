From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd stuckage
Date: Tue, 6 Jan 2009 19:15:01 -0500
Message-ID: <20090107001501.GH13785@fieldses.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org> <20090106230244.GB13785@fieldses.org> <20090106230356.GA31520@lst.de> <20090106230551.GC13785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>, Eric Sesterhenn <snakebyte@gmx.de>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38165 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbZAGAPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 19:15:07 -0500
In-Reply-To: <20090106230551.GC13785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2009 at 06:05:51PM -0500, bfields wrote:
> On Wed, Jan 07, 2009 at 12:03:56AM +0100, Christoph Hellwig wrote:
> > On Tue, Jan 06, 2009 at 06:02:44PM -0500, J. Bruce Fields wrote:
> > > On Tue, Jan 06, 2009 at 02:56:12PM -0800, Andrew Morton wrote:
> > > > 
> > > > I just built current mainline plus the just-sent 266 -mm patches.
> > > > 
> > > > The machine failed to power off when hit with `halt -pfn'.  dmesg output:
> > > 
> > > Christoph, can you live with this for now?
> > 
> > nfsd part is well, livable.  But the fs/sync.c is buggy as stackable
> > filesystems can call vfs_fsync with a NULL pointer due to nfs calling it
> > that way, so please drop that hunk.
> 
> Whoops, OK, I didn't understand that.  I'll drop that hunk, retest, then
> submit--should take a few minutes.

So this works for me--and I guess I may as well submit it in a pull
request.  But: it sounds like we still have a regression for ecryptfs?
(Since on ecryptfs export nfsd will still try to get the mutex twice on
create, unlink, etc.)  Maybe we should just revert
4c728ef583b3d82266584da5cb068294c09df31e entirely for now?

--b.

commit 3fbc5c762bd9f9ff52fe7b5b09398a3cff0e8415
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jan 6 13:37:03 2009 -0500

    nfsd: fix double-locks of directory mutex
    
    A number of nfsd operations depend on the i_mutex to cover more code
    than just the fsync, so the approach of 4c728ef583b3d8 "add a vfs_fsync
    helper" doesn't work for nfsd.  Revert the parts of those patches that
    touch nfsd.
    
    Note: we can't, however, remove the logic from vfs_fsync that was needed
    only for the special case of nfsd, because a vfs_fsync(NULL,...) call
    can still result indirectly from a stackable filesystem that was called
    by nfsd.
    
    Reported-by: Eric Sesterhenn <snakebyte@gmx.de>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 44aa92a..6e50aaa 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -744,16 +744,44 @@ nfsd_close(struct file *filp)
 	fput(filp);
 }
 
+/*
+ * Sync a file
+ * As this calls fsync (not fdatasync) there is no need for a write_inode
+ * after it.
+ */
+static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
+			      const struct file_operations *fop)
+{
+	struct inode *inode = dp->d_inode;
+	int (*fsync) (struct file *, struct dentry *, int);
+	int err;
+
+	err = filemap_fdatawrite(inode->i_mapping);
+	if (err == 0 && fop && (fsync = fop->fsync))
+		err = fsync(filp, dp, 0);
+	if (err == 0)
+		err = filemap_fdatawait(inode->i_mapping);
+
+	return err;
+}
+
 static int
 nfsd_sync(struct file *filp)
 {
-	return vfs_fsync(filp, filp->f_path.dentry, 0);
+        int err;
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
+	mutex_lock(&inode->i_mutex);
+	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);
+	mutex_unlock(&inode->i_mutex);
+
+	return err;
 }
 
 int
-nfsd_sync_dir(struct dentry *dentry)
+nfsd_sync_dir(struct dentry *dp)
 {
-	return vfs_fsync(NULL, dentry, 0);
+	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
 }
 
 /*
