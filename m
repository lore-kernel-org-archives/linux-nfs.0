Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:50553 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757220AbbAHSen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 13:34:43 -0500
Received: by mail-qg0-f45.google.com with SMTP id z107so3865316qgd.4
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 10:34:43 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        hch@infradead.org
Subject: [PATCH v2 01/10] locks: add new struct list_head to struct file_lock
Date: Thu,  8 Jan 2015 10:34:16 -0800
Message-Id: <1420742065-28423-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...that we can use to queue file_locks to per-ctx list_heads. Go ahead
and convert locks_delete_lock and locks_dispose_list to use it instead
of the fl_block list.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c         | 8 +++++---
 include/linux/fs.h | 1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 735b8d3fa78c..fba8bc7af6d3 100644
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
index f90c0282c114..9eee7200cfe3 100644
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

