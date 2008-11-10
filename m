From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 28/85] nfs41: setup_sequence method
Date: Mon, 10 Nov 2008 22:22:56 +0200
Message-ID: <1226348576-8124-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48775 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbYKJUXD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:23:03 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allocate a slot in the session slot table and set the sequence op arguments.

Called at the rpc prepare stage.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c       |   23 ++++++++++++++++++++++-
 include/linux/nfs_xdr.h |    5 ++++-
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 30f76e7..af9ee0e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -353,7 +353,28 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 				int cache_reply,
 				struct rpc_task *task)
 {
-	/* stub */
+	struct nfs4_slot *slot;
+	struct nfs4_slot_table *tbl;
+
+	dprintk("--> %s\n", __func__);
+	tbl = &session->fore_channel.slot_table;
+	slot = nfs4_find_slot(tbl, task);
+
+	if (!slot) {
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+		dprintk("<-- %s: no free slots\n", __func__);
+		return -EAGAIN;
+	}
+
+	args->sa_session = session;
+	args->sa_slot = slot;
+	args->sa_cache_this = cache_reply;
+
+	dprintk("<-- %s slot=%p slotid=%d seqid=%d\n", __func__,
+		slot, slot_idx(tbl, slot), slot->seq_nr);
+
+	res->sr_slot = slot;
+	res->sr_renewal_time = jiffies;
 	return 0;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1ec56e5..9cefe0d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -120,7 +120,9 @@ struct sessionid4 {
 };
 
 struct nfs41_sequence_args {
-	/* stub */
+	struct nfs4_session	*sa_session;
+	struct nfs4_slot	*sa_slot;
+	u32			sa_cache_this;
 };
 
 #define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
@@ -135,6 +137,7 @@ struct nfs41_sequence_args {
 
 struct nfs41_sequence_res {
 	struct nfs4_slot	*sr_slot;	/* slot used to send request */
+	unsigned long		sr_renewal_time;
 };
 
 #if defined(CONFIG_NFS_V4_1)
-- 
1.6.0.2

