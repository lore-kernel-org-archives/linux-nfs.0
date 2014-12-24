Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:58637 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbaLXHOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:14:18 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so7270357iec.15
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:14:17 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 46/49] nfs41: add NFS_LAYOUT_RETRY_LAYOUTGET to layout header flags
Date: Tue, 23 Dec 2014 23:13:25 -0800
Message-Id: <1419405208-25975-47-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Use it to indicate that LD wants to retry layoutget. LD can set
it whenever it wants the common pnfs code to return and retry
pnfs path through a new layout.

The bit gets cleared when client does a new layoutget, when client
closes the file (ROC case), or when kernel needs to evict the inode
(non-ROC case).

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c |  3 +++
 fs/nfs/pnfs.h | 18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9e7092f..fec1d897 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -617,6 +617,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		pnfs_get_layout_hdr(lo);
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RO_FAILED);
 		pnfs_layout_clear_fail_bit(lo, NFS_LAYOUT_RW_FAILED);
+		pnfs_clear_retry_layoutget(lo);
 		spin_unlock(&nfsi->vfs_inode.i_lock);
 		pnfs_free_lseg_list(&tmp_list);
 		pnfs_put_layout_hdr(lo);
@@ -1070,6 +1071,7 @@ bool pnfs_roc(struct inode *ino)
 	if (!lo || !test_and_clear_bit(NFS_LAYOUT_ROC, &lo->plh_flags) ||
 	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
 		goto out_nolayout;
+	pnfs_clear_retry_layoutget(lo);
 	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
 		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
 			mark_lseg_invalid(lseg, &tmp_list);
@@ -1497,6 +1499,7 @@ lookup_again:
 		arg.length = PAGE_CACHE_ALIGN(arg.length);
 
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
+	pnfs_clear_retry_layoutget(lo);
 	atomic_dec(&lo->plh_outstanding);
 out_put_layout_hdr:
 	if (first) {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 04a5a31..67a436b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -99,6 +99,7 @@ enum {
 	NFS_LAYOUT_RETURN_BEFORE_CLOSE,	/* Return this layout before close */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
+	NFS_LAYOUT_RETRY_LAYOUTGET,	/* Retry layoutget */
 };
 
 enum layoutdriver_policy_flags {
@@ -349,6 +350,23 @@ nfs4_get_deviceid(struct nfs4_deviceid_node *d)
 	return d;
 }
 
+static inline void pnfs_set_retry_layoutget(struct pnfs_layout_hdr *lo)
+{
+	if (!test_and_set_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags))
+		atomic_inc(&lo->plh_refcount);
+}
+
+static inline void pnfs_clear_retry_layoutget(struct pnfs_layout_hdr *lo)
+{
+	if (test_and_clear_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags))
+		atomic_dec(&lo->plh_refcount);
+}
+
+static inline bool pnfs_should_retry_layoutget(struct pnfs_layout_hdr *lo)
+{
+	return test_bit(NFS_LAYOUT_RETRY_LAYOUTGET, &lo->plh_flags);
+}
+
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
-- 
1.9.3

