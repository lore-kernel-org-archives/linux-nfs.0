From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 30/46] nfs41: stubs for nfs41 procedures
Date: Wed,  4 Mar 2009 01:59:08 +0200
Message-ID: <1236124748-3812-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17755
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753721AbZCCX7W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:59:22 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h  |    2 ++
 fs/nfs/nfs4proc.c |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5d7b036..8e2eaa9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -205,6 +205,8 @@ extern struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops;
 #if defined(CONFIG_NFS_V4_1)
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
+extern int nfs4_proc_create_session(struct nfs4_session *);
+extern int nfs4_proc_destroy_session(struct nfs4_session *);
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const u32 nfs4_fattr_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7b69f00..bd2b62c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3802,6 +3802,11 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 }
 
 #ifdef CONFIG_NFS_V4_1
+static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	return -1;	/* stub */
+}
+
 /*
  * Initialize slot table
  */
@@ -3876,6 +3881,27 @@ void nfs4_destroy_session(struct nfs4_session *session)
 	kfree(session);
 }
 
+int nfs4_proc_create_session(struct nfs4_session *session)
+{
+	return -1;      /* stub */
+}
+
+int nfs4_proc_destroy_session(struct nfs4_session *session)
+{
+	return -1;      /* stub */
+}
+
+static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	return -1;      /* stub */
+}
+
+static int nfs41_proc_async_sequence(struct nfs_client *clp,
+				     struct rpc_cred *cred)
+{
+	return -1;      /* stub */
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
-- 
1.6.1.3

