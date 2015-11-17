Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:35632 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbbKQLxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:37 -0500
Received: by qkao63 with SMTP id o63so1676289qka.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:36 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 18/38] nfsd: convert nfs4_file->fi_fds array to use nfsd_files
Date: Tue, 17 Nov 2015 06:52:40 -0500
Message-Id: <1447761180-4250-19-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 23 ++++++++++++-----------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b800b5b8fed..e7adb6b60005 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -49,6 +49,7 @@
 
 #include "netns.h"
 #include "pnfs.h"
+#include "filecache.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -292,7 +293,7 @@ static struct file *
 __nfs4_get_fd(struct nfs4_file *f, int oflag)
 {
 	if (f->fi_fds[oflag])
-		return get_file(f->fi_fds[oflag]);
+		return get_file(f->fi_fds[oflag]->nf_file);
 	return NULL;
 }
 
@@ -449,17 +450,17 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 	might_lock(&fp->fi_lock);
 
 	if (atomic_dec_and_lock(&fp->fi_access[oflag], &fp->fi_lock)) {
-		struct file *f1 = NULL;
-		struct file *f2 = NULL;
+		struct nfsd_file *f1 = NULL;
+		struct nfsd_file *f2 = NULL;
 
 		swap(f1, fp->fi_fds[oflag]);
 		if (atomic_read(&fp->fi_access[1 - oflag]) == 0)
 			swap(f2, fp->fi_fds[O_RDWR]);
 		spin_unlock(&fp->fi_lock);
 		if (f1)
-			fput(f1);
+			nfsd_file_put(f1);
 		if (f2)
-			fput(f2);
+			nfsd_file_put(f2);
 	}
 }
 
@@ -3915,7 +3916,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 		struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp,
 		struct nfsd4_open *open)
 {
-	struct file *filp = NULL;
+	struct nfsd_file *nf = NULL;
 	__be32 status;
 	int oflag = nfs4_access_to_omode(open->op_share_access);
 	int access = nfs4_access_to_access(open->op_share_access);
@@ -3951,18 +3952,18 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 
 	if (!fp->fi_fds[oflag]) {
 		spin_unlock(&fp->fi_lock);
-		status = nfsd_open(rqstp, cur_fh, S_IFREG, access, &filp);
+		status = nfsd_file_acquire(rqstp, cur_fh, access, &nf);
 		if (status)
 			goto out_put_access;
 		spin_lock(&fp->fi_lock);
 		if (!fp->fi_fds[oflag]) {
-			fp->fi_fds[oflag] = filp;
-			filp = NULL;
+			fp->fi_fds[oflag] = nf;
+			nf = NULL;
 		}
 	}
 	spin_unlock(&fp->fi_lock);
-	if (filp)
-		fput(filp);
+	if (nf)
+		nfsd_file_put(nf);
 
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 77fdf4de91ba..473faa436e07 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -491,7 +491,7 @@ struct nfs4_file {
 	};
 	struct list_head	fi_clnt_odstate;
 	/* One each for O_RDONLY, O_WRONLY, O_RDWR: */
-	struct file *		fi_fds[3];
+	struct nfsd_file	*fi_fds[3];
 	/*
 	 * Each open or lock stateid contributes 0-4 to the counts
 	 * below depending on which bits are set in st_access_bitmap:
-- 
2.4.3

