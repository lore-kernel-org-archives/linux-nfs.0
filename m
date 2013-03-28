Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f175.google.com ([209.85.128.175]:63817 "EHLO
	mail-ve0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755835Ab3C1OHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2013 10:07:22 -0400
Received: by mail-ve0-f175.google.com with SMTP id pb11so5084760veb.34
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2013 07:07:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1364479112.11160.0.camel@leira.trondhjem.org>
References: <CAK1jPnLSFxLwSbe14mMbrois6bwFzbG_Q1kudBuNyywj70s7LA@mail.gmail.com>
	<1364479112.11160.0.camel@leira.trondhjem.org>
Date: Thu, 28 Mar 2013 22:07:21 +0800
Message-ID: <CAK1jPnJYJyC-62uXzJ4er2JZ0Zws1RN+bZ63TchCAVYgW5wNeQ@mail.gmail.com>
Subject: Re: [PATCH] sunrpc: the cache_detail in cache_is_valid is unused any more
From: chaoting fan <tingchaofan@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the cache_detail(*detail) in function cache_is_valid is unused any more.

Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>

---
 net/sunrpc/cache.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..adbbc19 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -201,7 +201,7 @@ static int cache_make_upcall(struct cache_detail
*cd, struct cache_head *h)
 	return cd->cache_upcall(cd, h);
 }

-static inline int cache_is_valid(struct cache_detail *detail, struct
cache_head *h)
+static inline int cache_is_valid(struct cache_head *h)
 {
 	if (!test_bit(CACHE_VALID, &h->flags))
 		return -EAGAIN;
@@ -227,7 +227,7 @@ static int try_to_negate_entry(struct cache_detail
*detail, struct cache_head *h
 	int rv;

 	write_lock(&detail->hash_lock);
-	rv = cache_is_valid(detail, h);
+	rv = cache_is_valid(h);
 	if (rv != -EAGAIN) {
 		write_unlock(&detail->hash_lock);
 		return rv;
@@ -260,7 +260,7 @@ int cache_check(struct cache_detail *detail,
 	long refresh_age, age;

 	/* First decide return status as best we can */
-	rv = cache_is_valid(detail, h);
+	rv = cache_is_valid(h);

 	/* now see if we want to start an upcall */
 	refresh_age = (h->expiry_time - h->last_refresh);
@@ -293,7 +293,7 @@ int cache_check(struct cache_detail *detail,
 			 * Request was not deferred; handle it as best
 			 * we can ourselves:
 			 */
-			rv = cache_is_valid(detail, h);
+			rv = cache_is_valid(h);
 			if (rv == -EAGAIN)
 				rv = -ETIMEDOUT;
 		}
-- 
1.7.10.4
