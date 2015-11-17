Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35865 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbbKQLxr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:47 -0500
Received: by qkda6 with SMTP id a6so1676995qkd.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:46 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 28/38] nfsd: close cached files prior to a REMOVE or RENAME that would replace target
Date: Tue, 17 Nov 2015 06:52:50 -0500
Message-Id: <1447761180-4250-29-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not uncommon for some workloads to do a bunch of I/O to a file and
delete it just afterward. If knfsd has a cached open file however, then
the file may still be open when the dentry is unlinked. If the
underlying filesystem is nfs, then that could trigger it to do a
sillyrename.

On a REMOVE or RENAME scan the nfsd_file cache for open files that
correspond to the inode, and proactively unhash and put their
references. This should prevent any delete-on-last-close activity from
occurring, solely due to knfsd's open file cache.

This must be done synchronously though so we use the variants that call
flush_delayed_fput. There are deadlock possibilities if you call
flush_delayed_fput while holding locks, however. In the case of
nfsd_rename, we don't even do the lookups of the dentries to be renamed
until we've locked for rename.

Once we've figured out what the target dentry is for a rename, check to
see whether there are cached open files associated with it. If there
are, then unwind all of the locking, close them all, and then reattempt
the rename.

None of this is really necessary for "typical" filesystems though. It's
mostly of use for NFS, so declare a new export op flag and use that to
determine whether to close the files beforehand.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 Documentation/filesystems/nfs/Exporting | 13 +++++++
 fs/nfsd/filecache.c                     | 29 +++++++++++++++
 fs/nfsd/filecache.h                     |  1 +
 fs/nfsd/trace.h                         |  2 ++
 fs/nfsd/vfs.c                           | 64 ++++++++++++++++++++++++++++-----
 include/linux/exportfs.h                |  5 +--
 6 files changed, 103 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/nfs/Exporting b/Documentation/filesystems/nfs/Exporting
index a89b5be22703..eb3eec811e67 100644
--- a/Documentation/filesystems/nfs/Exporting
+++ b/Documentation/filesystems/nfs/Exporting
@@ -186,3 +186,16 @@ following flags are defined:
     This flag exempts the filesystem from subtree checking and causes
     exportfs to get back an error if it tries to enable subtree checking
     on it.
+
+  EXPORT_OP_CLOSE_BEFORE_UNLINK - always close cached files before unlinking
+    On some exportable filesystems (such as NFS) unlinking a file that
+    is still open can cause a fair bit of extra work. For instance,
+    the NFS client will do a "sillyrename" to ensure that the file
+    sticks around while it's still open. When reexporting, that open
+    file is held by nfsd so we usually end up doing a sillyrename, and
+    then immediately deleting the sillyrenamed file just afterward when
+    the link count actually goes to zero. Sometimes this delete can race
+    with other operations (for instance an rmdir of the parent directory).
+    This flag causes nfsd to close any open files for this inode _before_
+    calling into the vfs to do an unlink or a rename that would replace
+    an existing file.
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 79daf2677176..e7756664b8d8 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -547,6 +547,35 @@ nfsd_file_find_locked(struct inode *inode, unsigned int may_flags,
 	return NULL;
 }
 
+/**
+ * nfsd_file_is_cached - are there any cached open files for this fh?
+ * @inode: inode of the file to check
+ *
+ * Scan the hashtable for open files that match this fh. Returns true if there
+ * are any, and false if not.
+ */
+bool
+nfsd_file_is_cached(struct inode *inode)
+{
+	bool			ret = false;
+	struct nfsd_file	*nf;
+	unsigned int		hashval;
+
+        hashval = (unsigned int)hash_long(inode->i_ino, NFSD_FILE_HASH_BITS);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(nf, &nfsd_file_hashtbl[hashval].nfb_head,
+				 nf_node) {
+		if (inode == nf->nf_inode) {
+			ret = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	trace_nfsd_file_is_cached(inode, hashval, (int)ret);
+	return ret;
+}
+
 __be32
 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  unsigned int may_flags, struct nfsd_file **pnf)
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index 756aea5431da..aea5d347c27b 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -38,6 +38,7 @@ void nfsd_file_cache_shutdown(void);
 void nfsd_file_put(struct nfsd_file *nf);
 struct nfsd_file *nfsd_file_get(struct nfsd_file *nf);
 void nfsd_file_close_inode_sync(struct inode *inode);
+bool nfsd_file_is_cached(struct inode *inode);
 __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  unsigned int may_flags, struct nfsd_file **nfp);
 int	nfsd_file_cache_stats_open(struct inode *, struct file *);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 9174d126ff6e..f991619f4f67 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -208,6 +208,7 @@ DEFINE_EVENT(nfsd_file_search_class, name,				\
 
 DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_close_inode_sync);
 DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_close_inode);
+DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_is_cached);
 
 TRACE_EVENT(nfsd_file_fsnotify_handle_event,
 	TP_PROTO(struct inode *inode, u32 mask),
@@ -227,6 +228,7 @@ TRACE_EVENT(nfsd_file_fsnotify_handle_event,
 	TP_printk("inode=0x%p nlink=%u mode=0%ho mask=0x%x", __entry->inode,
 			__entry->nlink, __entry->mode, __entry->mask)
 );
+
 #endif /* _NFSD_TRACE_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d3fac79c4eaa..9bf194be2b8e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1524,6 +1524,26 @@ out_nfserr:
 	goto out_unlock;
 }
 
+static void
+nfsd_close_cached_files(struct dentry *dentry)
+{
+	struct inode *inode = d_inode(dentry);
+
+	if (inode && S_ISREG(inode->i_mode))
+		nfsd_file_close_inode_sync(inode);
+}
+
+static bool
+nfsd_has_cached_files(struct dentry *dentry)
+{
+	bool		ret = false;
+	struct inode *inode = d_inode(dentry);
+
+	if (inode && S_ISREG(inode->i_mode))
+		ret = nfsd_file_is_cached(inode);
+	return ret;
+}
+
 /*
  * Rename a file
  * N.B. After this call _both_ ffhp and tfhp need an fh_put
@@ -1536,6 +1556,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	struct inode	*fdir, *tdir;
 	__be32		err;
 	int		host_err;
+	bool		close_cached = false;
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
 	if (err)
@@ -1554,6 +1575,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (!flen || isdotent(fname, flen) || !tlen || isdotent(tname, tlen))
 		goto out;
 
+retry:
 	host_err = fh_want_write(ffhp);
 	if (host_err) {
 		err = nfserrno(host_err);
@@ -1593,11 +1615,17 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
 
-	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
-	if (!host_err) {
-		host_err = commit_metadata(tfhp);
-		if (!host_err)
-			host_err = commit_metadata(ffhp);
+	if ((ndentry->d_sb->s_export_op->flags & EXPORT_OP_CLOSE_BEFORE_UNLINK) &&
+	    nfsd_has_cached_files(ndentry)) {
+		close_cached = true;
+		goto out_dput_old;
+	} else {
+		host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
+		if (!host_err) {
+			host_err = commit_metadata(tfhp);
+			if (!host_err)
+				host_err = commit_metadata(ffhp);
+		}
 	}
  out_dput_new:
 	dput(ndentry);
@@ -1610,12 +1638,26 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	 * as that would do the wrong thing if the two directories
 	 * were the same, so again we do it by hand.
 	 */
-	fill_post_wcc(ffhp);
-	fill_post_wcc(tfhp);
+	if (!close_cached) {
+		fill_post_wcc(ffhp);
+		fill_post_wcc(tfhp);
+	}
 	unlock_rename(tdentry, fdentry);
 	ffhp->fh_locked = tfhp->fh_locked = false;
 	fh_drop_write(ffhp);
 
+	/*
+	 * If the target dentry has cached open files, then we need to try to
+	 * close them prior to doing the rename. Flushing delayed fput
+	 * shouldn't be done with locks held however, so we delay it until this
+	 * point and then reattempt the whole shebang.
+	 */
+	if (close_cached) {
+		close_cached = false;
+		nfsd_close_cached_files(ndentry);
+		dput(ndentry);
+		goto retry;
+	}
 out:
 	return err;
 }
@@ -1662,10 +1704,14 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (!type)
 		type = d_inode(rdentry)->i_mode & S_IFMT;
 
-	if (type != S_IFDIR)
+	if (type != S_IFDIR) {
+		if (rdentry->d_sb->s_export_op->flags & EXPORT_OP_CLOSE_BEFORE_UNLINK)
+			nfsd_close_cached_files(rdentry);
 		host_err = vfs_unlink(dirp, rdentry, NULL);
-	else
+	} else {
 		host_err = vfs_rmdir(dirp, rdentry);
+	}
+
 	if (!host_err)
 		host_err = commit_metadata(fhp);
 	dput(rdentry);
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 5f9b5345f717..e8ba130f0aa5 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -214,8 +214,9 @@ struct export_operations {
 			  bool write, u32 *device_generation);
 	int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
 			     int nr_iomaps, struct iattr *iattr);
-#define	EXPORT_OP_NOWCC		(0x1)	/* Don't collect wcc data for NFSv3 replies */
-#define	EXPORT_OP_NOSUBTREECHK	(0x2)	/* Subtree checking is not supported! */
+#define	EXPORT_OP_NOWCC			(0x1) /* don't collect v3 wcc data */
+#define	EXPORT_OP_NOSUBTREECHK		(0x2) /* no subtree checking */
+#define	EXPORT_OP_CLOSE_BEFORE_UNLINK	(0x4) /* close files before unlink */
 	unsigned long	flags;
 };
 
-- 
2.4.3

