Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757652Ab2BHVTY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:19:24 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 15/17] FS-Cache: Limit the number of I/O error reports for a
 cache
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:19:15 +0000
Message-ID: <20120208211915.15607.60413.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Limit the number of I/O error reports for a cache to 1 to prevent massive
amounts of noise.  After the first I/O error the cache is taken off line
automatically, so must be restarted to resume caching.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/fscache/cache.c b/fs/fscache/cache.c
index 6a3c48a..b52aed1 100644
--- a/fs/fscache/cache.c
+++ b/fs/fscache/cache.c
@@ -314,10 +314,10 @@ EXPORT_SYMBOL(fscache_add_cache);
  */
 void fscache_io_error(struct fscache_cache *cache)
 {
-	set_bit(FSCACHE_IOERROR, &cache->flags);
-
-	printk(KERN_ERR "FS-Cache: Cache %s stopped due to I/O error\n",
-	       cache->ops->name);
+	if (!test_and_set_bit(FSCACHE_IOERROR, &cache->flags))
+		printk(KERN_ERR "FS-Cache:"
+		       " Cache '%s' stopped due to I/O error\n",
+		       cache->ops->name);
 }
 EXPORT_SYMBOL(fscache_io_error);
 

