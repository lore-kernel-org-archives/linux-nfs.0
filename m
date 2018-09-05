Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:53061 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:47 -0400
Received: by mail-it0-f66.google.com with SMTP id h3-v6so11504429ita.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:13 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.25.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:12 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] NFS: Convert lookups of the lock context to RCU
Date: Wed,  5 Sep 2018 15:23:56 -0400
Message-Id: <20180905192400.107485-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-3-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com>
 <20180905192400.107485-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Speed up lookups of an existing lock context by avoiding the inode->i_lock,
and using RCU instead.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c         | 25 ++++++++++++-------------
 include/linux/nfs_fs.h |  1 +
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b65aee481d13..09b3b7146ff4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -857,15 +857,14 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 
 static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
 {
-	struct nfs_lock_context *head = &ctx->lock_context;
-	struct nfs_lock_context *pos = head;
+	struct nfs_lock_context *pos;
 
-	do {
+	list_for_each_entry_rcu(pos, &ctx->lock_context.list, list) {
 		if (pos->lockowner != current->files)
 			continue;
-		refcount_inc(&pos->count);
-		return pos;
-	} while ((pos = list_entry(pos->list.next, typeof(*pos), list)) != head);
+		if (refcount_inc_not_zero(&pos->count))
+			return pos;
+	}
 	return NULL;
 }
 
@@ -874,10 +873,10 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 	struct nfs_lock_context *res, *new = NULL;
 	struct inode *inode = d_inode(ctx->dentry);
 
-	spin_lock(&inode->i_lock);
+	rcu_read_lock();
 	res = __nfs_find_lock_context(ctx);
+	rcu_read_unlock();
 	if (res == NULL) {
-		spin_unlock(&inode->i_lock);
 		new = kmalloc(sizeof(*new), GFP_KERNEL);
 		if (new == NULL)
 			return ERR_PTR(-ENOMEM);
@@ -885,14 +884,14 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 		spin_lock(&inode->i_lock);
 		res = __nfs_find_lock_context(ctx);
 		if (res == NULL) {
-			list_add_tail(&new->list, &ctx->lock_context.list);
+			list_add_tail_rcu(&new->list, &ctx->lock_context.list);
 			new->open_context = ctx;
 			res = new;
 			new = NULL;
 		}
+		spin_unlock(&inode->i_lock);
+		kfree(new);
 	}
-	spin_unlock(&inode->i_lock);
-	kfree(new);
 	return res;
 }
 EXPORT_SYMBOL_GPL(nfs_get_lock_context);
@@ -904,9 +903,9 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 
 	if (!refcount_dec_and_lock(&l_ctx->count, &inode->i_lock))
 		return;
-	list_del(&l_ctx->list);
+	list_del_rcu(&l_ctx->list);
 	spin_unlock(&inode->i_lock);
-	kfree(l_ctx);
+	kfree_rcu(l_ctx, rcu_head);
 }
 EXPORT_SYMBOL_GPL(nfs_put_lock_context);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a0831e9d19c9..d2f4f88a0e66 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -62,6 +62,7 @@ struct nfs_lock_context {
 	struct nfs_open_context *open_context;
 	fl_owner_t lockowner;
 	atomic_t io_count;
+	struct rcu_head	rcu_head;
 };
 
 struct nfs4_state;
-- 
2.17.1
