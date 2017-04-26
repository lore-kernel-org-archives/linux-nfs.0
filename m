Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:11104 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933126AbdDZSVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Apr 2017 14:21:25 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/1] NFS4.1 handle interrupted slot reuse from ERR_DELAY
Date: Wed, 26 Apr 2017 14:21:22 -0400
Message-ID: <20170426182122.1301-1-kolga@netapp.com>
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
index 85957ff..8904d08 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -698,7 +698,8 @@ static int nfs41_sequence_process(struct rpc_task *task,
 	session = slot->table->session;
 
 	if (slot->interrupted) {
-		slot->interrupted = 0;
+		if (res->sr_status != -NFS4ERR_DELAY)
+			slot->interrupted = 0;
 		interrupted = true;
 	}
 
-- 
1.8.3.1

