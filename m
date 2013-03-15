Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f43.google.com ([209.85.160.43]:51079 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab3COA6O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Mar 2013 20:58:14 -0400
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfsd: remove unnecessary permission checking in nfsv4
Date: Fri, 15 Mar 2013 08:46:07 +0800
Message-Id: <1363308367-13314-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

Since read can use stateid's from opens that only requested write access,
the value returned from access_permit_read() will always be true. It's not
necessary to check read permission in nfsv4.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4state.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..42824cd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3287,14 +3287,6 @@ STALE_STATEID(stateid_t *stateid, struct nfsd_net *nn)
 }
 
 static inline int
-access_permit_read(struct nfs4_ol_stateid *stp)
-{
-	return test_access(NFS4_SHARE_ACCESS_READ, stp) ||
-		test_access(NFS4_SHARE_ACCESS_BOTH, stp) ||
-		test_access(NFS4_SHARE_ACCESS_WRITE, stp);
-}
-
-static inline int
 access_permit_write(struct nfs4_ol_stateid *stp)
 {
 	return test_access(NFS4_SHARE_ACCESS_WRITE, stp) ||
@@ -3304,17 +3296,13 @@ access_permit_write(struct nfs4_ol_stateid *stp)
 static
 __be32 nfs4_check_openmode(struct nfs4_ol_stateid *stp, int flags)
 {
-        __be32 status = nfserr_openmode;
+	__be32 status = nfs_ok;
 
 	/* For lock stateid's, we test the parent open, not the lock: */
 	if (stp->st_openstp)
 		stp = stp->st_openstp;
 	if ((flags & WR_STATE) && !access_permit_write(stp))
-                goto out;
-	if ((flags & RD_STATE) && !access_permit_read(stp))
-                goto out;
-	status = nfs_ok;
-out:
+		status = nfserr_openmode;
 	return status;
 }
 
-- 
1.7.4.4

