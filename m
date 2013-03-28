Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:35998 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274Ab3C1OTq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2013 10:19:46 -0400
Received: by mail-vc0-f182.google.com with SMTP id ht11so7744544vcb.27
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2013 07:19:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1364479112.11160.0.camel@leira.trondhjem.org>
References: <CAK1jPnLSFxLwSbe14mMbrois6bwFzbG_Q1kudBuNyywj70s7LA@mail.gmail.com>
	<1364479112.11160.0.camel@leira.trondhjem.org>
Date: Thu, 28 Mar 2013 22:19:45 +0800
Message-ID: <CAK1jPnK_WHHH3cgnocQKgMDzcQOEn4Edc-MyaV8OwWLpBMQz3g@mail.gmail.com>
Subject: Re: [PATCH] sunrpc: the cache_detail in cache_is_valid is unused any more
From: chaoting fan <tingchaofan@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Why not just remove it altogether? There are only 3 callers.

thanks ,here is the change patch.

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
