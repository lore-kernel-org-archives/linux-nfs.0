From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 19/35] nfsd41: Add a create session replay cache
Date: Fri,  3 Apr 2009 08:28:32 +0300
Message-ID: <1238736512-17672-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28044 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754911AbZDCF2h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:37 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
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
[nfsd41: revert portion of nfsd4_set_cache_entry]
Signed-off-by: Andy Adamson <andros-Kun280L+pZkAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   39 +++++++++++++++++++++++++++------------
 include/linux/nfsd/state.h |    2 +-
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 463ae39..58f9797 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -649,6 +649,8 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
+	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
+			     clp->cl_slot.sl_cache_entry.ce_resused);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1263,11 +1265,12 @@ out_copy:
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
@@ -1309,7 +1312,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_create_session *cr_ses)
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
+	struct nfsd4_slot *slot = NULL;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1317,19 +1322,24 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -1337,11 +1347,15 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -1360,11 +1374,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
index 692edf4..f063df7 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -190,7 +190,7 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
-	u32			cl_seqid;       /* seqid for create_session */
+	struct nfsd4_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
 };
-- 
1.6.2.1

