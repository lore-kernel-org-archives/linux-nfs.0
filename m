Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60148 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757940Ab2EAPpy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 11:45:54 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/6] nfsd4: int/__be32 fixes
Date: Tue,  1 May 2012 11:45:47 -0400
Message-Id: <1335887149-30420-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1335887149-30420-1-git-send-email-bfields@redhat.com>
References: <1335887149-30420-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In each of these cases there's a simple unambiguous correct choice, and
no actual bug.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   22 +++++++++++-----------
 fs/nfsd/nfs4xdr.c   |   12 ++++++------
 fs/nfsd/xdr4.h      |    6 +++---
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7fe95ec..c33f052 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -886,7 +886,7 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	struct nfsd4_session *new;
 	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
 	int numslots, slotsize;
-	int status;
+	__be32 status;
 	int idx;
 
 	/*
@@ -1477,7 +1477,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		  struct nfsd4_exchange_id *exid)
 {
 	struct nfs4_client *unconf, *conf, *new;
-	int status;
+	__be32 status;
 	unsigned int		strhashval;
 	char			dname[HEXDIR_LEN];
 	char			addr_str[INET6_ADDRSTRLEN];
@@ -1599,7 +1599,7 @@ error:
 	return status;
 }
 
-static int
+static __be32
 check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
 {
 	dprintk("%s enter. seqid %d slot_seqid %d\n", __func__, seqid,
@@ -1627,7 +1627,7 @@ check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
  */
 static void
 nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
-			   struct nfsd4_clid_slot *slot, int nfserr)
+			   struct nfsd4_clid_slot *slot, __be32 nfserr)
 {
 	slot->sl_status = nfserr;
 	memcpy(&slot->sl_cr_ses, cr_ses, sizeof(*cr_ses));
@@ -1658,7 +1658,7 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
 				/* seqid, slotID, slotID, slotID, status */ \
 			5 ) * sizeof(__be32))
 
-static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs fchannel)
+static bool check_forechannel_attrs(struct nfsd4_channel_attrs fchannel)
 {
 	return fchannel.maxreq_sz < NFSD_MIN_REQ_HDR_SEQ_SZ
 		|| fchannel.maxresp_sz < NFSD_MIN_RESP_HDR_SEQ_SZ;
@@ -1674,7 +1674,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct nfsd4_session *new;
 	struct nfsd4_clid_slot *cs_slot = NULL;
 	bool confirm_me = false;
-	int status = 0;
+	__be32 status = 0;
 
 	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
 		return nfserr_inval;
@@ -1819,7 +1819,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 		      struct nfsd4_destroy_session *sessionid)
 {
 	struct nfsd4_session *ses;
-	u32 status = nfserr_badsession;
+	__be32 status = nfserr_badsession;
 
 	/* Notes:
 	 * - The confirmed nfs4_client->cl_sessionid holds destroyed sessinid
@@ -1915,7 +1915,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	struct nfsd4_session *session;
 	struct nfsd4_slot *slot;
 	struct nfsd4_conn *conn;
-	int status;
+	__be32 status;
 
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
@@ -2020,7 +2020,7 @@ __be32
 nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
 {
 	struct nfs4_client *conf, *unconf, *clp;
-	int status = 0;
+	__be32 status = 0;
 
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&dc->clientid);
@@ -2056,7 +2056,7 @@ out:
 __be32
 nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_reclaim_complete *rc)
 {
-	int status = 0;
+	__be32 status = 0;
 
 	if (rc->rca_one_fs) {
 		if (!cstate->current_fh.fh_dentry)
@@ -3378,7 +3378,7 @@ static bool stateid_generation_after(stateid_t *a, stateid_t *b)
 	return (s32)a->si_generation - (s32)b->si_generation > 0;
 }
 
-static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
+static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
 {
 	/*
 	 * When sessions are used the stateid generation number is ignored
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 59c5184..f7cc411 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3251,7 +3251,7 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
 }
 
 static __be32
-nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
+nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
 			 struct nfsd4_exchange_id *exid)
 {
 	__be32 *p;
@@ -3306,7 +3306,7 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
 }
 
 static __be32
-nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
+nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 			    struct nfsd4_create_session *sess)
 {
 	__be32 *p;
@@ -3355,7 +3355,7 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, int nfserr,
 }
 
 static __be32
-nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
+nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 			     struct nfsd4_destroy_session *destroy_session)
 {
 	return nfserr;
@@ -3377,7 +3377,7 @@ nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, int nfserr,
 }
 
 static __be32
-nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
+nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 		      struct nfsd4_sequence *seq)
 {
 	__be32 *p;
@@ -3400,7 +3400,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 }
 
 static __be32
-nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
+nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 			  struct nfsd4_test_stateid *test_stateid)
 {
 	struct nfsd4_test_stateid_id *stateid, *next;
@@ -3503,7 +3503,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
  * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
  * will be at least a page and will therefore hold the xdr_buf head.
  */
-int nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
+__be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 {
 	struct xdr_buf *xb = &resp->rqstp->rq_res;
 	struct nfsd4_session *session = NULL;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2a55814..c3a8aa1 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -60,7 +60,7 @@ struct nfsd4_compound_state {
 	__be32			*datap;
 	size_t			iovlen;
 	u32			minorversion;
-	u32			status;
+	__be32			status;
 	stateid_t	current_stateid;
 	stateid_t	save_stateid;
 	/* to indicate current and saved state id presents */
@@ -364,7 +364,7 @@ struct nfsd4_test_stateid_id {
 };
 
 struct nfsd4_test_stateid {
-	__be32		ts_num_ids;
+	u32		ts_num_ids;
 	struct list_head ts_stateid_list;
 };
 
@@ -549,7 +549,7 @@ int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundargs *);
 int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundres *);
-int nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
+__be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-- 
1.7.9.5

