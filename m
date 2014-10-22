Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:38608 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085AbaJVTxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2014 15:53:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFS: SEEK is an NFS v4.2 feature
Date: Wed, 22 Oct 2014 15:53:10 -0400
Message-ID: <1414007590-14286-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Somehow the nfs_v4_1_minor_ops had the NFS_CAP_SEEK flag set, enabling
SEEK over v4.1.  This is wrong, and can make servers crash.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
v2: Fix compile error

 fs/nfs/nfs4proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 405bd95..8aba549 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8408,8 +8408,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
-		| NFS_CAP_ATOMIC_OPEN_V1
-		| NFS_CAP_SEEK,
+		| NFS_CAP_ATOMIC_OPEN_V1,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
@@ -8431,7 +8430,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
-		| NFS_CAP_ATOMIC_OPEN_V1,
+		| NFS_CAP_ATOMIC_OPEN_V1
+		| NFS_CAP_SEEK,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
-- 
2.1.2

