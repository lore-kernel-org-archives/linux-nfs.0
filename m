From: andros@netapp.com
Subject: [PATCH 07/14] nfsd41: replace create_session DRC with xdr structure
Date: Wed, 24 Jun 2009 15:37:51 -0400
Message-ID: <1245872278-18743-8-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760148AbZFXTiC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:02 -0400
In-Reply-To: <1245872278-18743-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The nfs41 single slot clientid DRC holds the results of create session
processing.  CREATE_SESSION can be preceeded by a SEQUENCE operation
(an embedded CREATE_SESSION) and the create session single slot cache must be
maintained.  nfsd4_replay_cache_entry() and nfsd4_store_cache_entry() do not
implement the replay of an embedded CREATE_SESSION.

The cliendid DRC slot does not need the inuse, cachethis or other fields that
the multiple slot session cache uses.  Replace the clientid DRC cache struct
nfs4_slot cache with a new nfsd4_clid_slot cache.  Save the xdr struct
nfsd4_create_session into the cache at the end of processing, and on a replay,
replace the struct for the replay request with the cached version all while
under the state lock.

nfsd4_proc_compound will handle both the solo and embedded CREATE_SESSION case
via the normal use of encode_operation.

Errors that do not change the create session cache:
A create session NFS4ERR_STALE_CLIENTID error means that a client record
(and associated create session slot) could not be found and therefore can't
be changed.  NFSERR_SEQ_MISORDERED errors do not change the slot cache.

All other errors get cached.

Remove the clientid DRC specific check in nfs4svc_encode_compoundres to
put the session only if cstate.session is set which will now always be true.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c         |    2 +-
 fs/nfsd/nfs4state.c        |   64 ++++++++++++++++++++++++++------------------
 fs/nfsd/nfs4xdr.c          |    3 +-
 include/linux/nfsd/state.h |   21 +++++++++++++-
 include/linux/nfsd/xdr4.h  |   12 --------
 5 files changed, 60 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7c88017..b70a77d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1083,7 +1083,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			BUG_ON(op->status == nfs_ok);
 
 encode_op:
-		/* Only from SEQUENCE or CREATE_SESSION */
+		/* Only from SEQUENCE */
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
 			if (nfsd4_not_cached(resp))
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0eab5e2..e646a83 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -659,8 +659,6 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
-	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
-			     clp->cl_slot.sl_cache_entry.ce_resused);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1299,12 +1297,11 @@ out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
 
-	new->cl_slot.sl_seqid = 0;
 	exid->seqid = 1;
 	nfsd4_set_ex_flags(new, exid);
 
 	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
-		new->cl_slot.sl_seqid, new->cl_exchange_flags);
+		new->cl_cs_slot.sl_seqid, new->cl_exchange_flags);
 	status = nfs_ok;
 
 out:
@@ -1340,15 +1337,35 @@ check_slot_seqid(u32 seqid, u32 slot_seqid, int slot_inuse)
 	return nfserr_seq_misordered;
 }
 
+/*
+ * Cache the create session result into the create session single DRC
+ * slot cache by saving the xdr structure. sl_seqid has been set.
+ * Do this for solo or embedded create session operations.
+ */
+static void
+nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
+			   struct nfsd4_clid_slot *slot, int nfserr)
+{
+	slot->sl_status = nfserr;
+	memcpy(&slot->sl_cr_ses, cr_ses, sizeof(*cr_ses));
+}
+
+static __be32
+nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
+			    struct nfsd4_clid_slot *slot)
+{
+	memcpy(cr_ses, &slot->sl_cr_ses, sizeof(*cr_ses));
+	return slot->sl_status;
+}
+
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
 		     struct nfsd4_create_session *cr_ses)
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
-	struct nfsd4_slot *slot = NULL;
+	struct nfsd4_clid_slot *cs_slot = NULL;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1356,25 +1373,22 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	conf = find_confirmed_client(&cr_ses->clientid);
 
 	if (conf) {
-		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		cs_slot = &conf->cl_cs_slot;
+		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
-				slot->sl_seqid);
-			cstate->slot = slot;
-			cstate->status = status;
+				cs_slot->sl_seqid);
 			/* Return the cached reply status */
