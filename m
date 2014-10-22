Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:9213 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071AbaJVTsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 15:48:06 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: SEEK is an NFS v4.2 feature
Date: Wed, 22 Oct 2014 15:48:02 -0400
Message-ID: <1414007282-2358-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Somehow the nfs_v4_1_minor_ops had the NFS_CAP_SEEK flag set, enabling
SEEK over v4.1.  This is wrong, and can make servers crash.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 405bd95..07b041a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8409,7 +8409,6 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
-		| NFS_CAP_SEEK,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
@@ -8432,6 +8431,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
+		| NFS_CAP_SEEK,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
-- 
2.1.2

