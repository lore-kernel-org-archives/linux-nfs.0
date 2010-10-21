Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57701 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048Ab0JUQUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/11] nfsd4: delay session removal till free_client
Date: Thu, 21 Oct 2010 12:20:16 -0400
Message-Id: <1287678018-9266-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Have unhash_client_locked() remove client and associated sessions from
global hashes, but delay further dismantling till free_client().

(After unhash_client_locked(), the only remaining references outside the
destroying thread are from any connections which have xpt_user callbacks
registered.)

This will simplify locking on session destruction.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2327a8c..0f2643d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -883,6 +883,13 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 static inline void
 free_client(struct nfs4_client *clp)
 {
+	while (!list_empty(&clp->cl_sessions)) {
+		struct nfsd4_session *ses;
+		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
+				se_perclnt);
+		list_del(&ses->se_perclnt);
+		nfsd4_put_session(ses);
+	}
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -909,15 +916,12 @@ release_session_client(struct nfsd4_session *session)
 static inline void
 unhash_client_locked(struct nfs4_client *clp)
 {
+	struct nfsd4_session *ses;
+
 	mark_client_expired(clp);
 	list_del(&clp->cl_lru);
-	while (!list_empty(&clp->cl_sessions)) {
-		struct nfsd4_session  *ses;
-		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
-				 se_perclnt);
-		unhash_session(ses);
-		nfsd4_put_session(ses);
-	}
+	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
+		list_del_init(&ses->se_hash);
 }
 
 static void
@@ -1031,6 +1035,8 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	if (clp == NULL)
 		return NULL;
 
+	INIT_LIST_HEAD(&clp->cl_sessions);
+
 	princ = svc_gss_principal(rqstp);
 	if (princ) {
 		clp->cl_principal = kstrdup(princ, GFP_KERNEL);
@@ -1047,7 +1053,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
-	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
 	spin_lock_init(&clp->cl_lock);
 	INIT_WORK(&clp->cl_cb_null.cb_work, nfsd4_do_callback_rpc);
-- 
1.7.1

