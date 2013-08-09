Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f54.google.com ([209.85.213.54]:56546 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968210Ab3HIQuo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:50:44 -0400
Received: by mail-yh0-f54.google.com with SMTP id f10so1506251yha.13
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:50:43 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id m63sm20689877yhb.10.2013.08.09.09.50.41
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:50:42 -0700 (PDT)
Subject: [PATCH v2 20/33] NFS: Introduce a vector of migration recovery ops
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:50:41 -0400
Message-ID: <20130809165041.5362.9024.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
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
index 75b2335..02af354 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -50,6 +50,7 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
+	const struct nfs4_mig_recovery_ops *mig_recovery_ops;
 };
 
 #define NFS_SEQID_CONFIRMED 1
@@ -202,6 +203,9 @@ struct nfs4_state_maintenance_ops {
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
+struct nfs4_mig_recovery_ops {
+};
+
 extern const struct dentry_operations nfs4_dentry_operations;
 
 /* dir.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5640dc0..513de09 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7501,6 +7501,14 @@ static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
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
@@ -7516,6 +7524,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
+	.mig_recovery_ops = &nfs40_mig_recovery_ops,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -7536,6 +7545,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
+	.mig_recovery_ops = &nfs41_mig_recovery_ops,
 };
 #endif
 

