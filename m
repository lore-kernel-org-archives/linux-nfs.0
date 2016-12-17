Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34057 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752554AbcLQS1U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Dec 2016 13:27:20 -0500
Received: by mail-io0-f195.google.com with SMTP id y124so15270810iof.1
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 10:27:20 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/9] NFS: Clean up cache validity checking
Date: Sat, 17 Dec 2016 13:27:07 -0500
Message-Id: <20161217182711.10643-6-trond.myklebust@primarydata.com>
In-Reply-To: <20161217182711.10643-5-trond.myklebust@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <20161217182711.10643-3-trond.myklebust@primarydata.com>
 <20161217182711.10643-4-trond.myklebust@primarydata.com>
 <20161217182711.10643-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Consolidate the open-coded checking of NFS_I(inode)->cache_validity
into a couple of helper functions.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/file.c     | 12 +-----------
 fs/nfs/inode.c    | 43 ++++++++++++++++++++++++++++++++-----------
 fs/nfs/internal.h |  1 +
 3 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 64c11f399b3d..599a602cb2fd 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -101,21 +101,11 @@ EXPORT_SYMBOL_GPL(nfs_file_release);
 static int nfs_revalidate_file_size(struct inode *inode, struct file *filp)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs_inode *nfsi = NFS_I(inode);
-	const unsigned long force_reval = NFS_INO_REVAL_PAGECACHE|NFS_INO_REVAL_FORCED;
-	unsigned long cache_validity = nfsi->cache_validity;
-
-	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) &&
-	    (cache_validity & force_reval) != force_reval)
-		goto out_noreval;
 
 	if (filp->f_flags & O_DIRECT)
 		goto force_reval;
-	if (nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
-		goto force_reval;
-	if (nfs_attribute_timeout(inode))
+	if (nfs_check_cache_invalid(inode, NFS_INO_REVAL_PAGECACHE))
 		goto force_reval;
-out_noreval:
 	return 0;
 force_reval:
 	return __nfs_revalidate_inode(server, inode);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2fc237cd338e..e3194aa797f7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -160,6 +160,36 @@ int nfs_sync_mapping(struct address_space *mapping)
 	return ret;
 }
 
+static bool nfs_check_cache_invalid_delegated(struct inode *inode, unsigned long flags)
+{
+	unsigned long cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
+
+	/* Special case for the pagecache or access cache */
+	if (flags == NFS_INO_REVAL_PAGECACHE &&
+	    !(cache_validity & NFS_INO_REVAL_FORCED))
+		return false;
+	return (cache_validity & flags) != 0;
+}
+
+static bool nfs_check_cache_invalid_not_delegated(struct inode *inode, unsigned long flags)
+{
+	unsigned long cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
+
+	if ((cache_validity & flags) != 0)
+		return true;
+	if (nfs_attribute_timeout(inode))
+		return true;
+	return false;
+}
+
+bool nfs_check_cache_invalid(struct inode *inode, unsigned long flags)
+{
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
+		return nfs_check_cache_invalid_delegated(inode, flags);
+
+	return nfs_check_cache_invalid_not_delegated(inode, flags);
+}
+
 static void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1116,17 +1146,8 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 
 bool nfs_mapping_need_revalidate_inode(struct inode *inode)
 {
-	unsigned long cache_validity = NFS_I(inode)->cache_validity;
-
-	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ)) {
-		const unsigned long force_reval =
-			NFS_INO_REVAL_PAGECACHE|NFS_INO_REVAL_FORCED;
-		return (cache_validity & force_reval) == force_reval;
-	}
-
-	return (cache_validity & NFS_INO_REVAL_PAGECACHE)
-		|| nfs_attribute_timeout(inode)
-		|| NFS_STALE(inode);
+	return nfs_check_cache_invalid(inode, NFS_INO_REVAL_PAGECACHE) ||
+		NFS_STALE(inode);
 }
 
 int nfs_revalidate_mapping_rcu(struct inode *inode)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 6b79c2ca9b9a..09ca5095c04e 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -381,6 +381,7 @@ extern int nfs_drop_inode(struct inode *);
 extern void nfs_clear_inode(struct inode *);
 extern void nfs_evict_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
+extern bool nfs_check_cache_invalid(struct inode *, unsigned long);
 extern int nfs_wait_bit_killable(struct wait_bit_key *key, int mode);
 extern int nfs_wait_atomic_killable(atomic_t *p);
 
-- 
2.9.3

