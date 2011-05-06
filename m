Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932557Ab1EFS5j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2011 14:57:39 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] NFSD: added FREE_STATEID operation
Date: Fri,  6 May 2011 14:57:34 -0400
Message-Id: <1304708255-20464-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1304708255-20464-1-git-send-email-bjschuma@netapp.com>
References: <1304708255-20464-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

This operation is used by the client to tell the server to free a
stateid.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4proc.c  |    5 ++++
 fs/nfsd/nfs4state.c |   56 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c   |   32 +++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h      |    8 +++++++
 4 files changed, 99 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a6dbd7..7e00116 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1412,6 +1412,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
 	},
+	[OP_FREE_STATEID] = {
+		.op_func = (nfsd4op_func)nfsd4_free_stateid,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_FREE_STATEID",
+	},
 };
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a2ea14f..6beec13 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -60,6 +60,7 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
+static struct nfs4_stateid * search_for_stateid(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static void nfs4_set_recdir(char *recdir);
@@ -316,6 +317,12 @@ static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head client_lru;
 static struct list_head close_lru;
 
+static int
+stateid_has_locks(struct nfs4_stateid *stp)
+{
+	return list_empty(&stp->st_lockowners);
+}
+
 /*
  * We store the NONE, READ, WRITE, and BOTH bits separately in the
  * st_{access,deny}_bmap field of the stateid, in order to track not
@@ -3212,6 +3219,33 @@ out:
 	return status;
 }
 
+/*
+ * Free a state id
+ */
+__be32
+nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		   struct nfsd4_free_stateid *free_stateid)
+{
+	struct nfs4_stateid *stp = NULL;
+	stateid_t *stateid = &free_stateid->fr_stateid;
+
+	stp = search_for_stateid(stateid);
+	if (!stp)
+		return nfserr_bad_stateid;
+	if (stateid->si_generation != 0) {
+		if (stateid->si_generation < stp->st_stateid.si_generation)
+			return nfserr_old_stateid;
+		if (stateid->si_generation > stp->st_stateid.si_generation)
+			return nfserr_bad_stateid;
+	}
+
+	if (stateid_has_locks(stp))
+		return nfserr_locks_held;
+	if (stp)
+		release_open_stateid(stp);
+	return nfs_ok;
+}
+
 static inline int
 setlkflg (int type)
 {
@@ -3619,6 +3653,28 @@ find_stateid(stateid_t *stid, int flags)
 	return NULL;
 }
 
+static struct nfs4_stateid *
+search_for_stateid(stateid_t *stid)
+{
+	struct nfs4_stateid *local;
+	u32 st_id = stid->si_stateownerid;
+	u32 f_id  = stid->si_fileid;
+	unsigned int hashval = stateid_hashval(st_id, f_id);
+
+	list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
+		if ((local->st_stateid.si_stateownerid == st_id) &&
+		    (local->st_stateid.si_fileid == f_id))
+			return local;
+	}
+
+	list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
+		if ((local->st_stateid.si_stateownerid == st_id) &&
+		    (local->st_stateid.si_fileid == f_id))
+			return local;
+	}
+	return NULL;
+}
+
 static struct nfs4_delegation *
 find_delegation_stateid(struct inode *ino, stateid_t *stid)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 195a91d..5da6874 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1246,6 +1246,19 @@ nfsd4_decode_destroy_session(struct nfsd4_compoundargs *argp,
 }
 
 static __be32
+nfsd4_decode_free_stateid(struct nfsd4_compoundargs *argp,
+			  struct nfsd4_free_stateid *free_stateid)
+{
+	DECODE_HEAD;
+
+	READ_BUF(sizeof(stateid_t));
+	READ32(free_stateid->fr_stateid.si_generation);
+	COPYMEM(&free_stateid->fr_stateid.si_opaque, sizeof(stateid_opaque_t));
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 		      struct nfsd4_sequence *seq)
 {
@@ -1370,7 +1383,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
 	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
 	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
-	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_free_stateid,
 	[OP_GET_DIR_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -3115,6 +3128,21 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 	return nfserr;
 }
 
+static __be32
+nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, int nfserr,
+			  struct nfsd4_free_stateid *free_stateid)
+{
+	__be32 *p;
+
+	if (nfserr)
+		return nfserr;
+
+	RESERVE_SPACE(4);
+	WRITE32(nfserr);
+	ADJUST_ARGS();
+	return nfserr;
+}
+
 __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
@@ -3196,7 +3224,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
 	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
 	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
-	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_free_stateid,
 	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 366401e..ed1784d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -342,6 +342,11 @@ struct nfsd4_setclientid_confirm {
 	nfs4_verifier	sc_confirm;
 };
 
+struct nfsd4_free_stateid {
+	stateid_t	fr_stateid;         /* request */
+	__be32		fr_status;          /* response */
+};
+
 /* also used for NVERIFY */
 struct nfsd4_verify {
 	u32		ve_bmval[3];        /* request */
@@ -432,6 +437,7 @@ struct nfsd4_op {
 		struct nfsd4_destroy_session	destroy_session;
 		struct nfsd4_sequence		sequence;
 		struct nfsd4_reclaim_complete	reclaim_complete;
+		struct nfsd4_free_stateid	free_stateid;
 	} u;
 	struct nfs4_replay *			replay;
 };
@@ -564,6 +570,8 @@ extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
 extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
 			  struct nfsd4_compound_state *, clientid_t *clid);
+extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
 #endif
 
 /*
-- 
1.7.5.1

