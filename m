Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35651 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbbJELC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 07:02:58 -0400
Received: by qgt47 with SMTP id 47so145706655qgt.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 04:02:57 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v5 09/20] sunrpc: add a new cache_detail operation for when a cache is flushed
Date: Mon,  5 Oct 2015 07:02:31 -0400
Message-Id: <1444042962-6947-10-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
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
index 03d3b4c92d9f..d1c10a978bb2 100644
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
index 4a2340a54401..60da9aa2bdc5 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1451,6 +1451,9 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
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

