Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34905 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbbKBStM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 13:49:12 -0500
Received: by iofz202 with SMTP id z202so153199001iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2015 10:49:11 -0800 (PST)
Received: from leira.trondhjem.org (c-68-49-164-203.hsd1.mi.comcast.net. [68.49.164.203])
        by smtp.gmail.com with ESMTPSA id e8sm6334766igx.16.2015.11.02.10.49.10
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 10:49:10 -0800 (PST)
Message-ID: <1446490149.30323.2.camel@primarydata.com>
Subject: [PATCH 1/2] pNFS/flexfiles: When mirrored, retry failed reads by
 switching mirrors
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 02 Nov 2015 13:49:09 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the pNFS/flexfiles file is mirrored, and a read to one mirror fails,
then we should bump the mirror index, so that we retry to a different
mirror. Once we've iterated through all mirrors and all failed, we can
return the layout and issue a new LAYOUTGET.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
b/fs/nfs/flexfilelayout/flexfilelayout.c
index fbc5a56de875..7fc14b90886e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -741,17 +741,17 @@ ff_layout_alloc_commit_info(struct
pnfs_layout_segment *lseg,
 }
 
 static struct nfs4_pnfs_ds *
-ff_layout_choose_best_ds_for_read(struct nfs_pageio_descriptor *pgio,
+ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
+				  int start_idx,
 				  int *best_idx)
 {
-	struct nfs4_ff_layout_segment *fls;
+	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
 	struct nfs4_pnfs_ds *ds;
 	int idx;
 
-	fls = FF_LAYOUT_LSEG(pgio->pg_lseg);
 	/* mirrors are sorted by efficiency */
-	for (idx = 0; idx < fls->mirror_array_cnt; idx++) {
-		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, idx,
false);
+	for (idx = start_idx; idx < fls->mirror_array_cnt; idx++) {
+		ds = nfs4_ff_layout_prepare_ds(lseg, idx, false);
 		if (ds) {
 			*best_idx = idx;
 			return ds;
@@ -782,7 +782,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor
*pgio,
 	if (pgio->pg_lseg == NULL)
 		goto out_mds;
 
-	ds = ff_layout_choose_best_ds_for_read(pgio, &ds_idx);
+	ds = ff_layout_choose_best_ds_for_read(pgio->pg_lseg, 0,
&ds_idx);
 	if (!ds)
 		goto out_mds;
 	mirror = FF_LAYOUT_COMP(pgio->pg_lseg, ds_idx);
@@ -1171,6 +1171,10 @@ static int ff_layout_read_done_cb(struct
rpc_task *task,
 
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
+		if (ff_layout_choose_best_ds_for_read(hdr->lseg,
+					hdr->pgio_mirror_idx + 1,
+					&hdr->pgio_mirror_idx))
+			goto out_eagain;
 		set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 			&hdr->lseg->pls_layout->plh_flags);
 		pnfs_read_resend_pnfs(hdr);
@@ -1179,11 +1183,13 @@ static int ff_layout_read_done_cb(struct
rpc_task *task,
 		ff_layout_reset_read(hdr);
 		return task->tk_status;
 	case -EAGAIN:
-		rpc_restart_call_prepare(task);
-		return -EAGAIN;
+		goto out_eagain;
 	}
 
 	return 0;
+out_eagain:
+	rpc_restart_call_prepare(task);
+	return -EAGAIN;
 }
 
 static bool
-- 
Trond Myklebust
Principal System Architect
4300 El Camino Real | Suite 100
Los Altos, CA  94022
W: 650-422-3800
C: 801-921-4583 
www.primarydata.com

