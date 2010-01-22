From: andros@netapp.com
Subject: [PATCH 3/3] nfs41: cleanup callback code to use __be32 type
Date: Fri, 22 Jan 2010 12:03:08 -0500
Message-ID: <1264179788-5065-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab0AVRDb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 12:03:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |   15 ++++++++-------
 fs/nfs/callback_xdr.c  |   30 +++++++++++++++---------------
 2 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c79e18c..84761b5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -151,7 +151,7 @@ int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const n
  * checking the used_slots bit array on the table.  The lower layer guarantees
  * a single outstanding callback request at a time.
  */
-static int
+static __be32
 validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 {
 	struct nfs4_slot *slot;
@@ -285,11 +285,12 @@ out:
 	return status;
 }
 
-unsigned nfs4_callback_sequence(struct cb_sequenceargs *args,
+__be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 				struct cb_sequenceres *res)
 {
 	struct nfs_client *clp;
-	int i, status;
+	int i;
+	__be32 status;
 
 	status = htonl(NFS4ERR_BADSESSION);
 	clp = find_client_with_session(args->csa_addr, 4, &args->csa_sessionid);
@@ -333,10 +334,10 @@ out:
 	return status;
 }
 
-unsigned nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
+__be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 {
 	struct nfs_client *clp;
-	int status;
+	__be32 status;
 	fmode_t flags = 0;
 
 	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
@@ -363,11 +364,11 @@ out:
 }
 
 /* Reduce the fore channel's max_slots to the target value */
-unsigned nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
+__be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy)
 {
 	struct nfs_client *clp;
 	struct nfs4_slot_table *fc_tbl;
-	int status;
+	__be32 status;
 
 	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
 	clp = nfs_find_client(args->crsa_addr, 4);
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 8e66e20..db30c0b 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -219,10 +219,10 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 
-static unsigned decode_sessionid(struct xdr_stream *xdr,
+static __be32 decode_sessionid(struct xdr_stream *xdr,
 				 struct nfs4_sessionid *sid)
 {
-	uint32_t *p;
+	__be32 *p;
 	int len = NFS4_MAX_SESSIONID_LEN;
 
 	p = read_buf(xdr, len);
@@ -233,12 +233,12 @@ static unsigned decode_sessionid(struct xdr_stream *xdr,
 	return 0;
 }
 
-static unsigned decode_rc_list(struct xdr_stream *xdr,
+static __be32 decode_rc_list(struct xdr_stream *xdr,
 			       struct referring_call_list *rc_list)
 {
-	uint32_t *p;
+	__be32 *p;
 	int i;
-	unsigned status;
+	__be32 status;
 
 	status = decode_sessionid(xdr, &rc_list->rcl_sessionid);
 	if (status)
@@ -271,13 +271,13 @@ out:
 	return status;
 }
 
-static unsigned decode_cb_sequence_args(struct svc_rqst *rqstp,
+static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 					struct xdr_stream *xdr,
 					struct cb_sequenceargs *args)
 {
-	uint32_t *p;
+	__be32 *p;
 	int i;
-	unsigned status;
+	__be32 status;
 
 	status = decode_sessionid(xdr, &args->csa_sessionid);
 	if (status)
@@ -331,11 +331,11 @@ out_free:
 	goto out;
 }
 
-static unsigned decode_recallany_args(struct svc_rqst *rqstp,
+static __be32 decode_recallany_args(struct svc_rqst *rqstp,
 				      struct xdr_stream *xdr,
 				      struct cb_recallanyargs *args)
 {
-	uint32_t *p;
+	__be32 *p;
 
 	args->craa_addr = svc_addr(rqstp);
 	p = read_buf(xdr, 4);
@@ -350,7 +350,7 @@ static unsigned decode_recallany_args(struct svc_rqst *rqstp,
 	return 0;
 }
 
-static unsigned decode_recallslot_args(struct svc_rqst *rqstp,
+static __be32 decode_recallslot_args(struct svc_rqst *rqstp,
 					struct xdr_stream *xdr,
 					struct cb_recallslotargs *args)
 {
@@ -517,10 +517,10 @@ out:
 
 #if defined(CONFIG_NFS_V4_1)
 
-static unsigned encode_sessionid(struct xdr_stream *xdr,
+static __be32 encode_sessionid(struct xdr_stream *xdr,
 				 const struct nfs4_sessionid *sid)
 {
-	uint32_t *p;
+	__be32 *p;
 	int len = NFS4_MAX_SESSIONID_LEN;
 
 	p = xdr_reserve_space(xdr, len);
@@ -531,11 +531,11 @@ static unsigned encode_sessionid(struct xdr_stream *xdr,
 	return 0;
 }
 
-static unsigned encode_cb_sequence_res(struct svc_rqst *rqstp,
+static __be32 encode_cb_sequence_res(struct svc_rqst *rqstp,
 				       struct xdr_stream *xdr,
 				       const struct cb_sequenceres *res)
 {
-	uint32_t *p;
+	__be32 *p;
 	unsigned status = res->csr_status;
 
 	if (unlikely(status != 0))
-- 
1.6.6

