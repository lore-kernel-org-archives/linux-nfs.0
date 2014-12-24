Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:45289 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbaLXHN5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:13:57 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so6578296igd.14
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:13:57 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 21/49] nfs41: serialize first layoutget of a file
Date: Tue, 23 Dec 2014 23:13:00 -0800
Message-Id: <1419405208-25975-22-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Per RFC 5661 Errata 3208:
| A client MAY always forget its layout state and associated
| layout stateid at any time (See also section 12.5.5.1).
| In such case, the client MUST use a non-layout stateid for the next
| LAYOUTGET operation. This will signal the server that the client has
| no more layouts on the file and its respective layout state can be
| released before issuing a new layout in response to LAYOUTGET.

In order to make such a signal unique to server, client needs to serialize
all layoutgets using non-layout stateid. We implement this by serializing
layoutgets when client has no layout segments at hand.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/pnfs.c | 35 +++++++++++++++++++++++++++++++----
 fs/nfs/pnfs.h |  1 +
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fa00b56..7e1bac1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1288,6 +1288,7 @@ pnfs_update_layout(struct inode *ino,
 	struct nfs_client *clp = server->nfs_client;
 	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
+	bool first;
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		goto out;
@@ -1295,6 +1296,8 @@ pnfs_update_layout(struct inode *ino,
 	if (pnfs_within_mdsthreshold(ctx, ino, iomode))
 		goto out;
 
+lookup_again:
+	first = false;
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
 	if (lo == NULL) {
@@ -1312,10 +1315,27 @@ pnfs_update_layout(struct inode *ino,
 	if (pnfs_layout_io_test_failed(lo, iomode))
 		goto out_unlock;
 
-	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_find_lseg(lo, &arg);
-	if (lseg)
-		goto out_unlock;
+	first = list_empty(&lo->plh_segs);
+	if (first) {
+		/* The first layoutget for the file. Need to serialize per
+		 * RFC 5661 Errata 3208.
+		 */
+		if (test_and_set_bit(NFS_LAYOUT_FIRST_LAYOUTGET,
+				     &lo->plh_flags)) {
+			spin_unlock(&ino->i_lock);
+			wait_on_bit(&lo->plh_flags, NFS_LAYOUT_FIRST_LAYOUTGET,
+				    TASK_UNINTERRUPTIBLE);
+			pnfs_put_layout_hdr(lo);
+			goto lookup_again;
+		}
+	} else {
+		/* Check to see if the layout for the given range
+		 * already exists
+		 */
+		lseg = pnfs_find_lseg(lo, &arg);
+		if (lseg)
+			goto out_unlock;
+	}
 
 	if (pnfs_layoutgets_blocked(lo, 0))
 		goto out_unlock;
@@ -1343,6 +1363,13 @@ pnfs_update_layout(struct inode *ino,
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	atomic_dec(&lo->plh_outstanding);
 out_put_layout_hdr:
+	if (first) {
+		unsigned long *bitlock = &lo->plh_flags;
+
+		clear_bit_unlock(NFS_LAYOUT_FIRST_LAYOUTGET, bitlock);
+		smp_mb__after_atomic();
+		wake_up_bit(bitlock, NFS_LAYOUT_FIRST_LAYOUTGET);
+	}
 	pnfs_put_layout_hdr(lo);
 out:
 	dprintk("%s: inode %s/%llu pNFS layout segment %s for "
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a5b168c..6594429 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -95,6 +95,7 @@ enum {
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
+	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
 };
 
 enum layoutdriver_policy_flags {
-- 
1.9.3

