Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f196.google.com ([209.85.216.196]:36802 "EHLO
	mail-qc0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbbFFOl6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jun 2015 10:41:58 -0400
Message-ID: <557306AF.4020609@gmail.com>
Date: Sat, 06 Jun 2015 22:41:51 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 4/5 v4] sunrpc: New helper cache_force_expire for cache cleanup
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using expiry_time force cleanup a cache.

v4, same v1.

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
2.4.2

