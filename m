Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51652 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480AbaA0R0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jan 2014 12:26:06 -0500
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 Do not preallocate session slots in nfs4_end_drain_slot_tbl
Date: Mon, 27 Jan 2014 12:25:55 -0500
Message-ID: <1390843555-3498-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Pre-allocating session slots for RPC tasks waking up from a wait queue provides
a shorter slot allocation code path and can help performance.

Durring multiple server reboots (interface moves), the pre-allocated
slot can be held and not freed as a task is transferred to various slot table
wait queues and the state manager is draining these queues.  Not freeing the
slots results in a  state manager hang waiting for completion on the slot
table draining.  In this case, performance is not a consideration as the
client is in recovery of a session or a clientid.

Prevent this state manager hang by not pre-allocating session slots, but
just wake up the tasks and let them grab a sessions slot in the
nfs4_alloc_slot call in nfs41-setup_sequence.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e5be725..6ddd96e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -219,7 +219,7 @@ static void nfs4_end_drain_slot_table(struct nfs4_slot_table *tbl)
 {
 	if (test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
 		spin_lock(&tbl->slot_tbl_lock);
-		nfs41_wake_slot_table(tbl);
+		rpc_wake_up(&tbl->slot_tbl_waitq);
 		spin_unlock(&tbl->slot_tbl_lock);
 	}
 }
-- 
1.8.3.1

