Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37975 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbbKBShU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 13:37:20 -0500
Received: by igbdj2 with SMTP id dj2so59882699igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2015 10:37:20 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <1446489215.30323.0.camel@primarydata.com>
Mime-Version: 1.0
Subject: [PATCH 1/2] pNFS/flexfiles: When mirrored, retry failed reads by
 switching mirrors
Date: Mon, 02 Nov 2015 13:37:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)@mail.corp.redhat.com

If the pNFS/flexfiles file is mirrored, and a read to one mirror fails,
then we should bump the mirror index, so that we retry to a different
mirror. Once we've iterated through all mirrors and all failed, we can
return the layout and issue a new LAYOUTGET.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout=
/flexfilelayout.c
index fbc5a56de875..7fc14b90886e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -741,17 +741,17 @@ ff_layout_alloc_commit_info(struct pnfs_layout_segmen=
t *lseg,
 }
=20
 static struct nfs4_pnfs_ds *
-ff_layout_choose_best_ds_for_read(struct nfs_pageio_descriptor *pgio,
+ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
+				  int start_idx,
 				  int *best_idx)
 {
-	struct nfs4_ff_layout_segment *fls;
+	struct nfs4_ff_layout_segment *fls =3D FF_LAYOUT_LSEG(lseg);
 	struct nfs4_pnfs_ds *ds;
 	int idx;
=20
-	fls =3D FF_LAYOUT_LSEG(pgio->pg_lseg);
 	/* mirrors are sorted by efficiency */
-	for (idx =3D 0; idx < fls->mirror_array_cnt; idx++) {
-		ds =3D nfs4_ff_layout_prepare_ds(pgio->pg_lseg, idx, false);
+	for (idx =3D start_idx; idx < fls->mirror_array_cnt; idx++) {
+		ds =3D nfs4_ff_layout_prepare_ds(lseg, idx, false);
 		if (ds) {
 			*best_idx =3D idx;
 			return ds;
@@ -782,7 +782,7 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pg=
io,
 	if (pgio->pg_lseg =3D=3D NULL)
 		goto out_mds;
=20
-	ds =3D ff_layout_choose_best_ds_for_read(pgio, &ds_idx);
+	ds =3D ff_layout_choose_best_ds_for_read(pgio->pg_lseg, 0, &ds_idx);
 	if (!ds)
 		goto out_mds;
 	mirror =3D FF_LAYOUT_COMP(pgio->pg_lseg, ds_idx);
@@ -1171,6 +1171,10 @@ static int ff_layout_read_done_cb(struct rpc_task *t=
ask,
=20
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
+		if (ff_layout_choose_best_ds_for_read(hdr->lseg,
+					hdr->pgio_mirror_idx + 1,
+					&hdr->pgio_mirror_idx))
+			goto out_eagain;
 		set_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
 			&hdr->lseg->pls_layout->plh_flags);
 		pnfs_read_resend_pnfs(hdr);
@@ -1179,11 +1183,13 @@ static int ff_layout_read_done_cb(struct rpc_task *=
task,
 		ff_layout_reset_read(hdr);
 		return task->tk_status;
 	case -EAGAIN:
-		rpc_restart_call_prepare(task);
-		return -EAGAIN;
+		goto out_eagain;
 	}
=20
 	return 0;
+out_eagain:
+	rpc_restart_call_prepare(task);
+	return -EAGAIN;
 }
=20
 static bool
--=20
2.5.0

