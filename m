From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Wed, 23 Dec 2009 03:43:02 -0500
Message-ID: <20091223084302.GA14912@infradead.org>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost> <20091222123538.GB604@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58374 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbZLWInJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2009 03:43:09 -0500
In-Reply-To: <20091222123538.GB604-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 22, 2009 at 01:35:39PM +0100, Jan Kara wrote:
> >    nfsd_sync:
> >      [take i_mutex]
> >        filemap_fdatawrite  => can also be blocked, but less a problem
> >      [drop i_mutex]
> >        filemap_fdatawait
> >  
> >    Maybe it's a dumb question, but what's the purpose of i_mutex here?
> >    For correctness or to prevent livelock? I can imagine some livelock
> >    problem here (current implementation can easily wait for extra
> >    pages), however not too hard to fix.
>   Generally, most filesystems take i_mutex during fsync to
> a) avoid all sorts of livelocking problems
> b) serialize fsyncs for one inode (mostly for simplicity)
>   I don't see what advantage would it bring that we get rid of i_mutex
> for fdatawait - only that maybe writers could proceed while we are
> waiting but is that really the problem?

It would match what we do in vfs_fsync for the non-nfsd path, so it's
a no-brainer to do it.  In fact I did switch it over to vfs_fsync a
while ago but that go reverted because it caused deadlocks for
nfsd_sync_dir which for some reason can't take the i_mutex (I'd have to
check the archives why).

Here's a RFC patch to make some more sense of the fsync callers in nfsd,
including fixing up the data write/wait calling conventions to match the
regular fsync path (which might make this a -stable candidate):


Index: linux-2.6/fs/nfsd/vfs.c
===================================================================
--- linux-2.6.orig/fs/nfsd/vfs.c	2009-12-23 09:32:45.693170043 +0100
+++ linux-2.6/fs/nfsd/vfs.c	2009-12-23 09:39:47.627170082 +0100
@@ -769,45 +769,27 @@ nfsd_close(struct file *filp)
 }
 
 /*
- * Sync a file
- * As this calls fsync (not fdatasync) there is no need for a write_inode
- * after it.
+ * Sync a directory to disk.
+ *
+ * This is odd compared to all other fsync callers because we
+ *
+ *  a) do not have a file struct available
+ *  b) expect to have i_mutex already held by the caller
  */
-static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
-			      const struct file_operations *fop)
+int
+nfsd_sync_dir(struct dentry *dentry)
 {
-	struct inode *inode = dp->d_inode;
-	int (*fsync) (struct file *, struct dentry *, int);
+	struct inode *inode = dentry->d_inode;
 	int err;
 
-	err = filemap_fdatawrite(inode->i_mapping);
-	if (err == 0 && fop && (fsync = fop->fsync))
-		err = fsync(filp, dp, 0);
-	if (err == 0)
-		err = filemap_fdatawait(inode->i_mapping);
+	WARN_ON(!mutex_is_locked(&inode->i_mutex));
 
+	err = filemap_write_and_wait(inode->i_mapping);
+	if (err == 0 && inode->i_fop->fsync)
+		err = inode->i_fop->fsync(NULL, dentry, 0);
 	return err;
 }
 
-static int
-nfsd_sync(struct file *filp)
-{
-        int err;
-	struct inode *inode = filp->f_path.dentry->d_inode;
-	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
-	mutex_lock(&inode->i_mutex);
-	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);
-	mutex_unlock(&inode->i_mutex);
-
-	return err;
-}
-
-int
-nfsd_sync_dir(struct dentry *dp)
-{
-	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
-}
-
 /*
  * Obtain the readahead parameters for the file
  * specified by (dev, ino).
@@ -1011,7 +993,7 @@ static int wait_for_concurrent_writes(st
 
 	if (inode->i_state & I_DIRTY) {
 		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
-		err = nfsd_sync(file);
+		err = vfs_fsync(file, file->f_path.dentry, 0);
 	}
 	last_ino = inode->i_ino;
 	last_dev = inode->i_sb->s_dev;
@@ -1180,7 +1162,7 @@ nfsd_commit(struct svc_rqst *rqstp, stru
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
-			err = nfserrno(nfsd_sync(file));
+			err = nfserrno(vfs_fsync(file, file->f_path.dentry, 0));
 		} else {
 			err = nfserr_notsupp;
 		}
