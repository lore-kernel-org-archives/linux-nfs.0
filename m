Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:30938 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933170AbbGJU7N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 16:59:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 6/9] NFS: Remove nfs4_match_stateid()
Date: Fri, 10 Jul 2015 16:58:14 -0400
Message-ID: <1436561897-8051-7-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Let's just call nfs4_stateid_match() directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6f228b5..b911fb0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8514,12 +8514,6 @@ static bool nfs41_match_stateid(const nfs4_stateid *s1,
 
 #endif /* CONFIG_NFS_V4_1 */
 
-static bool nfs4_match_stateid(const nfs4_stateid *s1,
-		const nfs4_stateid *s2)
-{
-	return nfs4_stateid_match(s1, s2);
-}
-
 
 static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
@@ -8594,7 +8588,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 		| NFS_CAP_POSIX_LOCK,
 	.init_client = nfs40_init_client,
 	.shutdown_client = nfs40_shutdown_client,
-	.match_stateid = nfs4_match_stateid,
+	.match_stateid = nfs4_stateid_match,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
 	.alloc_seqid = nfs_alloc_seqid,
-- 
2.4.5

