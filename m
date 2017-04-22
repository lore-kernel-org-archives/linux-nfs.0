Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:53034 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1425695AbdDVQbm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 22 Apr 2017 12:31:42 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFS4.1 handle interrupted slot reuse from ERR_DELAY
Date: Sat, 22 Apr 2017 12:31:39 -0400
Message-ID: <20170422163139.97844-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the RPC slot was interrupted and server replied to the next
operation on the "reused" slot with ERR_DELAY, don't clear out
the "interrupted" flag until we properly recover.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0d3347e..a15979c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -697,7 +697,8 @@ static int nfs41_sequence_process(struct rpc_task *task,
 	session = slot->table->session;
 
 	if (slot->interrupted) {
-		slot->interrupted = 0;
+		if (task->tk_status != -NFS4ERR_DELAY)
+			slot->interrupted = 0;
 		interrupted = true;
 	}
 
-- 
1.8.3.1

