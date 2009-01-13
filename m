Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17445 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbZAMWxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2009 17:53:54 -0500
Subject: Re: [PATCH] out of order WRITE requests
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peter Staubach <staubach@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
        NFS list <linux-nfs@vger.kernel.org>
In-Reply-To: <496D1642.6060608@redhat.com>
References: <496D1642.6060608@redhat.com>
Content-Type: text/plain
Date: Tue, 13 Jan 2009 17:53:37 -0500
Message-Id: <1231887217.7036.24.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-01-13 at 17:31 -0500, Peter Staubach wrote:
> Hi.
> 
> Attached is a patch which addresses a continuing problem with
> the NFS client generating out of order WRITE requests.  While
> this is compliant with all of the current protocol
> specifications, there are servers in the market which can not
> handle out of order WRITE requests very well.  Also, this may
> lead to sub-optimal block allocations in the underlying file
> system on the server.  This may cause the read throughputs to
> be reduced when reading the file from the server.
> 
> There has been a lot of work recently done to address out of
> order issues on a systemic level.  However, the NFS client is
> still susceptible to the problem.  Out of order WRITE
> requests can occur when pdflush is in the middle of writing
> out pages while the process dirtying the pages calls 
> generic_file_buffered_write which calls
> generic_perform_write which calls
> balance_dirty_pages_rate_limited which ends up calling
> writeback_inodes which ends up calling back into the NFS
> client to writes out dirty pages for the same file that
> pdflush happens to be working with.
> 
> The attached patch supplies synchronization in the NFS client
> code itself.  The entry point in the NFS client for both of
> the code paths mentioned is nfs_writepages, so serializing
> there resolves this issue.
> 
> My testing, informal, showed no degradation in WRITE
> throughput.
> 
>     Thanx...
> 
>        ps

Heh.... I happen to have a _very_ similar patch that is basically
designed to prevent new pages from being dirtied, and thus allowing
those cache consistency flushes at close() and stat() to make progress.
The difference is that I'm locking over nfs_write_mapping() instead of
nfs_writepages()...

Perhaps we should combine the two patches? If so, we need to convert
nfs_write_mapping() to only flush once using the WB_SYNC_ALL mode,
instead of the current 2 pass system...
-----------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 13 Jan 2009 14:07:32 -0500
NFS: Throttle page dirtying while we're flushing to disk

If we allow other processes to dirty pages while a process is doing a
consistency sync to disk, we can end up never making progress.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c          |    9 +++++++++
 fs/nfs/inode.c         |   12 ++++++++++++
 fs/nfs/internal.h      |    1 +
 fs/nfs/nfs4proc.c      |   10 +---------
 fs/nfs/write.c         |   15 +++++++++++++--
 include/linux/nfs_fs.h |    1 +
 6 files changed, 37 insertions(+), 11 deletions(-)


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
index 01ff31d..ae2fefc 100644
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
index 2547f65..cfbcbeb 100644
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
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1a99993..c1a04a4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1438,13 +1438,24 @@ static int nfs_write_mapping(struct address_space *mapping, int how)
 		.range_end = LLONG_MAX,
 		.for_writepages = 1,
 	};
+	unsigned long *bitlock = &NFS_I(mapping->host)->flags;
 	int ret;
 
+	/* Stop dirtying of new pages while we sync */
+	ret = wait_on_bit_lock(bitlock, NFS_INO_FLUSHING,
+			nfs_wait_bit_killable, TASK_KILLABLE);
+	if (ret)
+		return ret;
 	ret = __nfs_write_mapping(mapping, &wbc, how);
 	if (ret < 0)
-		return ret;
+		goto out_unlock;
 	wbc.sync_mode = WB_SYNC_ALL;
-	return __nfs_write_mapping(mapping, &wbc, how);
+	ret = __nfs_write_mapping(mapping, &wbc, how);
+out_unlock:
+	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
+	smp_mb__after_clear_bit();
+	wake_up_bit(bitlock, NFS_INO_FLUSHING);
+	return ret;
 }
 
 /*
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


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
