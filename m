Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:32776 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbaFZTO3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:29 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so3406550qgd.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:28 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 031/117] nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
Date: Thu, 26 Jun 2014 15:12:11 -0400
Message-Id: <1403810017-16062-32-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have them take NFS4_SHARE_ACCESS_* flags instead of an open mode. This
spares the callers from having to convert it themselves.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 58 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 35 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 40171e2f9178..a6f1549a560e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -340,6 +340,20 @@ static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 
+static int nfs4_access_to_omode(u32 access)
+{
+	switch (access & NFS4_SHARE_ACCESS_BOTH) {
+	case NFS4_SHARE_ACCESS_READ:
+		return O_RDONLY;
+	case NFS4_SHARE_ACCESS_WRITE:
+		return O_WRONLY;
+	case NFS4_SHARE_ACCESS_BOTH:
+		return O_RDWR;
+	}
+	WARN_ON_ONCE(1);
+	return O_RDONLY;
+}
+
 static unsigned int file_hashval(struct inode *ino)
 {
 	/* XXX: why are we hashing on inode pointer, anyway? */
@@ -354,8 +368,15 @@ static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 	atomic_inc(&fp->fi_access[oflag]);
 }
 
-static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
+	int oflag = nfs4_access_to_omode(access);
+
+	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
+	access &= (NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE);
+	if (access == 0)
+		return;
+
 	if (oflag == O_RDWR) {
 		__nfs4_file_get_access(fp, O_RDONLY);
 		__nfs4_file_get_access(fp, O_WRONLY);
@@ -389,8 +410,15 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 	}
 }
 
-static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
+static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 {
+	int oflag;
+
+	access &= (NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE);
+	if (!access)
+		return;
+
+	oflag = nfs4_access_to_omode(access);
 	if (oflag == O_RDWR) {
 		__nfs4_file_put_access(fp, O_RDONLY);
 		__nfs4_file_put_access(fp, O_WRONLY);
@@ -744,20 +772,6 @@ test_deny(u32 access, struct nfs4_ol_stateid *stp)
 	return test_bit(access, &stp->st_deny_bmap);
 }
 
-static int nfs4_access_to_omode(u32 access)
-{
-	switch (access & NFS4_SHARE_ACCESS_BOTH) {
-	case NFS4_SHARE_ACCESS_READ:
-		return O_RDONLY;
-	case NFS4_SHARE_ACCESS_WRITE:
-		return O_WRONLY;
-	case NFS4_SHARE_ACCESS_BOTH:
-		return O_RDWR;
-	}
-	WARN_ON_ONCE(1);
-	return O_RDONLY;
-}
-
 /* release all access and file references for a given stateid */
 static void
 release_all_access(struct nfs4_ol_stateid *stp)
@@ -766,8 +780,7 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 	for (i = 1; i < 4; i++) {
 		if (test_access(i, stp))
-			nfs4_file_put_access(stp->st_file,
-					     nfs4_access_to_omode(i));
+			nfs4_file_put_access(stp->st_file, i);
 		clear_access(i, stp);
 	}
 }
@@ -3264,7 +3277,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 			filp = NULL;
 		}
 	}
-	nfs4_file_get_access(fp, oflag);
+	nfs4_file_get_access(fp, open->op_share_access);
 	spin_unlock(&fp->fi_lock);
 	if (filp)
 		fput(filp);
@@ -3276,7 +3289,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	return nfs_ok;
 
 out_put_access:
-	nfs4_file_put_access(fp, oflag);
+	nfs4_file_put_access(fp, open->op_share_access);
 out:
 	return status;
 }
@@ -4211,7 +4224,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(access));
+	nfs4_file_put_access(stp->st_file, access);
 	clear_access(access, stp);
 }
 
@@ -4536,11 +4549,10 @@ check_lock_length(u64 offset, u64 length)
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
-	int oflag = nfs4_access_to_omode(access);
 
 	if (test_access(access, lock_stp))
 		return;
-	nfs4_file_get_access(fp, oflag);
+	nfs4_file_get_access(fp, access);
 	set_access(access, lock_stp);
 }
 
-- 
1.9.3

