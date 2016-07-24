Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33442 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcGXVbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:37 -0400
Received: by mail-io0-f196.google.com with SMTP id y195so10763484iod.0
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 04/14] pNFS: Always update the layout barrier seqid on LAYOUTGET
Date: Sun, 24 Jul 2016 17:30:49 -0400
Message-Id: <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, pnfs_set_layout_stateid() will update the layout sequence
id barrier only if the stateid itself is newer than the current
layout stateid. However in a situation where multiple LAYOUTGET calls
and a LAYOUTRETURN raced, it is entirely possible for one of the
LAYOUTGET to set the current stateid to something newer than the
LAYOUTRETURN that needs to set the barrier.

The fix is to allow the "update_barrier" flag to force a check as to
whether or not the barrier needs to be updated.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index eef844785bc6..85c3e7b47ddb 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -761,24 +761,25 @@ void
 pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 			bool update_barrier)
 {
-	u32 oldseq, newseq, new_barrier;
-	bool empty = !pnfs_layout_is_valid(lo);
+	u32 oldseq, newseq, new_barrier = 0;
+	bool invalid = !pnfs_layout_is_valid(lo);
 
 	oldseq = be32_to_cpu(lo->plh_stateid.seqid);
 	newseq = be32_to_cpu(new->seqid);
-	if (empty || pnfs_seqid_is_newer(newseq, oldseq)) {
+	if (invalid || pnfs_seqid_is_newer(newseq, oldseq)) {
 		nfs4_stateid_copy(&lo->plh_stateid, new);
-		if (update_barrier) {
-			new_barrier = be32_to_cpu(new->seqid);
-		} else {
-			/* Because of wraparound, we want to keep the barrier
-			 * "close" to the current seqids.
-			 */
-			new_barrier = newseq - atomic_read(&lo->plh_outstanding);
-		}
-		if (empty || pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
-			lo->plh_barrier = new_barrier;
+		/*
+		 * Because of wraparound, we want to keep the barrier
+		 * "close" to the current seqids.
+		 */
+		new_barrier = newseq - atomic_read(&lo->plh_outstanding);
 	}
+	if (update_barrier)
+		new_barrier = be32_to_cpu(new->seqid);
+	else if (new_barrier == 0)
+		return;
+	if (invalid || pnfs_seqid_is_newer(new_barrier, lo->plh_barrier))
+		lo->plh_barrier = new_barrier;
 }
 
 static bool
-- 
2.7.4

