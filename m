Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f195.google.com ([209.85.220.195]:45724 "EHLO
	mail-vc0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab3C1Nxx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2013 09:53:53 -0400
Received: by mail-vc0-f195.google.com with SMTP id gd11so2463647vcb.10
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2013 06:53:52 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 28 Mar 2013 21:53:52 +0800
Message-ID: <CAK1jPnLSFxLwSbe14mMbrois6bwFzbG_Q1kudBuNyywj70s7LA@mail.gmail.com>
Subject: [PATCH] sunrpc: the cache_detail in cache_is_valid is unused any more
From: chaoting fan <tingchaofan@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the cache_detail(*detail) in function cache_is_valid is unused any more,
mark it to be unused to avoid make warning.

Signed-off-by: fanchaoting <fanchaoting@cn.fujitsu.com>

---
 net/sunrpc/cache.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..efea2d9 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -201,7 +201,7 @@ static int cache_make_upcall(struct cache_detail
*cd, struct cache_head *h)
 	return cd->cache_upcall(cd, h);
 }

-static inline int cache_is_valid(struct cache_detail *detail, struct
cache_head *h)
+static inline int cache_is_valid(struct cache_detail *unused, struct
cache_head *h)
 {
 	if (!test_bit(CACHE_VALID, &h->flags))
 		return -EAGAIN;
-- 1.7.10.4
