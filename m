Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36549 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbHEVNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:48 -0400
Received: by ykeo23 with SMTP id o23so46444389yke.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:48 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/18] sunrpc: add a new cache_detail operation for when a cache is flushed
Date: Wed,  5 Aug 2015 17:13:25 -0400
Message-Id: <1438809216-4846-8-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the exports table is changed, exportfs will usually write a new
time to the "flush" file in the nfsd.export cache procfile. This tells
the kernel to flush any entries that are older than that value.

This gives us a mechanism to tell whether an unexport might have
occurred. Add a new ->flush cache_detail operation that is called after
flushing the cache whenever someone writes to a "flush" file.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 include/linux/sunrpc/cache.h | 1 +
 net/sunrpc/cache.c           | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 437ddb6c4aef..29033421aa0c 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -98,6 +98,7 @@ struct cache_detail {
 					      int has_died);
 
 	struct cache_head *	(*alloc)(void);
+	void			(*flush)(void);
 	int			(*match)(struct cache_head *orig, struct cache_head *new);
 	void			(*init)(struct cache_head *orig, struct cache_head *new);
 	void			(*update)(struct cache_head *orig, struct cache_head *new);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2928afffbb81..19dc71ccc706 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1452,6 +1452,9 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
 	cd->nextcheck = seconds_since_boot();
 	cache_flush();
 
+	if (cd->flush)
+		cd->flush();
+
 	*ppos += count;
 	return count;
 }
-- 
2.4.3

