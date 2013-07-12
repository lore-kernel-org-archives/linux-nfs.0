Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f170.google.com ([209.85.213.170]:46457 "EHLO
	mail-ye0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992Ab3GLQbz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:31:55 -0400
Received: by mail-ye0-f170.google.com with SMTP id q3so3225031yen.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:31:55 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id s80sm69030587yhe.27.2013.07.12.09.31.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:31:54 -0700 (PDT)
Subject: [PATCH v1 03/19] NFS: Introduce a vector of migration recovery ops
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:31:53 -0400
Message-ID: <20130712163153.1444.48514.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The differences between minor version 0 and minor version 1
migration will be abstracted by the addition of a set of migration
recovery ops.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h  |    4 ++++
 fs/nfs/nfs4proc.c |   10 ++++++++++
 2 files changed, 14 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3bc554e..40457e2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -52,6 +52,7 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
+	const struct nfs4_mig_recovery_ops *mig_recovery_ops;
 };
 
 #define NFS_SEQID_CONFIRMED 1
@@ -204,6 +205,9 @@ struct nfs4_state_maintenance_ops {
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
+struct nfs4_mig_recovery_ops {
+};
+
 extern const struct dentry_operations nfs4_dentry_operations;
 
 /* dir.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d74a2b5..2f6f3b9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6966,6 +6966,14 @@ static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 };
 #endif
 
+static const struct nfs4_mig_recovery_ops nfs40_mig_recovery_ops = {
+};
+
+#if defined(CONFIG_NFS_V4_1)
+static const struct nfs4_mig_recovery_ops nfs41_mig_recovery_ops = {
+};
+#endif	/* CONFIG_NFS_V4_1 */
+
 static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
 	.init_caps = NFS_CAP_READDIRPLUS
@@ -6979,6 +6987,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
+	.mig_recovery_ops = &nfs40_mig_recovery_ops,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -6997,6 +7006,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
+	.mig_recovery_ops = &nfs41_mig_recovery_ops,
 };
 #endif
 

