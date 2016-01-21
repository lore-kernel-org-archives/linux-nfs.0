Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35584 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbcAUUzi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2016 15:55:38 -0500
Received: by mail-ig0-f182.google.com with SMTP id t15so134989091igr.0
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jan 2016 12:55:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS/flexfiles: Improve merging of errors in LAYOUTRETURN
Date: Thu, 21 Jan 2016 15:55:12 -0500
Message-Id: <1453409713-15878-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we hit 22 errors, we start to overflow the memory buffers allocated
to the LAYOUTRETURN errors. The issue is that currently, RPC call reply
ordering determines how successful we are in merging errors that refer
to contiguous READ or WRITE requests.

Fix is to use an insertion sort to help detect contiguity.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 99 +++++++++++++------------------
 1 file changed, 40 insertions(+), 59 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index e125e55de86d..bcf79aad86fc 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -218,63 +218,55 @@ static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
 	err->length = end - err->offset;
 }
 
-static bool ds_error_can_merge(struct nfs4_ff_layout_ds_err *err,  u64 offset,
-			       u64 length, int status, enum nfs_opnum4 opnum,
-			       nfs4_stateid *stateid,
-			       struct nfs4_deviceid *deviceid)
+static int
+ff_ds_error_match(const struct nfs4_ff_layout_ds_err *e1,
+		const struct nfs4_ff_layout_ds_err *e2)
 {
-	return err->status == status && err->opnum == opnum &&
-	       nfs4_stateid_match(&err->stateid, stateid) &&
-	       !memcmp(&err->deviceid, deviceid, sizeof(*deviceid)) &&
-	       end_offset(err->offset, err->length) >= offset &&
-	       err->offset <= end_offset(offset, length);
-}
-
-static bool merge_ds_error(struct nfs4_ff_layout_ds_err *old,
-			   struct nfs4_ff_layout_ds_err *new)
-{
-	if (!ds_error_can_merge(old, new->offset, new->length, new->status,
-				new->opnum, &new->stateid, &new->deviceid))
-		return false;
-
-	extend_ds_error(old, new->offset, new->length);
-	return true;
+	int ret;
+
+	if (e1->opnum != e2->opnum)
+		return e1->opnum < e2->opnum ? -1 : 1;
+	if (e1->status != e2->status)
+		return e1->status < e2->status ? -1 : 1;
+	ret = memcmp(&e1->stateid, &e2->stateid, sizeof(e1->stateid));
+	if (ret != 0)
+		return ret;
+	ret = memcmp(&e1->deviceid, &e2->deviceid, sizeof(e1->deviceid));
+	if (ret != 0)
+		return ret;
+	if (end_offset(e1->offset, e1->length) < e2->offset)
+		return -1;
+	if (e1->offset > end_offset(e2->offset, e2->length))
+		return 1;
+	/* If ranges overlap or are contiguous, they are the same */
+	return 0;
 }
 
-static bool
+static void
 ff_layout_add_ds_error_locked(struct nfs4_flexfile_layout *flo,
 			      struct nfs4_ff_layout_ds_err *dserr)
 {
-	struct nfs4_ff_layout_ds_err *err;
-
-	list_for_each_entry(err, &flo->error_list, list) {
-		if (merge_ds_error(err, dserr)) {
-			return true;
-		}
-	}
-
-	list_add(&dserr->list, &flo->error_list);
-	return false;
-}
-
-static bool
-ff_layout_update_ds_error(struct nfs4_flexfile_layout *flo, u64 offset,
-			  u64 length, int status, enum nfs_opnum4 opnum,
-			  nfs4_stateid *stateid, struct nfs4_deviceid *deviceid)
-{
-	bool found = false;
-	struct nfs4_ff_layout_ds_err *err;
-
-	list_for_each_entry(err, &flo->error_list, list) {
-		if (ds_error_can_merge(err, offset, length, status, opnum,
-				       stateid, deviceid)) {
-			found = true;
-			extend_ds_error(err, offset, length);
+	struct nfs4_ff_layout_ds_err *err, *tmp;
+	struct list_head *head = &flo->error_list;
+	int match;
+
+	/* Do insertion sort w/ merges */
+	list_for_each_entry_safe(err, tmp, &flo->error_list, list) {
+		match = ff_ds_error_match(err, dserr);
+		if (match < 0)
+			continue;
+		if (match > 0) {
+			/* Add entry "dserr" _before_ entry "err" */
+			head = &err->list;
 			break;
 		}
+		/* Entries match, so merge "err" into "dserr" */
+		extend_ds_error(dserr, err->offset, err->length);
+		list_del(&err->list);
+		kfree(err);
 	}
 
-	return found;
+	list_add_tail(&dserr->list, head);
 }
 
 int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
@@ -283,7 +275,6 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 			     gfp_t gfp_flags)
 {
 	struct nfs4_ff_layout_ds_err *dserr;
-	bool needfree;
 
 	if (status == 0)
 		return 0;
@@ -291,14 +282,6 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	if (mirror->mirror_ds == NULL)
 		return -EINVAL;
 
-	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
-	if (ff_layout_update_ds_error(flo, offset, length, status, opnum,
-				      &mirror->stateid,
-				      &mirror->mirror_ds->id_node.deviceid)) {
-		spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
-		return 0;
-	}
-	spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
 	dserr = kmalloc(sizeof(*dserr), gfp_flags);
 	if (!dserr)
 		return -ENOMEM;
@@ -313,10 +296,8 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	       NFS4_DEVICEID4_SIZE);
 
 	spin_lock(&flo->generic_hdr.plh_inode->i_lock);
-	needfree = ff_layout_add_ds_error_locked(flo, dserr);
+	ff_layout_add_ds_error_locked(flo, dserr);
 	spin_unlock(&flo->generic_hdr.plh_inode->i_lock);
-	if (needfree)
-		kfree(dserr);
 
 	return 0;
 }
-- 
2.5.0

