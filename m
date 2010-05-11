From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 7/9] nfsd4: mark_client_expired
Date: Wed, 12 May 2010 00:13:41 +0300
Message-ID: <1273612421-13686-1-git-send-email-bhalevy@panasas.com>
References: <4BE9C7A2.8030801@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38017 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621Ab0EKVNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 17:13:44 -0400
In-Reply-To: <4BE9C7A2.8030801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mark the client as expired under the client_lock so it won't be renewed
when an nfsv4.1 session is done, after it was explicitly expired
during processing of the compound.

Do not renew a client mark as expired (in particular, it is not
on the lru list anymore)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   10 ++++++++++
 fs/nfsd/state.h     |   14 +++++++++++++-
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 295e8d9..378ee86 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -632,6 +632,14 @@ free_session(struct kref *kref)
 static inline void
 renew_client_locked(struct nfs4_client *clp)
 {
+	if (is_client_expired(clp)) {
+		dprintk("%s: client (clientid %08x/%08x) already expired\n",
+			__func__,
+			clp->cl_clientid.cl_boot,
+			clp->cl_clientid.cl_id);
+		return;
+	}
+
 	/*
 	* Move client to the end to the LRU list.
 	*/
@@ -697,6 +705,7 @@ free_client(struct nfs4_client *clp)
 static inline void
 unhash_client_locked(struct nfs4_client *clp)
 {
+	mark_client_expired(clp);
 	list_del(&clp->cl_lru);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session  *ses;
@@ -837,6 +846,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
+	clp->cl_time = get_seconds();
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	copy_verf(clp, verf);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 09c827d..37e1dff 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -166,7 +166,7 @@ struct nfsd4_session {
 	struct list_head	se_hash;	/* hash by sessionid */
 	struct list_head	se_perclnt;
 	u32			se_flags;
-	struct nfs4_client	*se_client;	/* for expire_client */
+	struct nfs4_client	*se_client;
 	struct nfs4_sessionid	se_sessionid;
 	struct nfsd4_channel_attrs se_fchannel;
 	struct nfsd4_channel_attrs se_bchannel;
@@ -243,6 +243,18 @@ struct nfs4_client {
 						/* wait here for slots */
 };
 
+static inline void
+mark_client_expired(struct nfs4_client *clp)
+{
+	clp->cl_time = 0;
+}
+
+static inline bool
+is_client_expired(struct nfs4_client *clp)
+{
+	return clp->cl_time == 0;
+}
+
 /* struct nfs4_client_reset
  * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl
  * upon lease reset, or from upcall to state_daemon (to read in state
-- 
1.6.5.1

