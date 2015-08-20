Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35732 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbbHTLRa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:30 -0400
Received: by ykbi184 with SMTP id i184so33651890ykb.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:30 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com,
        Andrew Morton <akpm@linux-foundation.org>,
        Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org
Subject: [PATCH v3 03/20] list_lru: add list_lru_rotate
Date: Thu, 20 Aug 2015 07:17:03 -0400
Message-Id: <1440069440-27454-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a function that can move an entry to the MRU end of the list.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-mm@kvack.org
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/list_lru.h | 13 +++++++++++++
 mm/list_lru.c            | 15 +++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 2a6b9947aaa3..4534b1b34d2d 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -96,6 +96,19 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item);
 bool list_lru_del(struct list_lru *lru, struct list_head *item);
 
 /**
+ * list_lru_rotate: rotate an element to the end of an lru list
+ * @list_lru: the lru pointer
+ * @item: the item to be rotated
+ *
+ * This function moves an entry to the end of an LRU list. Should be used when
+ * an entry that is on the LRU is used, and should be moved to the MRU end of
+ * the list. If the item is not on a list, then this function has no effect.
+ * The comments about an element already pertaining to a list are also valid
+ * for list_lru_rotate.
+ */
+void list_lru_rotate(struct list_lru *lru, struct list_head *item);
+
+/**
  * list_lru_count_one: return the number of objects currently held by @lru
  * @lru: the lru pointer.
  * @nid: the node id to count from.
diff --git a/mm/list_lru.c b/mm/list_lru.c
index e1da19fac1b3..66718c2a9a7b 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -130,6 +130,21 @@ bool list_lru_del(struct list_lru *lru, struct list_head *item)
 }
 EXPORT_SYMBOL_GPL(list_lru_del);
 
+void list_lru_rotate(struct list_lru *lru, struct list_head *item)
+{
+	int nid = page_to_nid(virt_to_page(item));
+	struct list_lru_node *nlru = &lru->node[nid];
+	struct list_lru_one *l;
+
+	spin_lock(&nlru->lock);
+	if (!list_empty(item)) {
+		l = list_lru_from_kmem(nlru, item);
+		list_move_tail(item, &l->list);
+	}
+	spin_unlock(&nlru->lock);
+}
+EXPORT_SYMBOL_GPL(list_lru_rotate);
+
 void list_lru_isolate(struct list_lru_one *list, struct list_head *item)
 {
 	list_del_init(item);
-- 
2.4.3

