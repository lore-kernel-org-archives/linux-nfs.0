From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 50/85] nfs41: schedule state recovery on BAD or DEAD session
Date: Mon, 10 Nov 2008 22:27:00 +0200
Message-ID: <1226348820-8894-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59967 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbYKJU1G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:27:06 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When a clientid is stale, the sequence operation will return NFS4ERR_BADSESSION
or NFS4ERR_DEADSESSION. This will put the session into reset mode, and
run the session_reclaimer thread which calls destroy_session and
create_session. Destroy_session will also return NFS4ERR_BADSESSION or
NFS4ERR_DEADSESSION which is ignored by the session reset. Create_session
will return NFS4ERR_STALE_CLIENTID and the session reclaimer sets the
nfs_client cl_state to NFS4CLNT_LEASE_EXPIRED.

Catch the NFS4CLNT_LEASE_EXPIRED cl_state in nfs4_find_slot, and attempt to
recover the expired client id.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 179ea6c..699bbe7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -403,6 +403,13 @@ nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task,
 			dprintk("%s Slot Table Empty\n", __func__);
 			spin_unlock(&tbl->slot_tbl_lock);
 			ret = nfs41_recover_session_sync(session);
+			if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED,
+						&session->clp->cl_state)) {
+
+				printk(KERN_WARNING "%s Clientid Reset\n",
+					__func__);
+				nfs4_schedule_state_recovery(session->clp);
+			}
 			if (ret)
 				return slot;
 			nfs41_wait_session_reset(session);
-- 
1.6.0.2

