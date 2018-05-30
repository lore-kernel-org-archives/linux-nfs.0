Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:40239 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753685AbeE3SG2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:28 -0400
Received: by mail-io0-f196.google.com with SMTP id g14-v6so22712735ioc.7
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:27 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.26
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:26 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/19] pnfs: Stop attempting LAYOUTGET on OPEN on failure
Date: Wed, 30 May 2018 14:05:46 -0400
Message-Id: <20180530180553.38769-13-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-12-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c         |  4 +++-
 fs/nfs/pnfs.c             | 19 ++++++++++++++++++-
 include/linux/nfs_fs_sb.h |  1 +
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a73c83f17a86..659ba6f0ca9b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9507,7 +9507,8 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
-		| NFS_CAP_ATOMIC_OPEN_V1,
+		| NFS_CAP_ATOMIC_OPEN_V1
+		| NFS_CAP_LGOPEN,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
@@ -9532,6 +9533,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
+		| NFS_CAP_LGOPEN
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_COPY
 		| NFS_CAP_DEALLOCATE
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 258b68110277..b2158e5bf7f7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2038,6 +2038,8 @@ void pnfs_lgopen_prepare(struct nfs4_opendata *data,
 	      server->pnfs_curr_ld->flags & PNFS_LAYOUTGET_ON_OPEN))
 		return;
 	/* Could check on max_ops, but currently hardcoded high enough */
+	if (!nfs_server_capable(data->dir->d_inode, NFS_CAP_LGOPEN))
+		return;
 	if (data->state)
 		_lgopen_prepare_attached(data, ctx);
 	else
@@ -2051,8 +2053,23 @@ void pnfs_parse_lgopen(struct inode *ino, struct nfs4_layoutget *lgp,
 	struct pnfs_layout_segment *lseg;
 	u32 iomode;
 
-	if (!lgp || lgp->res.layoutp->len == 0)
+	if (!lgp)
 		return;
+	dprintk("%s: entered with status %i\n", __func__, lgp->res.status);
+	if (lgp->res.status) {
+		switch (lgp->res.status) {
+		case -NFS4ERR_DELAY:
+		case -NFS4ERR_GRACE:
+		case -NFS4ERR_LAYOUTTRYLATER:
+			break;
+		default:
+			/* FIXME - Any error not listed above permanently
+			 * halts lgopen attempts.
+			 */
+			NFS_SERVER(ino)->caps &= ~NFS_CAP_LGOPEN;
+		}
+		return;
+	}
 	if (!lgp->args.inode) {
 		lo = _pnfs_grab_empty_layout(ino, ctx);
 		if (!lo)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4e735be53e70..2c18d618604e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -235,6 +235,7 @@ struct nfs_server {
 #define NFS_CAP_ACLS		(1U << 3)
 #define NFS_CAP_ATOMIC_OPEN	(1U << 4)
 /* #define NFS_CAP_CHANGE_ATTR	(1U << 5) */
+#define NFS_CAP_LGOPEN		(1U << 5)
 #define NFS_CAP_FILEID		(1U << 6)
 #define NFS_CAP_MODE		(1U << 7)
 #define NFS_CAP_NLINK		(1U << 8)
-- 
2.17.0

