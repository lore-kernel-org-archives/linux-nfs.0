Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45042 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253Ab2KMPqh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:37 -0500
Subject: [PATCH 10/15] nfsd: make sessionid_hashtbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:09 +0300
Message-ID: <20121113154909.12577.75763.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds established sessions state and closely associated with
nfs4_clients info, which are network namespace aware. So let's make it
allocated per network namespace too.

Note: this hash can be allocated in per-net operations. But it looks
better to allocate it on nfsd state start and thus don't waste resources
if server is not running.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    3 +++
 fs/nfsd/nfs4state.c |   28 +++++++++++++++++-----------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index f7a6b87..2c44f2b 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -32,6 +32,8 @@
 #define LOCKOWNER_INO_HASH_BITS		8
 #define LOCKOWNER_INO_HASH_SIZE		(1 << LOCKOWNER_INO_HASH_BITS)
 
+#define SESSION_HASH_SIZE	512
+
 struct cld_net;
 
 struct nfsd_net {
@@ -65,6 +67,7 @@ struct nfsd_net {
 	struct list_head *unconf_id_hashtbl;
 	struct list_head *ownerstr_hashtbl;
 	struct list_head *lockowner_ino_hashtbl;
+	struct list_head *sessionid_hashtbl;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ddc5a9f..f463d8f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -630,9 +630,6 @@ static void release_openowner(struct nfs4_openowner *oo)
 	nfs4_free_openowner(oo);
 }
 
-#define SESSION_HASH_SIZE	512
-static struct list_head sessionid_hashtbl[SESSION_HASH_SIZE];
-
 static inline int
 hash_sessionid(struct nfs4_sessionid *sessionid)
 {
@@ -926,6 +923,7 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
 void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	int idx;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	new->se_client = clp;
 	gen_sessionid(new);
@@ -939,7 +937,7 @@ void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4
 	kref_init(&new->se_ref);
 	idx = hash_sessionid(&new->se_sessionid);
 	spin_lock(&client_lock);
-	list_add(&new->se_hash, &sessionid_hashtbl[idx]);
+	list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
 	spin_lock(&clp->cl_lock);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
@@ -961,15 +959,16 @@ void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4
 
 /* caller must hold client_lock */
 static struct nfsd4_session *
-find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid)
+find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 {
 	struct nfsd4_session *elem;
 	int idx;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	dump_sessionid(__func__, sessionid);
 	idx = hash_sessionid(sessionid);
 	/* Search in the appropriate list */
-	list_for_each_entry(elem, &sessionid_hashtbl[idx], se_hash) {
+	list_for_each_entry(elem, &nn->sessionid_hashtbl[idx], se_hash) {
 		if (!memcmp(elem->se_sessionid.data, sessionid->data,
 			    NFS4_MAX_SESSIONID_LEN)) {
 			return elem;
@@ -1874,7 +1873,7 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
 	spin_lock(&client_lock);
-	cstate->session = find_in_sessionid_hashtbl(&bcts->sessionid);
+	cstate->session = find_in_sessionid_hashtbl(&bcts->sessionid, SVC_NET(rqstp));
 	/* Sorta weird: we only need the refcnt'ing because new_conn acquires
 	 * client_lock iself: */
 	if (cstate->session) {
@@ -1923,7 +1922,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	}
 	dump_sessionid(__func__, &sessionid->sessionid);
 	spin_lock(&client_lock);
-	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
+	ses = find_in_sessionid_hashtbl(&sessionid->sessionid, SVC_NET(r));
 	if (!ses) {
 		spin_unlock(&client_lock);
 		goto out;
@@ -2019,7 +2018,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 
 	spin_lock(&client_lock);
 	status = nfserr_badsession;
-	session = find_in_sessionid_hashtbl(&seq->sessionid);
+	session = find_in_sessionid_hashtbl(&seq->sessionid, SVC_NET(rqstp));
 	if (!session)
 		goto out;
 
@@ -4699,8 +4698,6 @@ nfs4_state_init(void)
 {
 	int i;
 
-	for (i = 0; i < SESSION_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
@@ -4759,6 +4756,10 @@ static int nfs4_state_start_net(struct net *net)
 			LOCKOWNER_INO_HASH_SIZE, GFP_KERNEL);
 	if (!nn->lockowner_ino_hashtbl)
 		goto err_lockowner_ino;
+	nn->sessionid_hashtbl = kmalloc(sizeof(struct list_head) *
+			SESSION_HASH_SIZE, GFP_KERNEL);
+	if (!nn->sessionid_hashtbl)
+		goto err_sessionid;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
@@ -4770,9 +4771,13 @@ static int nfs4_state_start_net(struct net *net)
 		INIT_LIST_HEAD(&nn->ownerstr_hashtbl[i]);
 	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->lockowner_ino_hashtbl[i]);
+	for (i = 0; i < SESSION_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 
 	return 0;
 
+err_sessionid:
+	kfree(nn->lockowner_ino_hashtbl);
 err_lockowner_ino:
 	kfree(nn->ownerstr_hashtbl);
 err_ownerstr:
@@ -4804,6 +4809,7 @@ __nfs4_state_shutdown_net(struct net *net)
 			destroy_client(clp);
 		}
 	}
+	kfree(nn->sessionid_hashtbl);
 	kfree(nn->lockowner_ino_hashtbl);
 	kfree(nn->ownerstr_hashtbl);
 	kfree(nn->unconf_id_hashtbl);

