Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403Ab0ITDhn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Sep 2010 23:37:43 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1OxXB0-0004t5-0Q
	for linux-nfs@vger.kernel.org; Sun, 19 Sep 2010 23:36:22 -0400
Date: Sun, 19 Sep 2010 23:36:21 -0400
To: linux-nfs@vger.kernel.org
Subject: hang on server boot
Message-ID: <20100920033621.GB18325@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trying to do some reboot testing, I hit this bug.  I'm planning to queue
up this fix for 2.6.37 absent any objections.

(Arguably it could go to 2.6.36, but we're getting closer to the next
release, the consequences of this bug aren't too horrible, and it's not
a new regression.)

--b.

commit fae1561d4f5ccd315741cf4cb9ca2fb7c3fbe377
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Sep 19 22:55:06 2010 -0400

    nfsd4: fix hang on fast-booting nfs servers
    
    The last_close field of a cache_detail is initialized to zero, so the
    condition
    
    	detail->last_close < seconds_since_boot() - 30
    
    may be false even for a cache that was never opened.
    
    However, we want to immediately fail upcalls to caches that were never
    opened: in the case of the auth_unix_gid cache, especially, which may
    never be opened by mountd (if the --manage-gids option is not set), we
    want to fail the upcall immediately.  Otherwise client requests will be
    dropped unnecessarily on reboot.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index da872f9..ca7c621 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1091,6 +1091,23 @@ static void warn_no_listener(struct cache_detail *detail)
 	}
 }
 
+static bool cache_listeners_exist(struct cache_detail *detail)
+{
+	if (atomic_read(&detail->readers))
+		return true;
+	if (detail->last_close == 0)
+		/* This cache was never opened */
+		return false;
+	if (detail->last_close < seconds_since_boot() - 30)
+		/*
+		 * We allow for the possibility that someone might
+		 * restart a userspace daemon without restarting the
+		 * server; but after 30 seconds, we give up.
+		 */
+		 return false;
+	return true;
+}
+
 /*
  * register an upcall request to user-space and queue it up for read() by the
  * upcall daemon.
@@ -1109,10 +1126,9 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 	char *bp;
 	int len;
 
-	if (atomic_read(&detail->readers) == 0 &&
-	    detail->last_close < seconds_since_boot() - 30) {
-			warn_no_listener(detail);
-			return -EINVAL;
+	if (!cache_listeners_exist(detail)) {
+		warn_no_listener(detail);
+		return -EINVAL;
 	}
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
