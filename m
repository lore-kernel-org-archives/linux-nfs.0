Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454Ab0JUQUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 03/11] nfsd4: use client pointer to backchannel session
Date: Thu, 21 Oct 2010 12:20:10 -0400
Message-Id: <1287678018-9266-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Instead of copying the sessionid, use the new cl_cb_session pointer,
which indicates which session we're using for the backchannel.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    9 +++++----
 fs/nfsd/nfs4state.c    |    4 +---
 fs/nfsd/state.h        |    1 -
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a269dbe..78ac779 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -251,6 +251,7 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 		   struct nfs4_cb_compound_hdr *hdr)
 {
 	__be32 *p;
+	struct nfsd4_session *ses = cb->cb_clp->cl_cb_session;
 
 	if (hdr->minorversion == 0)
 		return;
@@ -258,7 +259,7 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
 
 	WRITE32(OP_CB_SEQUENCE);
-	WRITEMEM(cb->cb_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	WRITEMEM(ses->se_sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(cb->cb_clp->cl_cb_seq_nr);
 	WRITE32(0);		/* slotid, always 0 */
 	WRITE32(0);		/* highest slotid always 0 */
@@ -341,6 +342,7 @@ static int
 decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 		   struct rpc_rqst *rqstp)
 {
+	struct nfsd4_session *ses = cb->cb_clp->cl_cb_session;
 	struct nfs4_sessionid id;
 	int status;
 	u32 dummy;
@@ -362,8 +364,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
 	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
 	p += XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN);
-	if (memcmp(id.data, cb->cb_clp->cl_sessionid.data,
-		   NFS4_MAX_SESSIONID_LEN)) {
+	if (memcmp(id.data, ses->se_sessionid.data, NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
 		goto out;
 	}
@@ -587,7 +588,7 @@ void nfsd4_probe_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
 		struct rpc_task *task)
 {
-	u32 *ptr = (u32 *)clp->cl_sessionid.data;
+	u32 *ptr = (u32 *)clp->cl_cb_session->se_sessionid.data;
 	int status = 0;
 
 	dprintk("%s: %u:%u:%u:%u\n", __func__,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index db5d8c8..c942511 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -753,8 +753,6 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
 
 	new->se_client = clp;
 	gen_sessionid(new);
-	memcpy(clp->cl_sessionid.data, new->se_sessionid.data,
-	       NFS4_MAX_SESSIONID_LEN);
 
 	INIT_LIST_HEAD(&new->se_conns);
 
@@ -1544,7 +1542,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-	memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
+	memcpy(cr_ses->sessionid.data, conf->cl_cb_session->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = cs_slot->sl_seqid;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6e63c1d..cdce26a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -243,7 +243,6 @@ struct nfs4_client {
 	struct list_head	cl_sessions;
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
-	struct nfs4_sessionid	cl_sessionid;
 	/* number of rpc's in progress over an associated session: */
 	atomic_t		cl_refcount;
 
-- 
1.7.1

