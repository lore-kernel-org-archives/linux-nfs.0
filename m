Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:20129 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315Ab2KVSpz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:45:55 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/20] NFSv4.1: Simplify struct nfs4_sequence_args too
Date: Wed, 21 Nov 2012 17:43:08 -0500
Message-Id: <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the session pointer + slotid with a pointer to the
allocated slot.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       |  6 +++---
 fs/nfs/nfs4xdr.c        | 21 ++++++++++-----------
 include/linux/nfs_xdr.h |  3 +--
 3 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4f2d058..7c2b037 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -592,7 +592,7 @@ out:
 static void nfs41_init_sequence(struct nfs4_sequence_args *args,
 		struct nfs4_sequence_res *res, int cache_reply)
 {
-	args->sa_session = NULL;
+	args->sa_slot = NULL;
 	args->sa_cache_this = 0;
 	if (cache_reply)
 		args->sa_cache_this = 1;
@@ -645,8 +645,8 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	rpc_task_set_priority(task, RPC_PRIORITY_NORMAL);
 	slot = tbl->slots + slotid;
 	slot->renewal_time = jiffies;
-	args->sa_session = session;
-	args->sa_slotid = slotid;
+
+	args->sa_slot = slot;
 
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 50bac70..27b0fec 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1833,18 +1833,16 @@ static void encode_sequence(struct xdr_stream *xdr,
 			    struct compound_hdr *hdr)
 {
 #if defined(CONFIG_NFS_V4_1)
-	struct nfs4_session *session = args->sa_session;
+	struct nfs4_session *session;
 	struct nfs4_slot_table *tp;
-	struct nfs4_slot *slot;
+	struct nfs4_slot *slot = args->sa_slot;
 	__be32 *p;
 
-	if (!session)
+	if (slot == NULL)
 		return;
 
-	tp = &session->fc_slot_table;
-
-	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
-	slot = tp->slots + args->sa_slotid;
+	tp = slot->table;
+	session = tp->session;
 
 	encode_op_hdr(xdr, OP_SEQUENCE, decode_sequence_maxsz, hdr);
 
@@ -1858,12 +1856,12 @@ static void encode_sequence(struct xdr_stream *xdr,
 		((u32 *)session->sess_id.data)[1],
 		((u32 *)session->sess_id.data)[2],
 		((u32 *)session->sess_id.data)[3],
-		slot->seq_nr, args->sa_slotid,
+		slot->seq_nr, slot->slot_nr,
 		tp->highest_used_slotid, args->sa_cache_this);
 	p = reserve_space(xdr, NFS4_MAX_SESSIONID_LEN + 16);
 	p = xdr_encode_opaque_fixed(p, session->sess_id.data, NFS4_MAX_SESSIONID_LEN);
 	*p++ = cpu_to_be32(slot->seq_nr);
-	*p++ = cpu_to_be32(args->sa_slotid);
+	*p++ = cpu_to_be32(slot->slot_nr);
 	*p++ = cpu_to_be32(tp->highest_used_slotid);
 	*p = cpu_to_be32(args->sa_cache_this);
 #endif /* CONFIG_NFS_V4_1 */
@@ -2025,8 +2023,9 @@ static void encode_free_stateid(struct xdr_stream *xdr,
 static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
 {
 #if defined(CONFIG_NFS_V4_1)
-	if (args->sa_session)
-		return args->sa_session->clp->cl_mvops->minor_version;
+
+	if (args->sa_slot)
+		return args->sa_slot->table->session->clp->cl_mvops->minor_version;
 #endif /* CONFIG_NFS_V4_1 */
 	return 0;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9c9b76c..deb31bb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -194,8 +194,7 @@ struct nfs4_slot {
 };
 
 struct nfs4_sequence_args {
-	struct nfs4_session	*sa_session;
-	u32			sa_slotid;
+	struct nfs4_slot	*sa_slot;
 	u8			sa_cache_this;
 };
 
-- 
1.7.11.7

