Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36427 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727815AbeIEX4u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:50 -0400
Received: by mail-it0-f65.google.com with SMTP id u13-v6so10991913iti.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:15 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.25.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:14 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] NFSv4: Convert open state lookup to use RCU
Date: Wed,  5 Sep 2018 15:23:59 -0400
Message-Id: <20180905192400.107485-7-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-6-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com>
 <20180905192400.107485-3-trond.myklebust@hammerspace.com>
 <20180905192400.107485-4-trond.myklebust@hammerspace.com>
 <20180905192400.107485-5-trond.myklebust@hammerspace.com>
 <20180905192400.107485-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Further reduce contention on the inode->i_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4_fs.h   |  1 +
 fs/nfs/nfs4state.c | 12 ++++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3a6904173214..1b4737f4cac4 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -191,6 +191,7 @@ struct nfs4_state {
 	atomic_t count;
 
 	wait_queue_head_t waitq;
+	struct rcu_head rcu_head;
 };
 
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index be92ce4259e9..7feac365038c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -684,7 +684,7 @@ __nfs4_find_state_byowner(struct inode *inode, struct nfs4_state_owner *owner)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs4_state *state;
 
-	list_for_each_entry(state, &nfsi->open_states, inode_states) {
+	list_for_each_entry_rcu(state, &nfsi->open_states, inode_states) {
 		if (state->owner != owner)
 			continue;
 		if (!nfs4_valid_open_stateid(state))
@@ -698,7 +698,7 @@ __nfs4_find_state_byowner(struct inode *inode, struct nfs4_state_owner *owner)
 static void
 nfs4_free_open_state(struct nfs4_state *state)
 {
-	kfree(state);
+	kfree_rcu(state, rcu_head);
 }
 
 struct nfs4_state *
@@ -707,9 +707,9 @@ nfs4_get_open_state(struct inode *inode, struct nfs4_state_owner *owner)
 	struct nfs4_state *state, *new;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	spin_lock(&inode->i_lock);
+	rcu_read_lock();
 	state = __nfs4_find_state_byowner(inode, owner);
-	spin_unlock(&inode->i_lock);
+	rcu_read_unlock();
 	if (state)
 		goto out;
 	new = nfs4_alloc_open_state();
@@ -720,7 +720,7 @@ nfs4_get_open_state(struct inode *inode, struct nfs4_state_owner *owner)
 		state = new;
 		state->owner = owner;
 		atomic_inc(&owner->so_count);
-		list_add(&state->inode_states, &nfsi->open_states);
+		list_add_rcu(&state->inode_states, &nfsi->open_states);
 		ihold(inode);
 		state->inode = inode;
 		spin_unlock(&inode->i_lock);
@@ -746,7 +746,7 @@ void nfs4_put_open_state(struct nfs4_state *state)
 	if (!atomic_dec_and_lock(&state->count, &owner->so_lock))
 		return;
 	spin_lock(&inode->i_lock);
-	list_del(&state->inode_states);
+	list_del_rcu(&state->inode_states);
 	list_del(&state->open_states);
 	spin_unlock(&inode->i_lock);
 	spin_unlock(&owner->so_lock);
-- 
2.17.1
