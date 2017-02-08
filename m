Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34142 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbdBHByt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 20:54:49 -0500
Received: by mail-io0-f194.google.com with SMTP id c80so14604240iod.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 17:54:49 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/2 v3] SUNRPC/Cache: Always treat the invalid cache as
 unexpired
Message-ID: <aed565ba-9eaf-23e4-6746-87b652a04685@gmail.com>
Date: Wed, 8 Feb 2017 09:54:42 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the first time pynfs runs after rpc/nfsd startup, always get the warning,

"Got error: Connection closed"

I found the problem is caused by,
1. A new startup of nfsd, rpc.mountd, etc,
2. A rpc request from client (pynfs test, or normal mounting),
3. An ip_map cache is created but invalid, so upcall to rpc.mountd,
4. rpc.mountd process the ip_map upcall, before write the valid data to nfsd,
   do auth_reload(), and check_useipaddr(),
5. For the first time, old_use_ipaddr = -1, it causes rpc.mountd do write_flush    that doing cache_clean,
6. The ip_map cache will be treat as expired and clean,
7. When rpc.mountd write the valid data to nfsd, a new ip_map is created
   and updated, the cache_check of old ip_map(doing the upcall) will
   return -ETIMEDOUT.
8. RPC layer return SVC_CLOSE and close the xprt after commit 4d712ef1db05
   "svcauth_gss: Close connection when dropping an incoming message"

NeilBrown suggest in another email,

"If CACHE_VALID is not set, then there is no data in the cache item,
 so there is nothing to expire. So it would be nice if cache items that
 don't have CACHE_VALID are never treated as expired."

v3, change the order of the two patches
v2, change the checking of CACHE_PENDING to CACHE_VALID

Reviewed-by: NeilBrown <neilb@suse.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 62a60ee..782024e 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -204,8 +204,11 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 	kref_put(&h->ref, cd->cache_put);
 }
 
-static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
+static inline bool cache_is_expired(struct cache_detail *detail, struct cache_head *h)
 {
+	if (!test_bit(CACHE_VALID, &h->flags))
+		return false;
+
 	return  (h->expiry_time < seconds_since_boot()) ||
 		(detail->flush_time >= h->last_refresh);
 }
-- 
2.9.3


