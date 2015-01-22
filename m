Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.230]:25231 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752008AbbAVObb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:31:31 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 01/13] locks: add new struct list_head to struct file_lock
Date: Thu, 22 Jan 2015 09:27:45 -0500
Message-Id: <1421936877-27529-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

...that we can use to queue file_locks to per-ctx list_heads. Go ahead
and convert locks_delete_lock and locks_dispose_list to use it instead
of the fl_block list.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Acked-by: Christoph Hellwig <hch@lst.de>
---
 fs/locks.c         | 8 +++++---
 include/linux/fs.h | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 59e2f905e4ff..bfe5f17401de 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -207,6 +207,7 @@ static struct kmem_cache *filelock_cache __read_mostly;
 static void locks_init_lock_heads(struct file_lock *fl)
 {
 	INIT_HLIST_NODE(&fl->fl_link);
+	INIT_LIST_HEAD(&fl->fl_list);
 	INIT_LIST_HEAD(&fl->fl_block);
 	init_waitqueue_head(&fl->fl_wait);
 }
@@ -243,6 +244,7 @@ EXPORT_SYMBOL_GPL(locks_release_private);
 void locks_free_lock(struct file_lock *fl)
 {
 	BUG_ON(waitqueue_active(&fl->fl_wait));
+	BUG_ON(!list_empty(&fl->fl_list));
 	BUG_ON(!list_empty(&fl->fl_block));
 	BUG_ON(!hlist_unhashed(&fl->fl_link));
 
@@ -257,8 +259,8 @@ locks_dispose_list(struct list_head *dispose)
 	struct file_lock *fl;
 
 	while (!list_empty(dispose)) {
-		fl = list_first_entry(dispose, struct file_lock, fl_block);
-		list_del_init(&fl->fl_block);
+		fl = list_first_entry(dispose, struct file_lock, fl_list);
+		list_del_init(&fl->fl_list);
 		locks_free_lock(fl);
 	}
 }
@@ -691,7 +693,7 @@ static void locks_delete_lock(struct file_lock **thisfl_p,
 
 	locks_unlink_lock(thisfl_p);
 	if (dispose)
-		list_add(&fl->fl_block, dispose);
+		list_add(&fl->fl_list, dispose);
 	else
 		locks_free_lock(fl);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 42efe13077b6..cd6818115162 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -934,6 +934,7 @@ int locks_in_grace(struct net *);
  */
 struct file_lock {
 	struct file_lock *fl_next;	/* singly linked list for this inode  */
+	struct list_head fl_list;	/* link into file_lock_context */
 	struct hlist_node fl_link;	/* node in global lists */
 	struct list_head fl_block;	/* circular list of blocked processes */
 	fl_owner_t fl_owner;
-- 
2.1.0

