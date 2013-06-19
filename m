Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934170Ab3FSRlp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jun 2013 13:41:45 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Apply v4.1 capabilities to v4.2
Date: Wed, 19 Jun 2013 13:41:43 -0400
Message-Id: <1371663703-4095-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This fixes POSIX locks and possibly a few other v4.2 features, like
readdir plus.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f27fdc2..86035d2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7451,9 +7451,16 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 #if defined(CONFIG_NFS_V4_2)
 static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 	.minor_version = 2,
+	.init_caps = NFS_CAP_READDIRPLUS
+		| NFS_CAP_ATOMIC_OPEN
+		| NFS_CAP_CHANGE_ATTR
+		| NFS_CAP_POSIX_LOCK
+		| NFS_CAP_STATEID_NFSV41
+		| NFS_CAP_ATOMIC_OPEN_V1,
 	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
+	.free_lock_state = nfs41_free_lock_state,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
-- 
1.8.3.1

