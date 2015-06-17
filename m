Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36732 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757818AbbFQHwo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 03:52:44 -0400
Message-ID: <55812746.8010704@gmail.com>
Date: Wed, 17 Jun 2015 15:52:38 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 5/6 v5] sunrpc: New helper cache_force_expire for cache cleanup
References: <5581266C.9080404@gmail.com>
In-Reply-To: <5581266C.9080404@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using expiry_time force cleanup a cache.

v5, same v1.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 437ddb6..ce75e9c 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -210,6 +210,17 @@ extern int cache_check(struct cache_detail *detail,
 		       struct cache_head *h, struct cache_req *rqstp);
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
+
+static inline void cache_force_expire(struct cache_detail *detail, struct cache_head *h)
+{
+	write_lock(&detail->hash_lock);
+	h->expiry_time = seconds_since_boot() - 1;
+	detail->nextcheck = seconds_since_boot();
+	write_unlock(&detail->hash_lock);
+
+	cache_flush();
+}
+
 #define NEVER (0x7FFFFFFF)
 extern void __init cache_initialize(void);
 extern int cache_register_net(struct cache_detail *cd, struct net *net);
-- 
2.4.3

