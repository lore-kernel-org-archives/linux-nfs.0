Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21778 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755778Ab0FPQgm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jun 2010 12:36:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: DEVONLY: nfs41: improve nfs41_sequence_done debug message on NFS4ERR_DELAY
Date: Wed, 16 Jun 2010 12:36:46 -0400
Message-Id: <1276706206-20027-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Note: this message was actually seen during the June 2010 Bakeathon.
Apparently we do get to this state unexpectedly.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e12d153..6b266dd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -440,7 +440,11 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 
 	/* Do not free slot if retried while operation was in progress */
 	if (res->sr_status == -NFS4ERR_DELAY) {
-		printk("WARNING: %s: Operation in progress: please report to pnfs@linux-nfs.org if you saw this message\n", __func__);
+		tbl = &clp->cl_session->fc_slot_table;
+		printk("WARNING: %s: Operation in progress slot=%d seq=%d highest_used_slotid=%d: "
+			"please report to pnfs@linux-nfs.org if you saw this message\n",
+			__func__, res->sr_slotid, tbl->slots[res->sr_slotid].seq_nr,
+			tbl->highest_used_slotid);
 		return;
 	}
 out:
-- 
1.6.4.4

