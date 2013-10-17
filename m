Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22748 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758657Ab3JQSMl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:41 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICeWl012723
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:41 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICdIx019115
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:39 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/21] NFS: Introduce a vector of migration recovery ops
Date: Thu, 17 Oct 2013 14:12:39 -0400
Message-Id: <20131017181239.1073.50044.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
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
index fcae728..4f48000 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -50,6 +50,7 @@ struct nfs4_minor_version_ops {
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
+	const struct nfs4_mig_recovery_ops *mig_recovery_ops;
 };
 
 #define NFS_SEQID_CONFIRMED 1
@@ -203,6 +204,9 @@ struct nfs4_state_maintenance_ops {
 	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
 };
 
+struct nfs4_mig_recovery_ops {
+};
+
 extern const struct dentry_operations nfs4_dentry_operations;
 
 /* dir.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d53d678..e4bd317 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7887,6 +7887,14 @@ static const struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
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
@@ -7902,6 +7910,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
+	.mig_recovery_ops = &nfs40_mig_recovery_ops,
 };
 
 #if defined(CONFIG_NFS_V4_1)
@@ -7922,6 +7931,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
+	.mig_recovery_ops = &nfs41_mig_recovery_ops,
 };
 #endif
 

