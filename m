Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:59833 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab3LELBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 06:01:03 -0500
Received: by mail-qc0-f176.google.com with SMTP id i8so4562627qcq.21
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 03:01:02 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH RFC 2/3] list_lru: add a new LRU_SKIP_REST lru_status value and handling
Date: Thu,  5 Dec 2013 06:00:52 -0500
Message-Id: <1386241253-5781-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current list_lru_walk_node implementation always walks the entire
list. In some cases, we can be sure that when an entry isn't freeable
that none of the rest of the entries on the list will be either.

Create a new LRU_SKIP_REST return value that not only indicates that
the current entry was skipped, but that caller should stop scanning
the current node.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/list_lru.h | 2 ++
 mm/list_lru.c            | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 3ce5417..6140c3a 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -15,6 +15,8 @@ enum lru_status {
 	LRU_REMOVED,		/* item removed from list */
 	LRU_ROTATE,		/* item referenced, give another pass */
 	LRU_SKIP,		/* item cannot be locked, skip */
+	LRU_SKIP_REST,		/* item isn't freeable, and none of the rest
+				   on the list will be either */
 	LRU_RETRY,		/* item not freeable. May drop the lock
 				   internally, but has to return locked. */
 };
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 72f9dec..abec7fb 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -98,6 +98,8 @@ restart:
 			break;
 		case LRU_SKIP:
 			break;
+		case LRU_SKIP_REST:
+			goto done;
 		case LRU_RETRY:
 			/*
 			 * The lru lock has been dropped, our list traversal is
@@ -108,7 +110,7 @@ restart:
 			BUG();
 		}
 	}
-
+done:
 	spin_unlock(&nlru->lock);
 	return isolated;
 }
-- 
1.8.4.2

