Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50A3FC43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 08:46:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8D2C2086B
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 08:46:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8D2C2086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727729AbeK1Tqz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 14:46:55 -0500
Received: from relay.sw.ru ([185.231.240.75]:57682 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727726AbeK1Tqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 14:46:55 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gRvTp-0003rF-BU; Wed, 28 Nov 2018 11:45:57 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 1/1] sunrpc: cache_head leak due queued request
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Cc:     "David S. Miller" <davem@davemloft.net>,
        NeilBrown <neilb@suse.com>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Message-ID: <c103fa7e-419c-266a-45f3-7ee9ed8f5d10@virtuozzo.com>
Date:   Wed, 28 Nov 2018 11:45:57 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After commit d202cce8963d  expired cache_head can be removed from
hash on cache_detail.

However expired cache_head can wait for reply from previously submitted
request. Such cache_head have increased refcounter and therefore it
cannot be freed after cache_put(freeme).

Because cache_head was removed from hash it cannot be found during
cache_clean() and can be leaked forever together with stalled cache_request
and other taken resources.

Fixes d202cce8963d ("sunrpc: never return expired entries in sunrpc_cache_lookup")
Cc: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Cc: stable@kernel.org # 2.6.35
Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/cache.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 109fbe591e7b..483a5cfd60f0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -54,6 +54,11 @@ static void cache_init(struct cache_head *h, struct cache_detail *detail)
 	h->last_refresh = now;
 }
 
+static void cache_fresh_locked(struct cache_head *head, time_t expiry,
+			       struct cache_detail *detail);
+static void cache_fresh_unlocked(struct cache_head *head,
+				 struct cache_detail *detail);
+
 struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 				       struct cache_head *key, int hash)
 {
@@ -95,6 +100,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 			if (cache_is_expired(detail, tmp)) {
 				hlist_del_init(&tmp->cache_list);
 				detail->entries --;
+				cache_fresh_locked(tmp, 0, detail);
 				freeme = tmp;
 				break;
 			}
@@ -110,8 +116,10 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 	cache_get(new);
 	write_unlock(&detail->hash_lock);
 
-	if (freeme)
+	if (freeme) {
+		cache_fresh_unlocked(freeme, detail);
 		cache_put(freeme, detail);
+	}
 	return new;
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
-- 
2.17.1

