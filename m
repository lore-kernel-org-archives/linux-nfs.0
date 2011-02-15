Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038Ab1BPSjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:04 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 2 07/18] NFSv4.1: add MDS mount DS only check
Date: Tue, 15 Feb 2011 03:38:52 -0500
Message-Id: <1297759143-2045-8-git-send-email-andros@netapp.com>
In-Reply-To: <1297759143-2045-1-git-send-email-andros@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

The DS only role cannot be used to mount.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c  |    6 ++++++
 fs/nfs/nfs4_fs.h |   13 +++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 280d41f6..4a501d0 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1400,6 +1400,12 @@ static int nfs4_set_client(struct nfs_server *server,
 		goto error;
 	}
 
+	/* Cannot mount a DS only server */
+	if (is_ds_only_client(clp)) {
+		error = -ENODEV;
+		goto error;
+	}
+
 	/*
 	 * Query for the lease time on clientid setup or renewal
 	 *
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
1.7.2.3

