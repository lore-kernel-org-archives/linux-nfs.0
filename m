Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166Ab1BDVeh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:37 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 17/40] SQUASHME pnfs-submit wave3 remove is_ds_only_session
Date: Fri,  4 Feb 2011 16:33:39 -0500
Message-Id: <1296855242-2592-18-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-17-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Remove the un-used is_ds_only_session. Move private function is_ds_only_client.
Use EXCHGID4_FLAG_MASK_PNFS which includes the NON_PNFS role.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h          |   13 +++++++++++++
 include/linux/nfs4.h      |    7 -------
 include/linux/nfs_fs_sb.h |   10 ----------
 3 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7a74740..5d84642 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -259,6 +259,13 @@ extern int nfs4_proc_destroy_session(struct nfs4_session *);
 extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
+
+static inline bool
+is_ds_only_client(struct nfs_client *clp)
+{
+	return (clp->cl_exchange_flags & EXCHGID4_FLAG_MASK_PNFS) ==
+		EXCHGID4_FLAG_USE_PNFS_DS;
+}
 #else /* CONFIG_NFS_v4_1 */
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
 {
@@ -276,6 +283,12 @@ static inline int nfs4_init_session(struct nfs_server *server)
 {
 	return 0;
 }
+
+static inline bool
+is_ds_only_client(struct nfs_client *clp)
+{
+	return false;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index b32a792..134716e 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -131,13 +131,6 @@
 #define EXCHGID4_FLAG_MASK_A			0x40070103
 #define EXCHGID4_FLAG_MASK_R			0x80070103
 
-static inline bool
-is_ds_only_session(u32 exchange_flags)
-{
-	u32 mask = EXCHGID4_FLAG_USE_PNFS_DS | EXCHGID4_FLAG_USE_PNFS_MDS;
-	return (exchange_flags & mask) == EXCHGID4_FLAG_USE_PNFS_DS;
-}
-
 #define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED	0x00000004
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 017f835..b197563 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -87,16 +87,6 @@ struct nfs_client {
 #endif
 };
 
-static inline bool
-is_ds_only_client(struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4_1
-	return is_ds_only_session(clp->cl_exchange_flags);
-#else
-	return false;
-#endif
-}
-
 /*
  * NFS client parameters stored in the superblock.
  */
-- 
1.6.6

