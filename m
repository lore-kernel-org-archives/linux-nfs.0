Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab1GMOuv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 10:50:51 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 0/2]  NFSD: add FREE_STATEID and TEST_STATEID operations
Date: Wed, 13 Jul 2011 10:50:47 -0400
Message-Id: <1310568648-11109-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1310568648-11109-1-git-send-email-bjschuma@netapp.com>
References: <1310568648-11109-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This operation is used by the client to tell the server to free a
stateid.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4proc.c  |    5 ++
 fs/nfsd/nfs4state.c |  118 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c   |   32 +++++++++++++-
 fs/nfsd/xdr4.h      |    8 +++
 4 files changed, 161 insertions(+), 2 deletions(-)

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
index e98f3c2..55c36e2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -60,9 +60,12 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
+static struct nfs4_stateid * search_for_stateid(stateid_t *stid);
+static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static void nfs4_set_recdir(char *recdir);
+static int check_for_locks(struct nfs4_file *filp, struct nfs4_stateowner *lowner);
 
 /* Locking: */
 
@@ -3137,6 +3140,11 @@ static int is_delegation_stateid(stateid_t *stateid)
 	return stateid->si_fileid == 0;
 }
 
+static int is_open_stateid(struct nfs4_stateid *stateid)
+{
+	return stateid->st_openstp == NULL;
+}
+
 /*
 * Checks for stateid operations
 */
@@ -3216,6 +3224,70 @@ out:
 	return status;
 }
 
+static __be32
+nfsd4_free_delegation_stateid(stateid_t *stateid)
+{
+	struct nfs4_delegation *dp = search_for_delegation(stateid);
+	if (dp)
+		return nfserr_locks_held;
+	return nfserr_bad_stateid;
+}
+
+static __be32
+nfsd4_free_lock_stateid(struct nfs4_stateid *stp)
+{
+	if (check_for_locks(stp->st_file, stp->st_stateowner))
+		return nfserr_locks_held;
+	release_lock_stateid(stp);
+	return nfs_ok;
+}
+
+/*
+ * Free a state id
+ */
+__be32
+nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		   struct nfsd4_free_stateid *free_stateid)
+{
+	stateid_t *stateid = &free_stateid->fr_stateid;
+	struct nfs4_stateid *stp;
+	__be32 ret;
+
+	nfs4_lock_state();
+	if (is_delegation_stateid(stateid)) {
+		ret = nfsd4_free_delegation_stateid(stateid);
+		goto out;
+	}
+
+	stp = search_for_stateid(stateid);
+	if (!stp) {
+		ret = nfserr_bad_stateid;
+		goto out;
+	}
+	if (stateid->si_generation != 0) {
+		if (stateid->si_generation < stp->st_stateid.si_generation) {
+			ret = nfserr_old_stateid;
+			goto out;
+		}
+		if (stateid->si_generation > stp->st_stateid.si_generation) {
+			ret = nfserr_bad_stateid;
+			goto out;
+		}
+	}
+
+	if (is_open_stateid(stp)) {
+		ret = nfserr_locks_held;
+		goto out;
+	} else {
+		ret = nfsd4_free_lock_stateid(stp);
+		goto out;
+	}
+
+out:
+	nfs4_unlock_state();
+	return ret;
+}
+
 static inline int
 setlkflg (int type)
 {
@@ -3594,6 +3666,14 @@ static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
 static struct list_head lockstateid_hashtbl[STATEID_HASH_SIZE];
 
+static int
+same_stateid(stateid_t *id_one, stateid_t *id_two)
+{
+	if (id_one->si_stateownerid != id_two->si_stateownerid)
+		return 0;
+	return id_one->si_fileid == id_two->si_fileid;
+}
+
 static struct nfs4_stateid *
 find_stateid(stateid_t *stid, int flags)
 {
@@ -3623,6 +3703,44 @@ find_stateid(stateid_t *stid, int flags)
 	return NULL;
 }
 
+static struct nfs4_stateid *
+search_for_stateid(stateid_t *stid)
+{
+	struct nfs4_stateid *local;
+	unsigned int hashval = stateid_hashval(stid->si_stateownerid, stid->si_fileid);
+
+	list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
+		if (same_stateid(&local->st_stateid, stid))
+			return local;
+	}
+
+	list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
+		if (same_stateid(&local->st_stateid, stid))
+			return local;
+	}
+	return NULL;
+}
+
+static struct nfs4_delegation *
+search_for_delegation(stateid_t *stid)
+{
+	struct nfs4_file *fp;
+	struct nfs4_delegation *dp;
+	struct list_head *pos;
+	int i;
+
+	for (i = 0; i < FILE_HASH_SIZE; i++) {
+		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
+			list_for_each(pos, &fp->fi_delegations) {
+				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
+				if (same_stateid(&dp->dl_stateid, stid))
+					return dp;
+			}
+		}
+	}
+	return NULL;
+}
+
 static struct nfs4_delegation *
 find_delegation_stateid(struct inode *ino, stateid_t *stid)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9901811..ef9bd6f 100644
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
@@ -3116,6 +3129,21 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 }
 
 static __be32
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
+static __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
 {
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
1.7.6

