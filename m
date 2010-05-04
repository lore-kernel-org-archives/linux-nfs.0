From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/8] nfsd4: rename sessionid_lock to client_lock
Date: Wed,  5 May 2010 01:43:40 +0300
Message-ID: <1273013020-32351-1-git-send-email-bhalevy@panasas.com>
References: <4BE0A1AE.4040905@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33154 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760225Ab0EDWnn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:43:43 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to share the lock's scope to both client
and session hash tables.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 737315c..2d77ae8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -249,6 +249,9 @@ unhash_delegation(struct nfs4_delegation *dp)
  * SETCLIENTID state 
  */
 
+/* client_lock protects the session hash table */
+static DEFINE_SPINLOCK(client_lock);
+
 /* Hash tables for nfs4_clientid state */
 #define CLIENT_HASH_BITS                 4
 #define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
@@ -367,7 +370,6 @@ static void release_openowner(struct nfs4_stateowner *sop)
 	nfs4_put_stateowner(sop);
 }
 
-static DEFINE_SPINLOCK(sessionid_lock);
 #define SESSION_HASH_SIZE	512
 static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
 
@@ -565,10 +567,10 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 
 	new->se_flags = cses->flags;
 	kref_init(&new->se_ref);
-	spin_lock(&sessionid_lock);
+	spin_lock(&client_lock);
 	list_add(&new->se_hash, &sessionid_hashtbl[idx]);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
-	spin_unlock(&sessionid_lock);
+	spin_unlock(&client_lock);
 
 	status = nfs_ok;
 out:
@@ -579,7 +581,7 @@ out_free:
 	goto out;
 }
 
-/* caller must hold sessionid_lock */
+/* caller must hold client_lock */
 static struct nfsd4_session *
 find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid)
 {
@@ -602,7 +604,7 @@ find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid)
 	return NULL;
 }
 
-/* caller must hold sessionid_lock */
+/* caller must hold client_lock */
 static void
 unhash_session(struct nfsd4_session *ses)
 {
@@ -613,9 +615,9 @@ unhash_session(struct nfsd4_session *ses)
 static void
 release_session(struct nfsd4_session *ses)
 {
-	spin_lock(&sessionid_lock);
+	spin_lock(&client_lock);
 	unhash_session(ses);
-	spin_unlock(&sessionid_lock);
+	spin_unlock(&client_lock);
 	nfsd4_put_session(ses);
 }
 
@@ -1372,15 +1374,15 @@ nfsd4_destroy_session(struct svc_rqst *r,
 			return nfserr_not_only_op;
 	}
 	dump_sessionid(__func__, &sessionid->sessionid);
-	spin_lock(&sessionid_lock);
+	spin_lock(&client_lock);
 	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
 	if (!ses) {
-		spin_unlock(&sessionid_lock);
+		spin_unlock(&client_lock);
 		goto out;
 	}
 
 	unhash_session(ses);
-	spin_unlock(&sessionid_lock);
+	spin_unlock(&client_lock);
 
 	/* wait for callbacks */
 	nfsd4_set_callback_client(ses->se_client, NULL);
@@ -1404,7 +1406,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (resp->opcnt != 1)
 		return nfserr_sequence_pos;
 
-	spin_lock(&sessionid_lock);
+	spin_lock(&client_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid);
 	if (!session)
@@ -1447,7 +1449,7 @@ out:
 	/* Hold a session reference until done processing the compound. */
 	if (cstate->session)
 		nfsd4_get_session(cstate->session);
-	spin_unlock(&sessionid_lock);
+	spin_unlock(&client_lock);
 	/* Renew the clientid on success and on replay */
 	if (cstate->session) {
 		nfs4_lock_state();
-- 
1.6.5.1

