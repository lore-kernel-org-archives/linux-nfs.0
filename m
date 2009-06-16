From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 05/44] nfsd41: separate clientid slot from session slot
Date: Tue, 16 Jun 2009 04:19:26 +0300
Message-ID: <1245115166-6964-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2504
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752928AbZFPBT0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The nfs41 single slot clientid cache holds the create session xdr struct
for replay on CREATE_SESSION retries.

struct nfsd4_clid_slot does not need the inuse, cachethis or other fields
that the multiple slot session cache uses.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: change struct nfsd4_clid_slot]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |   14 +++-----------
 include/linux/nfsd/state.h |   21 ++++++++++++++++++++-
 include/linux/nfsd/xdr4.h  |   12 ------------
 3 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5fdef66..f589952 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -652,8 +652,6 @@ static inline void
 free_client(struct nfs4_client *clp)
 {
 	shutdown_callback_client(clp);
-	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
-			     clp->cl_slot.sl_cache_entry.ce_resused);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -1297,7 +1295,6 @@ out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
 
-	new->cl_slot.sl_seqid = 0;
 	exid->seqid = 1;
 	nfsd4_set_ex_flags(new, exid);
 
@@ -1345,7 +1342,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
 	struct nfs4_client *conf, *unconf;
-	struct nfsd4_slot *slot = NULL;
+	struct nfsd4_clid_slot *slot = NULL;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1354,8 +1351,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (conf) {
 		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
@@ -1375,8 +1371,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 
 		slot = &unconf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
@@ -1406,9 +1401,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = slot->sl_seqid;
 
-	slot->sl_inuse = true;
-	/* Ensure a page is used for the cache */
-	slot->sl_cache_entry.ce_cachethis = 1;
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 105cc10..eae086c 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -126,6 +126,25 @@ struct nfsd4_channel_attrs {
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
@@ -192,7 +211,7 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
-	struct nfsd4_slot	cl_slot;	/* create_session slot */
+	struct nfsd4_clid_slot	cl_slot;	/* create_session slot */
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
1.6.3

