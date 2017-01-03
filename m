Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35514 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965396AbdACSXB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2017 13:23:01 -0500
Received: by mail-pf0-f194.google.com with SMTP id i88so25922398pfk.2
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jan 2017 10:23:01 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 2/2] mm: un-export wake_up_page functions
Date: Wed,  4 Jan 2017 04:22:34 +1000
Message-Id: <20170103182234.30141-3-npiggin@gmail.com>
In-Reply-To: <20170103182234.30141-1-npiggin@gmail.com>
References: <20170103182234.30141-1-npiggin@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are no longer used outside mm/filemap.c, so un-export them and
make them static where possible. These were exported specifically for
NFS use in commit a4796e37c12e ("MM: export page_wakeup functions").

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/linux/pagemap.h | 12 ++----------
 mm/filemap.c            | 10 ++++++++--
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 324c8dbad1e1..b572f5530392 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -482,19 +482,11 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 }
 
 /*
- * This is exported only for wait_on_page_locked/wait_on_page_writeback,
- * and for filesystems which need to wait on PG_private.
+ * This is exported only for wait_on_page_locked/wait_on_page_writeback, etc.,
+ * and should not be used directly.
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
-extern void wake_up_page_bit(struct page *page, int bit_nr);
-
-static inline void wake_up_page(struct page *page, int bit)
-{
-	if (!PageWaiters(page))
-		return;
-	wake_up_page_bit(page, bit);
-}
 
 /* 
  * Wait for a page to be unlocked.
diff --git a/mm/filemap.c b/mm/filemap.c
index d0e4d1002059..52115b967688 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -788,7 +788,7 @@ static int wake_page_function(wait_queue_t *wait, unsigned mode, int sync, void
 	return autoremove_wake_function(wait, mode, sync, key);
 }
 
-void wake_up_page_bit(struct page *page, int bit_nr)
+static void wake_up_page_bit(struct page *page, int bit_nr)
 {
 	wait_queue_head_t *q = page_waitqueue(page);
 	struct wait_page_key key;
@@ -821,7 +821,13 @@ void wake_up_page_bit(struct page *page, int bit_nr)
 	}
 	spin_unlock_irqrestore(&q->lock, flags);
 }
-EXPORT_SYMBOL(wake_up_page_bit);
+
+static void wake_up_page(struct page *page, int bit)
+{
+	if (!PageWaiters(page))
+		return;
+	wake_up_page_bit(page, bit);
+}
 
 static inline int wait_on_page_bit_common(wait_queue_head_t *q,
 		struct page *page, int bit_nr, int state, bool lock)
-- 
2.11.0

