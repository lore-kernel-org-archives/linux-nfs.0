Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:50430 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751959AbdCOPTA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Mar 2017 11:19:00 -0400
From: <andros@netapp.com>
To: <trondmy@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 1/1] NFS free the layoutget slot before calling pnfs_layout_process
Date: Wed, 15 Mar 2017 11:18:51 -0400
Message-ID: <20170315151851.5762-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Otherwise no slots could be available for the potential
pnfs_layout_process getdeviceinfo call and the client hangs on pNFS I/O.

This occurs in testing against the pynfs pNFS server where the
the on-wire reply highest_slotid and slot id are zero, and the
target high slot id is 8 (negotiated in CREATE_SESSION).

The internal fore channel slot table max_slotid, the maximum allowed
table slotid value, has been reduced via nfs41_set_max_slotid_locked
 from 8 to 1.  Thus there is one slot (slotid 0) available for use but
it has not been freed by layoutget proir to the getdeviceinfo request.

So the layout get call is waiting for the getdeviceinfo call to complete,
and the getdeviceinfo call is waiting for layoutget to free the slot.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1b18368..8ca92d0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8504,10 +8504,10 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 			&lgp->res.stateid,
 			status);
 
+	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
 	if (status == 0 && lgp->res.layoutp->len)
 		lseg = pnfs_layout_process(lgp);
-	nfs4_sequence_free_slot(&lgp->res.seq_res);
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	if (status)
-- 
2.9.3

