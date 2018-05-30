Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:37521 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932127AbeE3SG3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:29 -0400
Received: by mail-it0-f66.google.com with SMTP id l6-v6so11285155iti.2
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:29 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.27
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:27 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/19] pnfs: Fix manipulation of NFS_LAYOUT_FIRST_LAYOUTGET
Date: Wed, 30 May 2018 14:05:48 -0400
Message-Id: <20180530180553.38769-15-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-14-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
 <20180530180553.38769-4-trond.myklebust@hammerspace.com>
 <20180530180553.38769-5-trond.myklebust@hammerspace.com>
 <20180530180553.38769-6-trond.myklebust@hammerspace.com>
 <20180530180553.38769-7-trond.myklebust@hammerspace.com>
 <20180530180553.38769-8-trond.myklebust@hammerspace.com>
 <20180530180553.38769-9-trond.myklebust@hammerspace.com>
 <20180530180553.38769-10-trond.myklebust@hammerspace.com>
 <20180530180553.38769-11-trond.myklebust@hammerspace.com>
 <20180530180553.38769-12-trond.myklebust@hammerspace.com>
 <20180530180553.38769-13-trond.myklebust@hammerspace.com>
 <20180530180553.38769-14-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

The flag was not always being cleared after LAYOUTGET on OPEN.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++++++-
 fs/nfs/pnfs.c     |  9 ++-------
 fs/nfs/pnfs.h     |  6 ++++++
 3 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 659ba6f0ca9b..53f93c3993c8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1244,6 +1244,19 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	return NULL;
 }
 
+static void nfs4_lgopen_release(void *calldata)
+{
+	struct nfs4_layoutget *lgp = calldata;
+	struct inode *inode = lgp->args.inode;
+
+	if (inode) {
+		struct pnfs_layout_hdr *lo = NFS_I(inode)->layout;
+		atomic_dec(&lo->plh_outstanding);
+		pnfs_clear_first_layoutget(lo);
+	}
+	nfs4_layoutget_release(lgp);
+}
+
 static void nfs4_opendata_free(struct kref *kref)
 {
 	struct nfs4_opendata *p = container_of(kref,
@@ -1251,7 +1264,7 @@ static void nfs4_opendata_free(struct kref *kref)
 	struct super_block *sb = p->dentry->d_sb;
 
 	if (p->lgp)
-		nfs4_layoutget_release(p->lgp);
+		nfs4_lgopen_release(p->lgp);
 	nfs_free_seqid(p->o_arg.seqid);
 	nfs4_sequence_free_slot(&p->o_res.seq_res);
 	if (p->state != NULL)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5621b85a5c24..037e6b9b047b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1678,7 +1678,7 @@ static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr *lo)
 				   TASK_UNINTERRUPTIBLE);
 }
 
-static void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo)
+void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo)
 {
 	unsigned long *bitlock = &lo->plh_flags;
 
@@ -2079,13 +2079,11 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 		lgp->args.inode = ino;
 	} else
 		lo = NFS_I(lgp->args.inode)->layout;
-	pnfs_get_layout_hdr(lo);
 
 	if (read_seqcount_retry(&srv->nfs_client->cl_callback_count,
 				lgp->callback_count))
-		goto out;
+		return;
 	lseg = pnfs_layout_process(lgp);
-	atomic_dec(&lo->plh_outstanding);
 	if (IS_ERR(lseg)) {
 		/* ignore lseg, but would like to mark not to try lgopen */
 		/* clear some lo flags - first and fail ???? */
@@ -2094,9 +2092,6 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 		pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
 		pnfs_put_lseg(lseg);
 	}
-out:
-	pnfs_clear_first_layoutget(lo);
-	pnfs_put_layout_hdr(lo);
 }
 
 struct pnfs_layout_segment *
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b110c09ea89c..fc714caff52e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -380,6 +380,7 @@ void pnfs_layout_mark_request_commit(struct nfs_page *req,
 				     struct pnfs_layout_segment *lseg,
 				     struct nfs_commit_info *cinfo,
 				     u32 ds_commit_idx);
+void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo);
 void pnfs_lgopen_prepare(struct nfs4_opendata *data,
 			 struct nfs_open_context *ctx);
 void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
@@ -795,6 +796,11 @@ static inline void pnfs_parse_lgopen(struct inode *ino,
 		struct nfs_open_context *ctx)
 {
 }
+
+static inline void pnfs_clear_first_layoutget(struct pnfs_layout_hdr *lo)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #if IS_ENABLED(CONFIG_NFS_V4_2)
-- 
2.17.0

