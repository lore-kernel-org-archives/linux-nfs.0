Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34779 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932340AbcLICxz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2016 21:53:55 -0500
Received: by mail-io0-f194.google.com with SMTP id y124so4114785iof.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2016 18:53:55 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Fred Isaman <fred.isaman@gmail.com>,
        Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Fix a deadlock on LAYOUTGET
Date: Thu,  8 Dec 2016 21:53:51 -0500
Message-Id: <20161209025351.22069-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

  We encountered a deadlock where the SEQUENCE that accompanied the
LAYOUTGET triggered a session drain, while ff_layout_alloc_lseg
triggered a GETDEVICEINFO.  The GETDEVICEINFO hung waiting for the
session drain, while the LAYOUTGET held the slot waiting for
alloc_lseg to finish.
  Avoid this by moving the call to nfs4_find_get_deviceid out of
ff_layout_alloc_lseg and into nfs4_ff_layout_prepare_ds.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
[dros@primarydata.com: pNFS/flexfiles: fix races in ff_layout_mirror_valid]
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 37 ++---------------------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 50 ++++++++++++++++++++++++-------
 3 files changed, 43 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ca1012a42e14..ef4c9d17d4a5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -183,7 +183,7 @@ ff_layout_add_mirror(struct pnfs_layout_hdr *lo,
 
 	spin_lock(&inode->i_lock);
 	list_for_each_entry(pos, &ff_layout->mirrors, mirrors) {
-		if (mirror->mirror_ds != pos->mirror_ds)
+		if (memcmp(&mirror->devid, &pos->devid, sizeof(pos->devid)) != 0)
 			continue;
 		if (!ff_mirror_match_fh(mirror, pos))
 			continue;
@@ -360,19 +360,6 @@ static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
 	}
 }
 
-static void ff_layout_mark_devices_valid(struct nfs4_ff_layout_segment *fls)
-{
-	struct nfs4_deviceid_node *node;
-	int i;
-
-	if (!(fls->flags & FF_FLAGS_NO_IO_THRU_MDS))
-		return;
-	for (i = 0; i < fls->mirror_array_cnt; i++) {
-		node = &fls->mirror_array[i]->mirror_ds->id_node;
-		clear_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
-	}
-}
-
 static struct pnfs_layout_segment *
 ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		     struct nfs4_layoutget_res *lgr,
