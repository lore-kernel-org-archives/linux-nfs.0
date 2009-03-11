From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/30] NFS: Throttle page dirtying while we're flushing to
 disk
Date: Wed, 11 Mar 2009 14:41:08 -0400
Message-ID: <20090311184108.5578.53327.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Staubach <staubach@redhat.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754427AbZCKSoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:11 -0400
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch is a combination of a patch by myself and Peter
Staubach.

Trond: If we allow other processes to dirty pages while a process is doing
a consistency sync to disk, we can end up never making progress.

Peter: Attached is a patch which addresses a continuing problem with
the NFS client generating out of order WRITE requests.  While
this is compliant with all of the current protocol
specifications, there are servers in the market which can not
handle out of order WRITE requests very well.  Also, this may
lead to sub-optimal block allocations in the underlying file
system on the server.  This may cause the read throughputs to
be reduced when reading the file from the server.

Peter: There has been a lot of work recently done to address out of
order issues on a systemic level.  However, the NFS client is
still susceptible to the problem.  Out of order WRITE
requests can occur when pdflush is in the middle of writing
out pages while the process dirtying the pages calls
generic_file_buffered_write which calls
generic_perform_write which calls
balance_dirty_pages_rate_limited which ends up calling
writeback_inodes which ends up calling back into the NFS
client to writes out dirty pages for the same file that
pdflush happens to be working with.

Signed-off-by: Peter Staubach <staubach@redhat.com>
[modification by Trond to merge the two similar patches]
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c          |    9 +++++++++
 fs/nfs/inode.c         |   12 ++++++++++++
 fs/nfs/internal.h      |    1 +
 fs/nfs/nfs4proc.c      |   10 +---------
 fs/nfs/pagelist.c      |   11 -----------
 fs/nfs/write.c         |   28 +++++++++++++++++++---------
 include/linux/nfs_fs.h |    1 +
 7 files changed, 43 insertions(+), 29 deletions(-)


diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 90f292b..404c19c 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -354,6 +354,15 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+	/*
+	 * Prevent starvation issues if someone is doing a consistency
+	 * sync-to-disk
+	 */
+	ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
+			nfs_wait_bit_killable, TASK_KILLABLE);
+	if (ret)
+		return ret;
+
 	page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 00f116c..c40adc5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -66,6 +66,18 @@ nfs_fattr_to_ino_t(struct nfs_fattr *fattr)
 }
 
 /**
+ * nfs_wait_bit_killable - helper for functions that are sleeping on bit locks
+ * @word: long word containing the bit lock
+ */
+int nfs_wait_bit_killable(void *word)
+{
+	if (fatal_signal_pending(current))
+		return -ERESTARTSYS;
+	schedule();
+	return 0;
+}
+
+/**
  * nfs_compat_user_ino64 - returns the user-visible inode number
  * @fileid: 64-bit fileid
  *
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 340ede8..a55e69a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -165,6 +165,7 @@ extern void nfs_clear_inode(struct inode *);
 extern void nfs4_clear_inode(struct inode *);
 #endif
 void nfs_zap_acl_cache(struct inode *inode);
+extern int nfs_wait_bit_killable(void *word);
 
 /* super.c */
 void nfs_parse_ip_address(char *, size_t, struct sockaddr *, size_t *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 101f5f4..95f171e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -193,14 +193,6 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	kunmap_atomic(start, KM_USER0);
 }
 
-static int nfs4_wait_bit_killable(void *word)
-{
-	if (fatal_signal_pending(current))
-		return -ERESTARTSYS;
-	schedule();
-	return 0;
-}
-
 static int nfs4_wait_clnt_recover(struct nfs_client *clp)
 {
 	int res;
@@ -208,7 +200,7 @@ static int nfs4_wait_clnt_recover(struct nfs_client *clp)
 	might_sleep();
 
 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
-			nfs4_wait_bit_killable, TASK_KILLABLE);
+			nfs_wait_bit_killable, TASK_KILLABLE);
 	return res;
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7f07920..e297593 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -176,17 +176,6 @@ void nfs_release_request(struct nfs_page *req)
 	kref_put(&req->wb_kref, nfs_free_request);
 }
 
-static int nfs_wait_bit_killable(void *word)
-{
-	int ret = 0;
-
-	if (fatal_signal_pending(current))
-		ret = -ERESTARTSYS;
-	else
-		schedule();
-	return ret;
-}
-
 /**
  * nfs_wait_on_request - Wait for a request to complete.
  * @req: request to wait upon.
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1a99993..36fd35e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -313,19 +313,34 @@ static int nfs_writepages_callback(struct page *page, struct writeback_control *
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
+	unsigned long *bitlock = &NFS_I(inode)->flags;
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
+	/* Stop dirtying of new pages while we sync */
+	err = wait_on_bit_lock(bitlock, NFS_INO_FLUSHING,
+			nfs_wait_bit_killable, TASK_KILLABLE);
+	if (err)
+		goto out_err;
+
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
 	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc));
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
+
+	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
+	smp_mb__after_clear_bit();
+	wake_up_bit(bitlock, NFS_INO_FLUSHING);
+
 	if (err < 0)
-		return err;
-	if (pgio.pg_error < 0)
-		return pgio.pg_error;
+		goto out_err;
+	err = pgio.pg_error;
+	if (err < 0)
+		goto out_err;
 	return 0;
+out_err:
+	return err;
 }
 
 /*
@@ -1432,18 +1447,13 @@ static int nfs_write_mapping(struct address_space *mapping, int how)
 {
 	struct writeback_control wbc = {
 		.bdi = mapping->backing_dev_info,
-		.sync_mode = WB_SYNC_NONE,
+		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = 0,
 		.range_end = LLONG_MAX,
 		.for_writepages = 1,
 	};
-	int ret;
 
-	ret = __nfs_write_mapping(mapping, &wbc, how);
-	if (ret < 0)
-		return ret;
-	wbc.sync_mode = WB_SYNC_ALL;
 	return __nfs_write_mapping(mapping, &wbc, how);
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c9fecd3..933bc26 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -206,6 +206,7 @@ struct nfs_inode {
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
 #define NFS_INO_MOUNTPOINT	(3)		/* inode is remote mountpoint */
+#define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {

