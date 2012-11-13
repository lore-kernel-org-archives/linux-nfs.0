Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15605 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab2KMPql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:41 -0500
Subject: [PATCH 11/15] nfsd: make client_lru list per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:14 +0300
Message-ID: <20121113154914.12577.57487.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This list holds nfs4 clients queue for lease renewal, which are network
namespace aware. So let's make this list per network namespace too.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    5 +++++
 fs/nfsd/nfs4state.c |   16 ++++++++--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 2c44f2b..e9f9a51 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -68,6 +68,11 @@ struct nfsd_net {
 	struct list_head *ownerstr_hashtbl;
 	struct list_head *lockowner_ino_hashtbl;
 	struct list_head *sessionid_hashtbl;
+	/*
+	 * client_lru holds client queue ordered by nfs4_client.cl_time
+	 * for lease renewal.
+	 */
+	struct list_head client_lru;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f463d8f..1861016 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -402,13 +402,9 @@ static unsigned int clientstr_hashval(const char *name)
 }
 
 /*
- * client_lru holds client queue ordered by nfs4_client.cl_time
- * for lease renewal.
- *
  * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
  * for last close replay.
  */
-static struct list_head client_lru;
 static struct list_head close_lru;
 
 /*
@@ -993,6 +989,8 @@ unhash_session(struct nfsd4_session *ses)
 static inline void
 renew_client_locked(struct nfs4_client *clp)
 {
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
 	if (is_client_expired(clp)) {
 		WARN_ON(1);
 		printk("%s: client (clientid %08x/%08x) already expired\n",
@@ -1005,7 +1003,7 @@ renew_client_locked(struct nfs4_client *clp)
 	dprintk("renewing client (clientid %08x/%08x)\n", 
 			clp->cl_clientid.cl_boot, 
 			clp->cl_clientid.cl_id);
-	list_move_tail(&clp->cl_lru, &client_lru);
+	list_move_tail(&clp->cl_lru, &nn->client_lru);
 	clp->cl_time = get_seconds();
 }
 
@@ -3175,6 +3173,7 @@ nfs4_laundromat(void)
 	time_t cutoff = get_seconds() - nfsd4_lease;
 	time_t t, clientid_val = nfsd4_lease;
 	time_t u, test_val = nfsd4_lease;
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	nfs4_lock_state();
 
@@ -3182,7 +3181,7 @@ nfs4_laundromat(void)
 	nfsd4_end_grace(&init_net);
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&client_lock);
-	list_for_each_safe(pos, next, &client_lru) {
+	list_for_each_safe(pos, next, &nn->client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
 			t = clp->cl_time - cutoff;
@@ -4570,9 +4569,10 @@ void nfsd_forget_clients(u64 num)
 {
 	struct nfs4_client *clp, *next;
 	int count = 0;
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	nfs4_lock_state();
-	list_for_each_entry_safe(clp, next, &client_lru, cl_lru) {
+	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
 		expire_client(clp);
 		if (++count == num)
 			break;
@@ -4702,7 +4702,6 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
 	INIT_LIST_HEAD(&close_lru);
-	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
 }
 
@@ -4773,6 +4772,7 @@ static int nfs4_state_start_net(struct net *net)
 		INIT_LIST_HEAD(&nn->lockowner_ino_hashtbl[i]);
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
+	INIT_LIST_HEAD(&nn->client_lru);
 
 	return 0;
 

