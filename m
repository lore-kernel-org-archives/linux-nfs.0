Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36202 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbbFBB0o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 21:26:44 -0400
Message-ID: <556D064D.2020802@gmail.com>
Date: Tue, 02 Jun 2015 09:26:37 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.de>, kinglongmee@gmail.com
Subject: [PATCH 4/5 v3] sunrpc: New helper cache_force_expire for cache cleanup
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using expiry_time force cleanup a cache.

v3: same as v1.

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

