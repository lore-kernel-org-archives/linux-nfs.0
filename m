Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56557 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993Ab3J3RiR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Oct 2013 13:38:17 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Add support for NFS v4.2 operation checking
Date: Wed, 30 Oct 2013 13:38:13 -0400
Message-ID: <1383154693-29741-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server does allow NFS over v4.2, even if it doesn't add any new
operations yet.

I also switch to using constants to represent the last operation for
each minor version since this makes the code cleaner and easier to
understand at a quick glance.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4xdr.c    | 8 +++++---
 include/linux/nfs4.h | 3 +++
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 99bebea..83db5a7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1585,11 +1585,13 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 static inline bool
 nfsd4_opnum_in_range(struct nfsd4_compoundargs *argp, struct nfsd4_op *op)
 {
-	if (op->opnum < FIRST_NFS4_OP || op->opnum > LAST_NFS4_OP)
+	if (op->opnum < FIRST_NFS4_OP)
 		return false;
-	else if (argp->minorversion == 0 && op->opnum > OP_RELEASE_LOCKOWNER)
+	else if (argp->minorversion == 0 && op->opnum > LAST_NFS40_OP)
 		return false;
-	else if (argp->minorversion == 1 && op->opnum > OP_RECLAIM_COMPLETE)
+	else if (argp->minorversion == 1 && op->opnum > LAST_NFS41_OP)
+		return false;
+	else if (argp->minorversion == 2 && op->opnum > LAST_NFS42_OP)
 		return false;
 	return true;
 }
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c56fa8f..9577769 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -118,6 +118,9 @@ Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
 #define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
+#define LAST_NFS40_OP	OP_RELEASE_LOCKOWNER
+#define LAST_NFS41_OP	OP_RECLAIM_COMPLETE
+#define LAST_NFS42_OP	OP_RECLAIM_COMPLETE
 
 enum nfsstat4 {
 	NFS4_OK = 0,
-- 
1.8.4.2

