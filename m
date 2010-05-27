From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 5/5] pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
Date: Thu, 27 May 2010 21:13:49 +0300
Message-ID: <1274984029-26628-1-git-send-email-bhalevy@panasas.com>
References: <4BFEB5D4.30608@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58957 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934672Ab0E0SNv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:13:51 -0400
In-Reply-To: <4BFEB5D4.30608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Boaz Harrosh <bharrosh@panasas.com>

OK This is definitely my stupidity when converting panfs_shim to the
new objlayout_read/write_done() API. But that was very, very long
time ago.

So I fixed the stale check on ol_state.status which is never set
until much later inside the call to generic layer.

While at it I converted the BUG_ONs to WARN_ONs because it could
be data corruption but otherwise it will not crush the Kernel.
Better continue to be able to debug it better. (And added missing
information to the WARN_ON)

Congratulation, I've successfully ran all tests over
panfs-export/panfs_shim over real Panasas HW. With latest code.
[ This is with the new panfs-export that is also compatible with
  the std objects layout driver. Patches to that will follow]

TODO:
  I should also simulate/cause some IO errors and see that
  errors are reported at layout_return

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/objlayout/panfs_shim.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
index 414831e..7bb00aa 100644
--- a/fs/nfs/objlayout/panfs_shim.c
+++ b/fs/nfs/objlayout/panfs_shim.c
@@ -421,9 +421,7 @@ panfs_shim_read_done(
 		rc = res_p->result;
 	if (rc == PAN_SUCCESS) {
 		status = res_p->length;
-		BUG_ON(state->ol_state.status < 0);
-		BUG_ON((pan_stor_len_t)state->ol_state.status !=
-		       state->u.read.res.length);
+		WARN_ON(status < 0);
 	} else {
 		status = -panfs_export_ops->convert_rc(rc);
 		dprintk("%s: pan_sam_read rc %d: status %Zd\n",
@@ -499,9 +497,8 @@ panfs_shim_write_done(
 	if (rc == PAN_SUCCESS) {
 		state->ol_state.committed = NFS_FILE_SYNC;
 		status = res_p->length;
-		BUG_ON(state->ol_state.status < 0);
-		BUG_ON((pan_stor_len_t)state->ol_state.status !=
-		       state->u.write.res.length);
+		WARN_ON(status < 0);
+
 		objlayout_add_delta_space_used(&state->ol_state,
 					       res_p->delta_capacity_used);
 	} else {
-- 
1.6.6.1

