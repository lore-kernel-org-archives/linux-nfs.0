From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 7/8] nfsd4: keep a reference count on client while in use
Date: Wed,  5 May 2010 01:44:54 +0300
Message-ID: <1273013094-32569-1-git-send-email-bhalevy@panasas.com>
References: <4BE0A1AE.4040905@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38827 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934370Ab0EDWo5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:44:57 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get a refcount on the client on SEQUENCE,
Release the refcount and renew the client when all respective compounds completed.
Do not expire the client by the laundromat while in use.
If the client was expired via another path, free it when the compounds
complete and the refcount reaches 0.

Note that unhash_client_locked must call list_del_init on cl_lru as
it may be called twice for the same client (once from nfs4_laundromat
and then from expire_client)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   27 +++++++++++++++++++++++----
 fs/nfsd/nfs4xdr.c   |    3 ++-
 fs/nfsd/state.h     |    1 +
 3 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4b1d39f..3b46994 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -692,11 +692,26 @@ free_client(struct nfs4_client *clp)
 	kfree(clp);
 }
 
+void
+release_session_client(struct nfsd4_session *session)
+{
+	struct nfs4_client *clp = session->se_client;
+
+	spin_lock(&client_lock);
+	BUG_ON(clp->cl_refcount <= 0);
+	if (--clp->cl_refcount <= 0)
+		free_client(clp);
+	else if (clp->cl_refcount == 1)
+		renew_client_locked(clp);
+	spin_unlock(&client_lock);
+	nfsd4_put_session(session);
+}
+
 /* must be called under the client_lock */
 static inline void
 unhash_client_locked(struct nfs4_client *clp)
 {
-	list_del(&clp->cl_lru);
+	list_del_init(&clp->cl_lru);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session  *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
@@ -1460,8 +1475,7 @@ out:
 	/* Hold a session reference until done processing the compound. */
 	if (cstate->session) {
 		nfsd4_get_session(cstate->session);
-		/* Renew the clientid on success and on replay */
-		renew_client_locked(session->se_client);
+		session->se_client->cl_refcount++;
 	}
 	spin_unlock(&client_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
@@ -2581,7 +2595,12 @@ nfs4_laundromat(void)
 				clientid_val = t;
 			break;
 		}
-		list_del_init(&clp->cl_lru);
+		if (clp->cl_refcount > 1) {
+			dprintk("NFSD: client in use (clientid %08x)\n",
+				clp->cl_clientid.cl_id);
+			continue;
+		}
+		unhash_client_locked(clp);
 		spin_unlock(&client_lock);
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b27bcf3..05536e8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3312,7 +3312,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			cs->slot->sl_inuse = false;
 		}
-		nfsd4_put_session(cs->session);
+		/* Renew the clientid on success and on replay */
+		release_session_client(cs->session);
 	}
 	return 1;
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 09c827d..30121c3 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -407,6 +407,7 @@ extern int nfs4_has_reclaimed_state(const char *name, bool use_exchange_id);
 extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
+extern void release_session_client(struct nfsd4_session *);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)
-- 
1.6.5.1

