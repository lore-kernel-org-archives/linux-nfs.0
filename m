From: andros@netapp.com
Subject: [PATCH 3/4] SQUASHME pnfs remove ifdef around layoutcommit_needed
Date: Thu,  3 Jun 2010 12:25:26 -0400
Message-ID: <1275582327-9285-4-git-send-email-andros@netapp.com>
References: <1275582327-9285-1-git-send-email-andros@netapp.com>
 <1275582327-9285-2-git-send-email-andros@netapp.com>
 <1275582327-9285-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55065 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756493Ab0FCQZb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:25:31 -0400
In-Reply-To: <1275582327-9285-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c            |    2 --
 include/linux/nfs4_pnfs.h |    8 ++++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c93b756..086d46f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1106,7 +1106,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			!test_bit(NFS_INO_MOUNTPOINT, &nfsi->flags))
 		server->fsid = fattr->fsid;
 
-#ifdef CONFIG_NFS_V4_1
 	/*
 	 * file needs layout commit, server attributes may be stale
 	 */
@@ -1115,7 +1114,6 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			__func__, inode->i_sb->s_id, inode->i_ino);
 		return 0;
 	}
-#endif /* CONFIG_NFS_V4_1 */
 	/*
 	 * Update the read time so we don't revalidate too often.
 	 */
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 84d2e95..c248ae9 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -86,6 +86,14 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 	return nfsi->lo_cred != NULL;
 }
 
+#else /* CONFIG_NFS_V4_1 */
+
+static inline bool
+layoutcommit_needed(struct nfs_inode *nfsi)
+{
+	return 0;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct pnfs_layout_segment {
-- 
1.6.2.5

