Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:62456 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:51 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so5325912qge.32
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 011/100] nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
Date: Tue,  8 Jul 2014 14:02:59 -0400
Message-Id: <1404842668-22521-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have them take NFS4_SHARE_ACCESS_* flags instead of an open mode. This
spares the callers from having to convert it themselves.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 59 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 775267ed186a..2c49cd909115 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -341,6 +341,20 @@ static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
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
@@ -355,8 +369,15 @@ static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 	atomic_inc(&fp->fi_access[oflag]);
 }
 
-static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
+	int oflag = nfs4_access_to_omode(access);
+
+	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
+	access &= NFS4_SHARE_ACCESS_BOTH;
+	if (access == 0)
+		return;
+
 	if (oflag == O_RDWR) {
 		__nfs4_file_get_access(fp, O_RDONLY);
 		__nfs4_file_get_access(fp, O_WRONLY);
@@ -392,8 +413,16 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 	}
 }
 
-static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
+static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 {
+	int oflag;
+
+	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
+	access &= NFS4_SHARE_ACCESS_BOTH;
+	if (!access)
+		return;
+
+	oflag = nfs4_access_to_omode(access);
 	if (oflag == O_RDWR) {
 		__nfs4_file_put_access(fp, O_RDONLY);
 		__nfs4_file_put_access(fp, O_WRONLY);
@@ -747,20 +776,6 @@ test_deny(u32 access, struct nfs4_ol_stateid *stp)
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
@@ -769,8 +784,7 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 	for (i = 1; i < 4; i++) {
 		if (test_access(i, stp))
-			nfs4_file_put_access(stp->st_file,
-					     nfs4_access_to_omode(i));
+			nfs4_file_put_access(stp->st_file, i);
 		clear_access(i, stp);
 	}
 }
@@ -3302,7 +3316,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 			filp = NULL;
 		}
 	}
-	nfs4_file_get_access(fp, oflag);
+	nfs4_file_get_access(fp, open->op_share_access);
 	spin_unlock(&fp->fi_lock);
 	if (filp)
 		fput(filp);
@@ -3314,7 +3328,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	return nfs_ok;
 
 out_put_access:
-	nfs4_file_put_access(fp, oflag);
+	nfs4_file_put_access(fp, open->op_share_access);
 out:
 	return status;
 }
@@ -4223,7 +4237,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(access));
+	nfs4_file_put_access(stp->st_file, access);
 	clear_access(access, stp);
 }
 
@@ -4548,11 +4562,10 @@ check_lock_length(u64 offset, u64 length)
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

