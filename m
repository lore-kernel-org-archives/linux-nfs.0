Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33020 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755272AbdGSWKS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:18 -0400
Received: by mail-it0-f68.google.com with SMTP id t6so860633itb.0
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:18 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 16/20] NFS: Remove unuse function nfs_page_group_lock_wait()
Date: Wed, 19 Jul 2017 18:09:51 -0400
Message-Id: <20170719220955.58210-17-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-16-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
 <20170719220955.58210-7-trond.myklebust@primarydata.com>
 <20170719220955.58210-8-trond.myklebust@primarydata.com>
 <20170719220955.58210-9-trond.myklebust@primarydata.com>
 <20170719220955.58210-10-trond.myklebust@primarydata.com>
 <20170719220955.58210-11-trond.myklebust@primarydata.com>
 <20170719220955.58210-12-trond.myklebust@primarydata.com>
 <20170719220955.58210-13-trond.myklebust@primarydata.com>
 <20170719220955.58210-14-trond.myklebust@primarydata.com>
 <20170719220955.58210-15-trond.myklebust@primarydata.com>
 <20170719220955.58210-16-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c        | 21 ---------------------
 include/linux/nfs_page.h |  1 -
 2 files changed, 22 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a6f2bbd709ba..ced7974622dd 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -166,27 +166,6 @@ nfs_page_group_lock(struct nfs_page *req, bool nonblock)
 }
 
 /*
- * nfs_page_group_lock_wait - wait for the lock to clear, but don't grab it
- * @req - a request in the group
- *
- * This is a blocking call to wait for the group lock to be cleared.
- */
-void
-nfs_page_group_lock_wait(struct nfs_page *req)
-{
-	struct nfs_page *head = req->wb_head;
-
-	WARN_ON_ONCE(head != head->wb_head);
-
-	if (!test_bit(PG_HEADLOCK, &head->wb_flags))
-		return;
-	set_bit(PG_CONTENDED1, &head->wb_flags);
-	smp_mb__after_atomic();
-	wait_on_bit(&head->wb_flags, PG_HEADLOCK,
-		TASK_UNINTERRUPTIBLE);
-}
-
-/*
  * nfs_page_group_unlock - unlock the head of the page group
  * @req - request in group that is to be unlocked
  */
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d67b67ae6c8b..de1d24cedaa2 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -140,7 +140,6 @@ extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern	void nfs_unlock_and_release_request(struct nfs_page *);
 extern int nfs_page_group_lock(struct nfs_page *, bool);
-extern void nfs_page_group_lock_wait(struct nfs_page *);
 extern void nfs_page_group_unlock(struct nfs_page *);
 extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned int);
 extern bool nfs_async_iocounter_wait(struct rpc_task *, struct nfs_lock_context *);
-- 
2.13.3

