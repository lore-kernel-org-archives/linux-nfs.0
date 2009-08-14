From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 17/21] nfs: nfs4xdr: introduce decode_sessionid helper
Date: Fri, 14 Aug 2009 17:20:00 +0300
Message-ID: <1250259600-14025-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27325
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932147AbZHNOUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:20:07 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b835dcc..af08947 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4212,6 +4212,11 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 	return 0;
 }
 
+static int decode_sessionid(struct xdr_stream *xdr, struct nfs4_sessionid *sid)
+{
+	return decode_opaque_fixed(xdr, sid->data, NFS4_MAX_SESSIONID_LEN);
+}
+
 static int decode_create_session(struct xdr_stream *xdr,
 				 struct nfs41_create_session_res *res)
 {
@@ -4221,14 +4226,11 @@ static int decode_create_session(struct xdr_stream *xdr,
 	struct nfs4_session *session = clp->cl_session;
 
 	status = decode_op_hdr(xdr, OP_CREATE_SESSION);
-
-	if (status)
+	if (!status)
+		status = decode_sessionid(xdr, &session->sess_id);
+	if (unlikely(status))
 		return status;
 
-	/* sessionid */
-	READ_BUF(NFS4_MAX_SESSIONID_LEN);
-	COPYMEM(&session->sess_id, NFS4_MAX_SESSIONID_LEN);
-
 	/* seqid, flags */
 	READ_BUF(8);
 	clp->cl_seqid = be32_to_cpup(p++);
@@ -4262,7 +4264,9 @@ static int decode_sequence(struct xdr_stream *xdr,
 		return 0;
 
 	status = decode_op_hdr(xdr, OP_SEQUENCE);
-	if (status)
+	if (!status)
+		status = decode_sessionid(xdr, &id);
+	if (unlikely(status))
 		goto out_err;
 
 	/*
@@ -4271,15 +4275,16 @@ static int decode_sequence(struct xdr_stream *xdr,
 	 */
 	status = -ESERVERFAULT;
 
-	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
-	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
-	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
 	if (memcmp(id.data, res->sr_session->sess_id.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
 		goto out_err;
 	}
+
+	READ_BUF(20);
+
 	/* seqid */
+	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
 	dummy = be32_to_cpup(p++);
 	if (dummy != slot->seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
-- 
1.6.4

