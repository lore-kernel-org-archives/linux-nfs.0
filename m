Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:4796 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab1B0PEY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Feb 2011 10:04:24 -0500
Message-ID: <4D6A67F3.3060308@panasas.com>
Date: Sun, 27 Feb 2011 17:04:19 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH] SQUASHME: pnfs: FIX stupid recall_layout BUG
References: <4D686893.7010106@panasas.com>
In-Reply-To: <4D686893.7010106@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


OK, who wrote this code? He did not stop to think for even a
second. And surely it was never tested, since it is 100%
repeatable. Smack yourself on the head!

Simple: layout is in use, a recall comes in. _DELAY is returned
meanwhile, a flag is set and no new IOs are allowed. The last
IO dereference the layout, there are no more layouts. The server
persists, sends a second recall, boom below code crash.

* While at it fix an if();else {} style violation
* The added BUG_ON is important because the address taken from
  a member of a null pointer is not null, and the crash is not
  at all clean.

It no longer crashes my trunc_test, Now I need to verify the recall
is actually honoured.

Signed-off-by: Boaz Harrosh <Boaz Harrosh bharrosh@panasas.com>
---
 fs/nfs/callback_proc.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 12ab7b3..34aee16 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -252,9 +252,9 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 			if (nfs_compare_fh(&args->cbl_fh,
 					   &NFS_I(lo->plh_inode)->fh))
 				continue;
-			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 				rv = NFS4ERR_DELAY;
-			else {
+			} else {
 				/* FIXME I need to better understand igrab and
 				 * does having a layout ref keep ino around?
 				 *  It should.
@@ -270,6 +270,11 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 		}
 		spin_unlock(&clp->cl_lock);
 
+		if (rv == NFS4ERR_NOMATCHING_LAYOUT)
+			/* Nothing found */
+			return rv;
+
+		BUG_ON(!lo->plh_inode);
 		spin_lock(&lo->plh_inode->i_lock);
 		if (rv == NFS4_OK) {
 			lo->plh_block_lgets++;
-- 
1.7.3.4


