From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/30] NFS: Add options for finer control of the lookup
	cache
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.4355.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756174AbYJGWcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:50 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkw2026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:47 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the flag NFS_MOUNT_LOOKUP_CACHE_NONEG to turn off the caching of
negative dentries. In reality what we do is to force
nfs_lookup_revalidate() to always discard negative dentries.

Add the flag NFS_MOUNT_LOOKUP_CACHE_NONE for enforcing stricter
revalidation of dentries. It forces the revalidate code to always do a
lookup instead of just checking the cached mtime of the parent directory.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c              |    4 ++++
 include/linux/nfs_mount.h |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 74f92b7..49d5654 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -667,6 +667,8 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 {
 	if (IS_ROOT(dentry))
 		return 1;
+	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
+		return 0;
 	if (!nfs_verify_change_attribute(dir, dentry->d_time))
 		return 0;
 	/* Revalidate nfsi->cache_change_attribute before we declare a match */
@@ -750,6 +752,8 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 	/* Don't revalidate a negative dentry if we're creating a new file */
 	if (nd != NULL && nfs_lookup_check_intent(nd, LOOKUP_CREATE) != 0)
 		return 0;
+	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
+		return 1;
 	return !nfs_check_verifier(dir, dentry);
 }
 
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index df7c6b7..6549a06 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -65,4 +65,8 @@ struct nfs_mount_data {
 #define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
+/* The following are for internal use only */
+#define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x10000
+#define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
+
 #endif

