Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57925 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450AbaBFTxl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Feb 2014 14:53:41 -0500
Received: by mail-ie0-f180.google.com with SMTP id at1so943035iec.25
        for <linux-nfs@vger.kernel.org>; Thu, 06 Feb 2014 11:53:40 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Do not set NFS_INO_INVALID_LABEL unless server supports labeled NFS
Date: Thu,  6 Feb 2014 14:53:38 -0500
Message-Id: <1391716418-7353-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <20140206135101.1cc83442@notabene.brown>
References: <20140206135101.1cc83442@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit aa9c2669626c (NFS: Client implementation of Labeled-NFS) introduces
a performance regression. When nfs_zap_caches_locked is called, it sets
the NFS_INO_INVALID_LABEL flag irrespectively of whether or not the
NFS server supports security labels. Since that flag is never cleared,
it means that all calls to nfs_revalidate_inode() will now trigger
an on-the-wire GETATTR call.

This patch ensures that we never set the NFS_INO_INVALID_LABEL unless the
server advertises support for labeled NFS.
It also causes nfs_setsecurity() to clear NFS_INO_INVALID_LABEL when it
has successfully set the security label for the inode.
Finally it gets rid of the NFS_INO_INVALID_LABEL cruft from nfs_update_inode,
which has nothing to do with labeled NFS.

Reported-by: Neil Brown <neilb@suse.de>
Cc: stable@vger.kernel.org # 3.11+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---

Hi Neil,
Does this fix the GETATTR regression that you reported?

Cheers
 Trond

 fs/nfs/inode.c    | 14 ++++++++++----
 fs/nfs/internal.h |  9 +++++++++
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 29cb93653b3c..4636b828e957 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -169,7 +169,6 @@ static void nfs_zap_caches_locked(struct inode *inode)
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
 		nfs_fscache_invalidate(inode);
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-					| NFS_INO_INVALID_LABEL
 					| NFS_INO_INVALID_DATA
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL
@@ -177,10 +176,10 @@ static void nfs_zap_caches_locked(struct inode *inode)
 		nfs_zap_readdir_cookie(nfsi);
 	} else
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-					| NFS_INO_INVALID_LABEL
 					| NFS_INO_INVALID_ACCESS
 					| NFS_INO_INVALID_ACL
 					| NFS_INO_REVAL_PAGECACHE;
+	nfs_zap_label_cache_locked(nfsi);
 }
 
 void nfs_zap_caches(struct inode *inode)
@@ -272,6 +271,13 @@ nfs_init_locked(struct inode *inode, void *opaque)
 }
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
+static void nfs_clear_label_invalid(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_LABEL;
+	spin_unlock(&inode->i_lock);
+}
+
 void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 					struct nfs4_label *label)
 {
@@ -289,6 +295,7 @@ void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 					__func__,
 					(char *)label->label,
 					label->len, error);
+		nfs_clear_label_invalid(inode);
 	}
 }
 
@@ -1654,7 +1661,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		inode->i_blocks = fattr->du.nfs2.blocks;
 
 	/* Update attrtimeo value if we're out of the unstable period */
-	if (invalid & (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL)) {
+	if (invalid & NFS_INO_INVALID_ATTR) {
 		nfs_inc_stats(inode, NFSIOS_ATTRINVALIDATE);
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = now;
@@ -1667,7 +1674,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		}
 	}
 	invalid &= ~NFS_INO_INVALID_ATTR;
-	invalid &= ~NFS_INO_INVALID_LABEL;
 	/* Don't invalidate the data if we were to blame */
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8b5cc04a8611..fafdddac8271 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -279,9 +279,18 @@ static inline void nfs4_label_free(struct nfs4_label *label)
 	}
 	return;
 }
+
+static inline void nfs_zap_label_cache_locked(struct nfs_inode *nfsi)
+{
+	if (nfs_server_capable(&nfsi->vfs_inode, NFS_CAP_SECURITY_LABEL))
+		nfsi->cache_validity |= NFS_INO_INVALID_LABEL;
+}
 #else
 static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags) { return NULL; }
 static inline void nfs4_label_free(void *label) {}
+static inline void nfs_zap_label_cache_locked(struct nfs_inode *nfsi)
+{
+}
 #endif /* CONFIG_NFS_V4_SECURITY_LABEL */
 
 /* proc.c */
-- 
1.8.5.3

