Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35549 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbbJTReM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:12 -0400
Received: by qgbb65 with SMTP id b65so21696149qgb.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:12 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 15/19] nfsd: convert nfs4_file->fi_fds array to use nfsd_files
Date: Tue, 20 Oct 2015 13:33:48 -0400
Message-Id: <1445362432-18869-16-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 23 ++++++++++++-----------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2b73e2885a82..b72fa6816860 100644
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
 
@@ -3841,7 +3842,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 		struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp,
 		struct nfsd4_open *open)
 {
-	struct file *filp = NULL;
+	struct nfsd_file *nf = NULL;
 	__be32 status;
 	int oflag = nfs4_access_to_omode(open->op_share_access);
 	int access = nfs4_access_to_access(open->op_share_access);
@@ -3877,18 +3878,18 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 
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

