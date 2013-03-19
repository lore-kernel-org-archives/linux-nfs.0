Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389Ab3CSNHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:49 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/11] NFS: __nfs_find_lock_context needs to check ctx->lock_context for a match too
Date: Tue, 19 Mar 2013 09:07:35 -0400
Message-Id: <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we're forcing an unnecessary duplication of the
initial nfs_lock_context in calls to nfs_get_lock_context, since
__nfs_find_lock_context ignores the ctx->lock_context.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1f94167..55b840f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -565,16 +565,17 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
 
 static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context *ctx)
 {
-	struct nfs_lock_context *pos;
+	struct nfs_lock_context *head = &ctx->lock_context;
+	struct nfs_lock_context *pos = head;
 
-	list_for_each_entry(pos, &ctx->lock_context.list, list) {
+	do {
 		if (pos->lockowner.l_owner != current->files)
 			continue;
 		if (pos->lockowner.l_pid != current->tgid)
 			continue;
 		atomic_inc(&pos->count);
 		return pos;
-	}
+	} while ((pos = list_entry(pos->list.next, typeof(*pos), list)) != head);
 	return NULL;
 }
 
-- 
1.8.1.4

