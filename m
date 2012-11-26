Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875Ab2KZURB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:01 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/28] NFSv4.1: Label each entry in the session slot tables with its slot number
Date: Mon, 26 Nov 2012 15:16:26 -0500
Message-Id: <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of doing slot table pointer gymnastics every time we want to
know which slot we're using.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 12 +++++++-----
 fs/nfs/nfs4xdr.c        |  2 +-
 include/linux/nfs_xdr.h |  1 +
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f8cb60b..4f2d058 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -527,9 +527,9 @@ static int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *
 		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
 		 * of RFC5661.
 		 */
-		dprintk("%s: slot=%td seq=%d: Operation in progress\n",
+		dprintk("%s: slot=%u seq=%u: Operation in progress\n",
 			__func__,
-			slot - session->fc_slot_table.slots,
+			slot->slot_nr,
 			slot->seq_nr);
 		goto out_retry;
 	default:
@@ -672,9 +672,9 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 	if (session == NULL)
 		goto out;
 
-	dprintk("--> %s clp %p session %p sr_slot %td\n",
+	dprintk("--> %s clp %p session %p sr_slot %d\n",
 		__func__, session->clp, session, res->sr_slot ?
-			res->sr_slot - session->fc_slot_table.slots : -1);
+			res->sr_slot->slot_nr : -1);
 
 	ret = nfs41_setup_sequence(session, args, res, task);
 out:
@@ -5670,8 +5670,10 @@ struct nfs4_slot *nfs4_alloc_slots(struct nfs4_slot_table *table,
 
 	tbl = kmalloc_array(max_slots, sizeof(*tbl), gfp_flags);
 	if (tbl != NULL) {
-		for (i = 0; i < max_slots; i++)
+		for (i = 0; i < max_slots; i++) {
 			tbl[i].table = table;
+			tbl[i].slot_nr = i;
+		}
 	}
 	return tbl;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4126f05..50bac70 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5547,7 +5547,7 @@ static int decode_sequence(struct xdr_stream *xdr,
 	}
 	/* slot id */
 	dummy = be32_to_cpup(p++);
-	if (dummy != res->sr_slot - session->fc_slot_table.slots) {
+	if (dummy != res->sr_slot->slot_nr) {
 		dprintk("%s Invalid slot id\n", __func__);
 		goto out_err;
 	}
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0fd88ab..9c9b76c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -189,6 +189,7 @@ struct nfs4_channel_attrs {
 struct nfs4_slot {
 	struct nfs4_slot_table	*table;
 	unsigned long		renewal_time;
+	u32			slot_nr;
 	u32		 	seq_nr;
 };
 
-- 
1.7.11.7

