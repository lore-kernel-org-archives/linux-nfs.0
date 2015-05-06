Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36578 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbEFNUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:20:47 -0400
Message-ID: <554A1529.4050100@gmail.com>
Date: Wed, 06 May 2015 21:20:41 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 3/4] sunrpc: New helper cache_force_expire for cache cleanup
References: <554A149B.5060102@gmail.com>
In-Reply-To: <554A149B.5060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using expiry_time force cleanup a cache.

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
2.4.0

