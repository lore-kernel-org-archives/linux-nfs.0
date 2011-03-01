Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757133Ab1CAR36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:58 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 3 07/18] NFSv4.1: add MDS mount DS only check
Date: Mon, 28 Feb 2011 20:34:12 -0500
Message-Id: <1298943263-2886-8-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-7-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The DS only role cannot be used to mount.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c  |    4 ++++
 fs/nfs/nfs4_fs.h |   13 +++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 280d41f..d5c5bdf 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1453,6 +1453,10 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	BUG_ON(!server->nfs_client->rpc_ops);
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
+	/* data servers support only a subset of NFSv4.1 */
+	if (is_ds_only_client(server->nfs_client))
+		return -EPROTONOSUPPORT;
+
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
 		return -ENOMEM;
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
-- 
1.6.6

