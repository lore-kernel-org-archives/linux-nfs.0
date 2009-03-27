From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 25/47] nfsd41: Add a create session replay cache
Date: Fri, 27 Mar 2009 06:16:39 +0300
Message-ID: <1238123799-7722-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26089 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753483AbZC0DQo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:16:44 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replace the nfs4_client cl_seqid field with a single struct nfs41_slot used
for the create session replay cache.

The CREATE_SESSION slot sets the sl_session pointer to NULL. Otherwise, the
slot and it's replay cache are used just like the session slots.

Fix unconfirmed create_session replay response by initializing the
create_session slot sequence id to 0.

A future patch will set the CREATE_SESSION cache when a SEQUENCE operation
preceeds the CREATE_SESSION operation. This compound is currently only cached
in the session slot table.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use bool inuse for slot state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   47 ++++++++++++++++++++++++++++++-------------
 include/linux/nfsd/state.h |    2 +-
 2 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e4e2c19..61af434 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -662,6 +662,10 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
+#if defined(CONFIG_NFSD_V4_1)
+	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
+			     clp->cl_slot.sl_cache_entry.ce_resused);
+#endif /* CONFIG_NFSD_V4_1 */
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1055,12 +1059,14 @@ nfsd4_set_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	struct svc_rqst *rqstp = resp->rqstp;
+	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	struct nfsd4_op *op = &args->ops[resp->opcnt];
 	struct kvec *resv = &rqstp->rq_res.head[0];
 
 	dprintk("--> %s entry %p\n", __func__, entry);
 
-	/* Don't cache a failed OP_SEQUENCE */
-	if (resp->opcnt == 1 && resp->cstate.status)
+	/* Don't cache a failed OP_SEQUENCE. */
+	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return;
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	entry->ce_resused = rqstp->rq_resused;
@@ -1276,11 +1282,12 @@ out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
 
-	new->cl_seqid = exid->seqid = 1;
+	new->cl_slot.sl_seqid = 0;
+	exid->seqid = 1;
 	nfsd4_set_ex_flags(new, exid);
 
 	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
-		new->cl_seqid, new->cl_exchange_flags);
+		new->cl_slot.sl_seqid, new->cl_exchange_flags);
 	status = nfs_ok;
 
 out:
@@ -1322,7 +1329,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_create_session *cr_ses)
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
+	struct nfsd4_slot *slot = NULL;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1330,19 +1339,24 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	conf = find_confirmed_client(&cr_ses->clientid);
 
 	if (conf) {
-		status = nfs_ok;
-		if (conf->cl_seqid == cr_ses->seqid) {
+		slot = &conf->cl_slot;
+		status = check_slot_seqid(cr_ses->seqid, slot);
+		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
-				conf->cl_seqid);
-			goto out_replay;
-		} else if (cr_ses->seqid != conf->cl_seqid + 1) {
+				slot->sl_seqid);
+			cstate->slot = slot;
+			cstate->status = status;
+			/* Return the cached reply status */
+			status = nfsd4_replay_cache_entry(resp);
+			goto out;
+		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
 			status = nfserr_seq_misordered;
 			dprintk("Sequence misordered!\n");
 			dprintk("Expected seqid= %d but got seqid= %d\n",
-				conf->cl_seqid, cr_ses->seqid);
+				slot->sl_seqid, cr_ses->seqid);
 			goto out;
 		}
-		conf->cl_seqid++;
+		conf->cl_slot.sl_seqid++;
 	} else if (unconf) {
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    (ip_addr != unconf->cl_addr)) {
@@ -1350,11 +1364,15 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out;
 		}
 
-		if (unconf->cl_seqid != cr_ses->seqid) {
+		slot = &unconf->cl_slot;
+		status = check_slot_seqid(cr_ses->seqid, slot);
+		if (status) {
+			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
 			goto out;
 		}
 
+		slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
 		/*
@@ -1373,11 +1391,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-out_replay:
 	memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
-	cr_ses->seqid = conf->cl_seqid;
+	cr_ses->seqid = slot->sl_seqid;
 
+	slot->sl_inuse = true;
+	cstate->slot = slot;
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 98d7b1c..49d89fd 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -190,7 +190,7 @@ struct nfs4_client {
 	u32			cl_firststate;	/* recovery dir creation */
 #ifdef CONFIG_NFSD_V4_1
 	struct list_head	cl_sessions;
-	u32			cl_seqid;       /* seqid for create_session */
+	struct nfsd4_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
 
-- 
1.6.2.1

