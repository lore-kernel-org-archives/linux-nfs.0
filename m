Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34754 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753850AbdBGNtY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:49:24 -0500
Received: by mail-it0-f68.google.com with SMTP id o185so12362515itb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:49:24 -0800 (PST)
Subject: [PATCH 5/7] sunrpc: update the comments of sunrpc proc path
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <c1bab8c3-a319-4df0-f332-62f44c48d0ea@gmail.com>
Date: Tue, 7 Feb 2017 21:49:17 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/cache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 688ef8c..9e8561d 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -717,7 +717,7 @@ void cache_clean_deferred(void *owner)
 /*
  * communicate with user-space
  *
- * We have a magic /proc file - /proc/sunrpc/<cachename>/channel.
+ * We have a magic /proc file - /proc/net/rpc/<cachename>/channel.
  * On read, you get a full request, or block.
  * On write, an update request is processed.
  * Poll works if anything to read, and always allows write.
@@ -1272,7 +1272,7 @@ EXPORT_SYMBOL_GPL(qword_get);
 
 
 /*
- * support /proc/sunrpc/cache/$CACHENAME/content
+ * support /proc/net/rpc/$CACHENAME/content
  * as a seqfile.
  * We call ->cache_show passing NULL for the item to
  * get a header, then pass each real item in the cache
-- 
2.9.3

