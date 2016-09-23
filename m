Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:23333 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965005AbcIWVYH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Sep 2016 17:24:07 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Retry operation on EREMOTEIO on an interrupted slot
Date: Fri, 23 Sep 2016 17:24:03 -0400
Message-ID: <1474665843-56183-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an operation got interrupted, then since we don't know if the
server processed it on not, we keep the seq#. Upon reuse of slot
and seq# if we get reply from the cache (ie EREMOTEIO) then we
need to retry the operation after bumping the seq#

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 88b549e..3c652bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -722,6 +722,13 @@ static int nfs41_sequence_process(struct rpc_task *task,
 	/* Check the SEQUENCE operation status */
 	switch (res->sr_status) {
 	case 0:
+		/* If previous op on slot was interrupted and we reused
+		 * the seq# and got a reply from the cache, then retry
+		 */
+		if (task->tk_status == -EREMOTEIO && interrupted) {
+			++slot->seq_nr;
+			goto retry_nowait;
+		}
 		/* Update the slot's sequence and clientid lease timer */
 		slot->seq_done = 1;
 		clp = session->clp;
-- 
1.8.3.1

