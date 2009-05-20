From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [RFC 09/11] nfsd41: cb_sequence callback
Date: Tue, 19 May 2009 20:00:26 -0700
Message-ID: <1242788428-18723-9-git-send-email-Ricardo.Labiaga@netapp.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com>
 <1242788428-18723-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-6-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-7-git-send-email-Ricardo.Labiaga@netapp.com>
 <1242788428-18723-8-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10447 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755574AbZETDAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 23:00:32 -0400
In-Reply-To: <1242788428-18723-8-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Implement the cb_sequence callback conforming to draft-ietf-nfsv4-minorversion1

Note: highest slot id and target highest slot id do not have to be 0
as was previously implemented.  They can be greater than what the
nfs server sent if the client supports a larger slot table on the
backchannel.  At this point we just ignore that.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[Rework the back channel xdr using the shared v4.0 and v4.1 framework.]
Signed-off-by: Andy Adamson <andros@netapp.com>
[fixed indentation]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use nfsd4_cb_sequence for callback minorversion]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: fix verification of CB_SEQUENCE highest slot id[
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: Backchannel: Remove old backchannel serialization]
[nfsd41: Backchannel: First callback sequence ID should be 1]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: decode_cb_sequence does not need to actually decode ignored fields]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfsd/nfs4callback.c |   72 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index b739cc9..521d5f5 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -260,6 +260,27 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp,
 	hdr->nops++;
 }
 
+static void
+encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
+		   struct nfs4_cb_compound_hdr *hdr)
+{
+	__be32 *p;
+
+	if (hdr->minorversion == 0)
+		return;
+
+	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
+
+	WRITE32(OP_CB_SEQUENCE);
+	WRITEMEM(args->cbs_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	WRITE32(args->cbs_clp->cl_cb_seq_nr);
+	WRITE32(0);		/* slotid, always 0 */
+	WRITE32(0);		/* highest slotid always 0 */
+	WRITE32(0);		/* cachethis always 0 */
+	WRITE32(0); /* FIXME: support referring_call_lists */
+	hdr->nops++;
+}
+
 static int
 nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 {
@@ -321,6 +342,57 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	return 0;
 }
 
+/*
+ * Our current back channel implmentation supports a single backchannel
+ * with a single slot.
+ */
+static int
+decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
+		   struct rpc_rqst *rqstp)
+{
+	struct nfs4_sessionid id;
+	int status;
+	u32 dummy;
+	__be32 *p;
+
+	if (res->cbs_minorversion == 0)
+		return 0;
+
+	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
+	if (status)
+		return status;
+
+	/*
+	 * If the server returns different values for sessionID, slotID or
+	 * sequence number, the server is looney tunes.
+	 */
+	status = -ESERVERFAULT;
+
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
+	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
+	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
+	if (memcmp(id.data, res->cbs_clp->cl_sessionid.data,
+		   NFS4_MAX_SESSIONID_LEN)) {
+		dprintk("%s Invalid session id\n", __func__);
+		goto out;
+	}
+	READ32(dummy);
+	if (dummy != res->cbs_clp->cl_cb_seq_nr) {
+		dprintk("%s Invalid sequence number\n", __func__);
+		goto out;
+	}
+	READ32(dummy); 	/* slotid must be 0 */
+	if (dummy != 0) {
+		dprintk("%s Invalid slotid\n", __func__);
+		goto out;
+	}
+	/* FIXME: process highest slotid and target highest slotid */
+	status = 0;
+out:
+	return status;
+}
+
+
 static int
 nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 {
-- 
1.5.4.3

