Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:53158 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaGJSHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:07:50 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so2233831qae.6
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 04/11] nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
Date: Thu, 10 Jul 2014 14:07:28 -0400
Message-Id: <1405015655-12469-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have them take NFS4_SHARE_ACCESS_* flags instead of an open mode. This
spares the callers from having to convert it themselves.

This also allows us to simplify these functions as we no longer need
to do the access_to_omode conversion in either one.

Note too that this patch eliminates the WARN_ON in
__nfs4_file_get_access. It's valid for now, but in a later patch we'll
be bumping the refcounts prior to opening the file in order to close
some races, at which point we'll need to remove it anyway.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 48 +++++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4ab567e7db0f..a19257f91f25 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -374,19 +374,24 @@ static unsigned int file_hashval(struct inode *ino)
 
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 
-static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+static void
+__nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
-	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
-	atomic_inc(&fp->fi_access[oflag]);
+	if (access & NFS4_SHARE_ACCESS_WRITE)
+		atomic_inc(&fp->fi_access[O_WRONLY]);
+	if (access & NFS4_SHARE_ACCESS_READ)
+		atomic_inc(&fp->fi_access[O_RDONLY]);
 }
 
-static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+static __be32
+nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 {
-	if (oflag == O_RDWR) {
-		__nfs4_file_get_access(fp, O_RDONLY);
-		__nfs4_file_get_access(fp, O_WRONLY);
-	} else
-		__nfs4_file_get_access(fp, oflag);
+	/* Does this access mode make sense? */
+	if (access & ~NFS4_SHARE_ACCESS_BOTH)
+		return nfserr_inval;
+
+	__nfs4_file_get_access(fp, access);
+	return nfs_ok;
 }
 
 static struct file *nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
@@ -417,13 +422,14 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 	}
 }
 
-static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
+static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 {
-	if (oflag == O_RDWR) {
-		__nfs4_file_put_access(fp, O_RDONLY);
+	WARN_ON_ONCE(access & ~NFS4_SHARE_ACCESS_BOTH);
+
+	if (access & NFS4_SHARE_ACCESS_WRITE)
 		__nfs4_file_put_access(fp, O_WRONLY);
-	} else
-		__nfs4_file_put_access(fp, oflag);
+	if (access & NFS4_SHARE_ACCESS_READ)
+		__nfs4_file_put_access(fp, O_RDONLY);
 }
 
 static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
@@ -784,8 +790,7 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 	for (i = 1; i < 4; i++) {
 		if (test_access(i, stp))
-			nfs4_file_put_access(stp->st_file,
-					     nfs4_access_to_omode(i));
+			nfs4_file_put_access(stp->st_file, i);
 		clear_access(i, stp);
 	}
 }
@@ -3307,10 +3312,12 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 			filp = NULL;
 		}
 	}
-	nfs4_file_get_access(fp, oflag);
+	status = nfs4_file_get_access(fp, open->op_share_access);
 	spin_unlock(&fp->fi_lock);
 	if (filp)
 		fput(filp);
+	if (status)
+		goto out_put_access;
 
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status)
@@ -3319,7 +3326,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	return nfs_ok;
 
 out_put_access:
-	nfs4_file_put_access(fp, oflag);
+	nfs4_file_put_access(fp, open->op_share_access);
 out:
 	return status;
 }
@@ -4228,7 +4235,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(access));
+	nfs4_file_put_access(stp->st_file, access);
 	clear_access(access, stp);
 }
 
@@ -4555,11 +4562,10 @@ check_lock_length(u64 offset, u64 length)
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
-	int oflag = nfs4_access_to_omode(access);
 
 	if (test_access(access, lock_stp))
 		return;
-	nfs4_file_get_access(fp, oflag);
+	__nfs4_file_get_access(fp, access);
 	set_access(access, lock_stp);
 }
 
-- 
1.9.3

