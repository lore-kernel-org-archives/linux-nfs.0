Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49270 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbbAGA3q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 19:29:46 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so1106662pad.3
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 16:29:45 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 33/49] nfs: rename pgio header ds_idx to ds_commit_idx
Date: Tue,  6 Jan 2015 16:28:38 -0800
Message-Id: <1420590534-84063-34-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

'ds_commit_idx' is a better name - it is used to select the right
commit bucket for pnfs.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/direct.c                | 14 ++++++--------
 fs/nfs/filelayout/filelayout.c |  4 ++--
 include/linux/nfs_xdr.h        |  2 +-
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e84f764..d7c2d43 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -112,22 +112,22 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
  * nfs_direct_select_verf - select the right verifier
  * @dreq - direct request possibly spanning multiple servers
  * @ds_clp - nfs_client of data server or NULL if MDS / non-pnfs
- * @ds_idx - index of data server in data server list, only valid if ds_clp set
+ * @commit_idx - commit bucket index for the DS
  *
  * returns the correct verifier to use given the role of the server
  */
 static struct nfs_writeverf *
 nfs_direct_select_verf(struct nfs_direct_req *dreq,
 		       struct nfs_client *ds_clp,
-		       int ds_idx)
+		       int commit_idx)
 {
 	struct nfs_writeverf *verfp = &dreq->verf;
 
 #ifdef CONFIG_NFS_V4_1
 	if (ds_clp) {
 		/* pNFS is in use, use the DS verf */
-		if (ds_idx >= 0 && ds_idx < dreq->ds_cinfo.nbuckets)
-			verfp = &dreq->ds_cinfo.buckets[ds_idx].direct_verf;
+		if (commit_idx >= 0 && commit_idx < dreq->ds_cinfo.nbuckets)
+			verfp = &dreq->ds_cinfo.buckets[commit_idx].direct_verf;
 		else
 			WARN_ON_ONCE(1);
 	}
@@ -148,8 +148,7 @@ static void nfs_direct_set_hdr_verf(struct nfs_direct_req *dreq,
 {
 	struct nfs_writeverf *verfp;
 
-	verfp = nfs_direct_select_verf(dreq, hdr->ds_clp,
-				      hdr->ds_idx);
+	verfp = nfs_direct_select_verf(dreq, hdr->ds_clp, hdr->ds_commit_idx);
 	WARN_ON_ONCE(verfp->committed >= 0);
 	memcpy(verfp, &hdr->verf, sizeof(struct nfs_writeverf));
 	WARN_ON_ONCE(verfp->committed < 0);
@@ -169,8 +168,7 @@ static int nfs_direct_set_or_cmp_hdr_verf(struct nfs_direct_req *dreq,
 {
 	struct nfs_writeverf *verfp;
 
-	verfp = nfs_direct_select_verf(dreq, hdr->ds_clp,
-					 hdr->ds_idx);
+	verfp = nfs_direct_select_verf(dreq, hdr->ds_clp, hdr->ds_commit_idx);
 	if (verfp->committed < 0) {
 		nfs_direct_set_hdr_verf(dreq, hdr);
 		return 0;
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 2af32fc..520cbc5 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -492,7 +492,7 @@ filelayout_read_pagelist(struct nfs_pgio_header *hdr)
 	/* No multipath support. Use first DS */
 	atomic_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
-	hdr->ds_idx = idx;
+	hdr->ds_commit_idx = idx;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
 		hdr->args.fh = fh;
@@ -536,7 +536,7 @@ filelayout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	hdr->pgio_done_cb = filelayout_write_done_cb;
 	atomic_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
-	hdr->ds_idx = idx;
+	hdr->ds_commit_idx = idx;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
 		hdr->args.fh = fh;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4fd7793..5bc99f0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1328,7 +1328,7 @@ struct nfs_pgio_header {
 	__u64			mds_offset;	/* Filelayout dense stripe */
 	struct nfs_page_array	page_array;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
-	int			ds_idx;		/* ds index if ds_clp is set */
+	int			ds_commit_idx;	/* ds index if ds_clp is set */
 };
 
 struct nfs_mds_commit_info {
-- 
1.9.3