-			status = nfsd4_replay_cache_entry(resp, NULL);
+			status = nfsd4_replay_create_session(cr_ses, cs_slot);
 			goto out;
-		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
+		} else if (cr_ses->seqid != cs_slot->sl_seqid + 1) {
 			status = nfserr_seq_misordered;
 			dprintk("Sequence misordered!\n");
 			dprintk("Expected seqid= %d but got seqid= %d\n",
-				slot->sl_seqid, cr_ses->seqid);
+				cs_slot->sl_seqid, cr_ses->seqid);
 			goto out;
 		}
-		conf->cl_slot.sl_seqid++;
+		cs_slot->sl_seqid++;
 	} else if (unconf) {
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    (ip_addr != unconf->cl_addr)) {
@@ -1382,16 +1396,15 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out;
 		}
 
-		slot = &unconf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		cs_slot = &unconf->cl_cs_slot;
+		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
-			goto out;
+			goto out_cache;
 		}
 
-		slot->sl_seqid++; /* from 0 to 1 */
+		cs_slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
 		/*
@@ -1412,12 +1425,11 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
-	cr_ses->seqid = slot->sl_seqid;
+	cr_ses->seqid = cs_slot->sl_seqid;
 
-	slot->sl_inuse = true;
-	cstate->slot = slot;
-	/* Ensure a page is used for the cache */
-	slot->sl_cache_entry.ce_cachethis = 1;
+out_cache:
+	/* cache solo and embedded create sessions under the state lock */
+	nfsd4_cache_create_session(cr_ses, cs_slot, status);
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2dcc7fe..fdf632b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3313,8 +3313,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			resp->cstate.slot->sl_inuse = 0;
 		}
-		if (resp->cstate.session)
-			nfsd4_put_session(resp->cstate.session);
+		nfsd4_put_session(resp->cstate.session);
 	}
 	return 1;
 }
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 10b6b30..c45a7bd 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -128,6 +128,25 @@ struct nfsd4_channel_attrs {
 	u32		rdma_attrs;
 };
 
+struct nfsd4_create_session {
+	clientid_t			clientid;
+	struct nfs4_sessionid		sessionid;
+	u32				seqid;
+	u32				flags;
+	struct nfsd4_channel_attrs	fore_channel;
+	struct nfsd4_channel_attrs	back_channel;
+	u32				callback_prog;
+	u32				uid;
+	u32				gid;
+};
+
+/* The single slot clientid cache structure */
+struct nfsd4_clid_slot {
+	u32				sl_seqid;
+	__be32				sl_status;
+	struct nfsd4_create_session	sl_cr_ses;
+};
+
 struct nfsd4_session {
 	struct kref		se_ref;
 	struct list_head	se_hash;	/* hash by sessionid */
@@ -194,7 +213,7 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
-	struct nfsd4_slot	cl_slot;	/* create_session slot */
+	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
 };
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 2bacf75..5e4beb0 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -366,18 +366,6 @@ struct nfsd4_exchange_id {
 	int		spa_how;
 };
 
-struct nfsd4_create_session {
-	clientid_t		clientid;
-	struct nfs4_sessionid	sessionid;
-	u32			seqid;
-	u32			flags;
-	struct nfsd4_channel_attrs fore_channel;
-	struct nfsd4_channel_attrs back_channel;
-	u32			callback_prog;
-	u32			uid;
-	u32			gid;
-};
-
 struct nfsd4_sequence {
 	struct nfs4_sessionid	sessionid;		/* request/response */
 	u32			seqid;			/* request/response */
-- 
1.5.4.3

