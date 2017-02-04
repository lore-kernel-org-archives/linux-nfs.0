Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33343 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753539AbdBDFmc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Feb 2017 00:42:32 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so4274126iom.0
        for <linux-nfs@vger.kernel.org>; Fri, 03 Feb 2017 21:42:32 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] sunrpc/cache: skip checking the pending cache expired
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <cb2a552c-51ec-f230-0b39-0bd4002e351d@gmail.com>
Date: Sat, 4 Feb 2017 13:41:30 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the first time pynfs runs after rpc/nfsd startup, always get the warning, 

Got error: Connection closed

Commit 778620364ef5 "sunrpc/cache: make cache flushing more reliable." lets
cache_is_expired() checking expired as, 

return (h->expiry_time < seconds_since_boot()) ||
        (detail->flush_time >= h->last_refresh);

The detail->flush_time is equal to h->last_refresh time, when the cache is
new created and then do the upcall immediately. So that, the cache will be
treated as expired and be cleaned when write_flush().

This patch skips checking the pending cache expired when doing upcall.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 62a60ee..9961c1f 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -204,8 +204,11 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 	kref_put(&h->ref, cd->cache_put);
 }
 
-static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
+static inline bool cache_is_expired(struct cache_detail *detail, struct cache_head *h)
 {
+	if (test_bit(CACHE_PENDING, &h->flags))
+		return false;
+
 	return  (h->expiry_time < seconds_since_boot()) ||
 		(detail->flush_time >= h->last_refresh);
 }
-- 
2.9.3

