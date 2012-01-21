Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755935Ab2AUAEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 19:04:10 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4: Avoid thundering herd issues with nfs_release_seqid
Date: Fri, 20 Jan 2012 19:03:47 -0500
Message-Id: <1327104228-14764-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Store a pointer to the rpc_task in struct nfs_seqid so that we can wake up
only that request that holds the lock after we've released it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4state.c |   21 +++++++++++++++------
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c45c21a..b133b50 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -71,6 +71,7 @@ struct nfs_seqid_counter {
 struct nfs_seqid {
 	struct nfs_seqid_counter *sequence;
 	struct list_head list;
+	struct rpc_task *task;
 };
 
 static inline void nfs_confirm_seqid(struct nfs_seqid_counter *seqid, int status)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f0e9881..7d09860 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -916,20 +916,28 @@ struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_m
 	if (new != NULL) {
 		new->sequence = counter;
 		INIT_LIST_HEAD(&new->list);
+		new->task = NULL;
 	}
 	return new;
 }
 
 void nfs_release_seqid(struct nfs_seqid *seqid)
 {
-	if (!list_empty(&seqid->list)) {
-		struct nfs_seqid_counter *sequence = seqid->sequence;
+	struct nfs_seqid_counter *sequence;
 
-		spin_lock(&sequence->lock);
-		list_del_init(&seqid->list);
-		spin_unlock(&sequence->lock);
-		rpc_wake_up(&sequence->wait);
+	if (list_empty(&seqid->list))
+		return;
+	sequence = seqid->sequence;
+	spin_lock(&sequence->lock);
+	list_del_init(&seqid->list);
+	if (!list_empty(&sequence->list)) {
+		struct nfs_seqid *next;
+
+		next = list_first_entry(&sequence->list,
+				struct nfs_seqid, list);
+		rpc_wake_up_queued_task(&sequence->wait, next->task);
 	}
+	spin_unlock(&sequence->lock);
 }
 
 void nfs_free_seqid(struct nfs_seqid *seqid)
@@ -1000,6 +1008,7 @@ int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task)
 	int status = 0;
 
 	spin_lock(&sequence->lock);
+	seqid->task = task;
 	if (list_empty(&seqid->list))
 		list_add_tail(&seqid->list, &sequence->list);
 	if (list_first_entry(&sequence->list, struct nfs_seqid, list) == seqid)
-- 
1.7.7.5

