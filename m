Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56178 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932360Ab1AKQVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:42 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/14] nfsd4: support BIND_CONN_TO_SESSION
Date: Tue, 11 Jan 2011 11:21:22 -0500
Message-Id: <1294762894-21371-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Basic xdr and processing for BIND_CONN_TO_SESSION.  This adds a
connection to the list of connections associated with a session.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c   |    9 ++++++-
 fs/nfsd/nfs4state.c  |   59 ++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c    |   34 +++++++++++++++++++++++++++-
 fs/nfsd/state.h      |    5 ++++
 fs/nfsd/xdr4.h       |    2 +
 include/linux/nfs4.h |    3 ++
 6 files changed, 102 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fd6694b..db52546 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1004,8 +1004,8 @@ static const char *nfsd4_op_name(unsigned opnum);
  * Also note, enforced elsewhere:
  *	- SEQUENCE other than as first op results in
  *	  NFS4ERR_SEQUENCE_POS. (Enforced in nfsd4_sequence().)
- *	- BIND_CONN_TO_SESSION must be the only op in its compound
- *	  (Will be enforced in nfsd4_bind_conn_to_session().)
+ *	- BIND_CONN_TO_SESSION must be the only op in its compound.
+ *	  (Enforced in nfsd4_bind_conn_to_session().)
  *	- DESTROY_SESSION must be the final operation in a compound, if
  *	  sessionid's in SEQUENCE and DESTROY_SESSION are the same.
  *	  (Enforced in nfsd4_destroy_session().)
@@ -1326,6 +1326,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_EXCHANGE_ID",
 	},
+	[OP_BIND_CONN_TO_SESSION] = {
+		.op_func = (nfsd4op_func)nfsd4_bind_conn_to_session,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_name = "OP_BIND_CONN_TO_SESSION",
+	},
 	[OP_CREATE_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_create_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3cf9900..956174f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -679,15 +679,12 @@ static int nfsd4_register_conn(struct nfsd4_conn *conn)
 	return register_xpt_user(conn->cn_xprt, &conn->cn_xpt_user);
 }
 
-static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses, u32 dir)
 {
 	struct nfsd4_conn *conn;
-	u32 flags = NFS4_CDFC4_FORE;
 	int ret;
 
-	if (ses->se_flags & SESSION4_BACK_CHAN)
-		flags |= NFS4_CDFC4_BACK;
-	conn = alloc_conn(rqstp, flags);
+	conn = alloc_conn(rqstp, dir);
 	if (!conn)
 		return nfserr_jukebox;
 	nfsd4_hash_conn(conn, ses);
@@ -698,6 +695,17 @@ static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
 	return nfs_ok;
 }
 
