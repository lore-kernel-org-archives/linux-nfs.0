From: Greg Banks <gnb@sgi.com>
Subject: [patch 04/14] sunrpc: Minor indentation cleanup in cache.c
Date: Thu, 08 Jan 2009 19:25:14 +1100
Message-ID: <20090108082603.233757000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50387 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751695AbZAHI0W (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:22 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -1045,8 +1045,8 @@ static int cache_make_upcall(struct cach
 
 	if (atomic_read(&cd->readers) == 0 &&
 	    cd->last_close < get_seconds() - 30) {
-			warn_no_listener(cd);
-			return -EINVAL;
+		warn_no_listener(cd);
+		return -EINVAL;
 	}
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
