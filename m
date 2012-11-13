Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:48360 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab2KMPqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:46:46 -0500
Subject: [PATCH 12/15] nfsd: make close_lru list per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:19 +0300
Message-ID: <20121113154919.12577.6199.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This list holds nfs4 clients (open) stateowner queue for last close replay,
which are network namespace aware. So let's make this list per network
namespace too.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    4 ++++
 fs/nfsd/nfs4state.c |   18 +++++++-----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index e9f9a51..f024fe2 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -71,8 +71,12 @@ struct nfsd_net {
 	/*
 	 * client_lru holds client queue ordered by nfs4_client.cl_time
 	 * for lease renewal.
+	 *
+	 * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
+	 * for last close replay.
 	 */
 	struct list_head client_lru;
+	struct list_head close_lru;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1861016..d55136e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -402,12 +402,6 @@ static unsigned int clientstr_hashval(const char *name)
 }
 
 /*
- * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
- * for last close replay.
- */
-static struct list_head close_lru;
-
-/*
  * We store the NONE, READ, WRITE, and BOTH bits separately in the
  * st_{access,deny}_bmap field of the stateid, in order to track not
  * only what share bits are currently in force, but also what
@@ -2444,11 +2438,13 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 }
 
 static void
-move_to_close_lru(struct nfs4_openowner *oo)
+move_to_close_lru(struct nfs4_openowner *oo, struct net *net)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
 	dprintk("NFSD: move_to_close_lru nfs4_openowner %p\n", oo);
 
-	list_move_tail(&oo->oo_close_lru, &close_lru);
+	list_move_tail(&oo->oo_close_lru, &nn->close_lru);
 	oo->oo_time = get_seconds();
 }
 
@@ -3221,7 +3217,7 @@ nfs4_laundromat(void)
 		unhash_delegation(dp);
 	}
 	test_val = nfsd4_lease;
-	list_for_each_safe(pos, next, &close_lru) {
+	list_for_each_safe(pos, next, &nn->close_lru) {
 		oo = container_of(pos, struct nfs4_openowner, oo_close_lru);
 		if (time_after((unsigned long)oo->oo_time, (unsigned long)cutoff)) {
 			u = oo->oo_time - cutoff;
@@ -3799,7 +3795,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			 * little while to handle CLOSE replay.
 			 */
 			if (list_empty(&oo->oo_owner.so_stateids))
-				move_to_close_lru(oo);
+				move_to_close_lru(oo, SVC_NET(rqstp));
 		}
 	}
 out:
@@ -4701,7 +4697,6 @@ nfs4_state_init(void)
 	for (i = 0; i < FILE_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&file_hashtbl[i]);
 	}
-	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
 }
 
@@ -4773,6 +4768,7 @@ static int nfs4_state_start_net(struct net *net)
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	INIT_LIST_HEAD(&nn->client_lru);
+	INIT_LIST_HEAD(&nn->close_lru);
 
 	return 0;
 

