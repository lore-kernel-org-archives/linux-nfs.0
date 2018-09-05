Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:54567 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:51 -0400
Received: by mail-it0-f67.google.com with SMTP id f14-v6so11501826ita.4
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:16 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.25.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:15 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] NFSv4: Convert struct nfs4_state to use refcount_t
Date: Wed,  5 Sep 2018 15:24:00 -0400
Message-Id: <20180905192400.107485-8-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-7-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com>
 <20180905192400.107485-3-trond.myklebust@hammerspace.com>
 <20180905192400.107485-4-trond.myklebust@hammerspace.com>
 <20180905192400.107485-5-trond.myklebust@hammerspace.com>
 <20180905192400.107485-6-trond.myklebust@hammerspace.com>
 <20180905192400.107485-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4_fs.h   | 2 +-
 fs/nfs/nfs4proc.c  | 8 ++++----
 fs/nfs/nfs4state.c | 8 ++++----
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1b4737f4cac4..8d59c9655ec4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -188,7 +188,7 @@ struct nfs4_state {
 	unsigned int n_wronly;		/* Number of write-only references */
 	unsigned int n_rdwr;		/* Number of read/write references */
 	fmode_t state;			/* State on the server (R,W, or RW) */
-	atomic_t count;
+	refcount_t count;
 
 	wait_queue_head_t waitq;
 	struct rcu_head rcu_head;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 10c20a5b075d..4da59bd53f98 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1777,7 +1777,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 out:
 	return ERR_PTR(ret);
 out_return_state:
-	atomic_inc(&state->count);
+	refcount_inc(&state->count);
 	return state;
 }
 
@@ -1849,7 +1849,7 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 update:
 	update_open_stateid(state, &data->o_res.stateid, NULL,
 			    data->o_arg.fmode);
-	atomic_inc(&state->count);
+	refcount_inc(&state->count);
 
 	return state;
 }
@@ -1887,7 +1887,7 @@ nfs4_opendata_find_nfs4_state(struct nfs4_opendata *data)
 		return ERR_CAST(inode);
 	if (data->state != NULL && data->state->inode == inode) {
 		state = data->state;
-		atomic_inc(&state->count);
+		refcount_inc(&state->count);
 	} else
 		state = nfs4_get_open_state(inode, data->owner);
 	iput(inode);
@@ -1978,7 +1978,7 @@ static struct nfs4_opendata *nfs4_open_recoverdata_alloc(struct nfs_open_context
 	if (opendata == NULL)
 		return ERR_PTR(-ENOMEM);
 	opendata->state = state;
-	atomic_inc(&state->count);
+	refcount_inc(&state->count);
 	return opendata;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7feac365038c..6ca3bd076073 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -655,7 +655,7 @@ nfs4_alloc_open_state(void)
 	state = kzalloc(sizeof(*state), GFP_NOFS);
 	if (!state)
 		return NULL;
-	atomic_set(&state->count, 1);
+	refcount_set(&state->count, 1);
 	INIT_LIST_HEAD(&state->lock_states);
 	spin_lock_init(&state->state_lock);
 	seqlock_init(&state->seqlock);
@@ -689,7 +689,7 @@ __nfs4_find_state_byowner(struct inode *inode, struct nfs4_state_owner *owner)
 			continue;
 		if (!nfs4_valid_open_stateid(state))
 			continue;
-		if (atomic_inc_not_zero(&state->count))
+		if (refcount_inc_not_zero(&state->count))
 			return state;
 	}
 	return NULL;
@@ -743,7 +743,7 @@ void nfs4_put_open_state(struct nfs4_state *state)
 	struct inode *inode = state->inode;
 	struct nfs4_state_owner *owner = state->owner;
 
-	if (!atomic_dec_and_lock(&state->count, &owner->so_lock))
+	if (!refcount_dec_and_lock(&state->count, &owner->so_lock))
 		return;
 	spin_lock(&inode->i_lock);
 	list_del_rcu(&state->inode_states);
@@ -1573,7 +1573,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			continue;
 		if (state->state == 0)
 			continue;
-		atomic_inc(&state->count);
+		refcount_inc(&state->count);
 		spin_unlock(&sp->so_lock);
 		status = ops->recover_open(sp, state);
 		if (status >= 0) {
-- 
2.17.1