@@ -426,8 +413,6 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 
 	for (i = 0; i < fls->mirror_array_cnt; i++) {
 		struct nfs4_ff_layout_mirror *mirror;
-		struct nfs4_deviceid devid;
-		struct nfs4_deviceid_node *idnode;
 		struct auth_cred acred = { .group_info = ff_zero_group };
 		struct rpc_cred	__rcu *cred;
 		u32 ds_count, fh_count, id;
@@ -452,24 +437,10 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		fls->mirror_array[i]->ds_count = ds_count;
 
 		/* deviceid */
-		rc = decode_deviceid(&stream, &devid);
+		rc = decode_deviceid(&stream, &fls->mirror_array[i]->devid);
 		if (rc)
 			goto out_err_free;
 
-		idnode = nfs4_find_get_deviceid(NFS_SERVER(lh->plh_inode),
-						&devid, lh->plh_lc_cred,
-						gfp_flags);
-		/*
-		 * upon success, mirror_ds is allocated by previous
-		 * getdeviceinfo, or newly by .alloc_deviceid_node
-		 * nfs4_find_get_deviceid failure is indeed getdeviceinfo falure
-		 */
-		if (idnode)
-			fls->mirror_array[i]->mirror_ds =
-				FF_LAYOUT_MIRROR_DS(idnode);
-		else
-			goto out_err_free;
-
 		/* efficiency */
 		rc = -EIO;
 		p = xdr_inline_decode(&stream, 4);
@@ -567,8 +538,6 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 	rc = ff_layout_check_layout(lgr);
 	if (rc)
 		goto out_err_free;
-	ff_layout_mark_devices_valid(fls);
-
 	ret = &fls->generic_hdr;
 	dprintk("<-- %s (success)\n", __func__);
 out_free_page:
@@ -2332,7 +2301,7 @@ ff_layout_mirror_prepare_stats(struct pnfs_layout_hdr *lo,
 	list_for_each_entry(mirror, &ff_layout->mirrors, mirrors) {
 		if (i >= dev_limit)
 			break;
-		if (!mirror->mirror_ds)
+		if (IS_ERR_OR_NULL(mirror->mirror_ds))
 			continue;
 		if (!test_and_clear_bit(NFS4_FF_MIRROR_STAT_AVAIL, &mirror->flags))
 			continue;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 35221fe390c5..7223c4ea8cde 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -74,6 +74,7 @@ struct nfs4_ff_layout_mirror {
 	struct list_head		mirrors;
 	u32				ds_count;
 	u32				efficiency;
+	struct nfs4_deviceid		devid;
 	struct nfs4_ff_layout_ds	*mirror_ds;
 	u32				fh_versions_cnt;
 	struct nfs_fh			*fh_versions;
@@ -211,7 +212,6 @@ nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg,
 				 struct inode *inode);
 struct rpc_cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
 				       u32 ds_idx, struct rpc_cred *mdscred);
-bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 142bfd0b1663..3cc39d1c1206 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -20,9 +20,11 @@
 static unsigned int dataserver_timeo = NFS_DEF_TCP_RETRANS;
 static unsigned int dataserver_retrans;
 
+static bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg);
+
 void nfs4_ff_layout_put_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
 {
-	if (mirror_ds)
+	if (!IS_ERR_OR_NULL(mirror_ds))
 		nfs4_put_deviceid_node(&mirror_ds->id_node);
 }
 
@@ -182,12 +184,29 @@ static void ff_layout_mark_devid_invalid(struct pnfs_layout_segment *lseg,
 }
 
 static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
-		struct nfs4_ff_layout_mirror *mirror)
+				   struct nfs4_ff_layout_mirror *mirror,
+				   bool create)
 {
-	if (mirror == NULL || mirror->mirror_ds == NULL) {
-		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
-					lseg);
-		return false;
+	if (mirror == NULL || IS_ERR(mirror->mirror_ds))
+		goto outerr;
+	if (mirror->mirror_ds == NULL) {
+		if (create) {
+			struct nfs4_deviceid_node *node;
+			struct pnfs_layout_hdr *lh = lseg->pls_layout;
+			struct nfs4_ff_layout_ds *mirror_ds = ERR_PTR(-ENODEV);
+
+			node = nfs4_find_get_deviceid(NFS_SERVER(lh->plh_inode),
+					&mirror->devid, lh->plh_lc_cred,
+					GFP_KERNEL);
+			if (node)
+				mirror_ds = FF_LAYOUT_MIRROR_DS(node);
+
+			/* check for race with another call to this function */
+			if (cmpxchg(&mirror->mirror_ds, NULL, mirror_ds) &&
+			    mirror_ds != ERR_PTR(-ENODEV))
+				nfs4_put_deviceid_node(node);
+		} else
+			goto outerr;
 	}
 	if (mirror->mirror_ds->ds == NULL) {
 		struct nfs4_deviceid_node *devid;
@@ -196,6 +215,9 @@ static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
 		return false;
 	}
 	return true;
+outerr:
+	pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode, lseg);
+	return false;
 }
 
 static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
@@ -323,7 +345,7 @@ nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
 	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
 	struct nfs_fh *fh = NULL;
 
-	if (!ff_layout_mirror_valid(lseg, mirror)) {
+	if (!ff_layout_mirror_valid(lseg, mirror, false)) {
 		pr_err_ratelimited("NFS: %s: No data server for mirror offset index %d\n",
 			__func__, mirror_idx);
 		goto out;
@@ -363,7 +385,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	struct nfs_server *s = NFS_SERVER(ino);
 	unsigned int max_payload;
 
-	if (!ff_layout_mirror_valid(lseg, mirror)) {
+	if (!ff_layout_mirror_valid(lseg, mirror, true)) {
 		pr_err_ratelimited("NFS: %s: No data server for offset index %d\n",
 			__func__, ds_idx);
 		goto out;
@@ -547,7 +569,11 @@ static bool ff_read_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 
 	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
 		mirror = FF_LAYOUT_COMP(lseg, idx);
-		if (mirror && mirror->mirror_ds) {
+		if (mirror) {
+			if (!mirror->mirror_ds)
+				return true;
+			if (IS_ERR(mirror->mirror_ds))
+				continue;
 			devid = &mirror->mirror_ds->id_node;
 			if (!ff_layout_test_devid_unavailable(devid))
 				return true;
@@ -565,8 +591,10 @@ static bool ff_rw_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 
 	for (idx = 0; idx < FF_LAYOUT_MIRROR_COUNT(lseg); idx++) {
 		mirror = FF_LAYOUT_COMP(lseg, idx);
-		if (!mirror || !mirror->mirror_ds)
+		if (!mirror || IS_ERR(mirror->mirror_ds))
 			return false;
+		if (!mirror->mirror_ds)
+			continue;
 		devid = &mirror->mirror_ds->id_node;
 		if (ff_layout_test_devid_unavailable(devid))
 			return false;
@@ -575,7 +603,7 @@ static bool ff_rw_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 	return FF_LAYOUT_MIRROR_COUNT(lseg) != 0;
 }
 
-bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
+static bool ff_layout_has_available_ds(struct pnfs_layout_segment *lseg)
 {
 	if (lseg->pls_range.iomode == IOMODE_READ)
 		return  ff_read_layout_has_available_ds(lseg);
-- 
2.9.3

