Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35419 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab2BXBkz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2012 20:40:55 -0500
Received: by ghrr11 with SMTP id r11so944259ghr.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2012 17:40:55 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd41: free_session/free_client must be called under the client_lock
Date: Thu, 23 Feb 2012 17:40:52 -0800
Message-Id: <1330047652-21252-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The session client is manipulated under the client_lock hence
both free_session and nfsd4_del_conns must be called under this lock.

This patch adds a BUG_ON that checks this condition in the
respective functions and implements the missing locks.

nfsd4_{get,put}_session helpers were moved to the C file that uses them
so to prevent use from external files and an unlocked version of
nfsd4_put_session is provided for external use from nfs4xdr.c

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---

 fs/nfsd/nfs4state.c |   35 +++++++++++++++++++++++++++++++----
 fs/nfsd/state.h     |   13 +------------
 2 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3876c75..cc89f0d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -93,6 +93,19 @@
 static struct kmem_cache *stateid_slab = NULL;
 static struct kmem_cache *deleg_slab = NULL;
 
+static void free_session(struct kref *);
+
+/* Must be called under the client_lock */
+static void nfsd4_put_session_locked(struct nfsd4_session *ses)
+{
+	kref_put(&ses->se_ref, free_session);
+}
+
+static void nfsd4_get_session(struct nfsd4_session *ses)
+{
+	kref_get(&ses->se_ref);
+}
+
 void
 __nfs4_lock_state(const char *func)
 {
@@ -860,11 +873,12 @@ static void nfsd4_del_conns(struct nfsd4_session *s)
 	spin_unlock(&clp->cl_lock);
 }
 
-void free_session(struct kref *kref)
+static void free_session(struct kref *kref)
 {
 	struct nfsd4_session *ses;
 	int mem;
 
+	BUG_ON(!spin_is_locked(&client_lock));
 	ses = container_of(kref, struct nfsd4_session, se_ref);
 	nfsd4_del_conns(ses);
 	spin_lock(&nfsd_drc_lock);
@@ -875,6 +889,13 @@ void free_session(struct kref *kref)
 	kfree(ses);
 }
 
+void nfsd4_put_session(struct nfsd4_session *ses)
+{
+	spin_lock(&client_lock);
+	nfsd4_put_session_locked(ses);
+	spin_unlock(&client_lock);
+}
+
 static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new;
@@ -922,7 +943,9 @@ void free_session(struct kref *kref)
 	status = nfsd4_new_conn_from_crses(rqstp, new);
 	/* whoops: benny points out, status is ignored! (err, or bogus) */
 	if (status) {
+		spin_lock(&client_lock);
 		free_session(&new->se_ref);
+		spin_unlock(&client_lock);
 		return NULL;
 	}
 	if (cses->flags & SESSION4_BACK_CHAN) {
@@ -1034,12 +1057,13 @@ void free_session(struct kref *kref)
 static inline void
 free_client(struct nfs4_client *clp)
 {
+	BUG_ON(!spin_is_locked(&client_lock));
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
 				se_perclnt);
 		list_del(&ses->se_perclnt);
-		nfsd4_put_session(ses);
+		nfsd4_put_session_locked(ses);
 	}
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
@@ -1212,7 +1236,9 @@ struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 	if (princ) {
 		clp->cl_principal = kstrdup(princ, GFP_KERNEL);
 		if (clp->cl_principal == NULL) {
+			spin_lock(&client_lock);
 			free_client(clp);
+			spin_unlock(&client_lock);
 			return NULL;
 		}
 	}
@@ -1877,9 +1903,10 @@ static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4
 	nfsd4_probe_callback_sync(ses->se_client);
 	nfs4_unlock_state();
 
+	spin_lock(&client_lock);
 	nfsd4_del_conns(ses);
-
-	nfsd4_put_session(ses);
+	nfsd4_put_session_locked(ses);
+	spin_unlock(&client_lock);
 	status = nfs_ok;
 out:
 	dprintk("%s returns %d\n", __func__, ntohl(status));
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e2dd1c6..d381508 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -195,18 +195,7 @@ struct nfsd4_session {
 	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
 
-static inline void
-nfsd4_put_session(struct nfsd4_session *ses)
-{
-	extern void free_session(struct kref *kref);
-	kref_put(&ses->se_ref, free_session);
-}
-
-static inline void
-nfsd4_get_session(struct nfsd4_session *ses)
-{
-	kref_get(&ses->se_ref);
-}
+extern void nfsd4_put_session(struct nfsd4_session *ses);
 
 /* formatted contents of nfs4_sessionid */
 struct nfsd4_sessionid {
-- 
1.7.6.5