+static __be32 nfsd4_new_conn_from_crses(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+{
+	u32 dir = NFS4_CDFC4_FORE;
+
+	if (ses->se_flags & SESSION4_BACK_CHAN)
+		dir |= NFS4_CDFC4_BACK;
+
+	return nfsd4_new_conn(rqstp, ses, dir);
+}
+
+/* must be called under client_lock */
 static void nfsd4_del_conns(struct nfsd4_session *s)
 {
 	struct nfs4_client *clp = s->se_client;
@@ -776,7 +784,7 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	spin_unlock(&clp->cl_lock);
 	spin_unlock(&client_lock);
 
-	status = nfsd4_new_conn(rqstp, new);
+	status = nfsd4_new_conn_from_crses(rqstp, new);
 	/* whoops: benny points out, status is ignored! (err, or bogus) */
 	if (status) {
 		free_session(&new->se_ref);
@@ -1597,6 +1605,45 @@ static bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
 	return argp->opcnt == resp->opcnt;
 }
 
+static __be32 nfsd4_map_bcts_dir(u32 *dir)
+{
+	switch (*dir) {
+	case NFS4_CDFC4_FORE:
+	case NFS4_CDFC4_BACK:
+		return nfs_ok;
+	case NFS4_CDFC4_FORE_OR_BOTH:
+	case NFS4_CDFC4_BACK_OR_BOTH:
+		*dir = NFS4_CDFC4_BOTH;
+		return nfs_ok;
+	};
+	return nfserr_inval;
+}
+
+__be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
+		     struct nfsd4_compound_state *cstate,
+		     struct nfsd4_bind_conn_to_session *bcts)
+{
+	__be32 status;
+
+	if (!nfsd4_last_compound_op(rqstp))
+		return nfserr_not_only_op;
+	spin_lock(&client_lock);
+	cstate->session = find_in_sessionid_hashtbl(&bcts->sessionid);
+	/* Sorta weird: we only need the refcnt'ing because new_conn acquires
+	 * client_lock iself: */
+	if (cstate->session) {
+		nfsd4_get_session(cstate->session);
+		atomic_inc(&cstate->session->se_client->cl_refcount);
+	}
+	spin_unlock(&client_lock);
+	if (!cstate->session)
+		return nfserr_badsession;
+
+	status = nfsd4_map_bcts_dir(&bcts->dir);
+	nfsd4_new_conn(rqstp, cstate->session, bcts->dir);
+	return nfs_ok;
+}
+
 static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
 {
 	if (!session)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ca37869..4ff2c9e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -421,6 +421,21 @@ nfsd4_decode_access(struct nfsd4_compoundargs *argp, struct nfsd4_access *access
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp, struct nfsd4_bind_conn_to_session *bcts)
+{
+	DECODE_HEAD;
+	u32 dummy;
+
+	READ_BUF(NFS4_MAX_SESSIONID_LEN + 8);
+	COPYMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+	READ32(bcts->dir);
+	/* XXX: Perhaps Tom Tucker could help us figure out how we
+	 * should be using ctsa_use_conn_in_rdma_mode: */
+	READ32(dummy);
+
+	DECODE_TAIL;
+}
+
 static __be32
 nfsd4_decode_close(struct nfsd4_compoundargs *argp, struct nfsd4_close *close)
 {
@@ -1359,7 +1374,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 
 	/* new operations for NFSv4.1 */
 	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_BIND_CONN_TO_SESSION]= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_BIND_CONN_TO_SESSION]= (nfsd4_dec)nfsd4_decode_bind_conn_to_session,
 	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
 	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
 	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
@@ -2383,6 +2398,21 @@ nfsd4_encode_access(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_
 	return nfserr;
 }
 
+static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_bind_conn_to_session *bcts)
+{
+	__be32 *p;
+
+	if (!nfserr) {
+		RESERVE_SPACE(NFS4_MAX_SESSIONID_LEN + 8);
+		WRITEMEM(bcts->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+		WRITE32(bcts->dir);
+		/* XXX: ? */
+		WRITE32(0);
+		ADJUST_ARGS();
+	}
+	return nfserr;
+}
+
 static __be32
 nfsd4_encode_close(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_close *close)
 {
@@ -3174,7 +3204,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 
 	/* NFSv4.1 operations */
 	[OP_BACKCHANNEL_CTL]	= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_noop,
+	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_bind_conn_to_session,
 	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
 	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
 	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cf6dc83..442f6d8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -148,6 +148,11 @@ struct nfsd4_create_session {
 	u32				gid;
 };
 
+struct nfsd4_bind_conn_to_session {
+	struct nfs4_sessionid		sessionid;
+	u32				dir;
+};
+
 /* The single slot clientid cache structure */
 struct nfsd4_clid_slot {
 	u32				sl_seqid;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 799c30c..3a7aa4d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -427,6 +427,7 @@ struct nfsd4_op {
 
 		/* NFSv4.1 */
 		struct nfsd4_exchange_id	exchange_id;
+		struct nfsd4_bind_conn_to_session bind_conn_to_session;
 		struct nfsd4_create_session	create_session;
 		struct nfsd4_destroy_session	destroy_session;
 		struct nfsd4_sequence		sequence;
@@ -523,6 +524,7 @@ extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_exchange_id *);
+extern __be32 nfsd4_bind_conn_to_session(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_bind_conn_to_session *);
 extern __be32 nfsd4_create_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_create_session *);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 26afa30..a591893 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -65,6 +65,9 @@
 
 #define NFS4_CDFC4_FORE	0x1
 #define NFS4_CDFC4_BACK 0x2
+#define NFS4_CDFC4_BOTH 0x3
+#define NFS4_CDFC4_FORE_OR_BOTH 0x3
+#define NFS4_CDFC4_BACK_OR_BOTH 0x7
 
 #define NFS4_SET_TO_SERVER_TIME	0
 #define NFS4_SET_TO_CLIENT_TIME	1
-- 
1.7.1

