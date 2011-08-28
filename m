Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51079 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1H1GWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2011 02:22:47 -0400
Received: by bke11 with SMTP id 11so3440684bke.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Aug 2011 23:22:46 -0700 (PDT)
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: peng_tao@emc.com, linux-nfs@vger.kernel.org,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
Date: Sun, 28 Aug 2011 10:22:38 +0400
Message-Id: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

pnfs_layout_segment can be already under handling LAYOUTCOMMIT,
so adding list twice causes hang:

   BUG: soft lockup - CPU#0 stuck for 22s! [kworker/0:0:4]
   Call Trace:

     nfs4_layoutcommit_release+0x5a/0x9c [nfs]
     rpc_release_calldata+0x17/0x19 [sunrpc]
     rpc_free_task+0x5e/0x66 [sunrpc]
     __rpc_execute+0x29e/0x2ad [sunrpc]
     rpc_async_schedule+0x15/0x17 [sunrpc]
     process_one_work+0x213/0x3ba
     process_one_work+0x142/0x3ba
     __rpc_execute+0x2ad/0x2ad [sunrpc]
     worker_thread+0xfd/0x181

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/pnfs.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e550e88..1465f44 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1376,7 +1376,8 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 
 	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
 		if (lseg->pls_range.iomode == IOMODE_RW &&
-		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags) &&
+		    list_empty(&lseg->pls_lc_list))
 			list_add(&lseg->pls_lc_list, listp);
 	}
 }
-- 
1.7.4.1

